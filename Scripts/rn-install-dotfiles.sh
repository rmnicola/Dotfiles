#!/bin/bash

# ==========================================
# Omarchy Dotfiles Manager
# Clones remote repos and symlinks specific configs
# ==========================================

# Configuration
DOCUMENTS_DIR="$HOME/Documents"
CONFIG_DIR="$HOME/.config"

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
# Main Logic
# ==========================================

show_header

# 1. Check for Git
if ! command -v git &> /dev/null; then
    gum log --level error "Git is not installed."
    exit 1
fi

# 2. Get Repository (Default: rnicola/Dotfiles)
echo ""
gum style --foreground 212 "Enter the GitHub repository to clone (Format: user/repo)"
REPO_INPUT=$(gum input --placeholder "rnicola/Dotfiles")
# Use default if input is empty
REPO_STRING="${REPO_INPUT:-rnicola/Dotfiles}"

# Derive folder name from repo (e.g., 'Dotfiles')
REPO_NAME=$(basename "$REPO_STRING" .git)
TARGET_DIR="$DOCUMENTS_DIR/$REPO_NAME"

# 3. Clone or Pull
echo ""
if [ -d "$TARGET_DIR" ]; then
    gum log --level info "Directory exists at $TARGET_DIR"
    if gum confirm "Pull latest changes?"; then
        if gum spin --spinner globe --title "Pulling updates..." -- \
            bash -c "cd '$TARGET_DIR' && git pull"; then
            gum log --level info "✓ Updated successfully."
        fi
    fi
else
    gum style --foreground 212 "Cloning $REPO_STRING into Documents..."
    if gum spin --spinner globe --title "Cloning..." -- \
        git clone "https://github.com/$REPO_STRING" "$TARGET_DIR"; then
        gum log --level info "✓ Cloned successfully."
    else
        gum log --level error "✗ Failed to clone repository."
        exit 1
    fi
fi

# 4. Scan and Select Configs
cd "$TARGET_DIR" || exit 1

# Find subdirectories (excluding hidden ones like .git and special configs)
# keyd is excluded - use rn-install-keyd.sh for system-level config
mapfile -t AVAILABLE_CONFIGS < <(find . -maxdepth 1 -type d -not -path '*/.*' -not -path '.' -printf '%P\n' | grep -v '^keyd$' | sort)

if [ ${#AVAILABLE_CONFIGS[@]} -eq 0 ]; then
    gum log --level warn "No directories found in this repository."
    exit 0
fi

echo ""
gum style --foreground 212 "Select configurations to link to ~/.config/"
gum style --foreground 240 --italic "(Space to select, Enter to confirm)"

# Reverted to gum choose (matches omarchy-setup.sh behavior)
SELECTED_ITEMS=$(gum choose --no-limit --height 15 "${AVAILABLE_CONFIGS[@]}")

if [[ -z "$SELECTED_ITEMS" ]]; then
    gum log --level info "No configurations selected."
    exit 0
fi

# 5. Process Selection (Backup & Symlink)
echo ""
gum style --foreground 212 "Linking configurations..."

success_count=0
fail_count=0

# Loop through selected lines
while IFS= read -r item; do
    SOURCE_PATH="$TARGET_DIR/$item"
    DEST_PATH="$CONFIG_DIR/$item"
    
    # Visual progress
    gum style --foreground 99 "Processing: $item"

    # A. Check if destination exists
    if [ -e "$DEST_PATH" ] || [ -L "$DEST_PATH" ]; then
        BACKUP_NAME="${item}.backup.$(date +%s)"
        gum log --level warn "  Collision: ~/.config/$item already exists."
        
        # Move to backup
        if mv "$DEST_PATH" "$CONFIG_DIR/$BACKUP_NAME"; then
             gum log --level info "  ↳ Moved existing config to ~/.config/$BACKUP_NAME"
        else
             gum log --level error "  ✗ Failed to backup/remove existing directory."
             ((fail_count++))
             continue
        fi
    fi

    # B. Create Symlink
    if ln -s "$SOURCE_PATH" "$DEST_PATH"; then
        gum log --level info "  ✓ Linked: $item -> ~/.config/$item"
        ((success_count++))
    else
        gum log --level error "  ✗ Failed to create symlink."
        ((fail_count++))
    fi
    echo ""

done <<< "$SELECTED_ITEMS"

# 6. Summary
if [ $fail_count -eq 0 ]; then
    gum style --foreground 82 "Success! $success_count configurations linked."
else
    gum style --foreground 214 "Completed with issues. Success: $success_count, Failed: $fail_count"
fi
