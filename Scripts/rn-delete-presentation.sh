#!/bin/bash

# Configuration
PRESENT_ROOT="$HOME/Documents/Presentations"
ICON="🗑️"

# Ensure the directory exists to avoid errors
if [ ! -d "$PRESENT_ROOT" ]; then
    notify-send "❌ Error" "Presentation directory not found."
    exit 1
fi

# 1. Select Presentation to Delete
# Lists all directories in the presentations folder (excluding hidden)
SELECTION=$(find "$PRESENT_ROOT" -mindepth 1 -maxdepth 1 -type d ! -name '.*' -printf '%f\n' | sort | sed "s/^/$ICON /" | walker --dmenu --placeholder "⚠️  DELETE PRESENTATION")

# Exit if user cancelled (Esc)
[ -z "$SELECTION" ] && exit 0

# Clean the selection
SELECTED_DIR="${SELECTION#"$ICON" }"
FULL_PATH="$PRESENT_ROOT/$SELECTED_DIR"

# 2. Safety Confirmation
# We pipe a Yes/No option into Walker to prevent accidental Enter presses
CONFIRM=$(echo -e "❌ NO - CANCEL\n✅ YES - DELETE FOREVER" | walker --dmenu --placeholder "Are you sure you want to delete '$SELECTED_DIR'?")

if [[ "$CONFIRM" == "✅ YES - DELETE FOREVER" ]]; then
    
    # Check if it actually exists before deleting
    if [ -d "$FULL_PATH" ]; then
        rm -rf "$FULL_PATH"
        notify-send "🗑️ Deleted" "'$SELECTED_DIR' has been removed."
    else
        notify-send "❌ Error" "Directory not found: $SELECTED_DIR"
    fi

else
    notify-send "🛑 Cancelled" "Deletion aborted."
fi
