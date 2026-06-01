#!/bin/bash

# 1. Get the theme name from Omarchy (passed as argument)
NEW_THEME="$1"

# 2. Map Omarchy themes -> Zellij themes
case "$NEW_THEME" in
    # --- Direct & Near Matches ---
    "catppuccin")       ZELLIJ_THEME="catppuccin-macchiato" ;;
    "catppuccin-latte") ZELLIJ_THEME="catppuccin-latte" ;;
    "everforest")       ZELLIJ_THEME="everforest-dark" ;;
    "gruvbox")          ZELLIJ_THEME="gruvbox-dark" ;;
    "kanagawa")         ZELLIJ_THEME="kanagawa" ;;
    "nord")             ZELLIJ_THEME="nord" ;;
    "tokyo-night")      ZELLIJ_THEME="tokyo-night" ;;

    # --- Aesthetic Mappings ---
    
    # "Hackerman" -> Cyberpunk/Neon
    "hackerman")        ZELLIJ_THEME="cyber-noir" ;;

    # "Matte Black" -> High contrast/Monochrome
    "matte-black")      ZELLIJ_THEME="vesper" ;;

    # "Flexoki Light" -> Warm/Ink Light
    "flexoki-light")    ZELLIJ_THEME="gruvbox-light" ;;

    # "Rose Pine" -> Warm/Rosy -> Dracula preserves the purple/pink hue best.
    "rose-pine")        ZELLIJ_THEME="dracula" ;;

    # "Ristretto" -> Monokai Pro Ristretto (vibrant/warm) -> Ayu Dark matches the richness
    "ristretto")        ZELLIJ_THEME="ayu-dark" ;;

    # "Ethereal" -> Dreamy/Dark -> Tokyo Night Storm (lighter dark/blue)
    "ethereal")         ZELLIJ_THEME="tokyo-night-storm" ;;

    # "Osaka Jade" -> Lush tropical jade/green -> Everforest Dark (green/nature)
    "osaka-jade")       ZELLIJ_THEME="everforest-dark" ;;

    # --- New Themes ---
    
    # "Lumon" -> Cold blue/oceanic, serene -> Iceberg Dark (cool blue tones)
    "lumon")            ZELLIJ_THEME="iceberg-dark" ;;

    # "Miasma" -> Dusty earthy wasteland (olive/terracotta) -> Gruvbox Dark (warm earth)
    "miasma")           ZELLIJ_THEME="gruvbox-dark" ;;

    # "Retro 82" -> Retrowave/synthwave (dark navy, orange, teal) -> Retro Wave (perfect match)
    "retro-82")         ZELLIJ_THEME="retro-wave" ;;

    # "Vantablack" -> Pure black monochrome -> Molokai Dark (high contrast, black bg)
    "vantablack")       ZELLIJ_THEME="molokai-dark" ;;

    # "White" -> Pure white light mode -> Pencil Light (clean paper-like light)
    "white")            ZELLIJ_THEME="pencil-light" ;;

    # --- Catch-all Fallback ---
    *)                  ZELLIJ_THEME="default" ;;
esac

# 3. Apply the theme
sed -i "s/theme \".*\"/theme \"$ZELLIJ_THEME\"/" ~/.config/zellij/config.kdl
