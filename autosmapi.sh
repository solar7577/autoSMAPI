#!/bin/bash

# AutoSMAPI - Stardew Valley Linux Mod Manager
# Fixed for Lubuntu/Steam paths and Permissions

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

CONFIG_FILE="$HOME/.config/autosmapi/config"

# --- HELPER FUNCTIONS ---

print_message() {
    echo -e "${1}${2}${NC}"
}

print_header() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}\n"
}

# --- DIRECTORY FUNCTIONS ---

# Defined early so other functions can find it
get_mod_directory() {
    local base_dir="$1"
    if [ -z "$base_dir" ]; then
        return 1
    fi
    local mod_path="$base_dir/Mods"
    
    # Create directory if missing
    if [ ! -d "$mod_path" ]; then
        mkdir -p "$mod_path" 2>/dev/null || sudo mkdir -p "$mod_path"
    fi
    echo "$mod_path"
}

# --- CONFIGURATION ---

save_config() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    # FIX: We now use escaped quotes \" to handle spaces in filenames safely
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

select_game_directory() {
    print_header "STEP 1: SELECT GAME DIRECTORY"
    echo "1) GOG: ~/GOG Games/Stardew Valley/game"
    echo "2) Steam: ~/.local/share/Steam/steamapps/common/Stardew Valley"
    echo "3) Steam (alternate): ~/.steam/steam/steamapps/common/Stardew Valley"
    echo "4) Custom path"
    
    read -p "Enter your choice (1-4): " choice
    case $choice in
        1) GAME_DIR="$HOME/GOG Games/Stardew Valley/game" ;;
        2) GAME_DIR="$HOME/.local/share/Steam/steamapps/common/Stardew Valley" ;;
        3) GAME_DIR="$HOME/.steam/steam/steamapps/common/Stardew Valley" ;;
        4) read -p "Enter custom path: " GAME_DIR; GAME_DIR="${GAME_DIR/#\~/$HOME}" ;;
        *) print_message "$RED" "Invalid choice."; exit 1 ;;
    esac

    if [ ! -d "$GAME_DIR" ]; then
        print_message "$RED" "Error: Directory not found: $GAME_DIR"
        exit 1
    fi
    print_message "$GREEN" "✓ Game directory set: $GAME_DIR"
}

select_mod_archive_directory() {
    print_header "STEP 3: SELECT DOWNLOADS FOLDER"
    read -p "Directory with zip files [default: ~/Downloads]: " input_dir
    
    if [ -z "$input_dir" ]; then
        MOD_ARCHIVE_DIR="$HOME/Downloads"
    else
        MOD_ARCHIVE_DIR="${input_dir/#\~/$HOME}"
    fi
    
    if [ ! -d "$MOD_ARCHIVE_DIR" ]; then
        print_message "$RED" "Error: Directory not found."
        exit 1
    fi
    print_message "$GREEN" "✓ mod directory set: $MOD_ARCHIVE_DIR"
}

# --- INSTALLATION LOGIC ---

check_dependencies() {
    print_header "CHECKING DEPENDENCIES"
    local missing=0
    for cmd in unzip wget; do
        command -v $cmd >/dev/null 2>&1 || { print_message "$RED" "Missing: $cmd"; missing=1; }
    done
    [ $missing -eq 1 ] && print_message "$YELLOW" "Install missing tools with: sudo apt install unzip wget" && exit 1
    print_message "$GREEN" "✓ Dependencies OK"
}

install_smapi() {
    print_header "STEP 2: INSTALLING SMAPI"
    
    if [ -f "$GAME_DIR/StardewModdingAPI" ]; then
        read -p "SMAPI detected. Reinstall? (y/n): " reinstall
        [[ ! "$reinstall" =~ ^[Yy]$ ]] && return 0
    fi
    
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR" || exit 1
    
    print_message "$BLUE" "Downloading SMAPI..."
    SMAPI_URL=$(wget -qO- https://api.github.com/repos/Pathoschild/SMAPI/releases/latest | grep "browser_download_url.*installer\.zip" | cut -d '"' -f 4 | head -n 1)
    [ -z "$SMAPI_URL" ] && SMAPI_URL="https://github.com/Pathoschild/SMAPI/releases/latest/download/SMAPI-4.3.2-installer.zip"
    
    wget -q --show-progress "$SMAPI_URL" -O smapi.zip
    unzip -q smapi.zip
    
    SMAPI_DIR=$(find . -maxdepth 1 -type d -name "SMAPI*" | head -n 1)
    cd "$SMAPI_DIR" || exit 1
    
    chmod +x "install on Linux.sh"
    
    print_message "$YELLOW" "Opening Installer..."
    INSTALL_CMD="bash './install on Linux.sh'"
    
    # Try different terminals for Lubuntu
    if command -v qterminal >/dev/null 2>&1; then qterminal --wait -e "$INSTALL_CMD"
    elif command -v lxterminal >/dev/null 2>&1; then lxterminal -e "$INSTALL_CMD"
    elif command -v x-terminal-emulator >/dev/null 2>&1; then x-terminal-emulator -e "$INSTALL_CMD"
    else bash "./install on Linux.sh"; fi

    cd "$HOME"
    rm -rf "$TEMP_DIR"
    
    # Init folders
    mkdir -p "$GAME_DIR/Mods"
    print_message "$GREEN" "✓ SMAPI Setup Complete"
}

extract_mods() {
    print_header "STEP 4: INSTALLING MODS"
    
    # Safety Check
    if [ -z "$GAME_DIR" ]; then print_message "$RED" "Error: GAME_DIR not set"; return 1; fi
    
    MOD_DIR=$(get_mod_directory "$GAME_DIR")
    print_message "$BLUE" "Target: $MOD_DIR"
    
    shopt -s nullglob
    for archive in "$MOD_ARCHIVE_DIR"/*.{zip,7z,rar}; do
        filename=$(basename "$archive")
        print_message "$BLUE" "Processing: $filename"
        
        tmp_e=$(mktemp -d)
        
        # Extract based on extension
        case "${archive##*.}" in
            zip) unzip -q "$archive" -d "$tmp_e" 2>/dev/null ;;
            7z) 7z x "$archive" -o"$tmp_e" >/dev/null 2>&1 ;;
            rar) unrar x "$archive" "$tmp_e/" >/dev/null 2>&1 ;;
        esac

        # Smart Find: Look for manifest.json to find the real mod root
        mod_root=$(find "$tmp_e" -name "manifest.json" -type f -exec dirname {} \; | head -n 1)
        
        if [ -n "$mod_root" ]; then
            mod_name=$(basename "$mod_root")
            
            # If the folder name is generic (like "tmp"), use the zip name
            [[ "$mod_name" == tmp* ]] && mod_name="${filename%.*}"
            
            dest="$MOD_DIR/$mod_name"
            
            # Remove old version if exists
            if [ -d "$dest" ]; then
                rm -rf "$dest" 2>/dev/null || sudo rm -rf "$dest"
            fi
            
            # Move with fallback to sudo
            if mv "$mod_root" "$dest" 2>/dev/null; then
                print_message "$GREEN" "  ✓ Installed: $mod_name"
                rm "$archive"
            else
                print_message "$YELLOW" "  ⚠ Permission denied. Asking for password..."
                sudo mv "$mod_root" "$dest" && print_message "$GREEN" "  ✓ Installed (via sudo)" && rm "$archive"
            fi
        else
            print_message "$RED" "  ✗ Skipped: No manifest.json found"
        fi
        
        rm -rf "$tmp_e"
    done
    shopt -u nullglob
}

# --- MAIN LOOP ---

main() {
    clear
    print_message "$YELLOW" "AutoSMAPI Installer"
    
    if load_config; then
        print_message "$BLUE" "Loaded Config: $GAME_DIR"
        read -p "Use this config? (y/n): " use_conf
        if [[ ! "$use_conf" =~ ^[Yy]$ ]]; then
            rm "$CONFIG_FILE"
            select_game_directory
            select_mod_archive_directory
            save_config
        fi
    else
        select_game_directory
        select_mod_archive_directory
        save_config
    fi
    
    check_dependencies
    install_smapi
    extract_mods
    
    echo ""
    print_message "$YELLOW" "Installation Finished! Press [ENTER] to exit."
    read
}

main