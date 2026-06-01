#!/bin/bash
# ==========================================
# Dynamically generate zsh completions for
# all rn-* scripts by extracting flags from
# their source code.
# ==========================================

# Must be sourced into zsh, not executed directly.
# Usage in .zshrc or zsh config:
#   if command -v rn-generate-completions &>/dev/null; then
#     eval "$(rn-generate-completions)"
#   fi

cat <<'END_COMP'
_rn_scripts() {
    local cmd script flags
    cmd="$words[1]"
    script=$(command -v "$cmd" 2>/dev/null)
    [[ -z "$script" ]] && return 1

    flags=(${(f)"$(grep -oP '^\s*(--?[a-zA-Z][a-zA-Z0-9-]*)\)' "$script" \
        | sed 's/)//' | sed 's/^[[:space:]]*//' | sort -u)"})

    if (( ${#flags} )); then
        _arguments -s "${flags[@]}"
    fi
}

compdef _rn_scripts rn-*
END_COMP
