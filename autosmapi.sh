#!/bin/bash

# AutoSMAPI
# Automated SMAPI installation and mod extraction utility

# Color codes for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Config file location
CONFIG_FILE="$HOME/.config/autosmapi/config"

# Function to display the Stardew Valley chicken ASCII art
show_logo() {
    echo -e "${YELLOW}"
    cat << "EOF"
                                                                                                              
                                                                     ____                 ,-.----.            
   ,---,                        ___              .--.--.           ,'  , `.   ,---,       \    /  \     ,---, 
  '  .' \                     ,--.'|_           /  /    '.      ,-+-,.' _ |  '  .' \      |   :    \ ,`--.' | 
 /  ;    '.             ,--,  |  | :,'   ,---. |  :  /`. /   ,-+-. ;   , || /  ;    '.    |   |  .\ :|   :  : 
:  :       \          ,'_ /|  :  : ' :  '   ,'\;  |  |--`   ,--.'|'   |  ;|:  :       \   .   :  |: |:   |  ' 
:  |   /\   \    .--. |  | :.;__,'  /  /   /   |  :  ;_    |   |  ,', |  '::  |   /\   \  |   |   \ :|   :  | 
|  :  ' ;.   : ,'_ /| :  . ||  |   |  .   ; ,. :\  \    `. |   | /  | |  |||  :  ' ;.   : |   : .   /'   '  ; 
|  |  ;/  \   \|  ' | |  . .:__,'| :  '   | |: : `----.   \'   | :  | :  |,|  |  ;/  \   \;   | |`-' |   |  | 
'  :  | \  \ ,'|  | ' |  | |  '  : |__'   | .; : __ \  \  |;   . |  ; |--' '  :  | \  \ ,'|   | ;    '   :  ; 
|  |  '  '--'  :  | : ;  ; |  |  | '.'|   :    |/  /`--'  /|   : |  | ,    |  |  '  '--'  :   ' |    |   |  ' 
|  :  :        '  :  `--'   \ ;  :    ;\   \  /'--'.     / |   : '  |/     |  :  :        :   : :    '   :  | 
|  | ,'        :  ,      .-./ |  ,   /  `----'   `--'---'  ;   | |`-'      |  | ,'        |   | :    ;   |.'  
`--''           `-`----'      ---`-'                      |   ;/          `--''          `---'.|    '---'    
                                                           '---'                            `---`             
                                                                                                              
EOF
    echo -e "${NC}"
}

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print section headers
print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to save config
save_config() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo "GAME_DIR=$GAME_DIR" > "$CONFIG_FILE"
    echo "MOD_ARCHIVE_DIR=$MOD_ARCHIVE_DIR" >> "$CONFIG_FILE"
}

# Function to load config
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        return 0
    fi
    return 1
}

# Function to select game directory
select_game_directory() {
    print_header "STEP 1: SELECT GAME DIRECTORY"
    
    echo -e "${BLUE}Please select your Stardew Valley installation:${NC}"
    echo ""
    echo "1) GOG: ~/GOG Games/Stardew Valley/game"
    echo "2) Steam: ~/.local/share/Steam/steamapps/common/Stardew Valley"
    echo "3) Steam (alternate): ~/.steam/steam/steamapps/common/Stardew Valley"
    echo "4) Custom path"
    echo ""
    
    read -p "Enter your choice (1-4): " choice
    
    case $choice in
        1)
            GAME_DIR="$HOME/GOG Games/Stardew Valley/game"
            ;;
        2)
            GAME_DIR="$HOME/.local/share/Steam/steamapps/common/Stardew Valley"
            ;;
        3)
            GAME_DIR="$HOME/.steam/steam/steamapps/common/Stardew Valley"
            ;;
        4)
            read -p "Enter custom path: " GAME_DIR
            GAME_DIR="${GAME_DIR/#\~/$HOME}"
            ;;
        *)
            print_message "$RED" "Invalid choice. Exiting."
            exit 1
            ;;
    esac
    
    if [ ! -d "$GAME_DIR" ]; then
        print_message "$RED" "Error: Directory does not exist: $GAME_DIR"
        exit 1
    fi
    
    print_message "$GREEN" "✓ Game directory set: $GAME_DIR"
}

# Function to check and install dependencies
check_dependencies() {
    print_header "CHECKING DEPENDENCIES"
    
    local missing_deps=()
    
    # Check for required tools
    command -v unzip >/dev/null 2>&1 || missing_deps+=("unzip")
    command -v wget >/dev/null 2>&1 || missing_deps+=("wget")
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_message "$YELLOW" "Missing dependencies: ${missing_deps[*]}"
        print_message "$YELLOW" "Please install them with:"
        print_message "$YELLOW" "sudo apt install ${missing_deps[*]}"
        exit 1
    fi
    
    # Check for optional tools
    command -v 7z >/dev/null 2>&1 || print_message "$YELLOW" "⚠ 7z not found. Install with: sudo apt install p7zip-full"
    command -v unrar >/dev/null 2>&1 || print_message "$YELLOW" "⚠ unrar not found. Install with: sudo apt install unrar"
    
    print_message "$GREEN" "✓ All required dependencies found"
}

# Function to install SMAPI
install_smapi() {
    print_header "STEP 2: INSTALLING SMAPI"
    
    # Check if SMAPI is already installed
    if [ -f "$GAME_DIR/StardewModdingAPI" ]; then
        print_message "$GREEN" "✓ SMAPI is already installed"
        read -p "Do you want to reinstall/update SMAPI? (y/n): " reinstall
        if [[ ! "$reinstall" =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    print_message "$BLUE" "Downloading latest SMAPI..."
    
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR" || exit 1
    
    SMAPI_URL=$(wget -qO- https://api.github.com/repos/Pathoschild/SMAPI/releases/latest | grep "browser_download_url.*installer\.zip" | cut -d '"' -f 4 | head -n 1)
    [ -z "$SMAPI_URL" ] && SMAPI_URL="https://github.com/Pathoschild/SMAPI/releases/latest/download/SMAPI-4.3.2-installer.zip"
    
    wget -q --show-progress "$SMAPI_URL" -O smapi.zip
    unzip -q smapi.zip
    
    # Capture the folder name correctly
    SMAPI_DIR=$(find . -maxdepth 1 -type d -name "SMAPI*" | head -n 1)
    cd "$SMAPI_DIR" || exit 1
    
    # Ensure permissions
    chmod +x "install on Linux.sh"
    chmod +x internal/linux/install.sh
    
    print_message "$YELLOW" "Opening SMAPI Installer..."

    # Define the command to run
    # Using 'bash -c' inside the terminal often fixes the Lubuntu crash
    INSTALL_CMD="bash './install on Linux.sh'"

    if command -v lxterminal >/dev/null 2>&1; then
        lxterminal -e "$INSTALL_CMD"
    elif command -v qterminal >/dev/null 2>&1; then
        qterminal -e "$INSTALL_CMD"
    elif command -v x-terminal-emulator >/dev/null 2>&1; then
        x-terminal-emulator -e "$INSTALL_CMD"
    else
        # If all else fails, run it in the current window
        ./"install on Linux.sh"
    fi

    if [ $? -eq 0 ]; then
        print_message "$GREEN" "✓ SMAPI installation session finished"
    else
        print_message "$RED" "Error: Installer exited with an error code"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Cleanup and Init
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    
    print_message "$BLUE" "Running SMAPI once to initialize mod folders..."
    cd "$GAME_DIR"
    timeout 5 ./StardewModdingAPI --no-terminal 2>/dev/null || true
}

# Function to select mod archive directory
select_mod_archive_directory() {
    print_header "STEP 3: SELECT MOD ARCHIVE DIRECTORY"
    
    echo -e "${YELLOW}⚠  WARNING ⚠${NC}"
    echo -e "${YELLOW}The utility will process ALL archive files (.zip, .7z, .rar)${NC}"
    echo -e "${YELLOW}in the specified directory. Only specify folders containing${NC}"
    echo -e "${YELLOW}mod archives you want to install!${NC}"
    echo ""
    
    read -p "Enter the directory containing mod archives [default: ~/Downloads]: " input_dir
    
    if [ -z "$input_dir" ]; then
        MOD_ARCHIVE_DIR="$HOME/Downloads"
    else
        MOD_ARCHIVE_DIR="${input_dir/#\~/$HOME}"
    fi
    
    if [ ! -d "$MOD_ARCHIVE_DIR" ]; then
        print_message "$RED" "Error: Directory does not exist: $MOD_ARCHIVE_DIR"
        exit 1
    fi
    
    # Count archives
    archive_count=$(find "$MOD_ARCHIVE_DIR" -maxdepth 1 -type f \( -name "*.zip" -o -name "*.7z" -o -name "*.rar" \) | wc -l)
    
    print_message "$GREEN" "✓ Archive directory set: $MOD_ARCHIVE_DIR"
    print_message "$BLUE" "Found $archive_count archive(s) to process"
    
    if [ $archive_count -eq 0 ]; then
        print_message "$YELLOW" "No archives found. Exiting."
        exit 0
    fi
    
    read -p "Continue with extraction? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_message "$YELLOW" "Cancelled by user."
        exit 0
    fi
}

# Function to extract archive without nesting
extract_archive() {
    local archive="$1"
    local temp_extract="$2"
    local extension="${archive##*.}"
    
    case "$extension" in
        zip)
            unzip -q "$archive" -d "$temp_extract" 2>/dev/null
            ;;
        7z)
            7z x "$archive" -o"$temp_extract" >/dev/null 2>&1
            ;;
        rar)
            unrar x "$archive" "$temp_extract/" >/dev/null 2>&1
            ;;
    esac
    
    return $?
}

# Function to find the actual mod folder
find_mod_folder() {
    local extract_dir="$1"
    
    # Look for manifest.json to identify the real mod folder
    local manifest=$(find "$extract_dir" -name "manifest.json" -type f | head -n 1)
    
    if [ -n "$manifest" ]; then
        dirname "$manifest"
    else
        echo "$extract_dir"
    fi
}

# Function to extract and install mods
extract_mods() {
    print_header "STEP 4: EXTRACTING AND INSTALLING MODS"
    
    MOD_DIR=$(get_mod_directory "$GAME_DIR")
    print_message "$BLUE" "Mod installation directory: $MOD_DIR"
    echo ""
    
    local success_count=0
    local fail_count=0
    
    # Process each archive
    for archive in "$MOD_ARCHIVE_DIR"/*.{zip,7z,rar}; do
        [ -f "$archive" ] || continue
        
        local filename=$(basename "$archive")
        local name_no_ext="${filename%.*}"
        
        print_message "$BLUE" "Processing: $filename"
        
        # Create temporary extraction directory
        local temp_extract=$(mktemp -d)
        
        # Extract archive
        if extract_archive "$archive" "$temp_extract"; then
            # Find the actual mod folder
            local mod_folder=$(find_mod_folder "$temp_extract")
            
            # Get the mod name from the deepest folder or use filename
            local mod_name=$(basename "$mod_folder")
            
            # If the extracted content is just files, use the archive name
            if [ "$mod_folder" == "$temp_extract" ]; then
                mod_name="$name_no_ext"
            fi
            
            local dest_dir="$MOD_DIR/$mod_name"
            
            # Check if mod already exists
            if [ -d "$dest_dir" ]; then
                print_message "$YELLOW" "  ⚠ Mod already exists, overwriting: $mod_name"
                rm -rf "$dest_dir"
            fi
            
            # Move mod to Mods directory
            mv "$mod_folder" "$dest_dir"
            
            print_message "$GREEN" "  ✓ Installed: $mod_name"
            
            # Delete the archive
            rm "$archive"
            
            ((success_count++))
        else
            print_message "$RED" "  ✗ Failed to extract: $filename"
            ((fail_count++))
        fi
        
        # Cleanup temp directory
        rm -rf "$temp_extract"
        
        echo ""
        sleep 0.5
    done
    
    print_header "INSTALLATION COMPLETE"
    print_message "$GREEN" "Successfully installed: $success_count mod(s)"
    
    if [ $fail_count -gt 0 ]; then
        print_message "$RED" "Failed to install: $fail_count mod(s)"
    fi
}

# Function to show completion message
show_completion() {
    echo ""
    print_message "$GREEN" "╔═══════════════════════════════════════════════════════════╗"
    print_message "$GREEN" "║                                                           ║"
    print_message "$GREEN" "║  All mods have been installed!                            ║"
    print_message "$GREEN" "║                                                           ║"
    print_message "$GREEN" "║  To play with mods, launch Stardew Valley using:          ║"
    print_message "$GREEN" "║  $GAME_DIR/StardewModdingAPI"
    print_message "$GREEN" "║                                                           ║"
    print_message "$GREEN" "║  Your mods are located at:                                ║"
    print_message "$GREEN" "║  $(get_mod_directory "$GAME_DIR")"
    print_message "$GREEN" "║                                                           ║"
    print_message "$GREEN" "╚═══════════════════════════════════════════════════════════╝"
    echo ""
}

# Main execution
main() {
    clear
    show_logo
    
    # Check if config exists
    if load_config; then
        print_message "$BLUE" "Found existing configuration:"
        print_message "$BLUE" "  Game Directory: $GAME_DIR"
        print_message "$BLUE" "  Mod Archive Directory: $MOD_ARCHIVE_DIR"
        echo ""
        read -p "Use existing configuration? (y/n): " use_config
        
        if [[ ! "$use_config" =~ ^[Yy]$ ]]; then
            select_game_directory
            check_dependencies
            install_smapi
            select_mod_archive_directory
            save_config
        else
            check_dependencies
        fi
    else
        select_game_directory
        check_dependencies
        install_smapi
        select_mod_archive_directory
        save_config
    fi
    
    extract_mods
    show_completion
}

# Run main function
main
