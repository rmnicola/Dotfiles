#!/bin/bash

# ==========================================
# Configure Fingerprint Authentication
# Adds pam_fprintd.so to PAM and enrolls
# ==========================================

set -euo pipefail

AUTO_MODE=false
PAM_FILE="/etc/pam.d/system-auth"
FP_LINE="auth       sufficient                  pam_fprintd.so"

usage() {
    echo "Usage: $0 [--auto]"
    echo "  --auto    Skip enrollment prompt, only configure PAM"
    exit 0
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --auto) AUTO_MODE=true ;;
        -h|--help) usage ;;
        *) echo "Unknown: $1"; usage ;;
    esac
    shift
done

echo "🔍 Checking fingerprint support..."

# Check fprintd is installed
if ! command -v fprintd-list &> /dev/null; then
    echo "fprintd not found. Installing..."
    sudo pacman -S --needed --noconfirm fprintd libfprint
fi

# Check device detection
DEVICE_COUNT=$(fprintd-list 2>&1 | grep -c "found [0-9]* devices" || true)
DEVICE_DETECTED=$(fprintd-list 2>&1 | grep -c "Device at /net/reactivated/Fprint/Device/0" || true)

if [[ "$DEVICE_DETECTED" -eq 0 ]]; then
    echo "⚠ No fingerprint reader detected. Skipping configuration."
    echo "  Check with: fprintd-list $(whoami)"
    exit 1
fi

echo "✓ Fingerprint reader detected."

# ----- PAM Configuration (idempotent) -----
if grep -q "pam_fprintd.so" "$PAM_FILE" 2>/dev/null; then
    echo "✓ PAM already configured for fingerprint. Skipping."
else
    # Insert pam_fprintd.so before pam_faillock preauth
    sudo sed -i '/^auth.*pam_faillock\.so preauth/ i\'"$FP_LINE" "$PAM_FILE"
    echo "✓ pam_fprintd.so added to system-auth."
fi

# ----- Enrollment -----
CURRENT_USER=$(whoami)
HAS_FINGERPRINTS=$(fprintd-list "$CURRENT_USER" 2>&1 | grep -c "has no fingers enrolled" || true)

if [[ "$HAS_FINGERPRINTS" -eq 0 ]]; then
    echo "✓ Fingerprint(s) already enrolled for $CURRENT_USER."
    fprintd-list "$CURRENT_USER"
elif [[ "$AUTO_MODE" == "false" ]]; then
    echo ""
    echo "🖐 No fingerprints enrolled for $CURRENT_USER."
    echo ""

    if command -v gum &> /dev/null; then
        gum confirm "Enroll a fingerprint now?" && fprintd-enroll
    else
        read -r -p "Enroll a fingerprint now? [Y/n] " resp
        if [[ "$resp" =~ ^[Yy]?$ ]]; then
            fprintd-enroll
        fi
    fi
else
    echo " Auto mode: skipping enrollment."
    echo "  Enroll later with: fprintd-enroll"
fi

echo ""
echo "✓ Fingerprint setup complete."
echo "  Covers: sudo, login (SDDM), lock screen (hyprlock)"
