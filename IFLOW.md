# iFlow CLI - CCS Project Context

## Project Overview

**CCS (Claude Code Configuration Switcher)** is a powerful cross-platform command-line tool designed to quickly switch between different Claude Code API configurations. It provides global configuration persistence, web interface management, and intelligent model selection, with full support for multiple shell environments including Bash, Zsh, Fish, and PowerShell.

### Key Features
- 🔄 **One-Command Switching** - Switch between API providers instantly
- 🌐 **Web Interface** - Visual configuration management
- 🔧 **Cross-Platform** - Works on Linux, macOS, Windows
- 🐚 **Multi-Shell** - Supports Bash, Zsh, Fish, PowerShell
- 🔗 **Global Persistence** - Configuration persists across all terminals
- 📝 **Simple Config** - Human-readable TOML format

## Project Structure

```
/home/lyh/Documents/Github/ccs/
├── scripts/                    # Core scripts and installation
│   ├── shell/                  # Shell scripts (ccs.sh, ccs.fish, ccs-common.sh)
│   ├── install/                # Installation scripts
│   └── windows/                # Windows-specific scripts
├── config/                     # Configuration files
│   └── .ccs_config.toml.example # Example configuration
├── web/                        # Web interface (index.html)
├── docs/                       # Comprehensive documentation
├── assets/imgs/                # Screenshots and images
├── justfile                    # Primary build tool (recommended)
├── Makefile                    # Alternative build tool
└── package.json                # Project metadata
```

## Development Commands

### Primary Build Tool (Just - Recommended)
```bash
# Installation and Setup
just install              # Install CCS to system (Linux/macOS)
just install-windows      # Install CCS to Windows
just quick-install        # One-line installation script
just uninstall           # Uninstall CCS

# Testing and Validation
just test                # Run basic functionality tests
just test-all           # Test all shell scripts
just check-syntax       # Check script syntax
just validate-config    # Validate configuration files

# Web Interface
just web                # Launch web configuration interface
just web-dev           # Start development web server

# Development and Maintenance
just check-structure    # Verify project structure
just diagnose          # System environment diagnostics
just health-check      # Comprehensive health check
just fix-permissions   # Fix file permissions

# Configuration Management
just list-configs      # List all configurations
just current-config    # Show current configuration
just switch-config CONFIG  # Switch to specific configuration
just edit-config       # Edit configuration file
just backup-config     # Backup current configuration
```

### Alternative Build Tool (Make)
```bash
make help              # Show all available commands
make install          # Install CCS
make test             # Run tests
make web              # Launch web interface
make diagnose         # System diagnostics
make health-check     # Comprehensive check
```

## Core Configuration

### Configuration File Location
- **User Config**: `~/.ccs_config.toml`
- **Example Config**: `config/.ccs_config.toml.example`

### Supported API Providers
- **Anthropic** - Official Claude API
- **OpenAI** - GPT models
- **GLM** - 智谱AI
- **AnyRouter** - AnyRouter API service
- **SiliconFlow** - SiliconFlow API
- **Moonshot** - 月之暗面 (Kimi)
- **AICodeMirror** - AICodeMirror API
- **WenWen** - 文文AI API

### Configuration Format
```toml
default_config = "anthropic"
current_config = "anthropic"

[anthropic]
description = "Anthropic Official API"
base_url = "https://api.anthropic.com"
auth_token = "sk-ant-your-api-key-here"
model = ""  # Optional for Claude APIs
```

## Usage Patterns

### Basic Commands
```bash
ccs [config_name]     # Switch to specific configuration
ccs list             # List all available configurations
ccs current          # Show current configuration status
ccs web              # Launch web interface
ccs update           # Auto-update to latest version
```

### Advanced Features
```bash
ccs backup           # Backup current configuration
ccs verify           # Verify configuration integrity
ccs diagnose         # Run system diagnostics
ccs clear-cache      # Clear configuration cache
ccs test-config NAME # Test configuration connectivity
```

## Development Guidelines

### Code Standards
- **Shell Scripts**: Follow POSIX compliance where possible
- **Error Handling**: Use comprehensive error handling with specific error codes
- **Logging**: Implement debug logging with LOG_LEVEL environment variable
- **Cross-Platform**: Ensure compatibility across Linux, macOS, Windows

### Testing Requirements
- **Syntax Validation**: All scripts must pass syntax checks
- **Cross-Shell Testing**: Test with Bash, Zsh, Fish where applicable
- **Configuration Validation**: Verify TOML configuration parsing
- **Integration Testing**: Test complete workflow scenarios

### Performance Considerations
- **Configuration Caching**: Smart caching system for 5x performance improvement
- **Fast TOML Parser**: Optimized configuration parsing algorithms
- **Memory Management**: Efficient memory usage for large configuration files
- **Background Loading**: Asynchronous configuration loading

## Security Features

- **Sensitive Information Masking**: API keys are never displayed in full
- **Secure File Permissions**: Configuration files have restricted permissions (600)
- **No Telemetry**: No data collection or external communication
- **Local Processing**: All operations performed locally

## Troubleshooting

### Common Issues
1. **Command not found**: Run `source ~/.bashrc` or restart terminal
2. **Configuration not persisting**: Run `ccs diagnose` and `ccs status`
3. **Permission errors**: Use `just fix-permissions` or `chmod 600 ~/.ccs_config.toml`
4. **Web interface issues**: Check Python availability and firewall settings

### Debug Mode
```bash
ccs --debug [command]           # Enable debug mode
LOG_LEVEL=DEBUG ccs list        # Environment variable debug
```

## Build and Deployment

### Development Setup
```bash
git clone https://github.com/bahayonghang/ccs.git
cd ccs
just install                    # or: make install
just dev-setup                 # Developer environment setup
```

### Testing Suite
```bash
just full-test                 # Complete test suite
just check-syntax             # Syntax validation
just validate-config          # Configuration validation
just health-check            # Comprehensive health check
```

### Release Process
```bash
just build                     # Create distribution package
just check-release            # Verify release readiness
just clean                    # Clean build artifacts
```

## Documentation

Comprehensive documentation available in `docs/` directory:
- `architecture.md` - Technical architecture overview
- `cli-usage.md` - Command-line usage guide
- `configuration.md` - Configuration management
- `installation.md` - Installation instructions
- `troubleshooting.md` - Common issues and solutions
- `web-interface.md` - Web interface documentation

## Key Technologies

- **Shell Scripting**: Bash, Zsh, Fish for cross-platform compatibility
- **TOML**: Configuration file format
- **HTML/CSS/JavaScript**: Web interface
- **Python**: Web server and utilities
- **Just/Make**: Build automation
- **Git**: Version control and distribution

This context provides comprehensive information for working with the CCS project, including development workflows, testing procedures, and troubleshooting guidance.