                                                                                                              
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
- 🗂️ Intelligently handles nested folders (finds manifest.json automatically)
- 💾 Saves your configuration for future use
- 🧹 Cleans up archive files after extraction
- 🎨 Colorful terminal interface

### AutoSMAPIManager (Mod Manager)
- 📋 Lists all installed mods with details (name, version, folder)
- 🗑️ Delete mods by name or list number
- 🔍 Fuzzy matching - suggests similar mod names if you mistype
- ⚠️ Safety confirmations before deletion
- 💾 Shares configuration with AutoSMAPI
- 🎨 Matching colorful interface

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

## Requirements

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

#### First Run

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

#### Subsequent Runs

AutoSMAPI remembers your configuration! Just run it again and choose whether to use saved settings or reconfigure.

### AutoSMAPIManager - Managing Installed Mods

#### Starting the Manager

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

#### Fuzzy Matching Example

If you mistype a mod name, AutoSMAPIManager will suggest similar names:

```bash
> delete ChstAnywher
✗ Mod not found: ChstAnywher
Looking for similar mod names...

Did you mean one of these?
  1) ChestsAnywhere
  2) ChestPooling
  
Enter number to delete (or press Enter to cancel): 1

⚠  WARNING: This will permanently delete the mod folder!
Mod to delete: ChestsAnywhere
Path: /home/user/.config/StardewValley/Mods/ChestsAnywhere

Are you sure you want to delete this mod? (yes/no): yes
✓ Successfully deleted: ChestsAnywhere
```

## How It Works

### AutoSMAPI Installation Process

1. **Game Directory Selection**: Choose your Stardew Valley installation
2. **Dependency Check**: Verifies required tools are installed
3. **SMAPI Installation**: 
   - Downloads latest SMAPI from GitHub
   - Extracts and runs the installer
   - Initializes mod folders
4. **Mod Archive Processing**:
   - Scans your specified directory for archives
   - Extracts each archive to a temporary location
   - Searches for manifest.json to identify the real mod folder
   - Moves the mod to the correct Mods directory
   - Deletes the archive file

### AutoSMAPIManager Mod Display

The manager shows comprehensive mod information:

```
  1) Automate                              v2.3.1         [Automate]
  2) Chests Anywhere                       v1.25.2        [ChestsAnywhere]
  3) Content Patcher                       v2.3.0         [ContentPatcher]
 42) MyCustomMod                                          [MyCustomMod]
 43) BrokenMod                             (no manifest)
```

- **Green number**: Index for quick deletion
- **Cyan name**: Display name from manifest.json
- **Magenta version**: Mod version
- **Yellow brackets**: Actual folder name
- **Red warning**: Mods without a valid manifest.json

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

## Mods Directory

Mods are installed to a `Mods` folder inside your game directory. For example:
- GOG: `~/GOG Games/Stardew Valley/game/Mods`
- Steam: `~/.local/share/Steam/steamapps/common/Stardew Valley/Mods`
- Steam (alt): `~/.steam/steam/steamapps/common/Stardew Valley/Mods`

SMAPI creates this folder automatically on first run.

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

## Supported Archive Formats

- `.zip` - Always supported (requires unzip)
- `.7z` - Requires p7zip-full
- `.rar` - Requires unrar

## Examples

### Example: Installing Mods

```bash
$ ./autosmapi.sh

[AutoSMAPI Logo]

SELECT GAME DIRECTORY

Please select your Stardew Valley installation:

1) GOG: ~/GOG Games/Stardew Valley/game
2) Steam: ~/.local/share/Steam/steamapps/common/Stardew Valley
3) Steam (alternate): ~/.steam/steam/steamapps/common/Stardew Valley
4) Custom path

Enter your choice (1-4): 2
✓ Game directory set: /home/user/.local/share/Steam/steamapps/common/Stardew Valley

[SMAPI Installation proceeds...]

SELECT MOD ARCHIVE DIRECTORY

⚠  WARNING ⚠
The utility will process ALL archive files (.zip, .7z, .rar)
in the specified directory. Only specify folders containing
mod archives you want to install!

Enter the directory containing mod archives [default: ~/Downloads]: 
✓ Archive directory set: /home/user/Downloads
Found 5 archive(s) to process

Continue with extraction? (y/n): y

EXTRACTING AND INSTALLING MODS

Processing: Automate-2.3.1.zip
  ✓ Installed: Automate

Processing: ChestsAnywhere-1.25.2.zip
  ✓ Installed: ChestsAnywhere

[...]

Successfully installed: 5 mod(s)
```

### Example: Managing Mods

```bash
$ ./autosmapi-manager.sh

[AutoSMAPIManager Logo]

Found existing configuration:
  Game Directory: /home/user/.local/share/Steam/steamapps/common/Stardew Valley

Use existing configuration? (y/n): y

INSTALLED MODS

Mods directory: /home/user/.config/StardewValley/Mods

  1) Automate                              v2.3.1         [Automate]
  2) Chests Anywhere                       v1.25.2        [ChestsAnywhere]
  3) Content Patcher                       v2.3.0         [ContentPatcher]

Total mods: 3

╔═══════════════════════════════════════════════════════════╗
║  Enter command (type 'help' for available commands)      ║
╚═══════════════════════════════════════════════════════════╝

> delete 2

⚠  WARNING: This will permanently delete the mod folder!
Mod to delete: ChestsAnywhere
Path: /home/user/.config/StardewValley/Mods/ChestsAnywhere

Are you sure you want to delete this mod? (yes/no): yes
✓ Successfully deleted: ChestsAnywhere

> exit

Thanks for using AutoSMAPIManager!
Happy farming! 🌾🐔
```

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

## Safety Features

### AutoSMAPI
- ⚠️ Warns before processing archives
- ✓ Checks dependencies before proceeding
- ✓ Validates paths before processing
- ✓ Overwrites existing mods (with backup capability)
- ✓ Only deletes archives after successful extraction

### AutoSMAPIManager
- ⚠️ Requires "yes" confirmation before deletion
- ✓ Shows full path before deleting
- ✓ Suggests similar names if mod not found
- ✓ Validates mod numbers
- ✓ Clear error messages

## Tips and Best Practices

1. **Keep a backup**: Before mass-installing mods, back up your Mods directory
2. **Check compatibility**: Visit https://smapi.io/mods to check mod compatibility with your game version
3. **Read mod descriptions**: Some mods require dependencies (like Content Patcher)
4. **Use AutoSMAPIManager regularly**: Clean out old/unused mods to keep things tidy
5. **Check SMAPI logs**: If mods don't work, the SMAPI console will tell you why
6. **Update SMAPI**: Run AutoSMAPI periodically to update to the latest SMAPI version
7. **One archive directory**: Keep all your mod archives in one folder for easy batch installation

## Workflow Recommendations

### Installing New Mods
1. Download mod archives to your Downloads folder (or dedicated mod folder)
2. Run `./autosmapi.sh`
3. Let it extract and install all mods at once
4. Launch Stardew Valley with SMAPI to test

### Managing Existing Mods
1. Run `./autosmapi-manager.sh`
2. Review your installed mods with `list`
3. Delete unwanted mods with `delete <name>` or `delete <number>`
4. Exit and launch the game

### Updating Mods
1. Run `./autosmapi-manager.sh`
2. Delete the old version: `delete OldModName`
3. Download the new version to your archive directory
4. Run `./autosmapi.sh` to install the update

## Contributing

Feel free to submit issues, feature requests, or pull requests!

### Planned Features
- Mod update checker
- Backup/restore functionality
- Mod profile management
- Integration with Nexus Mods API

## License

MIT License - Feel free to use and modify as needed.

## Credits

- **SMAPI** by Pathoschild: https://smapi.io/
- **Stardew Valley** by ConcernedApe
- ASCII art logos created for AutoSMAPI

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Verify all dependencies are installed
3. Check the SMAPI log at https://smapi.io/log
4. Review the AutoSMAPI output for error messages
5. Open an issue on GitHub with:
   - Your Linux distribution and version
   - The exact error message
   - Steps to reproduce the problem

## Useful Links

- **SMAPI Official Site**: https://smapi.io/
- **SMAPI Mod Compatibility**: https://smapi.io/mods
- **Stardew Valley Wiki**: https://stardewvalleywiki.com/
- **Stardew Valley Subreddit**: https://reddit.com/r/StardewValley
- **Nexus Mods - Stardew Valley**: https://www.nexusmods.com/stardewvalley

---

Happy farming! 🌾🐔
