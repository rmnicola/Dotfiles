#!/bin/bash

# Default settings
MODE="standard"
SILENT="false"
URL=""
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --forced)
      MODE="nuclear"
      shift
      ;;
    -s|--silent)
      SILENT="true"
      shift
      ;;
    *)
      # Assume anything not a flag is the URL
      URL="$1"
      shift
      ;;
  esac
done

if [ -z "$URL" ]; then
    echo "Error: No URL provided."
    exit 1
fi

# Function to run Nuclear logic (Chromium dump)
run_nuclear() {
    # Dump DOM with Chromium -> Pipe to rdrview -> Output to stdout (no browser)
    chromium --headless=new --dump-dom --user-agent="$UA" "$URL" 2>/dev/null | rdrview -H
}

# Function to run Standard logic (Direct rdrview)
run_standard() {
    # Run rdrview on URL -> Output to stdout (no browser)
    rdrview -H "$URL"
}

# --- EXECUTION ---

if [ "$SILENT" == "true" ]; then
    # SILENT MODE: Output to temp file, do not open w3m
    if [ "$MODE" == "nuclear" ]; then
        run_nuclear
    else
        run_standard
    fi
else
    # INTERACTIVE MODE: Pipe result directly to w3m (using rdrview's -B or manual pipe)
    # We use manual piping to w3m here to keep logic consistent between modes
    if [ "$MODE" == "nuclear" ]; then
        chromium --headless=new --dump-dom --user-agent="$UA" "$URL" 2>/dev/null | rdrview -B w3m
    else
        rdrview -B w3m "$URL"
    fi
fi
