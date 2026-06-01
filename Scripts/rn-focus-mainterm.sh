#!/bin/sh
if hyprctl clients | grep -q "class: com.mainterm"; then
    hyprctl dispatch focuswindow "class:^com.mainterm$"
else
    ghostty --class=com.mainterm -e zellij a -c mainterm
fi
