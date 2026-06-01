#!/bin/bash

# ==========================================
# Omarchy: Switch from power-profiles-daemon to TLP
# ==========================================

set -e # Exit immediately if a command exits with a non-zero status

echo ">> Starting Power System Switch..."

# 1. Stop and Disable the Old System
echo ">> Ensuring power-profiles-daemon is stopped..."
sudo systemctl stop power-profiles-daemon.service 2>/dev/null || true
sudo systemctl disable power-profiles-daemon.service 2>/dev/null || true

# 2. Remove the Old Package
if pacman -Q power-profiles-daemon &> /dev/null; then
    echo ">> Removing power-profiles-daemon package..."
    sudo pacman -Rns --noconfirm power-profiles-daemon || true
else
    echo ">> power-profiles-daemon package not found (already removed). Skipping."
fi

# 3. Install TLP and Compatibility Layer
echo ">> Installing TLP components..."
sudo pacman -S --needed --noconfirm tlp tlp-pd

# 4. Enable New Services
echo ">> Enabling TLP services..."
sudo systemctl enable tlp.service
sudo systemctl enable --now tlp-pd.service

# 5. Create Compatibility Link for Omarchy Scripts
if [ -f /usr/bin/tlpctl ]; then
    echo ">> Updating compatibility link (powerprofilesctl -> tlpctl)..."
    sudo ln -sf /usr/bin/tlpctl /usr/local/bin/powerprofilesctl
else
    echo ">> Note: '/usr/bin/tlpctl' binary not found. Skipping symlink."
fi

# 6. Start TLP
echo ">> Starting TLP..."
sudo tlp start

# 7. Configure Passwordless Sudo for TLP
SUDOERS_FILE="/etc/sudoers.d/omarchy-tlp-nopasswd"
echo ">> Configuring passwordless sudo for TLP..."

# Write rule to temp file
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/tlp" | sudo tee "$SUDOERS_FILE.tmp" > /dev/null

# Validate syntax using SUDO (Fixes permission denied error)
if sudo visudo -cf "$SUDOERS_FILE.tmp"; then
    sudo mv "$SUDOERS_FILE.tmp" "$SUDOERS_FILE"
    sudo chmod 0440 "$SUDOERS_FILE"
    echo "   Passwordless sudo for TLP configured successfully."
else
    echo "!! Syntax check failed for sudoers file. Aborting sudo configuration."
    sudo rm "$SUDOERS_FILE.tmp"
    exit 1
fi

echo "=========================================="
echo "Success! TLP is fully configured."
echo "Your Waybar menu should now switch modes instantly."
echo "=========================================="
