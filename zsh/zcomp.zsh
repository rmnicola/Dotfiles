# -------- Completion

# >> Loading the required modules
zmodload zsh/complist

# >> Optimize Initialization
# Only run compinit if it hasn't been run yet.
# The -C flag skips security checks on cached files (Speed boost!)
if ! type compdef > /dev/null; then
  autoload -Uz compinit
  compinit -C
fi

# Compile the completion dump file for faster loading
# This runs in the background and only recompiles when the dump file changes
if [[ -s "$HOME/.zcompdump" && (! -s "${HOME}/.zcompdump.zwc" || "$HOME/.zcompdump" -nt "${HOME}/.zcompdump.zwc") ]]; then
  zcompile "$HOME/.zcompdump"
fi

# >> Completion options
_comp_options+=(globdots)

# >> Useful zstyles
zstyle ':completion:*' menu select

# >> Menu navigation
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# >> Zstyles
# Define the completers used for every completion
zstyle ':completion:*' completer _extensions _complete _approximate

# Use cache for every completion
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

# Sort file completions by last modification
zstyle ':completion:*' file-sort modification

# Grouping completions
zstyle ':completion:*' group-name ''

# Colorful menu select
zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}

# Color groups
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'
