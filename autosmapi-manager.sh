#!/bin/bash

# AutoSMAPIManager
# Mod management tool for AutoSMAPI

# Color codes for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Config file location
CONFIG_FILE="$HOME/.config/autosmapi/config"

# Function to display the Stardew Valley chicken ASCII art
show_logo() {
    echo -e "${YELLOW}"
    cat << "EOF"
                                          
                                   ____   
   ,---,       .--.--.           ,'  , `. 
  '  .' \     /  /    '.      ,-+-,.' _ | 
 /  ;    '.  |  :  /`. /   ,-+-. ;   , || 
:  :       \ ;  |  |--`   ,--.'|'   |  ;| 
:  |   /\   \|  :  ;_    |   |  ,', |  ': 
|  :  ' ;.   :\  \    `. |   | /  | |  || 
|  |  ;/  \   \`----.   \'   | :  | :  |, 
'  :  | \  \ ,'__ \  \  |;   . |  ; |--'  
|  |  '  '--' /  /`--'  /|   : |  | ,     
|  :  :      '--'.     / |   : '  |/      
|  | ,'        `--'---'  ;   | |`-'       
`--''                    |   ;/           
                         '---'

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
    print_header "SELECT GAME DIRECTORY"
    
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

# Function to get mod directory
get_mod_directory() {
    local game_dir="$1"
    
    # Look for Mods directory inside the game directory
    local mod_dir="$game_dir/Mods"
    
    if [ ! -d "$mod_dir" ]; then
        print_message "$RED" "Error: Mods directory not found at: $mod_dir"
        print_message "$YELLOW" "Have you run SMAPI at least once?"
        print_message "$YELLOW" "SMAPI creates the Mods folder on first run."
        exit 1
    fi
    
    echo "$mod_dir"
}

# Function to calculate Levenshtein distance (for fuzzy matching)
levenshtein() {
    local s1="$1"
    local s2="$2"
    local len1=${#s1}
    local len2=${#s2}
    
    # Convert to lowercase for case-insensitive comparison
    s1=$(echo "$s1" | tr '[:upper:]' '[:lower:]')
    s2=$(echo "$s2" | tr '[:upper:]' '[:lower:]')
    
    # Simple implementation - just count character differences for basic fuzzy matching
    local diff=0
    local max_len=$len1
    [ $len2 -gt $max_len ] && max_len=$len2
    
    # If lengths are very different, return high distance
    if [ $((max_len - ${#s1})) -gt 3 ] || [ $((max_len - ${#s2})) -gt 3 ]; then
        echo $max_len
        return
    fi
    
    # Check for substring match
    if [[ "$s2" == *"$s1"* ]] || [[ "$s1" == *"$s2"* ]]; then
        echo 1
        return
    fi
    
    # Simple character difference count
    for ((i=0; i<len1 && i<len2; i++)); do
        if [ "${s1:$i:1}" != "${s2:$i:1}" ]; then
            ((diff++))
        fi
    done
    
    diff=$((diff + (len1 > len2 ? len1 - len2 : len2 - len1)))
    echo $diff
}

# Function to find similar mod names
find_similar_mods() {
    local search_name="$1"
    local mod_dir="$2"
    local max_distance=3
    local similar_mods=()
    
    # Get all mod folders
    while IFS= read -r mod; do
        local mod_name=$(basename "$mod")
        local distance=$(levenshtein "$search_name" "$mod_name")
        
        if [ "$distance" -le "$max_distance" ]; then
            similar_mods+=("$mod_name:$distance")
        fi
    done < <(find "$mod_dir" -mindepth 1 -maxdepth 1 -type d)
    
    # Sort by distance and return top 3
    printf '%s\n' "${similar_mods[@]}" | sort -t: -k2 -n | head -n 3 | cut -d: -f1
}

# Function to list all mods
list_mods() {
    local mod_dir="$1"
    local mods=()
    local count=1
    
    print_header "INSTALLED MODS"
    
    # Check if mods directory has any mods
    if [ -z "$(ls -A "$mod_dir" 2>/dev/null)" ]; then
        print_message "$YELLOW" "No mods installed yet!"
        echo ""
        return 1
    fi
    
    print_message "$BLUE" "Mods directory: $mod_dir"
    echo ""
    
    # List all mod directories
    while IFS= read -r mod; do
        local mod_name=$(basename "$mod")
        
        # Check if it has a manifest.json to verify it's a real mod
        if [ -f "$mod/manifest.json" ]; then
            # Try to get mod name and version from manifest
            if command -v jq >/dev/null 2>&1; then
                local display_name=$(jq -r '.Name // empty' "$mod/manifest.json" 2>/dev/null)
                local version=$(jq -r '.Version // empty' "$mod/manifest.json" 2>/dev/null)
                
                if [ -n "$display_name" ]; then
                    printf "${GREEN}%3d)${NC} ${CYAN}%-40s${NC} ${MAGENTA}v%-10s${NC} ${YELLOW}[%s]${NC}\n" \
                        "$count" "$display_name" "$version" "$mod_name"
                else
                    printf "${GREEN}%3d)${NC} ${CYAN}%-40s${NC}\n" "$count" "$mod_name"
                fi
            else
                printf "${GREEN}%3d)${NC} ${CYAN}%-40s${NC}\n" "$count" "$mod_name"
            fi
        else
            printf "${GREEN}%3d)${NC} ${YELLOW}%-40s${NC} ${RED}(no manifest)${NC}\n" "$count" "$mod_name"
        fi
        
        mods+=("$mod_name")
        ((count++))
    done < <(find "$mod_dir" -mindepth 1 -maxdepth 1 -type d | sort)
    
    echo ""
    print_message "$BLUE" "Total mods: $((count - 1))"
    
    # Store mods array for later use
    INSTALLED_MODS=("${mods[@]}")
    
    return 0
}

# Function to delete a mod
delete_mod() {
    local mod_name="$1"
    local mod_dir="$2"
    local target_dir="$mod_dir/$mod_name"
    
    # Check if mod exists
    if [ ! -d "$target_dir" ]; then
        print_message "$RED" "✗ Mod not found: $mod_name"
        
        # Find similar mods
        print_message "$YELLOW" "Looking for similar mod names..."
        local similar=$(find_similar_mods "$mod_name" "$mod_dir")
        
        if [ -n "$similar" ]; then
            echo ""
            print_message "$YELLOW" "Did you mean one of these?"
            local count=1
            while IFS= read -r similar_mod; do
                echo -e "${GREEN}  $count)${NC} $similar_mod"
                ((count++))
            done <<< "$similar"
            
            echo ""
            read -p "Enter number to delete (or press Enter to cancel): " choice
            
            if [ -n "$choice" ] && [ "$choice" -ge 1 ] && [ "$choice" -lt "$count" ]; then
                local selected_mod=$(echo "$similar" | sed -n "${choice}p")
                delete_mod "$selected_mod" "$mod_dir"
                return
            else
                print_message "$YELLOW" "Cancelled."
                return
            fi
        else
            print_message "$YELLOW" "No similar mod names found."
        fi
        
        return 1
    fi
    
    # Confirm deletion
    echo ""
    print_message "$YELLOW" "⚠  WARNING: This will permanently delete the mod folder!"
    print_message "$YELLOW" "Mod to delete: $mod_name"
    print_message "$YELLOW" "Path: $target_dir"
    echo ""
    read -p "Are you sure you want to delete this mod? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ] || [ "$confirm" = "y" ]; then
        rm -rf "$target_dir"
        
        if [ $? -eq 0 ]; then
            print_message "$GREEN" "✓ Successfully deleted: $mod_name"
        else
            print_message "$RED" "✗ Failed to delete: $mod_name"
            return 1
        fi
    else
        print_message "$YELLOW" "Deletion cancelled."
    fi
}

# Function to show help
show_help() {
    echo ""
    print_message "$CYAN" "Available commands:"
    echo ""
    echo -e "${GREEN}  delete <mod_name>${NC}  - Delete a mod by folder name"
    echo -e "${GREEN}  delete <number>${NC}    - Delete a mod by its list number"
    echo -e "${GREEN}  list${NC}               - Refresh the mod list"
    echo -e "${GREEN}  help${NC}               - Show this help message"
    echo -e "${GREEN}  exit${NC} or ${GREEN}quit${NC}      - Exit the manager"
    echo ""
    print_message "$YELLOW" "Tip: Mod names with spaces need quotes, e.g., delete \"Mod Name\""
    print_message "$YELLOW" "Tip: The manager will suggest similar names if not found!"
    echo ""
}

# Function to handle user commands
handle_command() {
    local mod_dir="$1"
    
    while true; do
        echo ""
        print_message "$BLUE" "╔═══════════════════════════════════════════════════════════╗"
        print_message "$BLUE" "║  Enter command (type 'help' for available commands)      ║"
        print_message "$BLUE" "╚═══════════════════════════════════════════════════════════╝"
        echo ""
        read -p "> " command args
        
        # Combine command and args if they were split
        if [ -n "$args" ]; then
            full_input="$command $args"
        else
            full_input="$command"
        fi
        
        case "$command" in
            delete)
                if [ -z "$args" ]; then
                    print_message "$RED" "Error: Please specify a mod name or number"
                    echo "Usage: delete <mod_name> or delete <number>"
                else
                    # Check if it's a number
                    if [[ "$args" =~ ^[0-9]+$ ]]; then
                        # Delete by number
                        local index=$((args - 1))
                        if [ "$index" -ge 0 ] && [ "$index" -lt "${#INSTALLED_MODS[@]}" ]; then
                            delete_mod "${INSTALLED_MODS[$index]}" "$mod_dir"
                            echo ""
                            list_mods "$mod_dir"
                        else
                            print_message "$RED" "Error: Invalid mod number"
                        fi
                    else
                        # Delete by name (remove quotes if present)
                        local mod_name=$(echo "$args" | sed 's/^["'\'']\|["'\'']$//g')
                        delete_mod "$mod_name" "$mod_dir"
                        echo ""
                        list_mods "$mod_dir"
                    fi
                fi
                ;;
            list)
                list_mods "$mod_dir"
                ;;
            help)
                show_help
                ;;
            exit|quit)
                echo ""
                print_message "$GREEN" "Thanks for using AutoSMAPIManager!"
                print_message "$YELLOW" "Happy farming! 🌾🐔"
                echo ""
                exit 0
                ;;
            "")
                # Empty command, just show prompt again
                ;;
            *)
                print_message "$RED" "Unknown command: $command"
                print_message "$YELLOW" "Type 'help' for available commands"
                ;;
        esac
    done
}

# Main execution
main() {
    clear
    show_logo
    
    # Check if config exists and load it
    if load_config && [ -n "$GAME_DIR" ]; then
        print_message "$BLUE" "Found existing configuration:"
        print_message "$BLUE" "  Game Directory: $GAME_DIR"
        echo ""
        read -p "Use existing configuration? (y/n): " use_config
        
        if [[ ! "$use_config" =~ ^[Yy]$ ]]; then
            select_game_directory
        fi
    else
        select_game_directory
    fi
    
    # Get mod directory
    MOD_DIR=$(get_mod_directory "$GAME_DIR")
    
    # List all mods
    list_mods "$MOD_DIR"
    
    # Show help
    show_help
    
    # Enter command loop
    handle_command "$MOD_DIR"
}

# Run main function
main
