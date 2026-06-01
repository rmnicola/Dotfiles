#!/bin/bash
set -euo pipefail

# ============================================================================
# rn-open-workspace.sh — Workspace launcher for Hyprland
# Opens terminal on current workspace + Firefox on special:<ws>-vertical
# ============================================================================

DISCIPLINAS_DIR="$HOME/Documents/Disciplinas"
PROJETOS_DIR="$HOME/Documents/Projetos"
MATERIAIS_DIR="$HOME/Documents/Materiais"
DOTFILES_DIR="$HOME/Documents/Dotfiles"
ZETTELKASTEN_DIR="$HOME/Documents/Zettelkasten"
PROFILES_ROOT="$HOME/.local/share/project-browser-profiles"

usage() {
    cat <<EOF
Usage: rn-open-workspace.sh [OPTIONS]

Options:
    --disciplinas     Skip category menu, go to Disciplinas
    --projetos        Skip category menu, go to Projetos
    --materiais       Skip category menu, go to Materiais
    --dotfiles        Open Dotfiles directly
    --zettelkasten    Open Zettelkasten directly
    -h, --help        Show this help
EOF
    exit 0
}

check_dependencies() {
    local missing=()
    for cmd in walker jq hyprctl firefox ghostty zellij; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        notify-send -u critical "Workspace Launcher" "Missing: ${missing[*]}"
        exit 1
    fi
}

# --- Parse args ---
CATEGORY=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --disciplinas)   CATEGORY="disciplinas" ;;
        --projetos)      CATEGORY="projetos" ;;
        --materiais)     CATEGORY="materiais" ;;
        --dotfiles)      CATEGORY="dotfiles" ;;
        --zettelkasten)  CATEGORY="zettelkasten" ;;
        -h|--help)       usage ;;
        *) notify-send -u critical "Workspace Launcher" "Unknown: $1"; exit 1 ;;
    esac
    shift
done

check_dependencies

# --- Workspace check ---
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')
if [[ "$current_ws" -le 2 ]]; then
    notify-send -u critical "Workspace Launcher" \
        "Cannot open in workspace 1 or 2. Move to workspace 3+ first."
    exit 1
fi

# --- Category selection ---
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
        *) exit 1 ;;
    esac
fi

# --- Item selection ---
SELECTED_DIR=""
FULL_PATH=""

case "$CATEGORY" in
    disciplinas)   root_dir="$DISCIPLINAS_DIR" ;;
    projetos)      root_dir="$PROJETOS_DIR" ;;
    materiais)     root_dir="$MATERIAIS_DIR" ;;
    dotfiles)      SELECTED_DIR="Dotfiles"; FULL_PATH="$DOTFILES_DIR" ;;
    zettelkasten)  SELECTED_DIR="Zettelkasten"; FULL_PATH="$ZETTELKASTEN_DIR" ;;
esac

if [[ -z "$SELECTED_DIR" ]]; then
    selected_item=$(find "$root_dir" -mindepth 1 -maxdepth 1 -type d \
        -not -name '.*' -printf '%f\n' | sort \
        | walker --dmenu --placeholder "Select item…")
    [[ -z "$selected_item" ]] && exit 0
    SELECTED_DIR="$selected_item"
    FULL_PATH="$root_dir/$SELECTED_DIR"
fi

if [[ ! -d "$FULL_PATH" ]]; then
    notify-send -u critical "Workspace Launcher" "Not found: $FULL_PATH"
    exit 1
fi

# --- Session name ---
session_name=$(echo "$SELECTED_DIR" | tr '[:upper:]' '[:lower:]' | sed 's/[_ ]/-/g')
profile_dir="$PROFILES_ROOT/$session_name"
vertical_name="${current_ws}-vertical"

# --- Clear workspace ---
hyprctl clients -j \
    | jq -r ".[] | select(.workspace.id == $current_ws) | .address" \
    | xargs -r -I{} hyprctl dispatch closewindow address:{}

# Close Firefox on the vertical special workspace (if any)
hyprctl dispatch togglespecialworkspace "$vertical_name" 2>/dev/null || true
hyprctl clients -j \
    | jq -r ".[] | select(.workspace.name == \"special:$vertical_name\") | .address" \
    | xargs -r -I{} hyprctl dispatch closewindow address:{}

# --- Launch ---

# 1. Terminal on current workspace
hyprctl dispatch exec \
    "ghostty --class=com.workterm --working-directory='$FULL_PATH' -e zellij attach -c '$session_name'"

# 2. Firefox on special:<ws>-vertical
mkdir -p "$profile_dir"
hyprctl dispatch exec "[workspace special:$vertical_name silent] firefox --profile '$profile_dir'"

notify-send -u low "Workspace" "$SELECTED_DIR — SUPER+J toggles browser"
