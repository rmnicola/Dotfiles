#!/bin/bash
set -euo pipefail

# ============================================================================
# rn-open-workspace.sh — Workspace launcher for Hyprland
# Opens a project/discipline/material in the CURRENT workspace with a
# Ghostty+Zellij terminal and Firefox browser in scrolling layout.
# ============================================================================

# --- Constants ---
DISCIPLINAS_DIR="$HOME/Documents/Disciplinas"
PROJETOS_DIR="$HOME/Documents/Projetos"
MATERIAIS_DIR="$HOME/Documents/Materiais"
DOTFILES_DIR="$HOME/Documents/Dotfiles"
ZETTELKASTEN_DIR="$HOME/Documents/Zettelkasten"
PROFILES_ROOT="$HOME/.local/share/project-browser-profiles"

# --- Usage ---
usage() {
    cat <<EOF
Usage: rn-open-workspace.sh [OPTIONS]

Open a project/discipline/material in the current Hyprland workspace
with a Ghostty+Zellij terminal and Firefox browser (scrolling layout).

Options:
    --disciplinas     Skip category menu, go to Disciplinas
    --projetos        Skip category menu, go to Projetos
    --materiais       Skip category menu, go to Materiais
    --dotfiles        Open Dotfiles directly
    --zettelkasten    Open Zettelkasten directly
    -h, --help        Show this help message

Dependencies: jq, walker, hyprctl, firefox, ghostty, zellij
EOF
    exit 0
}

# --- Dependency Check ---
check_dependencies() {
    local missing=()
    for cmd in walker jq hyprctl firefox ghostty zellij; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        notify-send -u critical "Workspace Launcher" \
            "Missing dependencies: ${missing[*]}"
        exit 1
    fi
}

# --- Argument Parsing ---
CATEGORY=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --disciplinas)   CATEGORY="disciplinas" ;;
        --projetos)      CATEGORY="projetos" ;;
        --materiais)     CATEGORY="materiais" ;;
        --dotfiles)      CATEGORY="dotfiles" ;;
        --zettelkasten)  CATEGORY="zettelkasten" ;;
        -h|--help)       usage ;;
        *)
            notify-send -u critical "Workspace Launcher" \
                "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# --- Dependency Check ---
check_dependencies

# --- Workspace Check ---
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

if [[ "$current_ws" -le 2 ]]; then
    notify-send -u critical "Workspace Launcher" \
        "Cannot open in workspace 1 or 2. Move to workspace 3+ first."
    exit 1
fi

# --- Category Selection (if not provided via args) ---
if [[ -z "$CATEGORY" ]]; then
    category_choice=$(printf '%s\n' \
        "📚 Disciplinas" \
        "🚀 Projetos" \
        "📖 Materiais" \
        "⚙️ Dotfiles" \
        "📝 Zettelkasten" \
        | walker --dmenu --placeholder "Select category…")

    [[ -z "$category_choice" ]] && exit 0

    case "$category_choice" in
        *Disciplinas)   CATEGORY="disciplinas" ;;
        *Projetos)      CATEGORY="projetos" ;;
        *Materiais)     CATEGORY="materiais" ;;
        *Dotfiles)      CATEGORY="dotfiles" ;;
        *Zettelkasten)  CATEGORY="zettelkasten" ;;
        *)
            notify-send -u critical "Workspace Launcher" \
                "Invalid category selection."
            exit 1
            ;;
    esac
fi

# --- Item Selection ---
SELECTED_DIR=""
FULL_PATH=""

case "$CATEGORY" in
    disciplinas)
        root_dir="$DISCIPLINAS_DIR"
        ;;
    projetos)
        root_dir="$PROJETOS_DIR"
        ;;
    materiais)
        root_dir="$MATERIAIS_DIR"
        ;;
    dotfiles)
        SELECTED_DIR="Dotfiles"
        FULL_PATH="$DOTFILES_DIR"
        ;;
    zettelkasten)
        SELECTED_DIR="Zettelkasten"
        FULL_PATH="$ZETTELKASTEN_DIR"
        ;;
esac

if [[ -z "$SELECTED_DIR" ]]; then
    # Find subdirectories (not hidden, maxdepth 1) and show in walker
    selected_item=$(find "$root_dir" -mindepth 1 -maxdepth 1 -type d \
        -not -name '.*' -printf '%f\n' | sort \
        | walker --dmenu --placeholder "Select item…")

    [[ -z "$selected_item" ]] && exit 0

    SELECTED_DIR="$selected_item"
    FULL_PATH="$root_dir/$SELECTED_DIR"
fi

if [[ ! -d "$FULL_PATH" ]]; then
    notify-send -u critical "Workspace Launcher" \
        "Directory not found: $FULL_PATH"
    exit 1
fi

# --- Session Name Generation ---
session_name=$(echo "$SELECTED_DIR" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[_ ]/-/g')

profile_dir="$PROFILES_ROOT/$session_name"

# --- Workspace Setup ---

# Close all windows on current workspace
hyprctl clients -j \
    | jq -r ".[] | select(.workspace.id == $current_ws) | .address" \
    | xargs -r -I{} hyprctl dispatch closewindow address:{}

# Set workspace to scrolling layout
hyprctl keyword workspace $current_ws, layout:scrolling

# Create browser profile directory
mkdir -p "$profile_dir"

# --- Launch Apps ---

# 1. Ghostty terminal with Zellij
hyprctl dispatch exec \
    "ghostty --class=com.workterm --working-directory='$FULL_PATH' -e zellij attach -c '$session_name'"

sleep 0.5

# 2. Firefox with dedicated profile
nohup firefox --profile "$profile_dir" >/dev/null 2>&1 &
