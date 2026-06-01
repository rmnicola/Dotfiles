# Dotfiles

Personal dotfiles & system setup scripts for Arch Linux (Omarchy + Hyprland).

## Quick Start (TUI Wizard)

The wizard orchestrates the entire setup interactively.

```sh
git clone https://github.com/rnicola/Dotfiles ~/Documents/Dotfiles
cd ~/Documents/Dotfiles/Scripts
chmod +x *.sh
./rn-omarchy-setup.sh
```

Select the steps you want and follow the prompts.

## Manual Setup (Step by Step)

Run each script individually from inside `Scripts/`:

| # | Script | What it does |
|---|--------|--------------|
| 1 | `./rn-install-packages.sh -s Depend -a` | System dependencies (gum, yay, git, etc.) |
| 2 | `./rn-install-rust.sh` | Rust toolchain (rustup + nightly) |
| 3 | `./rn-install-packages.sh -e Depend` | All user packages (interactive selection) |
| 4 | `./rn-install-dotfiles.sh` | Clone & symlink configs to `~/.config/` |
| 5 | `./rn-configure-zsh.sh` | Default shell + XDG env vars |
| 6 | `./rn-configure-tlp.sh` | TLP power management |
| 7 | `./rn-generate-ssh-key.sh` | Generate SSH key for GitHub/GitLab |
| 8 | `./rn-configure-git.sh` | Git user, signing keys, editor |

Run `./rn-omarchy-setup.sh --all --no-reboot` for a fully unattended setup.

## Agent-Based Setup (OpenCode / CLI agents)

You can have an AI agent (like OpenCode) set up your system by having it read `AGENTS.md` at the repo root. That file contains everything the agent needs: script sequence, flags, preconditions, and safety notes.

Just point the agent at this repo and say: "read AGENTS.md and set up my system."

The agent will run the functional scripts directly (not the TUI wizard), passing the appropriate `--auto` / `--all` flags to skip interactive prompts.

**Steps that still need you:** git user name/email (step 8) and SSH key generation (step 7) are inherently personal — the agent will ask you or skip them.

## Structure

```
Dotfiles/
├── Scripts/        # All setup & utility scripts
├── nvim/           # Neovim config (symlink to ~/.config/nvim)
├── zsh/            # Zsh config (symlink to ~/.config/zsh)
├── zellij/         # Zellij config
├── hypr/           # Hyprland config
├── waybar/         # Waybar config
├── walker/         # Walker config
├── alacritty/      # Alacritty config
├── opencode/       # Opencode config
├── omarchy/        # Omarchy hooks & themes
├── starship/       # Starship prompt config
├── eilmeldung/     # RSS reader config
├── zk/             # Zettelkasten config
├── keyd/           # Keyd config (system-level, use rn-install-keyd.sh)
└── ghostty/        # Ghostty terminal config
```

## Requirements

- Arch Linux with sudo access
- Internet connection
