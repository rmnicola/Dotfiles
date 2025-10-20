#!/bin/bash

# Set default names for the class and the workspace
CLASS_NAME="mainscratch"
WORKSPACE_NAME="main"

# If --alt is passed, use the alternative names
if [[ "$1" == "--alt" ]]; then
    CLASS_NAME="altscratch"
    WORKSPACE_NAME="alt"
fi

# Check if a window with the specific class already exists anywhere
if hyprctl clients | grep -q "class: $CLASS_NAME"; then
    # If it exists, toggle the corresponding named special workspace
    hyprctl dispatch togglespecialworkspace $WORKSPACE_NAME
else
    # Otherwise, execute Alacritty on the corresponding named special workspace
    hyprctl dispatch exec "[workspace special:$WORKSPACE_NAME] alacritty --class $CLASS_NAME"
fi
