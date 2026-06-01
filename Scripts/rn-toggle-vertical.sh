#!/bin/bash
# Toggle the vertical companion (browser) for the current workspace.
# Workspace 3 -> special:3-vertical, workspace 4 -> special:4-vertical, etc.

set -euo pipefail

current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

if [[ "$current_ws" -le 2 ]]; then
    exit 0
fi

special_name="${current_ws}-vertical"

hyprctl dispatch togglespecialworkspace "$special_name"
