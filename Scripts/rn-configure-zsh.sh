#!/bin/bash

# ==========================================
# Omarchy Zsh Configuration
# ==========================================

# Visual Header
clear
gum style --foreground 212 --bold "🐚 Zsh Configuration"

# 1. Sudo Check
if ! sudo -n true 2>/dev/null; then
    gum style --foreground 214 "🔐 Sudo privileges required to configure global environments."
    if ! sudo true; then
        gum log --level error "Failed to obtain sudo."
        exit 1
    fi
fi

# 2. Detect Distribution & Install
detect_distribution() {
    if grep -q 'ID=ubuntu' /etc/os-release || grep -q 'ID=debian' /etc/os-release; then
        echo "ubuntu"
    elif grep -q 'ID=arch' /etc/os-release; then
        echo "arch"
    else
        echo "unknown"
    fi
}

DISTRO=$(detect_distribution)

# Check if Zsh is installed
if ! command -v zsh &> /dev/null; then
    gum style --foreground 212 "Installing Zsh for $DISTRO..."
    
    case "$DISTRO" in
        ubuntu)
            gum spin --spinner dot --title "Apt update..." -- sudo apt update
            gum spin --spinner dot --title "Installing zsh..." -- sudo apt install -y zsh
            ;;
        arch)
            gum spin --spinner dot --title "Pacman install..." -- sudo pacman -Syu --noconfirm zsh
            ;;
        *)
            gum log --level error "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
    gum log --level info "✓ Zsh installed."
else
    gum log --level info "✓ Zsh is already installed."
fi

# 3. Set Default Shell
CURRENT_SHELL=$(basename "$SHELL")
if [[ "$CURRENT_SHELL" != "zsh" ]]; then
    echo ""
    gum style --foreground 212 "Changing default shell to Zsh..."
    gum style --foreground 240 --italic "(You may be asked for your password)"
    
    TARGET_ZSH=$(which zsh)
    if chsh -s "$TARGET_ZSH"; then
        gum log --level info "✓ Default shell changed to $TARGET_ZSH"
    else
        gum log --level warn "⚠ Failed to change shell automatically. You may need to do this manually."
    fi
else
    gum log --level info "✓ Zsh is already the default shell."
fi

# 4. Configure /etc/zsh/zshenv
echo ""
gum style --foreground 212 "Configuring Environment Variables (/etc/zsh/zshenv)..."

declare -A LINES=(
    ["ZDOTDIR"]="$HOME/.config/zsh"
    ["XDG_CACHE_HOME"]="$HOME/.cache"
    ["XDG_CONFIG_HOME"]="$HOME/.config"
    ["XDG_DATA_HOME"]="$HOME/.local/share"
    ["XDG_RUNTIME_DIR"]="/run/user/$UID"
    ["XDG_CONFIG_DIRS"]="/etc/xdg"
)

# Ensure directory exists
if [ ! -d "/etc/zsh" ]; then
    sudo mkdir -p /etc/zsh
fi

# Write variables
for VAR in "${!LINES[@]}"; do
    LINE="${VAR}=${LINES[$VAR]}"
    if ! grep -qxF "$LINE" /etc/zsh/zshenv 2>/dev/null; then
        echo "$LINE" | sudo tee -a /etc/zsh/zshenv > /dev/null
        gum log --level info "  + Added $VAR"
    else
        gum log --level info "  • $VAR already exists"
    fi
done

# Final Success Message
echo ""
gum style --foreground 82 "✓ Zsh configuration complete."
gum style --foreground 240 --italic "Changes will take full effect after a reboot."

# CRITICAL CHANGE: 
# The original script ran 'zsh' here, which traps the automation.
# We do NOT run zsh here. We exit so the Wizard can continue.
