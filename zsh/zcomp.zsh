# -------- Completion
#
# This file contains further options for zsh completion and it is kept
# on a separate file to keep zshrc unbloated.

# >> Loading the required modules

zmodload zsh/complist			# listing extensions
autoload -U compinit; compinit		# base completion module

# >> Completion options

_comp_options+=(globdots)	 	# completion includes hidden files

# >> Useful zstyles

zstyle ':completion:*' menu select	# enables menu select

# >> Menu navigation
# -- Enables the use of vim keybindings to navigate menu selection options.

bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# >> Zstyles
# -- Zstyles are used to modify module behaviors
# -- Pattern => :completion:<function>:<completer>:<command>:<argument>:<tag>

# Define the completers used for every completion
zstyle ':completion:*' completer _extensions _complete _approximate

# Use cache for every completion
zstyle ':completion:*' use-cache on

# Defines where to look for cache 
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

# Sort file completions by last modification
zstyle ':completion:*' file-sort modification

# Grouping completions
zstyle ':completion:*' group-name ''

# Colorful menu select
zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}

# Color groups
zstyle ':completion:*:*:*:*:corrections' \
format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:descriptions' \
format '%F{blue}-- %D %d --%f'
zstyle ':completion:*:*:*:*:messages' \
format ' %F{purple} -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' \
format ' %F{red}-- no matches found --%f'
