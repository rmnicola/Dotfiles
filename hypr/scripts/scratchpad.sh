#!/bin/zsh

# Set default names for the class and the workspace
CLASS_NAME="com.mainpad"
WORKSPACE_NAME="main"
CMD=""

# If --alt is passed, use the alternative names
if [[ "$1" == "--alt" ]]; then
    CLASS_NAME="com.altpad"
    WORKSPACE_NAME="alt"
elif [[ "$1" == "--zk" ]]; then
    CLASS_NAME="com.zkpad"
    WORKSPACE_NAME="zk"
    CMD="zk z"
fi

# Check if a window with the specific class already exists anywhere
if hyprctl clients | grep -q "class: $CLASS_NAME"; then
    hyprctl dispatch togglespecialworkspace $WORKSPACE_NAME
else
    hyprctl dispatch exec "[workspace special:$WORKSPACE_NAME] \
      ghostty \
      --class=$CLASS_NAME \
      --command='$CMD'"
fi
