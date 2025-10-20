# -------- Modules
#
# Modules used range from default ones to ones made by third parties
# as well as (some) made by me

# Add modules subfolder to fpath
fpath=($ZDOTDIR/modules $fpath)

# >> Completion
source $ZDOTDIR/zcomp.zsh	# zcomp loads compinit with other options

# >> Zmove is awesome
autoload -U zmv			# zmv lets you easily rename files

# >> History search end
autoload -U history-search-end 	# go straight to the end of history line

# >> Zsh syntax highlighting by zsh-users (git submodule)
source $ZDOTDIR/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# >> Zsh completions by zsh-users (git submodule)
# Add every completion to fpath
fpath=($ZDOTDIR/modules/zsh-completions/src $fpath)

# >> Edit command line from zshcontrib
autoload -U edit-command-line
