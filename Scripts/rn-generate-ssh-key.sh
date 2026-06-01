#!/bin/bash

if [[ ! -x $(which figlet) ]]; then
    sudo pacman -S --noconfirm figlet
    exit 1
fi

if [[ ! -x $(which gum) ]]; then
    sudo pacman -S --noconfirm gum
    exit 1
fi

gum style \
	--border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
  --foreground "#9e53bc" \
  "$(figlet SSH)" \
  "$(figlet Keygen)"

gum style --foreground "#9e53bc" "Enter the name for your ssh key:"
SSH_KEY_NAME=$(gum input --placeholder "Default: id_rsa")

# If user simply pressed Enter, use the default path
if [ -z "${SSH_KEY_NAME}" ]; then
    SSH_KEY_NAME="id_rsa"
fi

SSH_KEY_PATH="$HOME/.ssh/$SSH_KEY_NAME"

# Generate the SSH Key
ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH"

# Get the public key path
SSH_KEY_PUB="${SSH_KEY_PATH}.pub"

wl-copy < "${SSH_KEY_PUB}"
echo "SSH public key copied to clipboard!"
chromium https://github.com/settings/keys https://gitlab.com/-/profile/keys
