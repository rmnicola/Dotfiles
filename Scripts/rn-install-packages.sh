#!/bin/bash

# ==========================================
# Omarchy Package Installer
# Matches visual style of Omarchy Cleaner
# ==========================================

# Configuration
INPUT_FILE="packages.txt"
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Locate packages.txt
if [ -f "$INPUT_FILE" ]; then
    TARGET_FILE="$INPUT_FILE"
elif [ -f "$SCRIPT_DIR/$INPUT_FILE" ]; then
    TARGET_FILE="$SCRIPT_DIR/$INPUT_FILE"
elif [ -f "$SCRIPT_DIR/../$INPUT_FILE" ]; then
    TARGET_FILE="$SCRIPT_DIR/../$INPUT_FILE"
else
    TARGET_FILE=""
fi

# State Variables
MODE="interactive" # Default mode
TARGET_SECTION=""
EXCLUDE_SECTIONS=""
FINAL_INSTALL_LIST=()
FINAL_REMOVE_LIST=()

# ==========================================
# UI Functions
# ==========================================

show_header() {
    clear
    gum style \
        --foreground 212 \
        "    ____              __        __  " \
        "   /  _/___  _______/ /_____ _/ / /" \
        "   / // __ \/ ___/ __/ __  / / / /" \
        " _/ // / / (__  ) /_/ /_/ / / / /" \
        "/___/_/ /_/____/\__/\__,_/_/_/_/" \
        "                                "

    echo ""
    gum style --foreground 237 "═════════════════════════════════════════════════"
    echo ""
}

show_summary() {
    local attempted=$1
    local failed=$2
    local successful=$((attempted - failed))

    echo ""
    if [[ $failed -eq 0 ]]; then
        gum style \
            --border double --border-foreground 82 --background 22 --foreground 15 \
            --bold --padding "1 2" --margin "1" --width 60 --align center \
            "✅ SUCCESS" "" "All $attempted package(s) processed successfully!"
    elif [[ $successful -gt 0 ]]; then
        gum style \
            --border double --border-foreground 214 --background 94 --foreground 15 \
            --bold --padding "1 2" --margin "1" --width 60 --align center \
            "⚠️  PARTIAL SUCCESS" "" "$successful installed, $failed failed."
    else
        gum style \
            --border double --border-foreground 196 --background 52 --foreground 15 \
            --bold --padding "1 2" --margin "1" --width 60 --align center \
            "❌ FAILED" "" "Could not install packages."
    fi
}

# ==========================================
# Logic Helper Functions
# ==========================================

# Check if a section is allowed based on -s and -e flags
is_section_allowed() {
    local section="$1"
    
    # 1. Check Exclusion (-e)
    if [ -n "$EXCLUDE_SECTIONS" ]; then
        IFS=',' read -ra EXCLUDES <<< "$EXCLUDE_SECTIONS"
        for exclude in "${EXCLUDES[@]}"; do
            if [[ "${section,,}" == "${exclude,,}" ]]; then
                return 1 # False (Excluded)
            fi
        done
    fi

    # 2. Check Inclusion (-s)
    if [ -n "$TARGET_SECTION" ]; then
        if [[ "${section,,}" != "${TARGET_SECTION,,}" ]]; then
            return 1 # False (Not target)
        fi
    fi

    return 0 # True
}

# Parse a raw line into Install/Remove lists
process_line_logic() {
    local line="$1"
    
    if [[ "$line" == *" --remove "* ]]; then
        local pkg_inst="${line%% --remove *}"
        local pkg_rem="${line##* --remove }"
        FINAL_INSTALL_LIST+=("$pkg_inst")
        FINAL_REMOVE_LIST+=("$pkg_rem")
    else
        FINAL_INSTALL_LIST+=("$line")
    fi
}

# ==========================================
# Core Operations
# ==========================================

# Reads file and filters content based on flags
# Returns raw lines in a format suitable for either auto-install or interactive menu
get_filtered_packages() {
    local buffer=()
    local current_sect="General"
    local capture=true

    # Initial check for General section
    is_section_allowed "$current_sect" || capture=false

    while IFS= read -r line || [ -n "$line" ]; do
        line=$(echo "$line" | xargs)
        if [[ -z "$line" ]]; then continue; fi

        # Header detection
        if [[ "$line" == \#* ]]; then
            current_sect=$(echo "${line}" | sed 's/^#//' | xargs)
            if is_section_allowed "$current_sect"; then
                capture=true
            else
                capture=false
            fi
            continue
        fi

        # Skip comments/metadata
        if [[ "$line" == \[* ]]; then continue; fi

        # Add to buffer if capturing
        if [[ "$capture" == "true" ]]; then
            # Store as "SECTION|LINE" so we can parse it later
            buffer+=("$current_sect|$line")
        fi
    done < "$TARGET_FILE"

    printf "%s\n" "${buffer[@]}"
}

perform_installation() {
    # 1. Handle Removals First
    if [ ${#FINAL_REMOVE_LIST[@]} -gt 0 ]; then
        echo ""
        gum style --foreground 208 --bold "🗑️  Removing conflicting packages..."
        for pkg in "${FINAL_REMOVE_LIST[@]}"; do
            if gum spin --spinner dot --title "Removing $pkg..." -- bash -c "yay -Rns --noconfirm '$pkg' >/dev/null 2>&1"; then
                gum log --level info "Removed: $pkg"
            else
                # Don't fail the whole script if removal fails (it might not exist)
                gum log --level warn "Could not remove: $pkg (might not be installed)"
            fi
        done
    fi

    # 2. Handle Installations
    local packages=("${FINAL_INSTALL_LIST[@]}")
    local failed_packages=()
    local total=${#packages[@]}
    local current=0

    echo ""
    gum style --foreground 212 --bold "📦 Installing $total package(s)..."
    echo ""

    # Sudo check
    if ! sudo -n true 2>/dev/null; then
        gum style --foreground 214 "🔐 Sudo privileges required."
        if ! sudo true; then
             gum log --level error "Failed to obtain sudo."
             exit 1
        fi
        echo ""
    fi

    for pkg in "${packages[@]}"; do
        ((current++))

        # Progress Text
        gum style --foreground 212 "[$current/$total] Processing: $pkg"

        # Spinner & Action
        if gum spin --spinner dot --title "Installing $pkg..." -- bash -c "yay -S --needed --noconfirm '$pkg' >/dev/null 2>&1"; then
            gum log --level info "✓ Installed: $pkg"
        else
            gum log --level warn "✗ Failed: $pkg"
            failed_packages+=("$pkg")
        fi

        # Progress Bar
        local percentage=$(( (current * 100) / total ))
        local filled=$(( percentage / 5 ))
        local empty=$(( (100 - percentage) / 5 ))

        printf "Progress: "
        printf '\033[92m█%.0s\033[0m' $(seq 1 $filled)
        printf '\033[90m░%.0s\033[0m' $(seq 1 $empty)
        printf " %d%% (%d/%d)\n" "$percentage" "$current" "$total"
        echo ""
    done

    show_summary "$total" "${#failed_packages[@]}"
}

# ==========================================
# Main Execution
# ==========================================

# Dependency Check
if ! command -v gum &> /dev/null; then
    echo "Error: gum is not installed."
    exit 1
fi

# Argument Parsing
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--section) TARGET_SECTION="$2"; shift ;;
        -e|--exclude) EXCLUDE_SECTIONS="$2"; shift ;;
        -a|--all) MODE="auto" ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

if [[ ! -f "$TARGET_FILE" ]]; then
    gum log --level error "Could not find packages.txt"
    exit 1
fi

show_header

# 1. Get List of Candidate Packages (Strings formatted as "SECTION|PACKAGE")
#    This respects -s and -e flags.
mapfile -t RAW_CANDIDATES < <(get_filtered_packages)

if [ ${#RAW_CANDIDATES[@]} -eq 0 ]; then
    gum style --foreground 196 "No packages found matching criteria."
    exit 0
fi

# 2. Select Packages based on Mode
if [[ "$MODE" == "auto" ]]; then
    # Automatically add everything from candidates to final lists
    for item in "${RAW_CANDIDATES[@]}"; do
        # Strip Section prefix (everything after first |)
        line="${item#*|}"
        process_line_logic "$line"
    done
else
    # Interactive Mode
    gum style --foreground 212 --italic "Select packages to install (Tab to select, Enter to confirm)"
    echo ""

    # Format for Gum: Replace "|" with pretty spacing for display
    # We use a trick: format data as "Package [Section]" or similar for the user
    # But we need to keep the raw data valid.
    
    DISPLAY_LIST=()
    for item in "${RAW_CANDIDATES[@]}"; do
        sect="${item%%|*}"
        pkg="${item#*|}"
        DISPLAY_LIST+=("[$sect] $pkg")
    done

    SELECTED_RAW=$(gum choose --no-limit "${DISPLAY_LIST[@]}")

    if [[ -z "$SELECTED_RAW" ]]; then
        gum style --foreground 196 "No packages selected. Exiting."
        exit 0
    fi

    # Process selections
    while IFS= read -r item; do
        # Remove the "[Section] " prefix to get back to the raw package line
        clean_line=$(echo "$item" | sed 's/^\[.*\] //')
        process_line_logic "$clean_line"
    done <<< "$SELECTED_RAW"

    # Confirmation
    echo ""
    gum style --bold "Selected ${#FINAL_INSTALL_LIST[@]} packages to install (and ${#FINAL_REMOVE_LIST[@]} to remove)."
    if ! gum confirm "Proceed?"; then
        gum log --level info "Operation cancelled"
        exit 0
    fi
fi

# 3. Execute
perform_installation
