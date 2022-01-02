# -------- ZSH options 
# If you actually need any of them in non-interactive shells, 
# transfer them to .zshenv.

# >> Changing Directories
setopt AUTO_CD 			# makes explicit use of 'cd' unnecessary 
setopt AUTO_PUSHD		# pushes the old directory into the stack
setopt PUSHD_TO_HOME		# pushd without arguments sends to home

# >> Completion
setopt GLOB_COMPLETE		# completion for glob patterns 
setopt MENU_COMPLETE		# start menu complete on first Tab key

# >> History
setopt HIST_FIND_NO_DUPS	# ignore duplicates on hist search
setopt HIST_IGNORE_SPACE	# space-starting commands won't go into hist
setopt HIST_REDUCE_BLANKS	# remove superfluous blanks from command


# -------- End of ZSH options 

# -------- Modules
autoload -U compinit; 	compinit
autoload -U zmv
