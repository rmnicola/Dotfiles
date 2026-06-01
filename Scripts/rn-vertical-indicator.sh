#!/bin/bash
# Outputs a Waybar JSON indicator when a vertical special workspace is active
# Used by Waybar custom/vertical-indicator module

if hyprctl clients -j 2>/dev/null | jq -e 'any(.[]; .workspace.name | test("^special:[0-9]+-vertical$"))' >/dev/null 2>&1; then
    echo '{"text": "◉", "class": "vertical", "tooltip": "Browser overlay active"}'
else
    echo '{"text": "", "class": ""}'
fi
