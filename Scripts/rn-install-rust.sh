#!/bin/bash

# ==========================================
# Omarchy Rust Configuration
# ==========================================

# Visual Header
clear
gum style --foreground 212 --bold "🦀 Rust Toolchain Setup"

# 0. Remove rust
if pacman -Qi rust &> /dev/null; then
    gum log --level warn "Rust package found in pacman. Uninstalling..."
    if sudo pacman -Rns --noconfirm rust; then
        gum log --level info "Rust uninstalled."
    else
        gum log --level error "Failed to uninstall rust."
        exit 1
    fi
else
    gum log --level info "Rust (pacman package) not found. Skipping."
fi

# 1. Ensure rustup is installed
if ! command -v rustup &> /dev/null; then
    gum log --level warn "Rustup not found. Installing via pacman..."
    
    if sudo pacman -S --needed --noconfirm rustup; then
        gum log --level info "Rustup installed."
    else
        gum log --level error "Failed to install rustup."
        exit 1
    fi
    
    # Initialize rustup if it's a fresh install
    gum spin --spinner dot --title "Initializing rustup..." -- rustup default stable
fi

# 2. Install Nightly Toolchain
echo ""
gum style --foreground 212 "Installing Rust Nightly toolchain..."

if gum spin --spinner globe --title "Downloading nightly (this may take a moment)..." -- \
    bash -c "rustup install nightly >/dev/null 2>&1"; then
    gum log --level info "✓ Nightly toolchain installed."
else
    gum log --level error "✗ Failed to install nightly toolchain."
    exit 1
fi

# 3. Set Default
if gum spin --spinner dot --title "Setting default to nightly..." -- \
    rustup default nightly >/dev/null 2>&1; then
    gum log --level info "✓ Default set to nightly."
else
    gum log --level error "✗ Failed to set default."
    exit 1
fi

# 4. Verify
echo ""
VERSION=$(rustc --version)
gum style --foreground 82 "✓ Rust is ready: $VERSION"
