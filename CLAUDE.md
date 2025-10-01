# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**CCS (Claude Code Configuration Switcher)** is a cross-platform CLI tool for managing and switching between multiple Claude Code API configurations. It supports global configuration persistence, web interface management, intelligent model selection, and multiple shell environments (Bash/Zsh/Fish/PowerShell).

**Version**: 2.0.0
**License**: MIT
**Primary Language**: Shell Script (Bash/Fish/PowerShell)

## Development Commands

### Installation & Setup
```bash
# Quick installation (recommended)
curl -L https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.sh | bash

# Manual installation
./scripts/install/install.sh

# Uninstall
./scripts/install/install.sh --uninstall
```

### Build & Development Tools

The project provides two build systems:

#### Using Just (Recommended)
```bash
just --list              # List all available commands
just install             # Install CCS to system
just test                # Run basic tests
just test-all            # Run comprehensive tests
just check-syntax        # Check script syntax
just web                 # Launch web interface
just diagnose            # Run system diagnostics
```

#### Using Make (Alternative)
```bash
make help                # Show available commands
make install             # Install CCS
make test                # Run tests
make check-syntax        # Check syntax
make web                 # Launch web interface
```

### Testing
```bash
# Basic functionality test
bash scripts/shell/ccs.sh list

# Test configuration switching
ccs list
ccs current
ccs [config_name]

# Syntax validation
shellcheck scripts/shell/*.sh
```

## Architecture

### High-Level Structure

```
CCS System Architecture:
┌─────────────────────────────────────┐
│  User Interface Layer               │
│  ├── CLI (ccs command)             │
│  └── Web UI (index.html)           │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│  Core Processing Layer              │
│  ├── Shell Scripts (ccs.sh/.fish)  │
│  ├── Common Library (ccs-common.sh)│
│  └── Platform Scripts (Windows)    │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│  Configuration Layer                │
│  ├── TOML Parser                   │
│  ├── Config Validator              │
│  └── Cache System (v2.0)           │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│  Environment Variables              │
│  ├── ANTHROPIC_BASE_URL            │
│  ├── ANTHROPIC_AUTH_TOKEN          │
│  ├── ANTHROPIC_MODEL               │
│  └── ANTHROPIC_SMALL_FAST_MODEL    │
└─────────────────────────────────────┘
```

### Core Components

1. **Shell Scripts Module** (`scripts/shell/`)
   - `ccs.sh`: Bash/Zsh main script with core functionality
   - `ccs.fish`: Fish shell implementation
   - `ccs-common.sh`: Shared utility library (v2.0 with caching)
   - See [scripts/shell/CLAUDE.md](scripts/shell/CLAUDE.md) for details

2. **Installation Scripts** (`scripts/install/`)
   - `install.sh`: Main installation script
   - `quick_install.sh`: One-line installation
   - Platform-specific logic for macOS/Linux/Windows

3. **Web Interface** (`web/`)
   - Pure HTML/CSS/JavaScript implementation
   - No external dependencies
   - Real-time configuration editing

4. **Configuration Module** (`config/`)
   - TOML configuration format
   - Example templates for various providers

### Data Flow

**Configuration Switching Flow**:
```
User executes: ccs [config]
    ↓
Parse command arguments
    ↓
Read & validate ~/.ccs_config.toml
    ↓
Check cache (v2.0 optimization)
    ↓
Extract configuration values
    ↓
Clear old environment variables
    ↓
Set new environment variables
    ↓
Update current_config in file
    ↓
Persist across shell sessions
```

**Auto-loading Flow** (on new shell):
```
Shell startup
    ↓
Source shell config (~/.bashrc, etc.)
    ↓
Execute CCS initialization
    ↓
Read current_config from TOML
    ↓
Silently set environment variables
    ↓
Configuration ready for Claude Code
```

## Configuration

### Configuration File Structure

**Location**: `~/.ccs_config.toml`

```toml
# Global settings
default_config = "anthropic"
current_config = "anthropic"  # Auto-managed

# Configuration sections
[anthropic]
description = "Anthropic Official API"
base_url = "https://api.anthropic.com"
auth_token = "sk-ant-your-key-here"
model = "claude-sonnet-4-5-20250929"  # Optional
small_fast_model = "claude-3-5-haiku-20241022"  # Optional

[openai]
description = "OpenAI Compatible API"
base_url = "https://api.openai.com/v1"
auth_token = "sk-your-openai-key"
model = "gpt-4"
```

**Required Fields**:
- `base_url`: API endpoint URL
- `auth_token`: API authentication token

**Optional Fields**:
- `model`: Default model name (auto-configured if not specified)
- `small_fast_model`: Fast model for lightweight tasks
- `description`: Human-readable description

## Key Features & Implementation

### 1. Global Configuration Persistence (v2.0)
- Configurations persist across all terminal sessions
- Uses TOML-based current_config tracking
- Survives system restarts
- Cross-shell compatibility (Bash/Zsh/Fish)

### 2. Performance Optimization (v2.0)
- **Configuration Caching**: 5x faster config parsing
- **Smart TOML Parser**: Optimized AWK-based parser
- **Cache TTL**: 300 seconds default (configurable)
- **Memory Efficiency**: Cleanup of stale cache entries

### 3. macOS Special Handling
- **Fish-Only Strategy**: Only configures Fish shell on macOS
- **Reason**: macOS ships with outdated Bash 3.2
- **Automatic Detection**: Installation script detects macOS
- **Clean Separation**: No Bash/Zsh integration on macOS

### 4. Error Handling & Safety
- **Comprehensive Error Codes**: 13 distinct error types
- **Safe Exit Mechanism**: Detects source vs direct execution
- **Auto-Recovery**: Missing field auto-fix in config
- **Backup System**: Automatic config backups before changes

### 5. Multi-Shell Support
- **Bash** (>=4.0): Full feature support
- **Zsh** (>=5.0): Compatible with Bash scripts
- **Fish** (>=3.0): Native Fish implementation
- **PowerShell** (>=5.1): Windows support

## Development Guidelines

### Code Style

**Shell Script Conventions**:
```bash
# Use strict mode
set -euo pipefail

# Variable naming
LOCAL_VAR="value"           # Local: lowercase with underscores
readonly GLOBAL_CONST="val" # Constants: uppercase with readonly

# Function naming
function_name() { }         # Functions: lowercase with underscores
_private_func() { }         # Private: underscore prefix

# Error handling
handle_error $ERROR_CODE "message" "show_help_flag"
```

**Logging**:
```bash
log_debug "Detailed debug info"
log_info "General information"
log_warn "Warning messages"
log_error "Error conditions"
```

### Important Notes

1. **Always Read Before Write**: Use `Read` tool before `Edit` or `Write`
2. **Preserve Indentation**: Match existing code indentation exactly
3. **Test Cross-Platform**: Verify changes on Linux/macOS/Windows
4. **Update Documentation**: Keep CLAUDE.md and docs/ in sync
5. **Version Consistency**: Update version in scripts when changing

### Testing Strategy

**Before Committing**:
```bash
# 1. Syntax check
just check-syntax  # or: make check-syntax

# 2. Basic tests
just test          # or: make test

# 3. Full test suite
just test-all      # or: make test-all

# 4. Manual verification
ccs list
ccs current
ccs [test-config]
```

## Common Workflows

### Adding a New Configuration Provider

1. Edit `~/.ccs_config.toml`
2. Add new configuration section:
   ```toml
   [provider-name]
   description = "Provider Description"
   base_url = "https://api.provider.com"
   auth_token = "your-token"
   model = "model-name"  # Optional
   ```
3. Test: `ccs provider-name`
4. Verify: `ccs current`

### Debugging Configuration Issues

```bash
# Enable debug mode
export CCS_LOG_LEVEL=0
export CCS_DEBUG=1

# Check configuration file
cat ~/.ccs_config.toml

# Validate syntax
grep -E '^\[|=' ~/.ccs_config.toml

# Check environment variables
env | grep ANTHROPIC

# Full diagnostic
just diagnose  # or: make diagnose
```

### Updating CCS

```bash
# Using built-in update command
ccs update

# The update command:
# 1. Intelligently finds installation script
# 2. Backs up current configuration
# 3. Runs installation script
# 4. Preserves user settings
```

## Important Files

### Core Scripts
- `scripts/shell/ccs.sh`: Main Bash/Zsh script (300+ lines)
- `scripts/shell/ccs.fish`: Fish shell implementation
- `scripts/shell/ccs-common.sh`: Utility library (1000+ lines, v2.0)
- `scripts/shell/banner.sh`: ASCII banner display

### Configuration
- `config/.ccs_config.toml.example`: Configuration template
- `~/.ccs_config.toml`: User configuration file (runtime)

### Documentation
- `README.md`: User documentation
- `BUILD.md`: Build system guide
- `docs/architecture.md`: Detailed architecture (Chinese)
- `docs/development.md`: Development guide (Chinese)

### Installation
- `scripts/install/install.sh`: Main installer
- `scripts/install/quick_install/quick_install.sh`: Quick install script

## Platform-Specific Notes

### Linux
- Full support for all shells
- Standard installation path: `~/.ccs/`
- Integrates with `.bashrc`, `.zshrc`, or Fish config

### macOS
- **Fish-Only Strategy**: Only Fish shell is configured
- **Why**: macOS Bash 3.2 lacks modern features (no associative arrays)
- **Verification**: `ls ~/.ccs/` should only show `ccs.fish`
- **Recommended**: Use Fish shell for best experience

### Windows
- PowerShell script: `scripts/windows/ccs.ps1`
- CMD batch script: `scripts/windows/ccs.bat`
- Quick install: `quick_install.ps1`
- Configuration path: `%USERPROFILE%\.ccs_config.toml`

## Performance Considerations

### v2.0 Optimizations
- **Configuration Cache**: Reduces parsing overhead by 80%
- **Smart TOML Parser**: O(n) complexity, single-pass parsing
- **Lazy Loading**: Configurations loaded only when needed
- **Cache Invalidation**: Automatic based on file modification time

### Resource Usage
- **Startup Time**: <50ms for config switching
- **Memory**: <10MB typical usage
- **Disk**: ~2MB installation size
- **Cache**: Auto-cleanup of entries older than 5 minutes

## Security

1. **Sensitive Data**: API tokens masked in output (first 10 chars visible)
2. **File Permissions**: Config file set to `600` (owner read/write only)
3. **No Telemetry**: All operations performed locally
4. **Input Validation**: All user inputs validated and sanitized

## Troubleshooting

### Common Issues

**"Configuration file not found"**
- Run: `./scripts/install/install.sh`
- Or: Quick install script

**"Command not found: ccs"**
- Restart terminal or: `source ~/.bashrc` (or appropriate config)
- Check: `echo $PATH | grep .ccs`

**"Environment variables not persisting"**
- Check: `grep current_config ~/.ccs_config.toml`
- Verify: Shell config files source CCS script
- Test: Open new terminal and run `ccs current`

**macOS Bash Issues**
- Solution: Use Fish shell instead
- Install Fish: `brew install fish`
- Reinstall CCS (will auto-configure Fish only)

## Related Documentation

- [Shell Module Guide](scripts/shell/CLAUDE.md): Detailed shell script documentation
- [Installation Module](scripts/install/CLAUDE.md): Installation process details
- [Web Interface](web/CLAUDE.md): Web UI architecture
- [Config Module](config/CLAUDE.md): Configuration system details

## Contributing

When contributing to CCS:
1. Follow existing code style and conventions
2. Add tests for new features
3. Update documentation (CLAUDE.md and README.md)
4. Ensure cross-platform compatibility
5. Run full test suite before submitting PR

## Version History

- **v2.0.0**: Performance optimization, caching system, enhanced error handling
- **v1.4.0**: Auto-update feature, smart path detection
- **v1.3.0**: Banner display, improved diagnostics
- **v1.0.0**: Initial release with basic functionality
