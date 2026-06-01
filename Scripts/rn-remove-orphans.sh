#!/bin/bash

# 1. Check for orphaned packages using pacman
# -Q: Query the package database
# -d: List packages installed as dependencies
# -t: List packages not required by any other package
# -q: Quiet mode (print only package names)
orphans=$(pacman -Qdtq)

# 2. handle case where no orphans exist
if [ -z "$orphans" ]; then
    echo "✅ No orphaned packages found. Your system is clean!"
    exit 0
fi

# 3. Pipe to fzf for selection
# --multi: Allow selecting multiple packages (Tab to toggle, Shift+Tab to toggle all)
# --preview: Shows package info using 'pacman -Qi' for the currently highlighted item
selected_packages=$(echo "$orphans" | fzf --multi --header="Select packages to remove (TAB to mark, ENTER to confirm)" --preview "pacman -Qi {1}")

# 4. Check if the user cancelled or didn't select anything
if [ -z "$selected_packages" ]; then
    echo "❌ No packages selected. Exiting."
    exit 0
fi

# 5. Remove the selected packages
# echo is used to convert newlines to spaces for the command line
# -R: Remove
# -n: Nosave (don't save backup configuration files)
# -s: Recursive (remove dependencies of the target that are also unneeded)
echo "Removing the following packages:"
echo "$selected_packages"
sudo pacman -Rns $selected_packages
