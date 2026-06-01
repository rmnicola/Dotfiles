#!/bin/bash

# 1. Get the theme name from Omarchy (passed as argument)
NEW_THEME="$1"

# 2. Map Omarchy themes -> Zellij themes
case "$NEW_THEME" in
    # --- Direct & Near Matches ---
    "catppuccin")       ZELLIJ_THEME="catppuccin-macchiato" ;; # Standard Dark
    "catppuccin-latte") ZELLIJ_THEME="catppuccin-latte" ;;
    "everforest")       ZELLIJ_THEME="everforest-dark" ;;
    "gruvbox")          ZELLIJ_THEME="gruvbox-dark" ;;
    "kanagawa")         ZELLIJ_THEME="kanagawa" ;;
    "nord")             ZELLIJ_THEME="nord" ;;
    "tokyo-night")      ZELLIJ_THEME="tokyo-night" ;;

    # --- Aesthetic Mappings (Best Effort) ---
    
    # "Hackerman" -> Cyberpunk/Neon -> Cyber Noir is perfect
    "hackerman")        ZELLIJ_THEME="cyber-noir" ;; 

    # "Matte Black" -> High contrast/Monochrome -> Vesper is strict/dark
    "matte-black")      ZELLIJ_THEME="vesper" ;;

    # "Flexoki Light" -> Warm/Ink Light -> Gruvbox Light is the closest warm light
    "flexoki-light")    ZELLIJ_THEME="gruvbox-light" ;;

    # "Rose Pine" -> Warm/Rosy -> Dracula (purples) or Kanagawa (warmth). 
    # Since Rose Pine isn't in your list, Dracula preserves the purple/pink hue best.
    "rose-pine")        ZELLIJ_THEME="dracula" ;;

    # "Ristretto" -> Coffee/Brown -> Fallback to Gruvbox Dark (warm/brown)
    "ristretto")        ZELLIJ_THEME="gruvbox-dark" ;;

    # "Ethereal" -> Dreamy/Dark -> Tokyo Night Storm (lighter dark/blue)
    "ethereal")         ZELLIJ_THEME="tokyo-night-storm" ;;

    # "Osaka Jade" -> City Pop/Green/Teal -> Retro Wave (Neon) or Nord (Cool).
    # Retro Wave fits the "Osaka" city vibe best.
    "osaka-jade")       ZELLIJ_THEME="retro-wave" ;;

    # --- Catch-all Fallback ---
    *)                  ZELLIJ_THEME="default" ;;
esac

# 3. Apply the theme
sed -i "s/theme \".*\"/theme \"$ZELLIJ_THEME\"/" ~/.config/zellij/config.kdl
