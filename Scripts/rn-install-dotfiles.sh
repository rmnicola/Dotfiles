#!/bin/bash

# ==========================================
# Omarchy Dotfiles Manager
# Clones remote repos and symlinks specific configs
# ==========================================

set -e
set -o pipefail

# Configuration
DOCUMENTS_DIR="$HOME/Documents"
CONFIG_DIR="$HOME/.config"
AUTO_MODE=false
REPO_STRING="rnicola/Dotfiles"

usage() {
    echo "Usage: $0 [--auto] [--repo USER/REPO]"
    echo ""
    echo "  --auto       Non-interactive mode (use defaults, link all configs)"
    echo "  --repo REPO  GitHub repo to clone (default: rnicola/Dotfiles)"
    echo "  -h, --help   Show this help"
    exit 0
}

# ==========================================
# UI Helpers
# ==========================================

show_header() {
    clear
    gum style \
        --foreground 212 \
        "    ____        __  _____ __        " \
        "   / __ \____  / /_/ __(_) /__  ___ " \
        "  / / / / __ \/ __/ /_/ / / _ \/ __|" \
        " / /_/ / /_/ / /_/ __/ / /  __/\__ \\" \
        "/_____/\____/\__/_/ /_/_/\___/_____/" \
        "                                    "
    echo ""
    gum style --foreground 237 "═════════════════════════════════════════════════"
    echo ""
}

# ==========================================
# Core Logic
# ==========================================

link_config() {
    local item="$1"
    local SOURCE_PATH="$TARGET_DIR/$item"
    local DEST_PATH="$CONFIG_DIR/$item"

    # Skip if symlink already points to the right place
    if [[ -L "$DEST_PATH" ]] && [[ "$(readlink "$DEST_PATH")" == "$SOURCE_PATH" ]]; then
        gum log --level info "  ✓ $item already linked correctly. Skipping."
        ((success_count += 1))
        return
    fi

    # Backup existing file/dir/symlink
    if [[ -e "$DEST_PATH" ]] || [[ -L "$DEST_PATH" ]]; then
        BACKUP_NAME="${item}.backup.$(date +%s)"
        gum log --level warn "  Collision: ~/.config/$item exists."
        if mv "$DEST_PATH" "$CONFIG_DIR/$BACKUP_NAME" 2>/dev/null; then
            gum log --level info "  ↳ Backed up to ~/.config/$BACKUP_NAME"
        else
            gum log --level error "  ✗ Failed to backup $item."
            ((fail_count += 1))
            return
        fi
    fi

    # Create symlink
    if ln -s "$SOURCE_PATH" "$DEST_PATH" 2>/dev/null; then
        gum log --level info "  ✓ Linked: $item -> ~/.config/$item"
        ((success_count += 1))
    else
        gum log --level error "  ✗ Failed to create symlink for $item."
        ((fail_count += 1))
    fi
}

# ==========================================
# Main Execution
# ==========================================

# Argument parsing
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --auto) AUTO_MODE=true ;;
        --repo) REPO_STRING="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown: $1"; usage ;;
    esac
    shift
done

if [[ "$AUTO_MODE" != "true" ]]; then
    show_header
fi

# 1. Check for Git
if ! command -v git &> /dev/null; then
    gum log --level error "Git is not installed."
    exit 1
fi

# 2. Resolve repo
REPO_NAME=$(basename "$REPO_STRING" .git)
TARGET_DIR="$DOCUMENTS_DIR/$REPO_NAME"

# 3. Clone or Pull
if [ -d "$TARGET_DIR" ]; then
    if [[ "$AUTO_MODE" == "true" ]]; then
        gum log --level info "Directory exists at $TARGET_DIR. Pulling updates..."
        if ! (cd "$TARGET_DIR" && git pull); then
            gum log --level error "Failed to pull updates."
            exit 1
        fi
        gum log --level info "✓ Updated successfully."
    else
        gum log --level info "Directory exists at $TARGET_DIR"
        if gum confirm "Pull latest changes?"; then
            if gum spin --spinner globe --title "Pulling updates..." -- \
                bash -c "cd '$TARGET_DIR' && git pull"; then
                gum log --level info "✓ Updated successfully."
            fi
        fi
    fi
else
    gum style --foreground 212 "Cloning $REPO_STRING into Documents..."
    if ! git clone "https://github.com/$REPO_STRING" "$TARGET_DIR"; then
        gum log --level error "✗ Failed to clone repository."
        exit 1
    fi
    gum log --level info "✓ Cloned successfully."
fi

# 4. Scan configs
cd "$TARGET_DIR" || exit 1

mapfile -t AVAILABLE_CONFIGS < <(
    find . -maxdepth 1 -type d \
        -not -path '*/.*' \
        -not -path '.' \
        -not -name 'keyd' \
        -not -name 'Scripts' \
        -printf '%P\n' \
        | sort
)

if [[ ${#AVAILABLE_CONFIGS[@]} -eq 0 ]]; then
    gum log --level warn "No config directories found."
    exit 0
fi

# 5. Select configs (or auto-select all)
if [[ "$AUTO_MODE" == "true" ]]; then
    gum log --level info "Auto mode: linking all configurations..."
    SELECTED_ITEMS=$(printf '%s\n' "${AVAILABLE_CONFIGS[@]}")
else
    echo ""
    gum style --foreground 212 "Select configurations to link to ~/.config/"
    gum style --foreground 240 --italic "(Space to select, Enter to confirm)"

    SELECTED_ITEMS=$(gum choose --no-limit --height 15 "${AVAILABLE_CONFIGS[@]}")
fi

if [[ -z "$SELECTED_ITEMS" ]]; then
    gum log --level info "No configurations selected."
    exit 0
fi

# 6. Link selected configs
echo ""
gum style --foreground 212 "Linking configurations..."

success_count=0
fail_count=0

while IFS= read -r item; do
    gum style --foreground 99 "Processing: $item"
    link_config "$item"
    echo ""
done <<< "$SELECTED_ITEMS"

# 7. Summary
if [[ $fail_count -eq 0 ]]; then
    gum style --foreground 82 "Success! $success_count configurations linked."
else
    gum style --foreground 214 "Completed with issues. Success: $success_count, Failed: $fail_count"
fi
