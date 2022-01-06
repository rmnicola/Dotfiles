# -------- Options 
#
# If you actually need any of them in non-interactive shells, 
# transfer them to .zshenv.

# >> Changing Directories
setopt AUTO_CD 			# makes explicit use of 'cd' unnecessary 
setopt AUTO_PUSHD		# pushes the old directory into the stack
setopt PUSHD_TO_HOME		# pushd without arguments sends to home
setopt PUSHD_IGNORE_DUPS	# ignore duplicates on pushd

# >> Completion
setopt GLOB_COMPLETE		# completion for glob patterns 
setopt COMPLETE_ALIASES		# treat aliases as distinct commands 

# >> History
setopt HIST_FIND_NO_DUPS	# ignore duplicates on hist search
setopt HIST_IGNORE_SPACE	# space-starting commands won't go into hist
setopt HIST_REDUCE_BLANKS	# remove superfluous blanks from command
setopt HIST_EXPIRE_DUPS_FIRST	# remove duplicates first when hist is full
setopt INC_APPEND_HISTORY	# commands are saved as soon as they run
setopt SHARE_HISTORY		# share history between instances of zsh

# >> Others
setopt NO_BEEP			# fuck beeps. No, seriously. Fuck them
setopt CORRECT			# offer to correct mistyped commands

# -------- End of Options 
#
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
# *** SEE END OF ZSHRC, IT IS SOURCE THERE ***

# >> Zsh completions by zsh-users (git submodule)
# Add every completion to fpath
fpath=($ZDOTDIR/modules/zsh-completions/src $fpath)

# >> Edit command line from zshcontrib
autoload -U edit-command-line

# >> Cursor_mode by Matthieu Cneude
# https://github.com/Phantas0s/.dotfiles
autoload -U cursor_mode; cursor_mode	# change cursor beam for insert/normal

# >> Git it on by Peter Wildeford 
# https://github.com/peterhurford/git-it-on.zsh
autoload -U gitit 		# interact with remote repo on your browser

# >> Gnome Backup Utilities by Me =)
autoload -U gbkp; gbkp

# >> Firefox Backup Utilities by Me =)
autoload -U fbkp; fbkp

# -------- End of Modules
#
# -------- Aliases

source $ZDOTDIR/zaliases.zsh

# -------- End of Aliases
#
# -------- Misc
#
# >> Vi mode shenanigans
# Add support for vi mode (unnecessary if vim is your default editor)
bindkey -v
# Faster, please...
export KEYTIMEOUT=1
# When in normal mode, bind the 'v' key to edit command in vim 
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# >> Better history search
# Bind keys to search in history for commands that start like the one you're
# typying at the moment
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^k" history-beginning-search-backward-end
bindkey "^j" history-beginning-search-forward-end

# >> Sourcing syntax-highlighting
source $ZDOTDIR/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
