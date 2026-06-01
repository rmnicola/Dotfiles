#!/bin/bash

# Configuration
PRESENT_ROOT="$HOME/Documents/Presentations"
ICON="📺"

# 1. Select Presentation
SELECTION=$(find "$PRESENT_ROOT" -mindepth 1 -maxdepth 1 -type d ! -name '.*' -printf \
  '%f\n' | sort | sed "s/^/$ICON /" |\
  walker --dmenu --placeholder "📺 Present")

[ -z "$SELECTION" ] && exit 0

SELECTED_DIR="${SELECTION#"$ICON" }"
FULL_PATH="$PRESENT_ROOT/$SELECTED_DIR"
PDF_PATH=$(find "$FULL_PATH/build" -name "*.pdf" -type f | head -n1)

if [[ -z "$PDF_PATH" ]]; then
    notify-send "❌ Error" "No PDF found in build/ directory for $SELECTED_DIR"
    exit 1
fi

# 2. Launch Evince Presentation
hyprctl dispatch exec "[fullscreen] evince --presentation ""$PDF_PATH"""
