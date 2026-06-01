#!/bin/bash

# ==========================================
# Omarchy System Setup Wizard
# The Orchestrator for all configuration scripts
# ==========================================

# Configuration
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
CLEANER_URL="https://raw.githubusercontent.com/maxart/omarchy-cleaner/main/omarchy-cleaner.sh"

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

# Wrapper to run a local script visually
run_script() {
    local title="$1"
    local script_name="$2"
    shift 2
    local args=("$@")

    echo ""
    gum style --foreground 212 --bold "👉 Step: $title"

    # Check if script exists
    if [[ ! -x "$SCRIPT_DIR/$script_name" ]]; then
        if [[ -f "$SCRIPT_DIR/$script_name" ]]; then
            chmod +x "$SCRIPT_DIR/$script_name"
        else
            gum style --foreground 196 "   Error: '$script_name' not found in $SCRIPT_DIR"
            return 1
        fi
    fi

    if "$SCRIPT_DIR/$script_name" "${args[@]}"; then
        gum style --foreground 82 "   ✓ $title complete."
        return 0
    else
        gum style --foreground 196 "   ✗ $title failed."
        return 1
    fi
}

# Special wrapper for the remote cleaner
run_cleaner() {
    echo ""
    gum style --foreground 212 --bold "👉 Step: Omarchy Cleaner"
    
    if gum confirm "Download and run the Cleaner script?"; then
        # We pipe directly to bash. Since the cleaner uses gum too, 
        # it will take over the TUI seamlessly.
        if curl -fsSL "$CLEANER_URL" | bash; then
            gum style --foreground 82 "   ✓ System cleaning complete."
        else
            gum style --foreground 196 "   ✗ Cleaner script failed or was cancelled."
        fi
    else
        gum style --foreground 240 "   Skipped Cleaner."
    fi
}

# ==========================================
# Main Logic
# ==========================================

# Dependency Check
if ! command -v gum &> /dev/null; then
    echo "Error: gum is not installed. Please install it manually first."
    exit 1
fi

show_header

# 1. Define the Menu Options
declare -a STEPS=(
    "1. Install dependencies"
    "2. Configure rust"
    "3. Install packages"
    "4. Install dotfiles"
    "5. Configure zsh"
    "6. Configure power management"
    "7. Configure git"
    "8. Run cleaner script"
)

# 2. Wizard Selection
gum style --foreground 212 --italic "Select steps to execute (Space to toggle, Enter to confirm)"
SELECTED_STEPS=$(gum choose --no-limit --selected="$(IFS=,; echo "${STEPS[*]}")" "${STEPS[@]}")

if [[ -z "$SELECTED_STEPS" ]]; then
    gum style --foreground 196 "No steps selected. Exiting."
    exit 0
fi

# 3. Execution Loop

# --- Step 1: System Packages ---
if [[ "$SELECTED_STEPS" == *"1. Install dependencies"* ]]; then
    run_script "System dependencies" "rn-install-packages.sh" "-s" "Depend" "-a"
fi

# --- Step 2: Rust ---
if [[ "$SELECTED_STEPS" == *"2. Configure rust"* ]]; then
    run_script "Rust configuration" "rn-install-rust.sh"
fi

# --- Step 3: All Packages ---
if [[ "$SELECTED_STEPS" == *"3. Install packages"* ]]; then
    run_script "Package installation" "rn-install-packages.sh" "-e" "Depend"
fi

# --- Step 4: Dotfiles ---
if [[ "$SELECTED_STEPS" == *"4. Install dotfiles"* ]]; then
    run_script "Dotfiles installation" "rn-install-dotfiles.sh"
fi

# --- Step 5: Zsh ---
if [[ "$SELECTED_STEPS" == *"5. Configure zsh"* ]]; then
    run_script "Zsh configuration" "rn-configure-zsh.sh"
fi

# --- Step 6: TLP ---
if [[ "$SELECTED_STEPS" == *"6. Configure power management"* ]]; then
    run_script "TLP power management" "rn-configure-tlp.sh"
fi

# --- Step 7: Git ---
if [[ "$SELECTED_STEPS" == *"7. Configure git"* ]]; then
    run_script "SSH key generation" "rn-generate-ssh-key.sh"
    run_script "Git configuration" "rn-configure-git.sh"
fi

# --- Step 8: Cleaner ---
if [[ "$SELECTED_STEPS" == *"8. Run cleaner script"* ]]; then
    run_cleaner
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
    "🎉 SETUP COMPLETE" \
    "" \
    "The system configuration sequence has finished." \
    "It is highly recommended to reboot your system now."

echo ""
if gum confirm "Reboot system now?"; then
    sudo reboot
else
    gum style --foreground 240 "Reboot skipped. Exiting."
fi
