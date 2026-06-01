#!/bin/bash
set -euo pipefail

# =============================================================================
# rn-profile-cleanup.sh — Clean up orphaned Firefox browser profiles
#
# Browser profiles live in ~/.local/share/project-browser-profiles/.
# Each profile directory corresponds to a workspace item (discipline, project,
# or material) under ~/Documents/.  A profile is "orphaned" when its name no
# longer matches any active workspace directory.
#
# Special profiles "default" and "personal" are always kept.
# =============================================================================

# --- Constants ---------------------------------------------------------------
PROFILES_ROOT="$HOME/.local/share/project-browser-profiles"
DISCIPLINAS_DIR="$HOME/Documents/Disciplinas"
PROJETOS_DIR="$HOME/Documents/Projetos"
MATERIAIS_DIR="$HOME/Documents/Materiais"
SPECIAL_PROFILES=("default" "personal")

# --- Argument parsing --------------------------------------------------------
AUTO_MODE=false

usage() {
    echo "Usage: rn-profile-cleanup.sh [OPTIONS]"
    echo ""
    echo "Clean up orphaned Firefox browser profiles."
    echo ""
    echo "Options:"
    echo "  --auto    Skip all prompts, delete every orphan found"
    echo "  -h|--help Show this help message"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --auto) AUTO_MODE=true ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

# --- Helper functions --------------------------------------------------------

# Convert a directory name to the profile/session slug format:
#   lowercase, spaces and underscores become hyphens.
to_slug() {
    local name="$1"
    echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[_ ]/-/g'
}

# Check whether a profile name is in the special (protected) list.
is_special_profile() {
    local profile_name="$1"
    local special
    for special in "${SPECIAL_PROFILES[@]}"; do
        if [[ "$profile_name" == "$special" ]]; then
            return 0
        fi
    done
    return 1
}

# Scan a directory for non-hidden subdirectories (maxdepth 1) and add their
# slug-converted names to the VALID_SLUGS associative array.
scan_workspace_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        return
    fi
    local entry slug
    while IFS= read -r entry; do
        slug=$(to_slug "$entry")
        VALID_SLUGS["$slug"]=1
    done < <(find "$dir" -mindepth 1 -maxdepth 1 -type d \
                 -not -name '.*' -printf '%f\n')
}

# --- Main --------------------------------------------------------------------

gum style --bold --foreground 212 "Firefox Profile Cleanup" 2>/dev/null \
    || echo "Firefox Profile Cleanup"
echo ""

# Step 1: Build whitelist of active workspace slugs
declare -A VALID_SLUGS

scan_workspace_dir "$DISCIPLINAS_DIR"
scan_workspace_dir "$PROJETOS_DIR"
scan_workspace_dir "$MATERIAIS_DIR"

# Always-valid hardcoded entries
VALID_SLUGS["dotfiles"]=1
VALID_SLUGS["zettelkasten"]=1

active_count=${#VALID_SLUGS[@]}
gum style --foreground 245 "  Active workspace entries: $active_count" 2>/dev/null \
    || echo "  Active workspace entries: $active_count"

# Step 2: Discover existing profiles and find orphans
if [[ ! -d "$PROFILES_ROOT" ]]; then
    gum style --foreground 245 "  Profiles directory not found: $PROFILES_ROOT" 2>/dev/null \
        || echo "  Profiles directory not found: $PROFILES_ROOT"
    exit 0
fi

orphans=()
kept=0

for profile_path in "$PROFILES_ROOT"/*/; do
    [[ -d "$profile_path" ]] || continue

    profile_name=$(basename "$profile_path")

    # Skip special profiles
    if is_special_profile "$profile_name"; then
        ((kept++))
        continue
    fi

    # Check against whitelist
    if [[ -z "${VALID_SLUGS[$profile_name]+_}" ]]; then
        orphans+=("$profile_name")
    else
        ((kept++))
    fi
done

# Step 3: Report orphans
if [[ ${#orphans[@]} -eq 0 ]]; then
    echo ""
    gum style --bold --foreground 82 "  No orphaned profiles found. Everything is clean!" 2>/dev/null \
        || echo "  No orphaned profiles found. Everything is clean!"
    notify-send "Profile Cleanup" "No orphaned profiles found." \
        --icon=dialog-information 2>/dev/null || true
    exit 0
fi

echo ""
gum style --bold --foreground 214 "  Found ${#orphans[@]} orphaned profile(s):" 2>/dev/null \
    || echo "  Found ${#orphans[@]} orphaned profile(s):"
echo ""

for orphan in "${orphans[@]}"; do
    orphan_path="$PROFILES_ROOT/$orphan"
    size=$(du -sh "$orphan_path" 2>/dev/null | cut -f1)
    gum style --foreground 196 "    - $orphan ($size)" 2>/dev/null \
        || echo "    - $orphan ($size)"
done

echo ""

# Step 4: Confirm deletion
should_delete=false
if [[ "$AUTO_MODE" == "true" ]]; then
    should_delete=true
    gum style --foreground 245 "  [auto mode] Deleting all orphans..." 2>/dev/null \
        || echo "  [auto mode] Deleting all orphans..."
else
    if gum confirm "Delete ${#orphans[@]} orphaned profile(s)?" 2>/dev/null; then
        should_delete=true
    else
        gum style --foreground 245 "  Aborted. No profiles were deleted." 2>/dev/null \
            || echo "  Aborted. No profiles were deleted."
        exit 0
    fi
fi

# Step 5: Delete orphans
deleted=0
if [[ "$should_delete" == "true" ]]; then
    echo ""
    for orphan in "${orphans[@]}"; do
        orphan_path="$PROFILES_ROOT/$orphan"
        gum style --foreground 214 "  Removing $orphan ..." 2>/dev/null \
            || echo "  Removing $orphan ..."
        rm -rf "$orphan_path"
        ((deleted++))
    done
fi

# Step 6: Summary
echo ""
summary="Cleaned $deleted profile(s), kept $kept."
gum style --bold --foreground 82 "  $summary" 2>/dev/null \
    || echo "  $summary"
notify-send "Profile Cleanup" "$summary" \
    --icon=dialog-information 2>/dev/null || true
