#!/bin/bash

# Configuration
PROJECTS_ROOT="$HOME/Documents/Projects"
PROFILES_ROOT="$HOME/.local/share/project-browser-profiles"
TERM_WORKSPACE=3
BROWSER_WORKSPACE=4
ICON="📂"

# --- 1. Input Handling ---

if [[ "$1" =~ ^[1-5]$ ]]; then
    # Quick Launch 1-5
    SELECTION=$(find "$PROJECTS_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | sed -n "${1}p")
    [ -z "$SELECTION" ] && { notify-send "🚀 Project Launcher" "No project found at index $1"; exit 1; }
    SELECTED_DIR="$SELECTION"
else
    # Interactive Mode
    RAW_INPUT=$(find "$PROJECTS_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | sed "s/^/$ICON /" | walker --dmenu --placeholder "🚀 Select, Create, or Clone (user/repo [name])")
    [ -z "$RAW_INPUT" ] && exit 0

    INPUT_CLEAN="${RAW_INPUT#$ICON }"

    # Split input into parts (to check for custom directory argument)
    # read -r assigns the first word to ARG1 and the *rest* to ARG2
    read -r ARG1 ARG2 <<< "$INPUT_CLEAN"

    # --- GIT CLONE LOGIC ---
    # Check if first part is a URL or user/repo pattern
    if [[ "$ARG1" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || [[ "$ARG1" =~ github\.com ]]; then
        
        # Normalize URL
        if [[ "$ARG1" =~ github\.com ]]; then
            REPO_URL="$ARG1"
        else
            REPO_URL="https://github.com/${ARG1}.git"
        fi

        # Determine Directory Name
        if [ -n "$ARG2" ]; then
            # User provided a custom name (e.g. "user/repo my-project")
            SELECTED_DIR="$ARG2"
        else
            # Default to repo name
            SELECTED_DIR=$(basename "$REPO_URL" .git)
        fi
        
        FULL_PATH="$PROJECTS_ROOT/$SELECTED_DIR"

        if [ -d "$FULL_PATH" ]; then
             notify-send "🚀 Project Exists" "Opening existing $SELECTED_DIR..."
        else
             notify-send "⬇️  Cloning..." "$REPO_URL -> $SELECTED_DIR"
             git clone "$REPO_URL" "$FULL_PATH"
             if [ $? -ne 0 ]; then
                 notify-send "❌ Error" "Git clone failed."
                 exit 1
             fi
        fi

    else
        # Standard Selection / Creation
        # If user typed "my new project", we use the full string as the directory name
        SELECTED_DIR="$INPUT_CLEAN"
        FULL_PATH="$PROJECTS_ROOT/$SELECTED_DIR"

        if [ ! -d "$FULL_PATH" ]; then
            notify-send "🚀 New Project" "Creating directory: $SELECTED_DIR"
            mkdir -p "$FULL_PATH"
        fi
    fi
fi

# Standard Setup
SESSION_NAME=$(echo "$SELECTED_DIR" | tr '[:upper:]' '[:lower:]' | sed 's/[_ ]/-/g')
PROJECT_PROFILE="$PROFILES_ROOT/$SESSION_NAME"


# --- 2. Handle Browser (Workspace 4) ---

if [ ! -d "$PROJECT_PROFILE" ]; then
    mkdir -p "$PROJECT_PROFILE/Default"
    echo '{ "session": { "restore_on_startup": 1 } }' > "$PROJECT_PROFILE/Default/Preferences"
fi

hyprctl clients -j | jq -r ".[] | select(.workspace.id == $BROWSER_WORKSPACE) | .address" | xargs -r -I{} hyprctl dispatch closewindow address:{}

nohup chromium \
    --class="com.projbrowser" \
    --user-data-dir="$PROJECT_PROFILE" \
    >/dev/null 2>&1 &


# --- 3. Handle Terminal (Workspace 3) ---

hyprctl clients -j | jq -r ".[] | select(.workspace.id == $TERM_WORKSPACE) | .address" | xargs -r -I{} hyprctl dispatch closewindow address:{}

hyprctl dispatch workspace $TERM_WORKSPACE
hyprctl dispatch exec "ghostty --class=com.projterm --working-directory=\"$FULL_PATH\" -e zellij attach -c \"$SESSION_NAME\""
