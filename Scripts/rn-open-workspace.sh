#!/bin/bash
set -euo pipefail

# ============================================================================
# rn-open-workspace.sh — Workspace launcher for Hyprland
# Terminal on current workspace + Firefox on special:<ws>-vertical
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
    for cmd in walker jq hyprctl firefox ghostty zellij git; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        notify-send -u critical "Workspace Launcher" "Missing: ${missing[*]}"
        exit 1
    fi
}

# --- Handle custom input (GitHub clone or new dir) ---
resolve_custom_input() {
    local input="$1"
    local root="$2"

    # GitHub clone: user/repo [custom-name]
    if [[ "$input" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+ ]] || [[ "$input" =~ github\.com ]]; then
        read -r repo_input custom_name <<< "$input"

        if [[ "$repo_input" =~ github\.com ]]; then
            REPO_URL="$repo_input"
        else
            REPO_URL="https://github.com/${repo_input}.git"
        fi

        if [[ -n "$custom_name" ]]; then
            SELECTED_DIR="$custom_name"
        else
            SELECTED_DIR=$(basename "$REPO_URL" .git)
        fi

        FULL_PATH="$root/$SELECTED_DIR"

        if [[ -d "$FULL_PATH" ]]; then
            notify-send "Workspace Launcher" "Already exists — opening $SELECTED_DIR"
        else
            notify-send "Workspace Launcher" "Cloning $repo_input → $SELECTED_DIR"
            git clone "$REPO_URL" "$FULL_PATH" || {
                notify-send -u critical "Workspace Launcher" "Clone failed"
                exit 1
            }
        fi

    # Create new directory
    else
        SELECTED_DIR="$input"
        FULL_PATH="$root/$SELECTED_DIR"
        mkdir -p "$FULL_PATH"
        if [[ "$CATEGORY" == "disciplinas" ]]; then
            mkdir -p "$FULL_PATH"/{aulas,atividades,projeto,provas,correcoes/{projeto,atividades,provas}}
        fi
        notify-send "Workspace Launcher" "Created $SELECTED_DIR"
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
    # Build list of existing items + "Create new" option at top
    existing_dirs=$(find "$root_dir" -mindepth 1 -maxdepth 1 -type d \
        -not -name '.*' -printf '%f\n' | sort)

    selected_item=$(printf '✦ Novo…\n%s' "$existing_dirs" \
        | walker --dmenu --placeholder "Select or type…")
    [[ -z "$selected_item" ]] && exit 0

    # --- Explicit "Create new" ---
    if [[ "$selected_item" == "✦ Novo…" ]]; then
        selected_item=$(gum input --placeholder "New name (or user/repo …)")
        [[ -z "$selected_item" ]] && exit 0

        # Check if it matches an existing dir (case-insensitive)
        found=false
        while IFS= read -r dir; do
            if [[ "${dir,,}" == "${selected_item,,}" ]]; then
                selected_item="$dir"
                found=true
                break
            fi
        done <<< "$existing_dirs"

        if [[ "$found" == "true" ]]; then
            SELECTED_DIR="$selected_item"
            FULL_PATH="$root_dir/$SELECTED_DIR"
        else
            resolve_custom_input "$selected_item" "$root_dir"
        fi
    else
        # Regular selection from list
        SELECTED_DIR="$selected_item"
        FULL_PATH="$root_dir/$SELECTED_DIR"
    fi
fi

# --- Session name ---
session_name=$(echo "$SELECTED_DIR" | tr '[:upper:]' '[:lower:]' | sed 's/[_ ]/-/g')
profile_dir="$PROFILES_ROOT/$session_name"
vertical_name="${current_ws}-vertical"

# --- Clear workspace (no toggles!) ---

# 1. Close windows on current workspace
hyprctl clients -j \
    | jq -r ".[] | select(.workspace.id == $current_ws) | .address" \
    | xargs -r -I{} hyprctl dispatch closewindow address:{}

# 2. Close windows on the vertical special workspace
hyprctl clients -j \
    | jq -r '.[] | select(.workspace.name == "special:'$vertical_name'") | .address' \
    | xargs -r -I{} hyprctl dispatch closewindow address:{}

sleep 0.3

# --- Launch ---

# 1. Terminal on current workspace
hyprctl dispatch exec \
    "ghostty --class=com.workterm --working-directory='$FULL_PATH' -e zellij attach -c '$session_name'"

# 2. Firefox — launch normally then move to special workspace
mkdir -p "$profile_dir"

# Ensure Firefox restores the last session for this profile
if [[ ! -f "$profile_dir/user.js" ]]; then
    cat > "$profile_dir/user.js" <<'USERJS'
user_pref("browser.startup.page", 3);
user_pref("browser.sessionstore.resume_session_once", true);
USERJS
fi
firefox --profile "$profile_dir" &
firefox_pid=$!

# Wait for Firefox window to appear, then move to vertical special workspace
for i in $(seq 1 30); do
    sleep 0.2
    addr=$(hyprctl clients -j 2>/dev/null \
        | jq -r ".[] | select(.pid == $firefox_pid) | .address" \
        | head -1)
    if [[ -n "$addr" && "$addr" != "null" ]]; then
        hyprctl dispatch movetoworkspacesilent "special:$vertical_name,address:$addr"
        break
    fi
done

notify-send -u low "Workspace" "$SELECTED_DIR  ·  SUPER+J = browser"
