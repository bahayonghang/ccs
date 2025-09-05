# Claude Code Configuration Switcher (CCS) v2.0

A cross-platform tool for quickly switching between different Claude Code API configurations [provider switching] with support for multiple shell environments and operating systems.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-blue.svg)](#)
[![Shell](https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh%20%7C%20Fish%20%7C%20PowerShell-green.svg)](#)

English | [中文](README_CN.md)

![Actual Effect](assets/imgs/screenshot1.png)

## 🚀 Quick Installation

### Linux/macOS
```bash
curl -L https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.sh | bash
```

### Windows
**Method 1: PowerShell (Recommended)**
```powershell
irm https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.ps1 | iex
```

**Method 2: CMD**
```cmd
curl -L https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.bat -o quick_install.bat && quick_install.bat
```

**Method 3: Manual Download**
Download and run: https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.bat

### Post-Installation Configuration
1. Reopen terminal (or run `source ~/.bashrc`)
2. Edit configuration file: `~/.ccs_config.toml` (Windows: `%USERPROFILE%\.ccs_config.toml`)
3. Add API keys and start using: `ccs list` → `ccs [config_name]`

### System Requirements
- **Linux**: Any mainstream distribution (Ubuntu, CentOS, Debian, etc.)
- **macOS**: 10.12+ (Sierra)
- **Windows**: 7+ with PowerShell 5.1+ or CMD support
- **Shell**: Bash 4.0+, Zsh, Fish 3.0+, PowerShell 5.1+

### Installation Troubleshooting
If you encounter installation errors, usually due to network or permission issues:
1. Ensure network connection is normal and can access GitHub
2. Linux/macOS ensure write permissions to `~/.ccs` directory
3. Windows if PowerShell execution policy issue: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
4. If issues persist, please [submit Issue](https://github.com/bahayonghang/ccs/issues)

## ✨ Features

### Core Functions
- 🔄 **Quick Configuration Switching** - Switch API configurations with one command, supports multiple AI services
- 🌐 **Web Interface Management** - Visual configuration management, real-time editing and saving
- 🔧 **Multi-platform Support** - Full coverage of Linux, macOS, Windows
- 🐚 **Multi-shell Compatible** - Full support for Bash, Zsh, Fish, PowerShell, CMD
- 📝 **TOML Configuration Format** - Human-readable configuration file format, easy to read and write

### Advanced Features
- 🔗 **Global Configuration Persistence** - Switch configuration in one terminal, all new terminals automatically inherit
- 🎯 **Smart Model Selection** - Claude services can use default models, other services specify models
- ⚡ **Performance Optimization** - Configuration caching system for fast command response
- 🔒 **Safe and Reliable** - Sensitive information masked display, automatic configuration backup
- 🛠️ **Enhanced Debugging** - Detailed error prompts and solutions
- 📊 **System Detection** - Intelligent detection of system environment and dependencies

## 📝 Configuration File

Configuration file located at `~/.ccs_config.toml`, example configuration in `config/.ccs_config.toml.example`:

```toml
default_config = "anyrouter"

# Current active configuration (automatically managed, do not modify manually)
current_config = "anyrouter"

[anyrouter]
description = "AnyRouter API Service"
base_url = "https://anyrouter.top"
auth_token = "sk-your-anyrouter-api-key-here"
# model = ""  # Leave empty to use default Claude model
# small_fast_model = ""  # Leave empty to use default fast model

[glm]
description = "Zhipu GLM API Service"
base_url = "https://open.bigmodel.cn/api/paas/v4"
auth_token = "your-glm-api-key-here"
model = "glm-4"

[anthropic]
description = "Anthropic Official API"
base_url = "https://api.anthropic.com"
auth_token = "sk-ant-your-api-key-here"
# model = ""  # Leave empty to use default Claude model
# small_fast_model = ""  # Leave empty to use default fast model

[openai]
description = "OpenAI API Configuration"
base_url = "https://api.openai.com/v1"
auth_token = "sk-your-openai-api-key-here"
model = "gpt-4"
```

### 🔧 Configuration Field Description

- `default_config`: Default configuration name
- `current_config`: Currently active configuration (automatically managed, no manual modification needed)
- `base_url`: API endpoint address
- `auth_token`: API authentication token
- `model`: Specify model name (optional)
  - If left empty or commented, Claude API services will use default model
  - For non-Claude services (like GLM, OpenAI), it is recommended to explicitly specify model
- `small_fast_model`: Fast model name (optional)

### 🎯 Model Configuration Strategy

- **Claude API Services** (anyrouter, anthropic, aicodemirror, etc.): It is recommended to leave the `model` field empty and use Claude Code tool's default model selection
- **Non-Claude Services** (glm, openai, moonshot, etc.): Explicitly specify the `model` field to ensure compatibility

## 📖 Usage

```bash
ccs list              # List all configurations
ccs [config_name]     # Switch to specified configuration (global effect)
ccs current          # Show current configuration
ccs web              # Launch web management interface
ccs uninstall        # Uninstall tool
ccs help             # Show help
ccs                  # Use current active configuration
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

## 🛠️ Advanced Features

### 🏎️ Performance Optimization (v2.0)

- **Configuration Caching**: Smart caching system reduces parsing time by 5x
- **Fast TOML Parser**: Optimized configuration file parsing algorithm
- **Memory Management**: Efficient memory usage for large configuration files
- **Background Loading**: Asynchronous configuration loading for better responsiveness

### 🔍 System Diagnostics

```bash
ccs diagnose           # Run comprehensive system diagnostics
ccs status            # Show system status overview
ccs cache-stats       # Display cache performance statistics
ccs --debug [command] # Run commands in debug mode
```

### 🌐 Web Management Interface

```bash
ccs web               # Launch web configuration interface
```

- **Visual Configuration**: Point-and-click configuration management
- **Real-time Validation**: Instant configuration validation and error checking
- **Import/Export**: Easy configuration backup and sharing
- **Multi-language Support**: Interface supports multiple languages

### 🔄 Backup and Recovery

```bash
ccs backup            # Backup current configuration
ccs restore [file]    # Restore configuration from backup
```

- **Automatic Backup**: Configuration changes are automatically backed up
- **Version Control**: Multiple backup versions with timestamps
- **Safe Recovery**: Rollback to previous configurations safely
- **Cross-platform**: Backup files work across different operating systems

### 🧪 Configuration Testing

```bash
ccs test-config [name] # Test configuration connectivity
```

- **Network Testing**: Verify API endpoint connectivity
- **Authentication Check**: Validate API keys and tokens
- **Performance Metrics**: Measure response times and latency
- **Error Diagnosis**: Detailed error reporting and solutions

## 📁 Architecture

### Cross-platform Support

CCS provides native support for all major platforms:

```
Linux/macOS:    ~/.ccs/ccs.sh, ~/.ccs/ccs.fish, ~/.ccs/ccs-common.sh
Windows:        %USERPROFILE%\.ccs\ccs.ps1, %USERPROFILE%\.ccs\ccs.bat
```

### Shell Integration

Automatic shell configuration for seamless integration:

```bash
# Bash/Zsh (~/.bashrc, ~/.zshrc)
if [ -f "$HOME/.ccs/ccs.sh" ]; then
    source "$HOME/.ccs/ccs.sh"
fi

# Fish (~/.config/fish/config.fish)
if test -f "$HOME/.ccs/ccs.fish"
    source "$HOME/.ccs/ccs.fish"
end

# PowerShell (Profile.ps1)
if (Test-Path "$env:USERPROFILE\.ccs\ccs.ps1") {
    . "$env:USERPROFILE\.ccs\ccs.ps1"
}
```

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

## 📊 Performance Benchmarks

### Configuration Switching Speed
- **Cold Start**: ~150ms (first run)
- **Cached Access**: ~30ms (subsequent runs)
- **Memory Usage**: <5MB for typical configurations
- **File I/O**: Optimized with caching and lazy loading

### Cross-platform Performance
- **Linux**: Native performance with optimized Bash
- **macOS**: Full compatibility with performance tuning
- **Windows**: PowerShell optimization with fallback to CMD
- **WSL**: Seamless integration with Windows host

## 🛡️ Security

### Data Protection
- **Sensitive Information Masking**: API keys are never displayed in full
- **Secure File Permissions**: Configuration files have restricted permissions (600)
- **No Telemetry**: No data collection or external communication
- **Local Processing**: All operations performed locally

### Best Practices
- **API Key Storage**: Secure storage with proper file permissions
- **Backup Encryption**: Optional encryption for configuration backups
- **Audit Trail**: Detailed logging of configuration changes
- **Access Control**: User-level permissions for configuration files

## 🆘 Troubleshooting

### Common Issues

**Command not found after installation**
```bash
source ~/.bashrc  # or appropriate shell config
# If still not working, check PATH and reinstall
```

**Configuration not persisting**
```bash
ccs diagnose      # Run system diagnostics
ccs status        # Check system status
```

**Web interface not working**
```bash
# Check Python availability
python3 --version
# Install Python if needed
# Check firewall settings
```

**Permission denied errors**
```bash
# Check file permissions
ls -la ~/.ccs_config.toml
# Fix permissions
chmod 600 ~/.ccs_config.toml
```

### Debug Mode

Enable debug mode for detailed troubleshooting:
```bash
ccs --debug list           # Debug mode for list command
ccs --debug current        # Debug mode for current command
LOG_LEVEL=DEBUG ccs list   # Environment variable debug
```

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