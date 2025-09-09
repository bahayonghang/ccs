# CODEBUDDY.md

This file provides guidance to CodeBuddy when working with code in this repository.

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
  - `ccs.sh`: Main Bash script with `ccs()` function - entry point for all operations
  - `ccs.fish`: Fish shell implementation with identical functionality
  - `ccs-common.sh`: Shared utility library with TOML parsing, error handling, logging
- **Windows Scripts** (`scripts/windows/`): Windows environment support
  - `ccs.ps1`: PowerShell script
  - `ccs.bat`: CMD batch script
- **Installation System** (`scripts/install/`): Cross-platform installation with shell detection
- **Web Interface** (`web/index.html`): Graphical configuration management

### Configuration System
- **Location**: `~/.ccs_config.toml` (Linux/macOS) or `%USERPROFILE%\.ccs_config.toml` (Windows)
- **Format**: TOML with global settings and named configuration sections
- **Environment Variables**: Automatically manages `ANTHROPIC_*` environment variables
- **Caching**: Performance-optimized configuration parsing with caching system

### Key Workflow
1. User runs `ccs [config_name]` command
2. Script parses TOML configuration file using optimized parser
3. Sets appropriate environment variables (`ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN`, etc.)
4. Updates `current_config` in TOML file for global persistence
5. New terminals automatically load the current configuration via shell integration

## File Structure

```
ccs/
├── scripts/                    # Core scripts
│   ├── shell/                 # Linux/macOS shell scripts
│   │   ├── ccs.sh             # Main Bash entry point
│   │   ├── ccs.fish           # Fish shell implementation  
│   │   └── ccs-common.sh      # Shared utility library
│   ├── windows/               # Windows scripts  
│   └── install/               # Installation scripts
├── config/                    # Configuration templates
│   └── .ccs_config.toml.example  # Example configuration
├── web/                       # Web interface
│   └── index.html            # Configuration management UI
├── docs/                      # Documentation
├── justfile                   # Just task runner (recommended)
├── Makefile                   # Make fallback
└── package.json              # Project metadata
```

## Development Standards

### Shell Script Standards
- Use `set -euo pipefail` for strict error handling in installation scripts
- Implement colored output with fallback for non-TTY environments
- Modular design with shared functions in `ccs-common.sh`
- Cross-shell compatibility (Bash 4.0+, Zsh, Fish 3.0+)
- Performance-optimized TOML parsing with caching
- Security: Validate file permissions (600) for configuration files

### Configuration Format
```toml
default_config = "config_name"
current_config = "config_name"  # Auto-managed by system

[config_name]
description = "Configuration description"
base_url = "https://api.example.com"
auth_token = "your-api-key"
model = "model-name"  # Optional
small_fast_model = "fast-model"  # Optional
```

### Testing Requirements
- Syntax validation for all shell scripts using `bash -n` and `fish -n`
- Cross-platform installation testing
- Configuration parsing validation with error handling
- Environment variable verification
- Web interface functionality testing

## Key Functions and Entry Points

### Main Entry Points
- **ccs.sh**: `ccs()` function - main Bash entry point at scripts/shell/ccs.sh:1
- **ccs.fish**: `ccs()` function - Fish shell entry point
- **install.sh**: `detect_shell()`, `setup_shell_integration()` - installation logic

### Core Utilities (ccs-common.sh)
- `parse_toml()`: Optimized TOML configuration parsing with caching
- `validate_config_file()`: Configuration validation with detailed error reporting
- `handle_error()`: Unified error handling with logging
- `get_system_info()`: System information detection for cross-platform support
- `log_debug()`, `log_info()`, `log_error()`: Structured logging system

### Configuration Management
- `update_current_config()`: Persist current configuration with atomic updates
- `load_current_config()`: Auto-load configuration on shell startup
- Environment variable setting based on configuration sections
- Configuration caching for performance optimization

## Platform-Specific Notes

### Linux/macOS
- Scripts installed to `~/.ccs/`
- Shell integration via `.bashrc`, `.zshrc`, Fish config files
- Uses `source` for shell integration
- File permissions set to 600 for security

### Windows  
- Scripts installed to `%USERPROFILE%\.ccs\`
- PowerShell profile integration
- PATH environment variable configuration
- Registry-based environment variable persistence

### Cross-Platform Considerations
- Path handling differences (forward vs. backward slashes)
- Environment variable syntax differences (`$VAR` vs `%VAR%`)
- Shell detection and configuration methods
- Permission and execution policy handling
- TOML parsing compatibility across platforms

## Performance Optimizations

### Caching System
- Configuration file parsing results cached for 5x speed improvement
- Smart cache invalidation based on file modification time
- Memory-efficient caching for large configuration files

### Error Handling
- Comprehensive error codes and messages
- Graceful degradation when optional dependencies unavailable
- Detailed logging for troubleshooting
- Automatic configuration file repair for common issues

## Security Considerations

- API keys never displayed in full (masked output)
- Configuration files have restricted permissions (600)
- No external telemetry or data collection
- All operations performed locally
- Input validation for configuration values