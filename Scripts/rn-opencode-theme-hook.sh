#!/bin/bash

# 1. Get the theme name from Omarchy (passed as argument)
NEW_THEME="$1"

# Notify that hook was called
notify-send "OpenCode Theme Hook" "Called with theme: $NEW_THEME" -t 3000

# 2. Map Omarchy themes -> OpenCode themes
case "$NEW_THEME" in
    # --- Direct & Near Matches ---
    "catppuccin")       OPENCODE_THEME="catppuccin-macchiato" ;; # Standard Dark
    "catppuccin-latte") OPENCODE_THEME="catppuccin-latte" ;;
    "everforest")       OPENCODE_THEME="everforest" ;;
    "gruvbox")          OPENCODE_THEME="gruvbox" ;;
    "kanagawa")         OPENCODE_THEME="kanagawa" ;;
    "nord")             OPENCODE_THEME="nord" ;;
    "tokyo-night")      OPENCODE_THEME="tokyonight" ;;

    # --- Aesthetic Mappings (Best Effort) ---
    
    # "Hackerman" -> Cyberpunk/Neon -> Matrix is perfect (green on black hacker theme)
    "hackerman")        OPENCODE_THEME="matrix" ;; 

    # "Matte Black" -> High contrast/Monochrome -> One Dark or Ayu
    "matte-black")      OPENCODE_THEME="one-dark" ;;

    # "Flexoki Light" -> Warm/Ink Light -> System (adapts to terminal)
    "flexoki-light")    OPENCODE_THEME="system" ;;

    # "Rose Pine" -> Warm/Rosy -> Catppuccin (soft pastels)
    "rose-pine")        OPENCODE_THEME="catppuccin" ;;

    # "Ristretto" -> Coffee/Brown -> Gruvbox (warm/brown)
    "ristretto")        OPENCODE_THEME="gruvbox" ;;

    # "Ethereal" -> Dreamy/Dark -> Tokyonight (dark/blue)
    "ethereal")         OPENCODE_THEME="tokyonight" ;;

    # "Osaka Jade" -> City Pop/Green/Teal -> Nord (cool blues/greens)
    "osaka-jade")       OPENCODE_THEME="nord" ;;

    # --- Catch-all Fallback ---
    *)                  OPENCODE_THEME="system" ;;
esac

# 3. Apply the theme to both config files using jq
UPDATED_COUNT=0
for config in ~/.config/opencode/opencode.json ~/.config/opencode-personal/opencode.json; do
    if [ -f "$config" ]; then
        if jq --arg theme "$OPENCODE_THEME" '.theme = $theme' "$config" > "$config.tmp" && mv "$config.tmp" "$config"; then
            UPDATED_COUNT=$((UPDATED_COUNT + 1))
        fi
    fi
done
