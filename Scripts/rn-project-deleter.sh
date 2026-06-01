#!/bin/bash
set -euo pipefail

# Configuration
PROJETOS_ROOT="$HOME/Documents/Projetos"
DISCIPLINAS_ROOT="$HOME/Documents/Disciplinas"
MATERIAIS_ROOT="$HOME/Documents/Materiais"
PROFILES_ROOT="$HOME/.local/share/project-browser-profiles"

# Icons per directory
ICON_PROJETOS="📂"
ICON_DISCIPLINAS="📚"
ICON_MATERIAIS="🌐"

# Build combined list of deletable items
# Format: "ICON [Category] dirname"
build_item_list() {
    local items=""

    if [[ -d "$PROJETOS_ROOT" ]]; then
        while IFS= read -r dir_name; do
            items+="${ICON_PROJETOS} [Projetos] ${dir_name}"$'\n'
        done < <(find "$PROJETOS_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
    fi

    if [[ -d "$DISCIPLINAS_ROOT" ]]; then
        while IFS= read -r dir_name; do
            items+="${ICON_DISCIPLINAS} [Disciplinas] ${dir_name}"$'\n'
        done < <(find "$DISCIPLINAS_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
    fi

    if [[ -d "$MATERIAIS_ROOT" ]]; then
        while IFS= read -r dir_name; do
            items+="${ICON_MATERIAIS} [Materiais] ${dir_name}"$'\n'
        done < <(find "$MATERIAIS_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
    fi

    echo -n "$items"
}

# Parse a selection line into category and directory name
parse_selection() {
    local line="$1"
    # Strip leading icon (emoji + space)
    local stripped="${line#* }"
    # Extract category from [Category]
    category="${stripped#\[}"
    category="${category%%\]*}"
    # Extract directory name after "] "
    dir_name="${stripped#*\] }"
}

# Resolve the full path for a category + dir_name
resolve_path() {
    local cat="$1"
    local name="$2"
    case "$cat" in
        Projetos)     echo "$PROJETOS_ROOT/$name" ;;
        Disciplinas)  echo "$DISCIPLINAS_ROOT/$name" ;;
        Materiais)    echo "$MATERIAIS_ROOT/$name" ;;
    esac
}

# 1. Select item to delete
item_list=$(build_item_list)

if [[ -z "$item_list" ]]; then
    notify-send "🗑️ Delete" "No items found in any directory."
    exit 0
fi

selection=$(echo "$item_list" | walker --dmenu \
    --placeholder "⚠️  DELETE ITEM (Esc for Cleanup Tool)")

# --- FALLBACK LOGIC ---
# If user cancels (Esc), launch the cleanup tool
if [[ -z "$selection" ]]; then
    notify-send "🧹 Project Cleanup" "Launching cleanup tool..."
    rn-project-cleanup
    notify-send "🧹 Project Cleanup" "Cleanup complete!"
    exit 0
fi

parse_selection "$selection"
full_path=$(resolve_path "$category" "$dir_name")
session_name=$(echo "$dir_name" | tr '[:upper:]' '[:lower:]' | sed 's/[_ ]/-/g')
project_profile="$PROFILES_ROOT/$session_name"

# 2. Safety Confirmation
confirm=$(echo -e "❌ NO - CANCEL\n✅ YES - DELETE FOREVER" | \
    walker --dmenu \
    --placeholder "Delete [$category] $dir_name?")

if [[ "$confirm" == "✅ YES - DELETE FOREVER" ]]; then
    msg=""

    # Delete directory
    if [[ -d "$full_path" ]]; then
        rm -rf "$full_path"
        msg="Directory deleted."
    else
        msg="Directory not found."
    fi

    # Delete browser profile (only relevant for Projetos)
    if [[ "$category" == "Projetos" ]] && [[ -d "$project_profile" ]]; then
        rm -rf "$project_profile"
        msg="$msg Profile deleted."
    fi

    notify-send "🗑️ Deleted" "[$category] $dir_name has been removed."
else
    notify-send "🛑 Cancelled" "Deletion aborted."
fi
