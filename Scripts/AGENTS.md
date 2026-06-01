# AGENTS.md - Development Guidelines for Scripts Repository

This repository contains shell scripts for system configuration and dotfiles management on Arch Linux/Omarchy.

## Overview

- **Language**: Bash scripts
- **Package Manager**: pacman/yay
- **Dependencies**: gum (CLI styling), rustup, fnm, go

## Running Scripts

```bash
# Make executable and run any script
chmod +x rn-*.sh
./rn-<script-name>.sh

# Run in auto mode (non-interactive) where supported
./rn-install-packages.sh --all
./rn-install-packages.sh --section "System"
./rn-install-packages.sh --exclude "TUI Applications"
```

## Scripts Reference

| Script | Purpose |
|--------|---------|
| `rn-install-packages.sh` | Install packages from packages.txt (interactive or auto mode) |
| `rn-install-rust.sh` | Configure Rust toolchain with nightly |
| `rn-install-dotfiles.sh` | Install dotfiles from repository |
| `rn-configure-zsh.sh` | Configure Zsh with Oh My Zsh |
| `rn-configure-git.sh` | Configure Git user and SSH keys |
| `rn-configure-tlp.sh` | Configure TLP power management |
| `rn-omarchy-setup.sh` | Full Omarchy system setup |
| `rn-open-presentation.sh` | Create/edit Typst presentations (copies .inteli-template) |
| `rn-view-presentation.sh` | Present Typst PDF with evince in fullscreen |
| `rn-delete-presentation.sh` | Delete presentations |
| `rn-project-*.sh` | Various project management utilities |

## No Build/Lint/Test Commands

This is a collection of standalone shell scripts with no:
- Build process
- Test suite
- Linting infrastructure

## Code Style Guidelines

### File Structure

```bash
#!/bin/bash

# ==========================================
# Section: Description
# ==========================================

# Constants at top
CONSTANT="value"

# Functions (alphabetical order preferred)
function_name() {
    local var="$1"
    # body
}

# Main execution
main() {
    # ...
}

main "$@"
```

### Naming Conventions

- **Scripts**: `rn-<feature>.sh` (e.g., `rn-install-packages.sh`)
- **Functions**: `snake_case` (e.g., `show_header`, `perform_installation`)
- **Variables**: `snake_case` with meaningful names (e.g., `TARGET_FILE`, `current_sect`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MODE="interactive"`)
- **Booleans**: Use meaningful prefixes (e.g., `capture=true`, `is_section_allowed`)

### ShellCheck Compliance

All scripts should pass ShellCheck:

```bash
shellcheck rn-*.sh
```

Common rules:
- Use `[[ ]]` instead of `[ ]` for tests
- Always quote variables: `"$var"` not `$var`
- Use `local` for function variables
- Use `function` keyword or `()` for function definitions (pick one)

### Formatting

- Use 4 spaces for indentation
- Maximum line width: 100 characters
- Use blank lines to separate logical sections
- Add spaces around `=` in variable assignments: `VAR="value"` not `VAR="value"`

### Error Handling

```bash
# Exit on any error
set -e
set -o pipefail

# Check required commands
if ! command -v gum &> /dev/null; then
    echo "Error: gum is not installed."
    exit 1
fi

# Check file exists
if [[ ! -f "$TARGET_FILE" ]]; then
    echo "Error: File not found: $TARGET_FILE"
    exit 1
fi

# Use gum for user output (consistent styling)
gum log --level error "Failed to install"
gum log --level warn "Warning message"
gum log --level info "Information"
```

### Input Handling

- Use `while [[ "$#" -gt 0 ]]` for argument parsing
- Support both short (`-s`) and long (`--section`) flags
- Provide usage/help: `if [[ "$1" == "-h" || "$1" == "--help" ]]`

### String Operations

- Use `[[ "$var" == *"pattern"* ]]` for substring matching
- Use parameter expansion: `${var%%pattern}`, `${var##pattern}`
- Use `$(command)` for command substitution (not backticks)

### Arrays

- Use `()` for array declaration: `arr=("one" "two" "three")`
- Use `+=()` to append: `arr+=("four")`
- Use `mapfile` or `read -a` for file-to-array conversion

### UI/Output

Use `gum` for consistent TUI output:
- `gum style` for headers and formatting
- `gum log` for messages with levels
- `gum spin` for loading spinners
- `gum choose` for interactive selection
- `gum confirm` for yes/no prompts

### Comments

- Use section headers: `# ==========================================`
- Comment complex logic only
- Keep comments brief and meaningful

### Gitignore

No specific gitignore needed for this repository. Scripts are intended to be run directly.

## Common Patterns

### Script Template

```bash
#!/bin/bash

set -e
set -o pipefail

CONSTANT="value"

usage() {
    echo "Usage: $0 [-h] [-s|--section SECTION]"
    exit 0
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -h|--help) usage ;;
            -s|--section) TARGET="$2"; shift ;;
            *) echo "Unknown: $1"; exit 1 ;;
        esac
        shift
    done
    
    # Implementation
}

main "$@"
```

### Progress Display

```bash
local percentage=$(( (current * 100) / total ))
local filled=$(( percentage / 5 ))
printf "Progress: "
printf '\033[92m█%.0s\033[0m' $(seq 1 $filled)
printf '\033[90m░%.0s\033[0m' $(seq 1 $empty)
printf " %d%% (%d/%d)\n" "$percentage" "$current" "$total"
```

## Dependencies

Required tools that must be available:
- `gum` - TUI styling and interaction
- `yay` - AUR package manager
- `walker` - dmenu-style interactive picker
- `typst` - Typst document compiler
- `evince` - PDF viewer with presentation mode
- Standard utilities: `sed`, `awk`, `xargs`, `readlink`

Optional but commonly used:
- `rustup` - Rust toolchain manager
- `fnm` - Fast Node.js version manager
- `micromamba` - Conda alternative
- `zellij` - Terminal multiplexer
- `ghostty` / `kitty` - Terminal emulators

## Best Practices

1. **Idempotency**: Scripts should be safe to run multiple times
2. **Fail Fast**: Exit immediately on errors with `set -e`
3. **Clean Up**: Handle interruptions gracefully
4. **Dependencies First**: Check required tools before proceeding
5. **User Feedback**: Always show progress and status
6. **No Secrets**: Never hardcode passwords or API keys
7. **Portability**: Use bash built-ins over external commands when possible
