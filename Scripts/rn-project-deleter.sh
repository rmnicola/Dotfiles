#!/bin/bash

PROJECTS_ROOT="$HOME/Documents/Projects"
PROFILES_ROOT="$HOME/.local/share/project-browser-profiles"
ICON="🗑️"

# 1. Select Project to Delete
SELECTION=$(find "$PROJECTS_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | sed "s/^/$ICON /" | walker --dmenu --placeholder "⚠️  DELETE PROJECT (Esc for Cleanup Tool)")

# --- FALLBACK LOGIC ---
# If user cancels (Esc), launch the cleanup tool in a terminal
if [ -z "$SELECTION" ]; then
    notify-send "🧹 Project Cleanup" "Launching cleanup tool..."
    # Using Ghostty with -e to keep window open
    # We pass no arguments so it runs interactively
    rn-project-cleanup
    notify-send "🧹 Project Cleanup" "Cleanup complete!"
    exit 0
fi

SELECTED_DIR="${SELECTION#$ICON }"
FULL_PATH="$PROJECTS_ROOT/$SELECTED_DIR"
SESSION_NAME=$(echo "$SELECTED_DIR" | tr '[:upper:]' '[:lower:]' | sed 's/[_ ]/-/g')
PROJECT_PROFILE="$PROFILES_ROOT/$SESSION_NAME"

# 2. Safety Confirmation
CONFIRM=$(echo -e "❌ NO - CANCEL\n✅ YES - DELETE FOREVER" | walker --dmenu --placeholder "Are you sure you want to delete '$SELECTED_DIR'?")

if [[ "$CONFIRM" == "✅ YES - DELETE FOREVER" ]]; then
    
    # Delete Project Folder
    if [ -d "$FULL_PATH" ]; then
        rm -rf "$FULL_PATH"
        MSG="Project deleted."
    else
        MSG="Project folder not found."
    fi

    # Delete Browser Profile
    if [ -d "$PROJECT_PROFILE" ]; then
        rm -rf "$PROJECT_PROFILE"
        MSG="$MSG Profile deleted."
    fi

    notify-send "🗑️ Deleted" "$SELECTED_DIR has been removed."
else
    notify-send "🛑 Cancelled" "Deletion aborted."
fi
