#!/usr/bin/zsh

# Grab script dir
SCRIPT_DIR=/home/$SUDO_USER/bin

# Require sudo
source $SCRIPT_DIR/require-sudo.sh

echo ">> Creating symlink to zsh config folder."
deescalate_user ln -sfvT $HOME/Dotfiles/zsh $ZDOTDIR
check_operation Zsh symlink creation

echo ">> Creating symlink to firefox custom launcher folder."
ln -sfvT /home/$SUDO_USER/Dotfiles/firefox/firefox-mod.desktop \
  /usr/share/applications/firefox-mod.desktop
check_operation Firefox symlink creation
