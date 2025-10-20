#!/bin/bash

# A unique class for the zk scratchpad window
ZK_CLASS="altscratch"

# Check if a window with this class is already open
if hyprctl clients | grep -q "class: $ZK_CLASS"; then
    # If it exists, just toggle the named special workspace "zk"
    hyprctl dispatch togglespecialworkspace zk
else
    # If not, launch zk in a new terminal within the "zk" special workspace
    hyprctl dispatch exec "[workspace special:zk] alacritty --class $ZK_CLASS -e bash -ic 'zk edit --interactive; exec bash'"
fi
