#!/bin/bash

# AutoSMAPI - Reorganized and Fixed
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

CONFIG_FILE="$HOME/.config/autosmapi/config"

# --- HELPER FUNCTIONS ---

print_message() { echo -e "${1}${2}${NC}"; }

print_header() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}\n"
}

# --- CONFIGURATION FUNCTIONS ---

save_config() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    # IMPORTANT: Use quotes around variables to handle spaces in paths
    echo "GAME_DIR=\"$GAME_DIR\"" > "$CONFIG_FILE"
    echo "MOD_ARCHIVE_DIR=\"$MOD_ARCHIVE_DIR\"" >> "$CONFIG_FILE"
}

load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        return 0
    fi
    return 1
}

# --- DIRECTORY & DEPENDENCY FUNCTIONS ---

get_mod_directory() {
    local mod_dir="$1/Mods"
    [ ! -d "$mod_dir" ] && mkdir -p "$mod_dir"
    echo "$mod_dir"
}

select_game_directory() {
    print_header "STEP 1: SELECT GAME DIRECTORY"
    echo "1) GOG: ~/GOG Games/Stardew Valley/game"
    echo "2) Steam: ~/.local/share/Steam/steamapps/common/Stardew Valley"
    echo "3) Steam (alternate): ~/.steam/steam/steamapps/common/Stardew Valley"
    echo "4) Custom path"
    read -p "Enter choice (1-4): " choice
    case $choice in
        1) GAME_DIR="$HOME/GOG Games/Stardew Valley/game" ;;
        2) GAME_DIR="$HOME/.local/share/Steam/steamapps/common/Stardew Valley" ;;
        3) GAME_DIR="$HOME/.steam/steam/steamapps/common/Stardew Valley" ;;
        4) read -p "Enter custom path: " GAME_DIR; GAME_DIR="${GAME_DIR/#\~/$HOME}" ;;
    esac
    [ ! -d "$GAME_DIR" ] && print_message "$RED" "Error: Invalid Dir" && exit 1
    print_message "$GREEN" "✓ Game directory set: $GAME_DIR"
}

check_dependencies() {
    print_header "CHECKING DEPENDENCIES"
    for cmd in unzip wget jq; do
        command -v $cmd >/dev/null 2>&1 || { print_message "$RED" "Missing $cmd. Install with: sudo apt install $cmd"; exit 1; }
    done
    print_message "$GREEN" "✓ All required dependencies found"
}

# --- SMAPI INSTALLER ---

install_smapi() {
    print_header "STEP 2: INSTALLING SMAPI"
    [ -f "$GAME_DIR/StardewModdingAPI" ] && read -p "SMAPI exists. Reinstall? (y/n): " ri && [[ ! "$ri" =~ ^[Yy]$ ]] && return 0

    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR" || exit 1
    SMAPI_URL=$(wget -qO- https://api.github.com/repos/Pathoschild/SMAPI/releases/latest | grep "browser_download_url.*installer\.zip" | cut -d '"' -f 4 | head -n 1)
    wget -q --show-progress "$SMAPI_URL" -O smapi.zip
    unzip -q smapi.zip
    
    SMAPI_DIR=$(find . -maxdepth 1 -type d -name "SMAPI*" | head -n 1)
    cd "$SMAPI_DIR" || exit 1
    chmod +x "install on Linux.sh"
    
    # Try terminal windows for Lubuntu
    INSTALL_CMD="bash './install on Linux.sh'"
    if command -v qterminal >/dev/null 2>&1; then qterminal -e "$INSTALL_CMD"
    elif command -v lxterminal >/dev/null 2>&1; then lxterminal -e "$INSTALL_CMD"
    else bash "./install on Linux.sh"; fi

    mkdir -p "$GAME_DIR/Mods"
    cd "$HOME" && rm -rf "$TEMP_DIR"
}

# --- MOD EXTRACTION ---

find_mod_folder() {
    local manifest_path=$(find "$1" -name "manifest.json" -type f -print -quit)
    [ -n "$manifest_path" ] && dirname "$manifest_path"
}

extract_archive() {
    local archive="$1"; local temp="$2"; local ext="${archive##*.}"
    case "$ext" in
        zip) unzip -q "$archive" -d "$temp" ;;
        7z) 7z x "$archive" -o"$temp" >/dev/null 2>&1 ;;
        rar) unrar x "$archive" "$temp/" >/dev/null 2>&1 ;;
    esac
}

extract_mods() {
    print_header "STEP 4: EXTRACTING AND INSTALLING MODS"
    MOD_DIR=$(get_mod_directory "$GAME_DIR")
    
    shopt -s nullglob
    for archive in "$MOD_ARCHIVE_DIR"/*.{zip,7z,rar}; do
        filename=$(basename "$archive")
        print_message "$BLUE" "Processing: $filename"
        tmp_e=$(mktemp -d)
        if extract_archive "$archive" "$tmp_e"; then
            actual_mod=$(find_mod_folder "$tmp_e")
            if [ -n "$actual_mod" ]; then
                m_name=$(basename "$actual_mod")
                dest="$MOD_DIR/$m_name"
                rm -rf "$dest"
                mv "$actual_mod" "$dest"
                print_message "$GREEN" "  ✓ Installed: $m_name"
                rm "$archive"
            fi
        fi
        rm -rf "$tmp_e"
    done
}

# --- MAIN ENGINE ---

main() {
    clear
    load_config
    if [ -z "$GAME_DIR" ]; then
        select_game_directory
        check_dependencies
        install_smapi
        # Default mod archive dir to Downloads if not set
        MOD_ARCHIVE_DIR="${MOD_ARCHIVE_DIR:-$HOME/Downloads}"
        save_config
    else
        print_message "$BLUE" "Using Config: $GAME_DIR"
        read -p "Change settings? (y/n): " change
        if [[ "$change" =~ ^[Yy]$ ]]; then
            rm "$CONFIG_FILE"
            main
            return
        fi
        check_dependencies
    fi
    
    extract_mods
    print_message "$YELLOW" "\nDone! Press [ENTER] to exit..."
    read
}

main