#!/bin/bash
set -euo pipefail

# Configuration
PROJETOS_ROOT="$HOME/Documents/Projetos"
DISCIPLINAS_ROOT="$HOME/Documents/Disciplinas"
MATERIAIS_ROOT="$HOME/Documents/Materiais"
PROFILES_ROOT="$HOME/.local/share/project-browser-profiles"

# Parse arguments
AUTO_MODE=false
SCAN_ALL=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --auto) AUTO_MODE=true ;;
        --all) SCAN_ALL=true ;;
        -h|--help)
            echo "Usage: rn-project-cleanup.sh [--auto] [--all]"
            echo "  --auto  Skip all prompts, auto-delete orphans"
            echo "  --all   Also scan Disciplinas/ and Materiais/"
            exit 0
            ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Check if profile-cleaner is installed
if ! command -v profile-cleaner &> /dev/null; then
    notify-send "❌ Error" "'profile-cleaner' is not installed."
    echo "❌ Error: 'profile-cleaner' is not installed."
    echo "   Please install it first (e.g., yay -S profile-cleaner)."
    exit 1
fi

# Build list of directories to scan
build_scan_dirs() {
    local -n dirs_ref=$1
    dirs_ref=("$PROJETOS_ROOT")
    if [[ "$SCAN_ALL" == "true" ]]; then
        [[ -d "$DISCIPLINAS_ROOT" ]] && dirs_ref+=("$DISCIPLINAS_ROOT")
        [[ -d "$MATERIAIS_ROOT" ]] && dirs_ref+=("$MATERIAIS_ROOT")
    fi
}

# Build whitelist of valid slugs from all scan directories
build_whitelist() {
    local -n whitelist_ref=$1
    local scan_dirs=()
    build_scan_dirs scan_dirs

    for root_dir in "${scan_dirs[@]}"; do
        [[ -d "$root_dir" ]] || continue
        while IFS= read -r dir_name; do
            local slug
            slug=$(echo "$dir_name" | tr '[:upper:]' '[:lower:]' | sed 's/[_ ]/-/g')
            whitelist_ref["$slug"]=1
        done < <(find "$root_dir" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')
    done
}

echo "============================================="
echo "   🕵️  PROJECT BROWSER CLEANUP TOOL"
echo "============================================="
echo ""

# --- PHASE 1: ORPHAN REMOVAL ---
echo "🔍 PHASE 1: Scanning for orphaned browser profiles..."

declare -A valid_slugs
build_whitelist valid_slugs

# Collect orphans into an array
orphans=()
for profile_path in "$PROFILES_ROOT"/*; do
    [[ -d "$profile_path" ]] || continue
    profile_name=$(basename "$profile_path")
    if [[ -z "${valid_slugs[$profile_name]:-}" ]]; then
        orphans+=("$profile_path")
    fi
done

orphans_found=${#orphans[@]}

if [[ "$orphans_found" -eq 0 ]]; then
    echo "   ✨ No orphans found."
    notify-send "🧹 Cleanup" "No orphaned profiles found."
else
    echo "   Found $orphans_found orphaned profile(s)."
    echo ""

    for profile_path in "${orphans[@]}"; do
        profile_name=$(basename "$profile_path")
        size=$(du -sh "$profile_path" | cut -f1)
        echo "   🗑️  Orphan: $profile_name ($size)"

        if [[ "$AUTO_MODE" == "true" ]]; then
            echo "       [Auto] Deleting..."
            rm -rf "$profile_path"
            echo "       ✅ Deleted."
        else
            if gum confirm "Delete profile '$profile_name' ($size)?"; then
                rm -rf "$profile_path"
                echo "       ✅ Deleted."
            else
                echo "       ⏭️  Skipped."
            fi
        fi
    done
fi

echo ""

# --- PHASE 2: OPTIMIZATION ---
echo "🧹 PHASE 2: Optimizing active profiles..."
echo "   (Vacuuming sqlite databases to save space)"
echo "---------------------------------------------"

echo "   🚀 Processing: base chromium"
profile-cleaner c
echo "---------------------------------------------"

for profile_path in "$PROFILES_ROOT"/*; do
    [[ -d "$profile_path" ]] || continue
    profile_name=$(basename "$profile_path")
    echo "   🚀 Processing: $profile_name"
    profile-cleaner p "$profile_path"
    echo "---------------------------------------------"
done

echo "✅ Cleanup and optimization complete."
notify-send "🧹 Cleanup Complete" "Browser profiles cleaned and optimized."

if [[ "$AUTO_MODE" == "false" ]]; then
    read -rp "Press any key to exit..."
fi
