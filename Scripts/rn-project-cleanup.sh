#!/bin/bash

PROJECTS_ROOT="$HOME/Documents/Projects"
PROFILES_ROOT="$HOME/.local/share/project-browser-profiles"

# Parse arguments for automatic "yes"
AUTO_YES=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -y|--yes) AUTO_YES=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Check if profile-cleaner is installed
if ! command -v profile-cleaner &> /dev/null; then
    echo "❌ Error: 'profile-cleaner' is not installed."
    echo "   Please install it first (e.g., yay -S profile-cleaner)."
    exit 1
fi

echo "============================================="
echo "   🕵️  PROJECT BROWSER CLEANUP TOOL"
echo "============================================="
echo ""

# --- PHASE 1: ORPHAN REMOVAL ---
echo "🔍 PHASE 1: Scanning for orphaned browser profiles..."

# 1. Build a whitelist of valid project slugs
declare -A VALID_SLUGS
if [ -d "$PROJECTS_ROOT" ]; then
    while IFS= read -r dir_name; do
        # Apply the exact slug logic used in the launcher
        slug=$(echo "$dir_name" | tr '[:upper:]' '[:lower:]' | sed 's/[_ ]/-/g')
        VALID_SLUGS["$slug"]=1
    done < <(find "$PROJECTS_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')
fi

# 2. Check existing profiles
ORPHANS_FOUND=0
for profile_path in "$PROFILES_ROOT"/*; do
    [ -d "$profile_path" ] || continue
    
    profile_name=$(basename "$profile_path")
    
    # If profile name is NOT in the whitelist, it's an orphan
    if [[ -z "${VALID_SLUGS[$profile_name]}" ]]; then
        echo "   🗑️  Orphan found: $profile_name"
        
        # Show size
        size=$(du -sh "$profile_path" | cut -f1)
        echo "       Size: $size"
        
        # Determine deletion choice
        if [ "$AUTO_YES" = true ]; then
             echo "       [Auto-Yes] Deleting..."
             REPLY="y"
        else
             read -p "       Delete this profile? [y/N] " -n 1 -r
             echo
        fi

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$profile_path"
            echo "       ✅ Deleted."
        else
            echo "       ⏭️  Skipped."
        fi
        ((ORPHANS_FOUND++))
    fi
done

if [ "$ORPHANS_FOUND" -eq 0 ]; then
    echo "   ✨ No orphans found."
fi
echo ""


# --- PHASE 2: OPTIMIZATION ---
echo "🧹 PHASE 2: Optimizing active profiles..."
echo "   (This vacuums sqlite databases to save space)"
echo "---------------------------------------------"

echo "   🚀 Processing: base chromium"
profile-cleaner c
echo "---------------------------------------------"

# Loop through all profiles that still exist
for profile_path in "$PROFILES_ROOT"/*; do
    [ -d "$profile_path" ] || continue
    
    profile_name=$(basename "$profile_path")
    
    echo "   🚀 Processing: $profile_name"
    profile-cleaner p "$profile_path"
    echo "---------------------------------------------"
done

echo "✅ Cleanup and optimization complete."
# Wait for user to read output if not auto-yes (or always wait if you prefer)
if [ "$AUTO_YES" = false ]; then
    read -p "Press any key to exit..."
fi
