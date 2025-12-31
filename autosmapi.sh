#!/bin/bash

# Configuration
CONFIG_FILE="$HOME/.config/autosmapi/config"
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# --- REQUIRED FUNCTIONS (Must be at the top) ---

get_mod_directory() {
    local base_dir="$1"
    if [ -z "$base_dir" ]; then
        return 1
    fi
    local mod_path="$base_dir/Mods"
    [ ! -d "$mod_path" ] && mkdir -p "$mod_path"
    echo "$mod_path"
}

print_message() { echo -e "${1}${2}${NC}"; }

# --- MOD INSTALLATION ENGINE ---

extract_mods() {
    echo -e "\n${BLUE}STEP 4: EXTRACTING AND INSTALLING MODS${NC}"
    
    # Validation: Ensure GAME_DIR is actually set
    if [ -z "$GAME_DIR" ] || [ "$GAME_DIR" == "/" ]; then
        print_message "$RED" "Error: Game directory is empty. Run Step 1 again."
        return 1
    fi

    MOD_DIR=$(get_mod_directory "$GAME_DIR")
    print_message "$GREEN" "Installing to: $MOD_DIR"

    shopt -s nullglob
    for archive in "$MOD_ARCHIVE_DIR"/*.{zip,7z,rar}; do
        filename=$(basename "$archive")
        print_message "$YELLOW" "Extracting: $filename"
        
        tmp_e=$(mktemp -d)
        unzip -q "$archive" -d "$tmp_e" 2>/dev/null
        
        # Find manifest
        actual_mod=$(find "$tmp_e" -name "manifest.json" -type f -exec dirname {} \; | head -n 1)
        
        if [ -n "$actual_mod" ]; then
            mod_name=$(basename "$actual_mod")
            dest="$MOD_DIR/$mod_name"
            
            # Try moving normally, fallback to sudo if denied
            if mv "$actual_mod" "$dest" 2>/dev/null; then
                print_message "$GREEN" "  ✓ Success: $mod_name"
                rm "$archive"
            else
                print_message "$YELLOW" "  ! Permission denied. Requesting sudo for $mod_name..."
                sudo mv "$actual_mod" "$dest" && print_message "$GREEN" "  ✓ Fixed with sudo" && rm "$archive"
            fi
        fi
        rm -rf "$tmp_e"
    done
}

# --- THE MAIN CALL ---

main() {
    # Check if config exists and load it properly
    if [ -f "$CONFIG_FILE" ]; then
        # Use 'export' to ensure variables are global
        set -a
        source "$CONFIG_FILE"
        set +a
    fi

    # ... (Your existing Step 1-3 logic here) ...

    extract_mods

    print_message "$YELLOW" "\nAll done. Press [ENTER] to close."
    read
}

main