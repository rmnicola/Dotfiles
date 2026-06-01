#!/bin/bash

# 1. Create the target directory if it doesn't exist
# This prevents errors if ~/.local/bin is missing
mkdir -p "$HOME/.local/bin"

for file in *.sh; do
    # Skip if no .sh files match (handles empty directories)
    [ -e "$file" ] || continue

    # Check if the file is not already executable
    if ! [ -x "$file" ]; then
        # Make the file executable
        # (sudo is only needed if you don't own these files)
        chmod +x "$file"
    fi

    if [ "$(basename "$file")" != "run-this.sh" ]; then
        # Strip the .sh extension from the filename
        filename=$(basename "$file" .sh)

        # 2. Use $HOME instead of ~
        target_link="$HOME/.local/bin/$filename"

        # Check if the symlink DOES NOT exist
        if ! [ -L "$target_link" ]; then
            # Create the link
            ln -s "$(pwd)/$file" "$target_link"
            echo "✅ $file -> $target_link"
        else
            echo "🚬 $target_link already exists"
        fi
    fi
done
