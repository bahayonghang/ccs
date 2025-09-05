# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CCS (Claude Code Configuration Switcher) is a cross-platform command-line tool for quickly switching between different Claude Code API configurations. It supports multiple shell environments (Bash, Zsh, Fish, PowerShell) across Linux, macOS, and Windows, using TOML configuration files for API management.

The tool enables global configuration persistence, allowing configuration changes made in one terminal to automatically apply to all new terminals, and includes a web interface for graphical configuration management.

## Essential Development Commands

### Build and Development
```bash
# Using just (recommended)
just --list                    # Show all available commands
just install                   # Install CCS to system
just test                      # Run basic functionality tests
just test-all                  # Test all shell scripts
just check-syntax              # Check script syntax
just web                       # Start web management interface

# Using make (fallback)
make help                      # Show available commands
make install                   # Install CCS to system
make test                      # Run basic functionality tests
make check-syntax              # Check script syntax
```

### Testing and Validation
```bash
# Test installation
./scripts/install/install.sh

# Test core functionality
source ./scripts/shell/ccs.sh
ccs list
ccs current
ccs help

# Test Fish support (if available)
fish scripts/shell/ccs.fish help

# Test Windows scripts (on Windows)
powershell scripts/windows/ccs.ps1
cmd scripts/windows/ccs.bat
```

### Quick Install and Uninstall
```bash
# Quick install
./scripts/install/quick_install/quick_install.sh

# Uninstall
./scripts/install/install.sh --uninstall
# or
ccs uninstall
```

## Architecture Overview

### Core Components
- **Shell Scripts** (`scripts/shell/`): Linux/macOS core functionality
  - `ccs.sh`: Bash main script with `ccs()` function
  - `ccs.fish`: Fish shell implementation
  - `ccs-common.sh`: Shared utility library
- **Windows Scripts** (`scripts/windows/`): Windows environment support
  - `ccs.ps1`: PowerShell script
  - `ccs.bat`: CMD batch script
- **Installation System** (`scripts/install/`): Cross-platform installation
- **Web Interface** (`web/index.html`): Graphical configuration management

### Configuration System
- **Location**: `~/.ccs_config.toml` (Linux/macOS) or `%USERPROFILE%\.ccs_config.toml` (Windows)
- **Format**: TOML with global settings and named configuration sections
- **Environment Variables**: Automatically manages `ANTHROPIC_*` environment variables

### Key Workflow
1. User runs `ccs [config_name]` command
2. Script parses TOML configuration file
3. Sets appropriate environment variables (`ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN`, etc.)
4. Updates `current_config` in TOML file for persistence
5. New terminals automatically load the current configuration

## File Structure

```
ccs/
├── scripts/                    # Core scripts
│   ├── shell/                 # Linux/macOS shell scripts
│   ├── windows/               # Windows scripts  
│   └── install/               # Installation scripts
├── config/                    # Configuration templates
├── web/                       # Web interface
├── docs/                      # Documentation
├── justfile                   # Just task runner (recommended)
├── Makefile                   # Make fallback
└── package.json              # Project metadata
```

## Development Standards

### Shell Script Standards
- Use `set -e` for error handling in installation scripts
- Implement colored output with fallback for non-TTY environments
- Modular design with shared functions in `ccs-common.sh`
- Cross-shell compatibility (Bash 4.0+, Zsh, Fish 3.0+)

### Configuration Format
```toml
default_config = "config_name"
current_config = "config_name"  # Auto-managed

[config_name]
description = "Configuration description"
base_url = "https://api.example.com"
auth_token = "your-api-key"
model = "model-name"  # Optional
small_fast_model = "fast-model"  # Optional
```

### Testing Requirements
- Syntax validation for all shell scripts
- Cross-platform installation testing
- Configuration parsing validation
- Environment variable verification

## Key Functions and Entry Points

### Main Entry Points
- **ccs.sh**: `ccs()` function - main Bash entry point
- **ccs.fish**: `ccs()` function - Fish shell entry point
- **install.sh**: `detect_shell()`, `setup_shell_integration()`

### Core Utilities (ccs-common.sh)
- `parse_toml()`: TOML configuration parsing
- `validate_config_file()`: Configuration validation
- `handle_error()`: Unified error handling
- `get_system_info()`: System information detection

### Configuration Management
- `update_current_config()`: Persist current configuration
- `load_current_config()`: Auto-load configuration on shell startup
- Environment variable setting based on configuration sections

## Platform-Specific Notes

### Linux/macOS
- Scripts installed to `~/.ccs/`
- Shell integration via `.bashrc`, `.zshrc`, Fish config
- Uses `source` for shell integration

### Windows  
- Scripts installed to `%USERPROFILE%\.ccs\`
- PowerShell profile integration
- PATH environment variable configuration
- Registry-based environment variable persistence

### Cross-Platform Considerations
- Path handling differences (forward vs. backward slashes)
- Environment variable syntax differences
- Shell detection and configuration methods
- Permission and execution policy handling