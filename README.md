```
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
`--''           `--`----'      ---`-'                      |   ;/          `--''          `---'.|    '---'    
                                                           '---'                            `---`             
```
# AutoSMAPI

Automated SMAPI installation and mod management utilities for Stardew Valley on Linux.

## Overview

AutoSMAPI is a suite of two command-line tools that make installing and managing Stardew Valley mods effortless:

- **autosmapi.sh** - Automated SMAPI installer and mod extractor
- **autosmapi-manager.sh** - Interactive mod management tool

## Features

### AutoSMAPI (Installer)
- 🎮 Supports GOG and Steam installations
- 🔧 Automatic SMAPI download and installation
- 📦 Extracts mods from .zip, .7z, and .rar archives
- 💾 Saves your configuration for future use
- 🧹 Cleans up archive files after extraction

### AutoSMAPIManager (Mod Manager)
- 📋 Lists all installed mods with details (name, version, folder)
- 🗑️ Delete mods by name or list number
- 💾 Shares configuration with AutoSMAPI

## Installation

### Quick Install

```bash
# Download both scripts
wget https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/autosmapi.sh
wget https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/autosmapi-manager.sh

# Make them executable
chmod +x autosmapi.sh autosmapi-manager.sh

# Optional: Move to a directory in your PATH for easy access
sudo mv autosmapi.sh /usr/local/bin/autosmapi
sudo mv autosmapi-manager.sh /usr/local/bin/autosmapi-manager
```

### Manual Install

1. Clone this repository or download the scripts
2. Make them executable: `chmod +x autosmapi.sh autosmapi-manager.sh`
3. Run them from their location or add to your PATH

### Required Dependencies

- `unzip` - Extract .zip files
- `wget` - Download SMAPI
- `jq` - Parse JSON (for mod info display)

Install with:
```bash
sudo apt install unzip wget jq
```

### Optional Dependencies

For additional archive format support:

- `p7zip-full` - Extract .7z files
- `unrar` - Extract .rar files

Install with:
```bash
sudo apt install p7zip-full unrar
```

## Usage

### AutoSMAPI - Installing SMAPI and Mods

1. Run the installer:
   ```bash
   ./autosmapi.sh
   ```

2. Select your Stardew Valley installation:
   - **GOG**: `~/GOG Games/Stardew Valley/game`
   - **Steam (standard)**: `~/.local/share/Steam/steamapps/common/Stardew Valley`
   - **Steam (alternate)**: `~/.steam/steam/steamapps/common/Stardew Valley`
   - **Custom path**: Enter your own installation path

3. The script will automatically:
   - Download and install the latest SMAPI
   - Run SMAPI once to initialize mod folders

4. Specify your mod archive directory (e.g., `~/Downloads`)
   - ⚠️ **WARNING**: The utility will process ALL archive files in this directory

5. AutoSMAPI will:
   - Extract all .zip, .7z, and .rar files
   - Find the actual mod folders (using manifest.json)
   - Handle nested folders intelligently
   - Install mods to the correct location
   - Delete archives after successful extraction
   
### AutoSMAPIManager - Managing Installed Mods

```bash
./autosmapi-manager.sh
```

If you've already configured AutoSMAPI, the manager will use those settings. Otherwise, it will ask you to select your game directory.

#### Available Commands

Once in the manager, use these commands:

**List all mods:**
```bash
> list
```

**Delete a mod by name:**
```bash
> delete ModFolderName
```

For names with spaces:
```bash
> delete "Mod Folder Name"
```

**Delete a mod by number:**
```bash
> delete 5
```
(Deletes the 5th mod in the list)

**Show help:**
```bash
> help
```

**Exit:**
```bash
> exit
```
or
```bash
> quit
```

## Configuration

Both scripts share configuration stored at:
```
~/.config/autosmapi/config
```

This includes:
- Game directory path
- Mod archive directory path (AutoSMAPI only)

Delete this file to reconfigure from scratch.

## Supported Installations

### GOG
```
~/GOG Games/Stardew Valley/game
```

### Steam (Standard)
```
~/.local/share/Steam/steamapps/common/Stardew Valley
```

### Steam (Alternate)
```
~/.steam/steam/steamapps/common/Stardew Valley
```

### Custom
Specify any custom installation path when prompted.

## Running Stardew Valley with Mods

After installation, launch the game with SMAPI:

```bash
cd "/path/to/Stardew Valley"
./StardewModdingAPI
```

### Setting Steam to Auto-Launch with SMAPI

1. Right-click Stardew Valley in Steam → **Properties**
2. In **Launch Options**, add:
   ```bash
   ./StardewModdingAPI %command%
   ```
3. Close and launch normally from Steam

## Troubleshooting

### AutoSMAPI Issues

**"Directory does not exist" error**
- Verify you selected the correct installation type
- Check your Stardew Valley installation path
- For custom paths, use absolute paths (e.g., `/home/username/...`)

**"Missing dependencies" error**
- Install required packages: `sudo apt install unzip wget jq`
- For optional formats: `sudo apt install p7zip-full unrar`

**Archive extraction fails**
- Check that archive files are not corrupted
- Ensure optional dependencies are installed for .7z and .rar files
- Verify you have write permissions to the Mods directory

**Mods install but don't appear in game**
- Launch with `./StardewModdingAPI`, not the regular game executable
- Check the SMAPI console window for error messages
- Visit https://smapi.io/log to analyze your log file

### AutoSMAPIManager Issues

**"Mods directory not found" error**
- Run SMAPI at least once to create the Mods directory
- Use AutoSMAPI to install SMAPI if not already installed

**Mod names not showing correctly**
- Install jq: `sudo apt install jq`
- Without jq, only folder names will be displayed

**Can't find a mod to delete**
- Use the `list` command to see all installed mods
- Check the folder name shown in yellow brackets
- Try fuzzy matching - type part of the name and accept suggestions

**Deleted mod still appears in SMAPI**
- The game may have cached the mod
- Restart Stardew Valley completely
- Check the Mods directory to ensure it was actually deleted

### Planned Features
- Mod profile management
- Automatic mod updates

# Useful Links

- **SMAPI Official Site**: https://smapi.io/
- **SMAPI Mod Compatibility**: https://smapi.io/mods
- **Nexus Mods - Stardew Valley**: https://www.nexusmods.com/stardewvalley
