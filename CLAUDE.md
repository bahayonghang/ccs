# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CCS (Claude Code Configuration Switcher) is a command-line tool for quickly switching between different Claude Code API configurations. It supports multiple environments including Linux/macOS shell environments (Bash, Zsh, Fish) and Windows environments (CMD, PowerShell), using TOML configuration files to manage API settings.

## Architecture

The project consists of several shell scripts that work together:

### Linux/macOS Scripts
- **ccs.sh** - Main Bash script containing the core functionality for configuration switching
- **ccs.fish** - Fish shell version with equivalent functionality 
- **install.sh** - Installation script that handles setup for all supported shells
- **quick_install.sh** - One-click installation script that downloads and runs the installer

### Windows Scripts
- **ccs.bat** - Windows CMD batch script with equivalent functionality
- **ccs.ps1** - PowerShell script with equivalent functionality
- **install.bat** - Windows installation script that handles setup for CMD and PowerShell
- **quick_install.bat** - Windows one-click installation script

## Configuration System

The tool uses a TOML configuration file with the following structure:

### Linux/macOS
- Location: `~/.ccs_config.toml`

### Windows
- Location: `%USERPROFILE%\.ccs_config.toml`

```toml
default_config = "config_name"

[config_name]
description = "Configuration description"
base_url = "https://api.example.com"
auth_token = "your-api-key"
model = "model-name"
small_fast_model = "fast-model-name"  # Optional
```

## Environment Variables

CCS manages these Claude Code environment variables:
- `ANTHROPIC_BASE_URL` - API base URL
- `ANTHROPIC_AUTH_TOKEN` - API authentication token  
- `ANTHROPIC_MODEL` - Primary model to use
- `ANTHROPIC_SMALL_FAST_MODEL` - Fast model for background tasks

## Development Commands

### Testing Installation
```bash
# Test the installation script
./install.sh

# Test the quick install script
./quick_install.sh

# Test uninstall functionality
./install.sh --uninstall
```

### Shell Script Testing
```bash
# Source the main script to test functions
source ./ccs.sh

# Test individual functions
ccs list
ccs current
ccs help
ccs [config_name]
```

### Configuration Testing
Create a test configuration file and verify:
- Configuration parsing works correctly
- Environment variables are set properly
- Default configuration handling
- Error handling for missing configs

## Key Functions

### Linux/macOS Functions

#### ccs.sh Functions
- `parse_toml()` - Parses TOML configuration and sets environment variables
- `list_configs()` - Lists all available configurations with descriptions
- `show_current()` - Shows current environment variable settings
- `ccs()` - Main command dispatcher

#### ccs.fish Functions  
- `ccs()` - Main Fish function with similar functionality to Bash version
- `__ccs_complete()` - Provides autocompletion for Fish shell

#### install.sh Functions
- `detect_shell()` - Detects current shell type
- `configure_shell_for_type()` - Configures specific shell environments
- `copy_script()` - Copies script files to user directory
- `create_config_file()` - Creates initial configuration file

### Windows Functions

#### ccs.bat Functions
- `parse_toml()` - Parses TOML configuration and sets environment variables
- `list_configs()` - Lists all available configurations with descriptions
- `show_current()` - Shows current environment variable settings
- `ccs_help()` - Displays help information
- Main command dispatcher with switch-case logic

#### ccs.ps1 Functions
- `Parse-Toml()` - Parses TOML configuration and sets environment variables
- `List-Configs()` - Lists all available configurations with descriptions
- `Show-Current()` - Shows current environment variable settings
- `Show-Help()` - Displays help information
- `ccs()` - Main PowerShell function dispatcher

#### install.bat Functions
- `check_powershell()` - Verifies PowerShell availability
- `configure_powershell()` - Configures PowerShell profile
- `configure_path()` - Adds to Windows PATH environment variable
- `copy_script()` - Copies Windows scripts to user directory
- `create_config_file()` - Creates initial configuration file

## Installation Process

### Linux/macOS Installation Process
1. Creates `~/.ccs/` directory
2. Copies scripts to `~/.ccs/`
3. Creates `~/.ccs_config.toml` if it doesn't exist
4. Adds sourcing lines to shell configuration files (.bashrc, .zshrc, or fish config)
5. Sets proper permissions on scripts

### Windows Installation Process
1. Creates `%USERPROFILE%\.ccs\` directory
2. Copies scripts to `%USERPROFILE%\.ccs\`
3. Creates `%USERPROFILE%\.ccs_config.toml` if it doesn't exist
4. Configures PowerShell profile by importing scripts
5. Attempts to add scripts directory to PATH environment variable (requires admin privileges)
6. Sets proper file permissions for scripts

## Shell Compatibility

### Linux/macOS Shells
- **Bash**: Fully supported with complete functionality
- **Zsh**: Fully supported with complete functionality  
- **Fish**: Fully supported with complete functionality

### Windows Environments
- **CMD**: Fully supported with complete functionality (Windows 7+)
- **PowerShell**: Fully supported with complete functionality (PowerShell 5.1+)
- **Windows Terminal**: Fully supported
- **WSL**: Fully supported through Linux scripts

## Error Handling

The scripts include error handling for:
- Missing configuration files
- Invalid configuration names
- Missing required configuration fields
- Shell detection failures
- File permission issues
- PowerShell availability (Windows)
- Administrator privilege checking (Windows)
- PATH environment variable modification (Windows)
- TOML parsing errors across all platforms

## Testing Notes

When modifying scripts:
- Test with all supported shells (Bash, Zsh, Fish)
- Test with Windows environments (CMD, PowerShell)
- Verify configuration parsing with various TOML formats
- Check environment variable setting and unsetting
- Test installation and uninstallation processes
- Verify autocompletion functionality (Fish shell)
- Test administrator vs non-admin scenarios (Windows)
- Verify PATH environment variable changes persist
- Test Windows service restart requirements
- Validate cross-platform configuration file compatibility