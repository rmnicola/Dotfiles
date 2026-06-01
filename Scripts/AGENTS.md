# AGENTS.md — Scripts Development

This directory lives inside the Dotfiles monorepo. Scripts are in `~/Documents/Dotfiles/Scripts/`.

## Overview

- **Language**: Bash
- **Package Manager**: pacman/yay
- **TUI Framework**: gum (for interactive prompts — all scripts must also support non-interactive flags)
- **Runtime**: All scripts assume they run from within this directory

## Script Conventions

### Required: Non-Interactive Mode

Every script that uses `gum` for prompts MUST provide a non-interactive fallback for agent execution:

| Flag | Behavior |
|------|----------|
| `--auto` | Skip all prompts, use defaults |
| `--all` | Select/install everything |
| `--section X` | Filter to a specific section |
| `--exclude X` | Skip a section |

Example pattern:
```bash
AUTO_MODE=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --auto) AUTO_MODE=true ;;
        -h|--help) usage ;;
    esac
    shift
done

if [[ "$AUTO_MODE" == "true" ]]; then
    # Skip interactive prompts
else
    # Use gum for TUI interaction
fi
```

### Required: Idempotency

All scripts must be safe to run multiple times:

- Package installs: use `--needed` flag
- File operations: check before writing, backup before overwriting
- Symlinks: verify target before creating, skip if already correct
- System services: use `enable` (idempotent), add `|| true` for stop/disable
- Config lines: use `grep -qxF` before appending

### Naming Conventions

- **Scripts**: `rn-<feature>.sh` (e.g., `rn-install-packages.sh`)
- **Functions**: `snake_case`
- **Variables**: `snake_case` for locals, `UPPER_SNAKE_CASE` for constants
- **Booleans**: meaningful prefixes (e.g., `AUTO_MODE=true`, `is_section_allowed`)

### ShellCheck Compliance

```bash
shellcheck rn-*.sh
```

- Use `[[ ]]` instead of `[ ]`
- Always quote variables: `"$var"` not `$var`
- Use `local` for function variables
- Use `$(command)` not backticks

### Formatting

- 4 spaces for indentation
- Max 100 characters per line
- Blank lines between logical sections

## Scripts Reference

| Script | Purpose | Non-interactive |
|--------|---------|-----------------|
| `rn-install-packages.sh` | Install packages from `packages.txt` | `--all`, `--section`, `--exclude` |
| `rn-install-rust.sh` | Rust toolchain with nightly | Already non-interactive |
| `rn-install-dotfiles.sh` | Clone & symlink dotfiles | `--auto`, `--repo` |
| `rn-configure-zsh.sh` | Zsh + XDG env vars | Already non-interactive |
| `rn-configure-git.sh` | Git user, SSH signing | Interactive only (user-specific) |
| `rn-configure-tlp.sh` | TLP power management | Already non-interactive |
| `rn-generate-ssh-key.sh` | Generate SSH keys | Interactive only (user-specific) |
| `rn-install-keyd.sh` | Install keyd config to /etc | Interactive (confirm restart) |
| `rn-omarchy-setup.sh` | TUI wizard orchestrator | `--all --no-reboot` |
| `run-this.sh` | Symlink all scripts to `~/.local/bin/` | Already non-interactive |

## Utility Scripts

| Script | Purpose |
|--------|---------|
| `rn-open-presentation.sh` | Create/edit Typst presentations |
| `rn-view-presentation.sh` | Present Typst PDF with evince |
| `rn-delete-presentation.sh` | Delete presentations |
| `rn-project-launcher.sh` | Launch projects |
| `rn-project-cleanup.sh` | Project cleanup utilities |
| `rn-project-deleter.sh` | Delete projects |
| `rn-news-reader.sh` | RSS reader launcher |
| `rn-tlp-menu.sh` | TLP mode switcher |
| `rn-focus-mainterm.sh` | Focus main terminal |
| `rn-omarchy-setup.sh` | Omarchy configuration hooks |
| `rn-opencode-theme-hook.sh` | Opencode theme integration |
| `rn-presenterm-theme-hook.sh` | Presenterm theme integration |
| `rn-zellij-theme-hook.sh` | Zellij theme integration |
| `rn-remove-orphans.sh` | Remove orphaned packages |

## Dependencies

Required (must be installed before most scripts):
- `gum` — TUI styling and interaction
- `yay` — AUR package manager
- `git`

Install with: `./rn-install-packages.sh --section "Depend" --all`

## No Build/Lint/Test Suite

This is a collection of standalone shell scripts with no:
- Build process
- Test suite
- Linting infrastructure (run `shellcheck` manually)
