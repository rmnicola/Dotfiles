#!/bin/bash

# ==========================================
# Uninstall Scripts from ~/.local/bin
# Removes symlinks created by run-this.sh
# ==========================================

BIN_DIR="$HOME/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

removed=0
skipped=0

echo ">> Scanning $BIN_DIR for script symlinks..."

for script in "$SCRIPT_DIR"/rn-*.sh; do
    [[ -f "$script" ]] || continue

    name=$(basename "$script" .sh)
    link="$BIN_DIR/$name"

    if [[ -L "$link" ]]; then
        target=$(readlink "$link")
        if [[ "$target" == "$script" ]]; then
            rm "$link" && ((removed++)) && echo "  ✓ Removed: $name"
        else
            ((skipped++))
            echo "  ! Skipped: $name points to $target (not this repo)"
        fi
    elif [[ -e "$link" ]]; then
        ((skipped++))
        echo "  ! Skipped: $name is not a symlink"
    else
        ((skipped++))
        echo "  · Not found: $name"
    fi
done

echo ""
echo "Done. Removed: $removed, Skipped: $skipped"
