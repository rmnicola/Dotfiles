#! /bin/bash

if ! command -v figlet &> /dev/null; then
    sudo pacman -S --needed --noconfirm figlet
fi

if ! command -v gum &> /dev/null; then
    echo "This script uses Gum. Installing..."
    sudo pacman -S --needed --noconfirm gum
fi

gum style \
	--border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
  --foreground "#9e53bc" \
  "$(figlet Git)" \
  "$(figlet Config.)"

NAME=$(gum input --placeholder "Type your full name")
if [[ -z "$NAME" ]]; then
    gum log --level error "Git user.name cannot be empty."
    exit 1
fi
git config --global user.name "$NAME"

EMAIL=$(gum input --placeholder "Type your email address")
if [[ -z "$EMAIL" ]]; then
    gum log --level error "Git user.email cannot be empty."
    exit 1
fi
git config --global user.email "$EMAIL"

gum style --foreground "#9e53bc" "Choose your commit editor:"
COMMIT_EDITOR=$(gum choose "Neovim" "Vscode" "Nano")
case $COMMIT_EDITOR in
    "Neovim")
        git config --global core.editor "nvim"
        ;;
    "Vscode")
        git config --global core.editor "code"
        ;;
    "Nano")
        git config --global core.editor "nano"
        ;;
esac

gum confirm "Do you want to configure your ssh signing keys?"
if [[ $? -eq 0 ]]; then
    mapfile -t PUBLIC_KEYS < <(find "$HOME/.ssh" -maxdepth 1 -type f -name '*.pub' -printf '%f\n' 2>/dev/null | sort)
    if [[ ${#PUBLIC_KEYS[@]} -gt 0 ]]; then
        echo "There are ${#PUBLIC_KEYS[@]} keys available to choose from. Choose:"
        PUB_KEY="$HOME/.ssh/$(gum choose "${PUBLIC_KEYS[@]}")"
        echo "Configuring git to use SSH key for signing commits..."
        git config --global gpg.format ssh
        echo "Setting user.signingkey to $PUB_KEY"
        git config --global user.signingkey "$PUB_KEY"
        echo "Enabling commit.gpgsign..."
        git config --global commit.gpgsign true
        echo "Configuring git to use SSH for GitHub repositories..."
        git config --global url."git@github.com:".insteadOf "https://github.com/"
        echo "Git configuration completed!"
    else
        gum log --level error "No SSH public keys found in ~/.ssh. Generate one first."
    fi
fi
