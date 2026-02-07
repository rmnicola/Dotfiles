# Personal Dotfiles

This repository contains my personal configuration files for a Linux environment centered around **Hyprland**. It is a monorepo that manages configurations for my shell, window manager, editor, and various terminal utilities.

## 📦 Contents

### System & UI
- **Hyprland:** My primary Window Manager configuration. It features a highly customized setup with "special workspaces" dedicated to specific workflows (AI, Music, Docker, Calendars) and integrates with the **Omarchy** framework.
- **Waybar:** Status bar configuration with custom CSS styling for a clean, flat aesthetic.
- **Walker:** Application launcher and command runner.

### Terminal & Shell
- **Shell:** **Zsh** setup that includes:
  - **Zoxide** for directory navigation.
  - **FZF** for fuzzy finding.
  - **FNM** for Node.js version management.
  - **Starship** for a fast, customizable shell prompt.
- **Terminals:**
  - **Ghostty:** My primary terminal emulator.
  - **Alacritty:** Secondary/Fallback terminal configuration.
- **Zellij:** Terminal multiplexer with custom keybindings and layouts.

### Editor & Tools
- **Neovim:** A comprehensive Lua-based configuration utilizing `lazy.nvim` for package management and `stylua` for formatting.
- **Zk:** Configuration for `zk`, a plain text note-taking tool based on the Zettelkasten method.
- **Presenterm:** Configuration for terminal-based presentations.

## ⚙️ Structure

This configuration is built on top of the **Omarchy** framework.
- **Defaults:** The core system defaults are sourced from `~/.local/share/omarchy/`.
- **User Config:** The files in this repository represent my personal overrides and custom modules, which are mapped to their respective locations in `~/.config/`.
