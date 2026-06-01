# AGENTS.md

Instructions for AI coding agents (Opencode, Cursor, Copilot) operating in this repository.

## System Setup Sequence

When asked to set up a new system from this repo, execute the scripts in this exact order. All scripts are in `Scripts/` and must be run from that directory.

### Prerequisites

- Arch Linux with `sudo` access
- Internet connection
- `git` installed (`sudo pacman -S --noconfirm git` if missing)

### Step 1: System Dependencies

```sh
cd ~/Documents/Dotfiles/Scripts
chmod +x *.sh
./rn-install-packages.sh --section "Depend" --all
```

Installs: gum, yay, base-devel, and other build tools. Uses `--all` for non-interactive mode.

**Verification:** `command -v gum && command -v yay`

### Step 2: Rust Toolchain

```sh
./rn-install-rust.sh
```

Removes any pacman-installed rust, installs rustup, and sets nightly as default. Fully non-interactive.

**Verification:** `rustc --version`

### Step 3: User Packages

```sh
./rn-install-packages.sh --exclude "Depend"
```

By default runs interactively (gum choose). For fully unattended install:

```sh
./rn-install-packages.sh --exclude "Depend" --all
```

Installs everything from `packages.txt` except the "Depend" section already done in step 1.

**Verification:** `yay -Q <package-name>` for spot checks.

### Step 4: Dotfiles (Symlink Configs)

```sh
./rn-install-dotfiles.sh --auto
```

Clones/pulls this repo to `~/Documents/Dotfiles` and symlinks all config directories to `~/.config/`. The `--auto` flag:
- Uses default repo `rnicola/Dotfiles`
- Auto-pulls if directory already exists
- Links all configs without prompting
- Skips `Scripts/` and `keyd/` (they are not dotfile configs)
- Skips symlinks that already point to the correct target (idempotent)

**Verification:** `ls -la ~/.config/` — look for symlinks to `~/Documents/Dotfiles/`.

### Step 5: Zsh Configuration

```sh
./rn-configure-zsh.sh
```

Installs zsh if missing, sets it as default shell, writes XDG environment variables to `/etc/zsh/zshenv`. Fully non-interactive and idempotent.

**Verification:** `echo $SHELL` should show `/usr/bin/zsh` after relogin.

### Step 6: TLP Power Management

```sh
./rn-configure-tlp.sh
```

Replaces power-profiles-daemon with TLP. Enables and starts services. Configures passwordless sudo for TLP. Requires sudo. Idempotent.

**Verification:** `sudo systemctl status tlp`

### Step 7: SSH Key Generation

```sh
./rn-generate-ssh-key.sh
```

INTERACTIVE — requires user input for key name. Generates RSA 4096-bit key, copies public key to clipboard, opens browser for GitHub/GitLab. An agent should either:
- Ask the user for a key name first, or
- Skip this step and let the user run it manually

### Step 8: Git Configuration

```sh
./rn-configure-git.sh
```

INTERACTIVE — requires user name and email. Sets git user.name, user.email, core.editor, and SSH signing. An agent should either:
- Ask the user for name/email first, or
- Skip this step and let the user run it manually

### Step 9: Reboot

```sh
sudo reboot
```

---

## Script Reference (Non-Interactive Flags)

| Script | Non-interactive flags |
|--------|----------------------|
| `rn-install-packages.sh` | `--all` (install all), `--section X` (filter), `--exclude X` (skip) |
| `rn-install-dotfiles.sh` | `--auto` (link all, no prompts), `--repo USER/REPO` |
| `rn-install-rust.sh` | Already non-interactive |
| `rn-configure-zsh.sh` | Already non-interactive |
| `rn-configure-tlp.sh` | Already non-interactive |
| `rn-omarchy-setup.sh` | `--all --no-reboot` (run unattended setup; skips interactive Git/SSH and Cleaner) |
| `rn-install-keyd.sh` | `--auto` (install config and restart service without prompt) |
| `rn-configure-git.sh` | Interactive only (needs name/email) |
| `rn-generate-ssh-key.sh` | Interactive only (needs key name) |

## Safety Notes

- All scripts are **idempotent** — safe to run multiple times.
- Scripts requiring sudo: `rn-configure-zsh.sh`, `rn-configure-tlp.sh`, `rn-install-keyd.sh`
- `rn-install-packages.sh` uses `yay -S --needed` — won't reinstall existing packages.
- `rn-install-dotfiles.sh` backs up existing configs with `.backup.<timestamp>` before overwriting.
- `rn-configure-tlp.sh` removes `power-profiles-daemon` (systemd service change).
- Never run these scripts with `sudo` unless explicitly noted (most use `sudo` internally where needed).

## Idempotency Guarantees

- **Symlinks**: Checked before creation — skip if already pointing to correct target.
- **Package installs**: All use `--needed` flag (pacman/yay).
- **Shell config**: Lines checked with `grep -qxF` before appending to `/etc/zsh/zshenv`.
- **System services**: Use `systemctl enable` (idempotent) and `|| true` for stop/disable.
- **File operations**: Backup with timestamp before overwriting.

## Code Style (for contributors)

See per-tool sections below for language-specific guidelines.

### General Principles

- **Modularity:** Keep configurations separated by tool (e.g., `hypr/`, `nvim/`, `zsh/`).
- **Omarchy Integration:** Respect the Omarchy structure. Do not edit files in `~/.local/share/omarchy/`. Put all overrides here.
- **Documentation:** Use comments to explain *why*, not *what*.

### Lua (Neovim)

- **Indentation:** 2 spaces (configured in `stylua.toml`).
- **Column Width:** 120 characters.
- **Naming:** `snake_case`.
- **Imports:** Use `require("config.options")` assuming `lua/` is the root.
- **Structure:** `lua/config/` for core settings, `lua/plugins/` for plugin configs.
- **Error Handling:** Wrap optional plugin setup in `pcall`.

### Shell (Zsh/Bash)

- **Indentation:** 2 spaces.
- **Environment:** Check if command exists before using it:
  ```bash
  if command -v tool_name &> /dev/null; then
    eval "$(tool_name init zsh)"
  fi
  ```
- **Function Naming:** `snake_case`.
- **Variable Naming:** `UPPER_CASE` for exported/env vars, `lower_case` for locals.

### Hyprland (`.conf`)

- **Variables:** Use `$` prefix (e.g., `$music`).
- **Sections:** Group related settings.
- **Special Workspaces:** Follow established patterns for webapps and TUIs.

### JSON / TOML / KDL

- **Indentation:** 2 spaces.
- **Consistency:** Maintain existing formatting patterns.

## Omarchy Integration

- `omarchy/hooks/`: Executable scripts triggered by system events (e.g., `theme-set`).
- `omarchy/current/`: Symlinks to the active theme/background.
- `omarchy/backgrounds/`: Organized by theme names.

When adding a new tool that should support theme switching:
1. Create a hook in `omarchy/hooks/`.
2. Prefix theme hooks with `rn-`.
3. Ensure the hook handles the theme name passed as the first argument.

## Tool-Specific Notes

### Neovim

- **Format:** `stylua nvim/`
- **Lint:** `nvim --headless -c "lua require('lint').try_lint()" -c "qa"`
- **Reload config:** `:source $MYVIMRC` inside nvim

### Hyprland

- **Reload:** `hyprctl reload`
- **Check errors:** `hyprctl msg geterror`

### Zsh

- **Syntax check:** `zsh -n path/to/script.zsh`
- **Reload:** `exec zsh`

### Waybar

- **Reload CSS:** `pkill -USR2 waybar`

### Zellij

- Config in KDL format at `zellij/config.kdl`.

### Opencode

- Config at `opencode/opencode.json`.
- Schema: `https://opencode.ai/config.json`.

---

## ⚠️ Safety Protocols

- **Never update git config** unless explicitly requested.
- **Never push --force** to main.
- **Avoid git commit --amend** unless conditions are met.
- **Secrets:** Do not commit API keys or personal tokens. Use environment variables.
