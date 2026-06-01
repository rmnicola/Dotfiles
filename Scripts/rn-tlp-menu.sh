#!/bin/bash

# Ensure we have access to Omarchy binaries/path if needed
export PATH="$HOME/.local/share/omarchy/bin:$PATH"

# 1. Define the Menu Function
menu() {
  local options="$1"
  # We use the same walker styling as before
  echo -e "$options" | omarchy-launch-walker --dmenu --width 295 --minheight 1 --maxheight 630 -p "Power Profile…" 2>/dev/null
}

# 2. Define Options
options="  Performance\n  Balanced\n  Power Saver"

# 3. Show Menu & Capture Selection
selected=$(menu "$options")

# 4. Execute Command (Now silently with notifications)
case "$selected" in
  *Performance*)
    sudo tlp performance
    notify-send -u low -i "power-profile-performance" "Power Profile" "Switched to Performance"
    ;;
  *Balanced*)
    sudo tlp balanced
    notify-send -u low -i "power-profile-balanced" "Power Profile" "Switched to Balanced"
    ;;
  *Power*)
    sudo tlp power-saver
    notify-send -u low -i "power-profile-power-saver" "Power Profile" "Switched to Power Saver"
    ;;
esac
