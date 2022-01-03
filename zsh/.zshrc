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

# >> Completion
source $ZDOTDIR/zcomp.zsh	# zcomp loads compinit with other options

zstyle ':completion:*' completer _extensions _complete _approximate

autoload -U zmv
