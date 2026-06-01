#! /bin/bash

if [[ ! -x $(which figlet) ]]; then
    sudo pacman -S --noconfirm figlet
    exit 1
fi

if [[ ! -x $(which gum) ]]; then
    echo "This script uses Gum. Install it before continuing..."
    sudo pacman -S --noconfirm gum
    exit 1
fi

gum style \
	--border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
  --foreground "#9e53bc" \
  "$(figlet Git)" \
  "$(figlet Config.)"

NAME=$(gum input --placeholder "Type your full name")
git config --global user.name "$NAME"

EMAIL=$(gum input --placeholder "Type your email address")
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
    PUBLIC_KEYS=$(ls "$HOME/.ssh" | grep pub | wc -l)
    if [[ $PUBLIC_KEYS -gt 0 ]]; then
        echo "There are $PUBLIC_KEYS keys available to choose from. Choose:"
        PUB_KEY="$HOME/.ssh/$(ls "$HOME/.ssh" | grep pub | gum choose)"
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
        gum -sl error "You didn't setup any ssh keys, idiot! Go do that!"
    fi
fi
