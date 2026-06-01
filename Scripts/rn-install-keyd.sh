#!/bin/bash

# ==========================================
# Keyd Configuration Installer
# Installs keyd config from dotfiles to /etc/keyd/default.conf
# ==========================================

set -e
set -o pipefail

DOTFILES_DIR="${1:-$HOME/Documents/Dotfiles}"
KEYD_SOURCE="$DOTFILES_DIR/keyd/default.conf"
KEYD_DEST="/etc/keyd/default.conf"

# ==========================================
# UI Helpers
# ==========================================

show_header() {
    clear
    gum style \
        --foreground 212 \
        "   __ __    ___     ___ ____  " \
        "  / // /   /   |   /   / ___/ " \
        " / // /   / /| |  / /_ \__ \  " \
        "/__  /   / ___ | / __/___/ /  " \
        "  /_/   /_/  |_|/_/  /____/   " \
        "                              "
    echo ""
    gum style --foreground 237 "═════════════════════════════════════════════════"
    echo ""
}

usage() {
    echo "Usage: $0 [dotfiles-path]"
    echo ""
    echo "Installs keyd configuration from dotfiles to /etc/keyd/default.conf"
    echo ""
    echo "Arguments:"
    echo "  dotfiles-path  Path to dotfiles directory (default: ~/Documents/Dotfiles)"
    echo ""
    echo "Examples:"
    echo "  $0                        # Uses ~/Documents/Dotfiles"
    echo "  $0 ~/my-dotfiles          # Uses specified path"
    exit 0
}

# ==========================================
# Main Logic
# ==========================================

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

show_header

# Check for sudo privileges
if ! sudo -v &> /dev/null; then
    gum log --level error "This script requires sudo privileges."
    exit 1
fi

# Check if dotfiles directory exists
if [[ ! -d "$DOTFILES_DIR" ]]; then
    gum log --level error "Dotfiles directory not found: $DOTFILES_DIR"
    exit 1
fi

# Check if keyd config exists in dotfiles
if [[ ! -f "$KEYD_SOURCE" ]]; then
    gum log --level error "Keyd config not found: $KEYD_SOURCE"
    gum log --level info "Expected structure: $DOTFILES_DIR/keyd/default.conf"
    exit 1
fi

gum log --level info "Source: $KEYD_SOURCE"
gum log --level info "Target: $KEYD_DEST"
echo ""

# Create /etc/keyd directory if it doesn't exist
if [[ ! -d "/etc/keyd" ]]; then
    gum spin --spinner line --title "Creating /etc/keyd directory..." -- \
        sudo mkdir -p /etc/keyd
    gum log --level info "✓ Created /etc/keyd directory"
fi

# Backup existing config if present
if [[ -f "$KEYD_DEST" ]]; then
    BACKUP_NAME="default.conf.backup.$(date +%s)"
    gum log --level warn "Existing config found at $KEYD_DEST"
    sudo mv "$KEYD_DEST" "/etc/keyd/$BACKUP_NAME"
    gum log --level info "  ↳ Backed up to /etc/keyd/$BACKUP_NAME"
fi

# Copy config with sudo
gum spin --spinner line --title "Installing keyd configuration..." -- \
    sudo cp "$KEYD_SOURCE" "$KEYD_DEST"

# Set ownership and permissions
sudo chown root:root "$KEYD_DEST"
sudo chmod 644 "$KEYD_DEST"

gum log --level info "✓ Installed keyd configuration"
gum log --level info "  Owner: root:root"
gum log --level info "  Permissions: 644"
echo ""

# Ask to restart keyd service
if gum confirm "Restart keyd service to apply changes?"; then
    if sudo systemctl restart keyd; then
        gum log --level info "✓ Keyd service restarted"
    else
        gum log --level error "✗ Failed to restart keyd service"
        exit 1
    fi
fi

echo ""
gum style --foreground 82 "Keyd configuration installed successfully!"
