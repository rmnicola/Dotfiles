#!/bin/bash

# 1. Get the theme name from Omarchy (passed as argument)
NEW_THEME="$1"

# 2. Map Omarchy themes -> Presenterm themes
case "$NEW_THEME" in
    # --- Direct & Near Matches ---
    "catppuccin")       PRESENTERM_THEME="catppuccin-macchiato" ;; 
    "catppuccin-latte") PRESENTERM_THEME="catppuccin-latte" ;;
    "gruvbox")          PRESENTERM_THEME="gruvbox-dark" ;;
    "tokyo-night")      PRESENTERM_THEME="tokyonight-night" ;;

    # --- Aesthetic Mappings (Best Effort) ---
    "everforest")       PRESENTERM_THEME="gruvbox-dark" ;;
    "kanagawa")         PRESENTERM_THEME="tokyonight-moon" ;;
    "nord")             PRESENTERM_THEME="tokyonight-storm" ;;
    "hackerman")        PRESENTERM_THEME="tokyonight-night" ;; 
    "matte-black")      PRESENTERM_THEME="dark" ;;
    "flexoki-light")    PRESENTERM_THEME="catppuccin-latte" ;;
    "rose-pine")        PRESENTERM_THEME="catppuccin-mocha" ;;
    "ristretto")        PRESENTERM_THEME="gruvbox-dark" ;;
    "ethereal")         PRESENTERM_THEME="tokyonight-moon" ;;
    "osaka-jade")       PRESENTERM_THEME="tokyonight-storm" ;;

    # --- Catch-all Fallback ---
    *)                  PRESENTERM_THEME="dark" ;;
esac

# 3. Apply the theme
# UPDATED SED COMMAND:
# - `^[[:blank:]]*` matches any spaces/tabs at the start of the line.
# - The `\1` in the replacement preserves that original indentation.
sed -i "s/\(^[[:blank:]]*theme: \).*/\1$PRESENTERM_THEME/" ~/.config/presenterm/config.yaml
