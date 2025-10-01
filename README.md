# Claude Code Configuration Switcher (CCS) v2.0.0

Quickly switch between different Claude Code API configurations with one command. Cross-platform support for Linux, macOS, and Windows with advanced caching, performance optimization, and comprehensive error handling.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-blue.svg)](#)

English | [中文](README_CN.md)

![Screenshot](assets/imgs/screenshot1.png)

## 🚀 Quick Start

### Installation

**Linux/macOS:**
```bash
curl -L https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.sh | bash
```

**Windows PowerShell:**
```powershell
irm https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.ps1 | iex
```

### Setup
1. Restart your terminal
2. Edit `~/.ccs_config.toml` and add your API keys
3. Start using: `ccs list` → `ccs [config_name]`

## 🍎 macOS Special Handling

**Fish Shell Only Strategy**: On macOS systems, CCS implements a fish-only installation strategy to ensure optimal compatibility:

- **Automatic Detection**: Installation script automatically detects macOS environment
- **Fish-Only Configuration**: Only configures Fish shell, skipping Bash and Zsh integration
- **Bash 3.2 Compatibility**: Handles macOS default Bash 3.2 limitations (no associative arrays)
- **Clean Installation**: Removes any existing Bash scripts to maintain clean fish-only setup
- **Zero Impact**: Leaves existing Bash/Zsh configurations completely untouched

**Why Fish-Only on macOS?**
- macOS ships with outdated Bash 3.2 (lacks modern features)
- Fish provides superior user experience and modern shell features
- Avoids compatibility issues with legacy shell versions
- Maintains clean separation between different shell environments

**Installation Behavior on macOS:**
```bash
# During installation, you'll see:
"🍎 macOS detected - configuring Fish shell only"
"⚠️  Skipping Bash/Zsh configuration (Fish-only strategy)"
"✅ Fish shell configured successfully"
```

**Verification:**
```bash
# Check installation result
ls ~/.ccs/          # Should only show ccs.fish (no ccs.sh)
grep ccs ~/.zshrc   # Should return "No CCS configuration found"
fish -c "ccs version"  # Should work perfectly
```

## ✨ Features

### Core Capabilities
- 🔄 **One-Command Switching** - Switch between API providers instantly (< 50ms)
- 🌐 **Web Interface** - Visual configuration management with real-time validation
- 🔧 **Cross-Platform** - Works on Linux, macOS, Windows
- 🐚 **Multi-Shell** - Supports Bash 4.0+, Zsh, Fish 3.0+, PowerShell 5.1+
- 🔗 **Global Persistence** - Configuration persists across all terminals and sessions
- 📝 **Simple Config** - Human-readable TOML format

### Advanced Features (v2.0.0)
- ⚡ **Smart Caching** - Configuration caching with 300s TTL (5x faster parsing)
- 🔁 **Auto-Retry** - Intelligent retry mechanism (up to 3 attempts)
- 📊 **Performance Monitoring** - Built-in performance tracking and metrics
- 🛡️ **Security Enhanced** - Comprehensive security checks and file permission validation
- 🔍 **Advanced Diagnostics** - Detailed system diagnostics and error reporting
- 📝 **Structured Logging** - Multi-level logging system (DEBUG/INFO/WARN/ERROR)
- 💾 **Auto-Backup** - Automatic configuration backup (up to 10 versions)
- 🎯 **Error Handling** - 13 distinct error codes with detailed solutions

## 📝 Configuration

Edit `~/.ccs_config.toml`:

```toml
default_config = "anthropic"

[anthropic]
description = "Anthropic Official API"
base_url = "https://api.anthropic.com"
auth_token = "sk-ant-your-api-key-here"

[openai]
description = "OpenAI API"
base_url = "https://api.openai.com/v1"
auth_token = "sk-your-openai-api-key-here"
model = "gpt-4"

[custom]
description = "Custom API Provider"
base_url = "https://your-api-provider.com"
auth_token = "your-api-key-here"
```

**Key Fields:**
- `base_url`: API endpoint
- `auth_token`: Your API key
- `model`: Model name (optional for Claude APIs)

## 📖 Usage

### Basic Commands
```bash
# Configuration management
ccs [config_name]           # Switch to specific configuration
ccs list                    # List all available configurations
ccs current                 # Show current configuration status

# Management commands
ccs web                     # Launch Web configuration interface
ccs update                  # Auto-update CCS to latest version
ccs backup                  # Backup current configuration file
ccs verify                  # Verify configuration file integrity
ccs clear-cache             # Clear configuration cache

# System commands
ccs diagnose                # Run comprehensive system diagnostics
ccs uninstall               # Uninstall CCS tool
ccs version                 # Show version information
ccs help                    # Show help information
```

### Debug Mode
```bash
# Enable debug mode for detailed troubleshooting
ccs --debug [command]       # Run command with debug mode enabled
export CCS_DEBUG=1          # Enable debug mode globally
export CCS_LOG_LEVEL=0      # Set log level to DEBUG (0=DEBUG, 1=INFO, 2=WARN, 3=ERROR)
```

### Environment Variables
```bash
# Performance tuning
export CCS_CACHE_TTL=300    # Cache time-to-live in seconds (default: 300)
export CCS_MAX_RETRIES=3    # Maximum retry attempts (default: 3)
export CCS_TIMEOUT=30       # Operation timeout in seconds (default: 30)

# Banner control
export CCS_DISABLE_BANNER=true  # Disable banner display
export NO_BANNER=1              # Alternative banner disable flag
```

### 🔗 Global Configuration Persistence

CCS supports global configuration persistence, solving traditional environment variable scope limitations:

```bash
# Terminal 1
ccs glm              # Switch to GLM configuration

# Terminal 2 (newly opened)
echo $ANTHROPIC_MODEL # Automatically displays: glm-4
```

- ✅ Switch configuration in any terminal, other new terminals automatically inherit
- ✅ Configuration remains unchanged after computer restart
- ✅ Support for multiple shells like Bash, Zsh, Fish

## 🔄 Auto-Update

CCS provides convenient auto-update functionality, eliminating the need to manually execute complex installation commands:

```bash
ccs update                  # Auto-update to latest version
```

### Update Features

- ✅ **Smart Path Detection** - Automatically searches for installation script locations with enhanced path discovery
- ✅ **Configuration Protection** - Automatically backs up existing configuration files
- ✅ **Complete Update** - Updates all script files and web interface
- ✅ **Environment Refresh** - Automatically refreshes shell environment configuration
- ✅ **Error Handling** - Detailed error messages and solution suggestions
- ✅ **Project Root Detection** - Intelligently finds project root directory from any subdirectory

### Update Process

1. **Smart Path Discovery** - Uses enhanced algorithm to search for `install.sh` in multiple locations:
   - Current directory and relative paths (up to 5 levels deep)
   - Intelligent project root detection
   - Common project locations (Documents/Github, Downloads, Desktop)
   - System installation paths (/opt, /usr/local)
   - User configuration directory (~/.ccs)

2. **Backup Configuration** - Automatically backs up current configuration to `~/.ccs/backups/`
3. **Execute Update** - Runs installation script to update all components
4. **Verify Completion** - Confirms successful update and provides follow-up instructions

### Usage Requirements

✅ **Recommended Usage**:
- Run `ccs update` from anywhere within the CCS project directory
- The command will automatically find the installation script regardless of your current subdirectory
- Works from project root, scripts/, docs/, web/, or any other subdirectory

### Important Notes

⚠️ **Post-Update Actions**:
- Restart terminal, or run `source ~/.bashrc` (Bash) / `source ~/.config/fish/config.fish` (Fish)
- Run `ccs version` to confirm version update success

⚠️ **Troubleshooting**:
- If update fails, the command will show all searched paths for debugging
- Ensure you have the CCS project downloaded locally
- Check network connection and disk space
- Manual fallback: `cd /path/to/ccs && ./scripts/install/install.sh`

### Enhanced Error Reporting

If the installation script cannot be found, CCS will display:
- All searched paths for easy debugging
- Suggested solutions including manual installation steps
- Guidance on proper project setup

## 🎨 Banner Display

CCS includes a beautiful ASCII art banner that displays when you run commands. The banner shows the CCS logo and project information in a modern, clean style.

```
██████╗ ██████╗ ███████╗
██╔════╝██╔════╝██╔════╝
██║     ██║     ███████╗
██║     ██║          ██║
╚██████╗╚██████╗███████║
 ╚═════╝ ╚═════╝╚══════╝

Claude Code Configuration Switcher
```

### Banner Commands

```bash
# Display full banner
just banner

# Display mini banner (compact version)
just banner-mini

# Display plain text banner (no colors)
just banner-plain
```

### Banner Integration

The banner automatically appears when you run CCS commands:
```bash
ccs list                   # Shows banner + lists configurations
ccs current               # Shows banner + current status
ccs anyrouter            # Shows banner + switches config
```

### Disable Banner

If you prefer to disable the banner display:
```bash
# Temporarily disable
export CCS_DISABLE_BANNER=true
export NO_BANNER=1

# Or add to your shell profile for permanent disable
echo 'export CCS_DISABLE_BANNER=true' >> ~/.bashrc
```

## 🛠️ Advanced Features

### 🏎️ Performance Optimization (v2.0.0)

CCS v2.0.0 introduces comprehensive performance optimizations:

- **Smart Configuration Caching**
  - Reduces parsing time by 5x with intelligent caching
  - Configurable TTL (default: 300 seconds)
  - Automatic cache invalidation based on file modification time
  - Memory-efficient with automatic cleanup of stale entries

- **Fast TOML Parser**
  - Optimized AWK-based parser with O(n) complexity
  - Single-pass parsing algorithm
  - Minimal memory footprint (<10MB typical usage)

- **Lazy Loading**
  - Configurations loaded only when needed
  - Background loading for better responsiveness
  - Startup time <50ms for config switching

- **Performance Metrics**
  ```bash
  ccs cache-stats       # Display cache performance statistics
  ccs status           # Show system status and performance overview
  ```

### 🔍 System Diagnostics

Comprehensive diagnostic capabilities for troubleshooting:

```bash
# Run full system diagnostics
ccs diagnose

# Diagnostic checks include:
# - Configuration file validation
# - TOML syntax verification
# - Environment variable status
# - Shell integration verification
# - File permissions check
# - Cache system status
# - Network connectivity (for update checks)
```

### 🛡️ Security Features

Built-in security enhancements in v2.0.0:

- **File Permission Validation**
  - Automatic permission checks during installation
  - Configuration file set to 600 (owner read/write only)
  - Detection of overly permissive permissions (777)

- **PATH Security Checks**
  - Detection of empty PATH elements
  - Warning for suspicious environment variables (LD_PRELOAD)

- **Sensitive Data Masking**
  - API tokens displayed with first 10 characters only
  - Automatic masking in logs and output
  - Secure backup file creation

- **Input Validation**
  - Comprehensive TOML syntax validation
  - Configuration field validation
  - Sanitization of user inputs

### 💾 Backup and Recovery

Automatic and manual backup capabilities:

```bash
ccs backup            # Create manual backup
ccs restore [file]    # Restore from backup file
```

**Backup Features**:
- ✅ **Automatic Backup**: Configuration changes auto-backed up before modifications
- ✅ **Version Control**: Multiple backup versions with timestamps (up to 10 versions)
- ✅ **Safe Recovery**: Rollback to previous configurations safely
- ✅ **Cross-platform**: Backup files work across different operating systems
- ✅ **Backup Location**: `~/.ccs/backups/` (or `%USERPROFILE%\.ccs\backups\` on Windows)

### 🌐 Web Interface

```bash
ccs web               # Launch web configuration interface
```

**Web Interface Features**:
- **Visual Configuration**: Point-and-click configuration management
- **Real-time Validation**: Instant configuration validation and error checking
- **Import/Export**: Easy configuration backup and sharing
- **No External Dependencies**: Pure HTML/CSS/JavaScript implementation
- **Auto-port Selection**: Automatically finds available port for HTTP server

## 📁 Architecture

### Project Structure

```
CCS/
├── scripts/
│   ├── shell/              # Shell scripts for Linux/macOS
│   │   ├── ccs.sh         # Bash/Zsh main script
│   │   ├── ccs.fish       # Fish shell implementation
│   │   ├── ccs-common.sh  # Utility library (v2.0 with caching)
│   │   └── banner.sh      # ASCII banner display
│   ├── install/           # Installation scripts
│   │   ├── install.sh     # Main installer (Linux/macOS)
│   │   └── quick_install/ # One-line installation scripts
│   └── windows/           # Windows PowerShell/Batch scripts
├── config/                # Configuration templates
│   └── .ccs_config.toml.example
├── web/                   # Web management interface
│   └── index.html
└── docs/                  # Documentation

Installation Structure:
~/.ccs/ (or %USERPROFILE%\.ccs\ on Windows)
├── ccs.sh / ccs.fish / ccs.ps1  # Platform-specific scripts
├── ccs-common.sh                # Shared utilities
├── banner.sh                    # Banner display
├── web/index.html               # Web interface
├── backups/                     # Config backups (up to 10)
└── logs/                        # Installation logs
```

### System Requirements

**Minimum Requirements**:
- **Linux**: Any major distribution with Bash 4.0+ or Fish 3.0+
- **macOS**: 10.12+ (Fish 3.0+ recommended due to Bash 3.2 limitations)
- **Windows**: Windows 7+ with PowerShell 5.1+
- **Disk Space**: ~5MB (including cache and backups)
- **Memory**: <10MB typical usage

**Optional Dependencies**:
- `curl` or `wget` - For downloads and updates
- `python3` or `python` - For web interface HTTP server
- `shellcheck` - For script validation during development

## 🔧 Development

### Building from Source

```bash
git clone https://github.com/bahayonghang/ccs.git
cd ccs
make install  # or: just install
```

### Testing

```bash
make test          # Run basic functionality tests
make test-all      # Test all shell scripts
make check-syntax  # Check script syntax
```

### Development Commands

```bash
just --list        # Show all available commands
just install       # Install CCS to system
just test          # Run tests
just web           # Start web interface
```

## 📊 Performance

CCS v2.0.0 is highly optimized for performance:

- **Config Switching**: < 50ms typical (5x faster than v1.x)
- **Memory Usage**: < 10MB typical, efficient cleanup
- **Startup Time**: < 50ms shell initialization
- **Cache Hit Rate**: > 90% after warm-up
- **TOML Parsing**: O(n) complexity, single-pass
- **Disk Usage**: ~2MB installation + ~3MB for cache/backups

**Performance Tuning**:
```bash
export CCS_CACHE_TTL=600     # Increase cache lifetime for better performance
export CCS_MAX_RETRIES=5     # More retries for unreliable networks
export CCS_TIMEOUT=60        # Longer timeout for slow connections
```

## 🛡️ Security

CCS v2.0.0 implements comprehensive security measures:

### Data Protection
- **Sensitive Information Masking**: API keys displayed with first 10 chars only (e.g., `sk-ant-abc***`)
- **Secure File Permissions**: Configuration files set to `600` (owner read/write only)
- **No Telemetry**: Zero data collection, all operations performed locally
- **Local Processing**: All operations executed on local machine only

### Security Validation
- **Permission Checks**: Automatic detection of overly permissive file permissions (777)
- **PATH Security**: Detection of empty PATH elements and security risks
- **Environment Validation**: Warning for suspicious variables (LD_PRELOAD)
- **Input Sanitization**: All user inputs validated and sanitized
- **TOML Validation**: Comprehensive syntax and structure validation

### Installation Security
```bash
# Security checks during installation
- Validates script permissions
- Checks PATH security
- Verifies file integrity
- Creates secure backup files
- Sets restrictive permissions automatically
```

### Best Practices
```bash
# Verify file permissions
ls -la ~/.ccs_config.toml        # Should show: -rw------- (600)

# Check for security issues
ccs diagnose                      # Includes security validation

# Enable security logging
export CCS_LOG_LEVEL=0           # Log all security events
```

## 🆘 Troubleshooting

### Common Issues & Solutions

**1. Command not found after installation**
```bash
# Solution 1: Reload shell configuration
source ~/.bashrc          # For Bash
source ~/.zshrc           # For Zsh
source ~/.config/fish/config.fish  # For Fish

# Solution 2: Check PATH
echo $PATH | grep .ccs    # Should show ~/.ccs in PATH

# Solution 3: Verify installation
ls -la ~/.ccs/            # Check if files exist
cat ~/.bashrc | grep ccs  # Check shell integration
```

**2. Configuration not persisting**
```bash
# Run diagnostics
ccs diagnose              # Comprehensive system check
ccs status                # Check current status

# Verify config file
cat ~/.ccs_config.toml | grep current_config

# Check file permissions
ls -la ~/.ccs_config.toml # Should be -rw------- (600)

# Manually fix permissions
chmod 600 ~/.ccs_config.toml
```

**3. Web interface not working**
```bash
# Check Python availability
python3 --version || python --version

# Install Python if needed (macOS)
brew install python3

# Install Python if needed (Linux)
sudo apt install python3    # Debian/Ubuntu
sudo dnf install python3    # Fedora/RHEL

# Check firewall settings
sudo ufw status             # Linux
```

**4. Permission denied errors**
```bash
# Fix file permissions
chmod 600 ~/.ccs_config.toml
chmod 755 ~/.ccs/*.sh
chmod 755 ~/.ccs/*.fish

# Fix directory permissions
chmod 755 ~/.ccs
chmod 755 ~/.ccs/backups
```

**5. Cache issues**
```bash
# Clear cache and retry
ccs clear-cache
ccs list

# Check cache statistics
ccs cache-stats

# Adjust cache settings
export CCS_CACHE_TTL=0    # Disable cache temporarily
```

**6. Environment variables not set**
```bash
# Check current environment
env | grep ANTHROPIC

# Verify configuration loaded
ccs current

# Force reload configuration
ccs [config_name]

# Check for errors
ccs --debug current
```

### Error Codes Reference

CCS uses 13 distinct error codes for precise troubleshooting:

| Code | Meaning | Common Solution |
|------|---------|----------------|
| 0 | Success | - |
| 1 | Config file missing | Run `ccs --install` or installation script |
| 2 | Config invalid | Check TOML syntax, verify required fields |
| 3 | Download failed | Check network, proxy, firewall settings |
| 4 | Permission denied | Fix file permissions with `chmod 600` |
| 5 | File not found | Reinstall CCS or check file paths |
| 6 | Invalid argument | Check command syntax with `ccs help` |
| 7 | Network unreachable | Check internet connection |
| 8 | Dependency missing | Install required tools (curl, python, etc) |
| 9 | Config corrupt | Restore from backup or recreate config |
| 10 | Resource busy | Close conflicting processes |
| 11 | Timeout | Increase `CCS_TIMEOUT` value |
| 12 | Auth failed | Verify API token validity |
| 99 | Unknown error | Run `ccs diagnose` for details |

### Debug Mode

Enable comprehensive debug logging for detailed troubleshooting:

```bash
# Method 1: Per-command debug
ccs --debug list              # Debug mode for specific command
ccs --debug current           # Show detailed environment info

# Method 2: Global debug mode
export CCS_DEBUG=1            # Enable debug output
export CCS_LOG_LEVEL=0        # Set to DEBUG level

# Method 3: Log to file
export CCS_LOG_FILE=~/ccs_debug.log
ccs --debug [command] 2>&1 | tee ~/ccs_debug.log

# View installation logs
ls ~/.ccs/logs/               # Installation log directory
tail -f ~/.ccs/logs/install_*.log  # Watch latest install log
```

**Debug Output Includes**:
- Configuration parsing details
- Cache hit/miss statistics
- Environment variable changes
- Function call traces
- TOML parser operations
- File I/O operations
- Error stack traces

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
git clone https://github.com/bahayonghang/ccs.git
cd ccs
# Set up development environment
./scripts/dev/setup.sh
```

### Code Style

- Follow existing code conventions
- Add tests for new features
- Update documentation as needed
- Ensure cross-platform compatibility

## 📋 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Claude Code** - For the amazing AI coding assistant
- **Open Source Community** - For tools and inspiration
- **Contributors** - For bug reports, feature requests, and code contributions

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/bahayonghang/ccs/issues)
- **Discussions**: [GitHub Discussions](https://github.com/bahayonghang/ccs/discussions)
- **Documentation**: [Wiki](https://github.com/bahayonghang/ccs/wiki)
- **Releases**: [Releases](https://github.com/bahayonghang/ccs/releases)

---

**⭐ If this project helps you, please give it a star!**

**🔄 CCS - Making Claude Code Configuration Management Simple and Efficient**