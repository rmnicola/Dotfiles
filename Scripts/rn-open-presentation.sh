#!/bin/bash

# Configuration
PRESENT_ROOT="$HOME/Documents/Presentations"
ZELLIJ_SESSION="mainterm"
ICON="📽️"

# Ensure root exists
mkdir -p "$PRESENT_ROOT"

# 1. Select or Create
RAW_INPUT=$(find "$PRESENT_ROOT" -mindepth 1 -maxdepth 1 -type d ! -name '.*' -printf \
  '%f\n' | sort | sed "s/^/$ICON /" | walker --dmenu --placeholder\
  "📝 Edit or Create Presentation")

[ -z "$RAW_INPUT" ] && exit 0

INPUT_CLEAN="${RAW_INPUT#"$ICON" }"
TITLE="$INPUT_CLEAN"
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[_ ]/-/g')
FULL_PATH="$PRESENT_ROOT/$SLUG"

# 2. Scaffolding
if [ ! -d "$FULL_PATH" ]; then
    notify-send "📽️ New Presentation" "Creating scaffolding for '$TITLE'..."
    cp -r "$PRESENT_ROOT/.inteli-template" "$FULL_PATH"
    mv "$FULL_PATH/main.typ" "$FULL_PATH/$SLUG.typ"
    rm -rf "$FULL_PATH/build"
    mkdir -p "$FULL_PATH/build"
fi

# 3. Open in Zellij
if zellij list-sessions | grep -q "$ZELLIJ_SESSION"; then
    hyprctl dispatch focuswindow "class:^com.mainterm$"
    export ZELLIJ_SESSION_NAME="$ZELLIJ_SESSION"

    # --- THE ROBUST FIX ---
    # Create a temporary layout file that explicitly defines the CWD and Command
    TMP_LAYOUT=$(mktemp /tmp/zellij-present-XXXX.kdl)

    cat <<EOF > "$TMP_LAYOUT"
layout {
    tab name="$SLUG" focus=true {
        pane {
            cwd "$FULL_PATH"
        }
        // We add your bar here so this specific tab looks consistent with your others
        pane size=1 borderless=true {
            plugin location="zellij:compact-bar"
        }
    }
}
EOF

    # Tell Zellij to open a new tab using this temporary layout
    zellij action new-tab --layout "$TMP_LAYOUT"
    
    # Cleanup
    rm "$TMP_LAYOUT"

else
    notify-send "⚠️ Mainterm not found" "Launching new session..."
    ghostty --class="com.mainterm" -e zellij attach -c "$ZELLIJ_SESSION" options --default-cwd "$FULL_PATH"
fi
