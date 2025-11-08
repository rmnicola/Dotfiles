#!/bin/bash

# Set defaults for the 3-month view
CLASS_NAME="cal"
WORKSPACE_NAME="calendar"
CAL_COMMAND="cal -3" # Default command

# Check for -y or -Y argument
if [[ "$1" == "-y" || "$1" == "-Y" ]]; then
    CLASS_NAME="yearcal"
    WORKSPACE_NAME="calendar"  # Use a new, unique workspace name
    CAL_COMMAND="cal $1"      # Overwrite the command with the provided argument
fi

# Check if a window with the specific class already exists
if hyprctl clients | grep -q "class: $CLASS_NAME"; then
    # If it exists, just toggle the special workspace
    hyprctl dispatch togglespecialworkspace $WORKSPACE_NAME
else
    # Otherwise, execute Alacritty on the special workspace with the cal command.
    # The bash -c string is double-quoted to allow $CAL_COMMAND to expand.
    # No "read" or "echo" command is included.
    hyprctl dispatch exec "[workspace special:$WORKSPACE_NAME] alacritty --class $CLASS_NAME -e bash -c '$CAL_COMMAND; read -n 1 -s'"
fi
