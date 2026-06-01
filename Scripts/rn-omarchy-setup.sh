#!/bin/bash

# ==========================================
# Omarchy System Setup Wizard
# The Orchestrator for all configuration scripts
# ==========================================

set -o pipefail

# Configuration
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
CLEANER_URL="https://raw.githubusercontent.com/maxart/omarchy-cleaner/main/omarchy-cleaner.sh"
AUTO_MODE=false
NO_REBOOT=false

bootstrap_gum() {
    if command -v gum &> /dev/null; then
        return 0
    fi

    echo "gum is not installed. Installing it with pacman..."
    if ! command -v pacman &> /dev/null; then
        echo "Error: pacman is required to bootstrap gum."
        exit 1
    fi

    sudo pacman -S --needed --noconfirm gum
}

usage() {
    echo "Usage: $0 [--all] [--no-reboot]"
    echo ""
    echo "  --all        Run all steps non-interactively"
    echo "  --no-reboot  Skip reboot prompt at the end"
    echo "  -h, --help   Show this help"
    exit 0
}

# ==========================================
# UI Functions
# ==========================================

show_header() {
    clear
    gum style \
        --foreground 212 \
        "   ___                            __         " \
        "  / _ \___ ___  ___ ___________/ /  __ __" \
        " / // / _ / _ \/ _ / __/ __/ _  / // /" \
        "/____/_//_/_//_/\_,_/_/  \__/_//_/\_, / " \
        "                                 /___/  " \
        "   SYSTEM CONFIGURATION WIZARD          "

    echo ""
    gum style --foreground 237 "═════════════════════════════════════════════════"
    echo ""
}

run_script() {
    local title="$1"
    local script_name="$2"
    shift 2
    local args=("$@")

    echo ""
    gum style --foreground 212 --bold "👉 Step: $title"

    if [[ ! -f "$SCRIPT_DIR/$script_name" ]]; then
        gum style --foreground 196 "   Error: '$script_name' not found in $SCRIPT_DIR"
        exit 1
    fi

    if [[ ! -x "$SCRIPT_DIR/$script_name" ]]; then
        chmod +x "$SCRIPT_DIR/$script_name"
    fi

    if "$SCRIPT_DIR/$script_name" "${args[@]}"; then
        gum style --foreground 82 "   ✓ $title complete."
        return 0
    else
        gum style --foreground 196 "   ✗ $title failed."
        exit 1
    fi
}

run_cleaner() {
    echo ""
    gum style --foreground 212 --bold "👉 Step: Omarchy Cleaner"

    if [[ "$AUTO_MODE" == "true" ]]; then
        if curl -fsSL "$CLEANER_URL" | bash; then
            gum style --foreground 82 "   ✓ System cleaning complete."
        else
            gum style --foreground 196 "   ✗ Cleaner script failed."
            return 1
        fi
        return
    fi

    if gum confirm "Download and run the Cleaner script?"; then
        if curl -fsSL "$CLEANER_URL" | bash; then
            gum style --foreground 82 "   ✓ System cleaning complete."
        else
            gum style --foreground 196 "   ✗ Cleaner script failed or was cancelled."
            return 1
        fi
    else
        gum style --foreground 240 "   Skipped Cleaner."
    fi
}

# ==========================================
# Main Logic
# ==========================================

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --all) AUTO_MODE=true ;;
        --no-reboot) NO_REBOOT=true ;;
        -h|--help) usage ;;
        *) echo "Unknown: $1"; usage ;;
    esac
    shift
done

bootstrap_gum

show_header

# --- Step selection ---
if [[ "$AUTO_MODE" == "true" ]]; then
    gum log --level info "Auto mode: running all steps..."
    SELECTED_STEPS="1. Install dependencies
2. Configure rust
3. Install packages
4. Install dotfiles
5. Install keyboard config
6. Configure zsh
7. Configure power management"
    gum log --level warn "Auto mode skips SSH/Git user configuration because it requires personal input."
    gum log --level warn "Auto mode skips Omarchy Cleaner because the external script is interactive."
else
    declare -a STEPS=(
        "1. Install dependencies"
        "2. Configure rust"
        "3. Install packages"
        "4. Install dotfiles"
        "5. Install keyboard config"
        "6. Configure zsh"
        "7. Configure power management"
        "8. Configure git"
        "9. Run cleaner script"
    )

    gum style --foreground 212 --italic "Select steps to execute (Space to toggle, Enter to confirm)"
    SELECTED_STEPS=$(gum choose --no-limit --selected="$(IFS=,; echo "${STEPS[*]}")" "${STEPS[@]}")

    if [[ -z "$SELECTED_STEPS" ]]; then
        gum style --foreground 196 "No steps selected. Exiting."
        exit 0
    fi
fi

# --- Execution ---
if [[ "$SELECTED_STEPS" == *"1. Install dependencies"* ]]; then
    run_script "System dependencies" "rn-install-packages.sh" "--section" "Depend" "--all"
fi

if [[ "$SELECTED_STEPS" == *"2. Configure rust"* ]]; then
    run_script "Rust configuration" "rn-install-rust.sh"
fi

if [[ "$SELECTED_STEPS" == *"3. Install packages"* ]]; then
    run_script "Package installation" "rn-install-packages.sh" "--exclude" "Depend" "--all"
fi

if [[ "$SELECTED_STEPS" == *"4. Install dotfiles"* ]]; then
    run_script "Dotfiles installation" "rn-install-dotfiles.sh" "--auto"
fi

if [[ "$SELECTED_STEPS" == *"5. Install keyboard config"* ]]; then
    run_script "Keyboard configuration" "rn-install-keyd.sh" "--auto" "$HOME/Documents/Dotfiles"
fi

if [[ "$SELECTED_STEPS" == *"6. Configure zsh"* ]]; then
    run_script "Zsh configuration" "rn-configure-zsh.sh"
fi

if [[ "$SELECTED_STEPS" == *"7. Configure power management"* ]]; then
    run_script "TLP power management" "rn-configure-tlp.sh"
fi

if [[ "$SELECTED_STEPS" == *"8. Configure git"* ]]; then
    run_script "SSH key generation" "rn-generate-ssh-key.sh"
    run_script "Git configuration" "rn-configure-git.sh"
fi

if [[ "$SELECTED_STEPS" == *"9. Run cleaner script"* ]]; then
    run_cleaner || exit 1
fi

# ==========================================
# Final Summary
# ==========================================

echo ""
gum style \
    --border double \
    --border-foreground 82 \
    --padding "1 2" \
    --margin "1" \
    --align center \
    "SETUP COMPLETE" \
    "" \
    "The system configuration sequence has finished." \
    "It is highly recommended to reboot your system now."

if [[ "$NO_REBOOT" == "true" ]]; then
    gum style --foreground 240 "Reboot skipped (--no-reboot)."
    exit 0
fi

echo ""
if gum confirm "Reboot system now?"; then
    sudo reboot
else
    gum style --foreground 240 "Reboot skipped. Exiting."
fi
