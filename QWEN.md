# Qwen Context for CCS Project

## Project Overview

This project is the **Claude Code Configuration Switcher (CCS)**. It's a command-line tool designed to quickly switch between different Claude Code API configurations. It supports multiple shell environments (Bash, Fish) and Windows environments (CMD, PowerShell). The tool also provides a web-based interface for managing configurations.

Key features include:
- Rapid switching of Claude Code API configurations.
- A web interface for visual configuration management.
- Support for multiple platforms and shell environments.
- TOML format for configuration files.

## Project Structure

```
ccs/
├── scripts/                    # Script files directory
│   ├── shell/                 # Shell scripts
│   │   ├── ccs.sh            # Main Bash script
│   │   ├── ccs.fish          # Fish script
│   │   └── ccs-common.sh     # Common utilities for shell scripts
│   ├── windows/              # Windows scripts
│   │   ├── ccs.bat           # Batch script
│   │   └── ccs.ps1           # PowerShell script
│   └── install/              # Installation scripts
│       ├── install.sh        # Linux/macOS installation
│       ├── install.bat       # Windows installation
│       └── quick_install/    # Quick install scripts
│           ├── quick_install.sh
│           └── quick_install.bat
├── config/                    # Configuration files directory
│   └── ccs_config.toml.example  # Example configuration file
├── web/                       # Web interface
│   └── index.html
├── docs/                      # Documentation directory
│   └── CLAUDE.md
├── assets/                    # Resource files directory
│   └── imgs/
│       ├── screenshot1.png
│       └── screenshot2.png
├── README.md                  # Project documentation
└── package.json              # Project metadata and NPM scripts
```

Installation places files in `~/.ccs/` and the configuration file at `~/.ccs_config.toml`.

## Key Files

- `scripts/shell/ccs.sh`: The primary Bash script that implements the `ccs` command functionality.
- `config/ccs_config.toml.example`: An example TOML configuration file showing various API service setups.
- `web/index.html`: The HTML file for the web-based configuration management interface.
- `README.md`: The main project documentation, providing installation, usage, and configuration details.
- `package.json`: Contains project metadata and defines NPM scripts for common tasks like install, uninstall, and test.

## Building and Running

This is a shell script-based project. There is no traditional build process. Installation involves copying scripts to a user directory and setting up environment variables.

### Installation

**Linux/macOS (Quick Install):**
```bash
curl -L https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.sh | bash
```

**Windows:**
Download and run: `https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.bat`

**Manual Installation (Linux/macOS):**
```bash
npm run install
# Or directly
cd scripts/install && bash install.sh
```

**Manual Installation (Windows):**
```bash
npm run install:windows
# Or directly
cd scripts/install && cmd.exe /c install.bat
```

### Usage

After installation, the `ccs` command is available:
- `ccs list`: List all configurations.
- `ccs [config_name]`: Switch to a specific configuration.
- `ccs current`: Show the current configuration.
- `ccs web`: Start the web management interface.
- `ccs uninstall`: Uninstall the tool.
- `ccs help`: Show help.

### Testing

A basic test script is defined to list configurations:
```bash
npm run test
# Or directly
bash scripts/shell/ccs.sh list
```

### Uninstallation

```bash
ccs uninstall
# Or
npm run uninstall
# Or directly
cd scripts/install && bash install.sh --uninstall
```

## Development Conventions

- **Primary Languages:** Bash, PowerShell, HTML/CSS/JavaScript, TOML for configuration.
- **Configuration Format:** Uses TOML for the `~/.ccs_config.toml` file.
- **Environment Variables:** The tool sets `ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_MODEL`, and `ANTHROPIC_SMALL_FAST_MODEL` based on the active configuration.
- **Web Interface:** A self-contained `index.html` file provides a GUI for configuration management.
- **Scripts:** Platform-specific scripts (`ccs.sh`, `ccs.fish`, `ccs.bat`, `ccs.ps1`) are located in `scripts/shell/` and `scripts/windows/` respectively.