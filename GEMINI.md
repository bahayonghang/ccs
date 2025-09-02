# GEMINI.md

## Project Overview

This project, "Claude Code Configuration Switcher" (CCS), is a command-line tool designed to simplify the management of different API configurations for Claude Code. It allows users to quickly switch between various API providers such as Anthropic, OpenAI, and others. The tool features a command-line interface (CLI) for configuration switching, a web interface for management, and global configuration persistence across multiple shell environments.

The primary technologies used are shell scripts (Bash, Fish, PowerShell) for the core logic, and a simple HTML/CSS/JS frontend for the web interface. Configuration is handled through a TOML file.

## Building and Running

The project uses a `justfile` to manage build, installation, and development tasks.

### Key Commands:

*   **Installation:**
    *   `just install`: Installs the tool on the system (Linux/macOS).
    *   `just install-windows`: Installs the tool on Windows.
    *   `just quick-install`: A one-line installation script for quick setup.

*   **Running:**
    *   `ccs list`: Lists all available configurations.
    *   `ccs <config_name>`: Switches to the specified configuration.
    *   `ccs current`: Shows the currently active configuration.
    *   `ccs web`: Starts the web interface for configuration management.

*   **Testing:**
    *   `just test`: Runs basic functionality tests.
    *   `just test-all`: Tests all shell scripts.
    *   `just check-syntax`: Checks the syntax of all scripts.

## Development Conventions

*   **Configuration:** Project configuration is managed through a `~/.ccs_config.toml` file, with an example provided in `config/.ccs_config.toml.example`.
*   **Shell Support:** The tool is designed to be cross-platform and supports Bash, Zsh, Fish, and PowerShell.
*   **Contribution:** The `justfile` provides a comprehensive set of commands for development, including testing, syntax checking, and release management. The `README.md` file is very detailed and should be consulted for any questions about the project.