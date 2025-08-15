@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
goto :main

REM Simple message functions
:print_message
if "%~1"=="" (
    echo [*]
) else (
    echo [*] %~1
)
goto :eof

:print_success
if "%~1"=="" (
    echo [OK]
) else (
    echo [OK] %~1
)
goto :eof

:print_warning
if "%~1"=="" (
    echo [!]
) else (
    echo [!] %~1
)
goto :eof

:print_error
if "%~1"=="" (
    echo [ERROR]
) else (
    echo [ERROR] %~1
)
goto :eof

REM Set variables
:set_variables
set CCS_DIR=%USERPROFILE%\.ccs
set CCS_BAT=%USERPROFILE%\.ccs\ccs.bat
set CCS_PS1=%USERPROFILE%\.ccs\ccs.ps1
set CONFIG_FILE=%USERPROFILE%\.ccs_config.toml
set SCRIPT_DIR=%~dp0
set REINSTALL=0
set ADMIN_PRIVILEGES=0

REM Check admin privileges
net session >nul 2>&1
if not errorlevel 1 set ADMIN_PRIVILEGES=1
goto :eof

REM Check if command exists
:command_exists
where "%~1" >nul 2>&1
goto :eof

REM Check PowerShell availability
:check_powershell
call :command_exists powershell
if errorlevel 1 (
    call :print_error "PowerShell not available"
    exit /b 1
)
goto :eof

REM Create directories
:create_directories
call :print_message "Creating directories..."
if not exist "!CCS_DIR!" (
    mkdir "!CCS_DIR!"
    set "success_msg=Created directory !CCS_DIR!"
    call :print_success "!success_msg!"
) else (
    set "warning_msg=Directory !CCS_DIR! already exists"
    call :print_warning "!warning_msg!"
)
goto :eof

REM Check existing installation
:check_existing_installation
if exist "!CCS_BAT!" (
    set REINSTALL=1
) else (
    set REINSTALL=0
)
goto :eof

REM Copy script files
:copy_scripts
if "%REINSTALL%"=="1" (
    call :print_message "Updating existing installation..."
)

call :print_message "Copying ccs scripts..."

REM Get source script paths
set source_bat=%SCRIPT_DIR%..\windows\ccs.bat
set source_ps1=%SCRIPT_DIR%..\windows\ccs.ps1

if not exist "!source_bat!" (
    set "error_msg=Source script not found: !source_bat!"
    call :print_error "!error_msg!"
    exit /b 1
)

REM Copy batch script
if "%REINSTALL%"=="1" (
    call :print_message "Updating batch script..."
    copy /Y "!source_bat!" "!CCS_BAT!" >nul
) else (
    call :print_message "Installing batch script..."
    copy "!source_bat!" "!CCS_BAT!" >nul
)

if errorlevel 1 (
    call :print_error "Failed to copy batch script"
    exit /b 1
)
set "success_msg=Batch script installed to !CCS_BAT!"
call :print_success "!success_msg!"

REM Copy PowerShell script
if exist "!source_ps1!" (
    if "%REINSTALL%"=="1" (
        call :print_message "Updating PowerShell script..."
        copy /Y "!source_ps1!" "!CCS_PS1!" >nul
    ) else (
        call :print_message "Installing PowerShell script..."
        copy "!source_ps1!" "!CCS_PS1!" >nul
    )
    
    if errorlevel 1 (
        call :print_error "Failed to copy PowerShell script"
        exit /b 1
    )
    set "success_msg=PowerShell script installed to !CCS_PS1!"
     call :print_success "!success_msg!"
) else (
    set "warning_msg=PowerShell script not found: !source_ps1!"
     call :print_warning "!warning_msg!"
)

REM Copy package.json file
set source_package=%SCRIPT_DIR%..\..\package.json
if not exist "!source_package!" (
    set source_package=%SCRIPT_DIR%package.json
)

if exist "!source_package!" (
    set package_path=%USERPROFILE%\.ccs\package.json
    if "%REINSTALL%"=="1" (
        call :print_message "Updating package.json..."
        copy /Y "!source_package!" "!package_path!" >nul
    ) else (
        call :print_message "Installing package.json..."
        copy "!source_package!" "!package_path!" >nul
    )
    
    if errorlevel 1 (
        call :print_warning "Failed to copy package.json"
    ) else (
        if "%REINSTALL%"=="1" (
            call :print_success "Updated package.json to !package_path!"
        ) else (
            call :print_success "Copied package.json to !package_path!"
        )
    )
) else (
    call :print_warning "package.json not found, skipping"
)

if "%REINSTALL%"=="1" (
    call :print_warning "Scripts updated, config files unchanged"
)
goto :eof

REM Create config file
:create_config_file
call :print_message "Checking config file..."
if exist "!CONFIG_FILE!" (
    call :print_warning "Config file already exists, skipping"
    goto :eof
)

REM Get example config path
set example_config=%SCRIPT_DIR%..\..\config\.ccs_config.toml.example
if not exist "!example_config!" (
    set "error_msg=Example config not found: !example_config!"
    call :print_error "!error_msg!"
    exit /b 1
)

copy "!example_config!" "!CONFIG_FILE!" >nul
if errorlevel 1 (
    call :print_error "Failed to create config file"
    exit /b 1
)
set "success_msg=Config file created: !CONFIG_FILE!"
call :print_success "!success_msg!"
call :print_warning "Please edit the config file and add your API keys"
goto :eof

REM Configure PowerShell environment
:configure_powershell
call :print_message "Configuring PowerShell environment..."

REM Check PowerShell profile
set PS_PROFILE=%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
set PS_PROFILE_DIR=%USERPROFILE%\Documents\WindowsPowerShell

REM Create PowerShell profile directory
if not exist "!PS_PROFILE_DIR!" (
    mkdir "!PS_PROFILE_DIR!"
)

REM Check if already configured
if exist "!PS_PROFILE!" (
    findstr /C:"ccs" "!PS_PROFILE!" >nul
    if not errorlevel 1 (
        call :print_warning "ccs already configured in PowerShell"
        goto :eof
    )
)

REM Add ccs configuration to PowerShell profile
echo # ccs configuration >> "!PS_PROFILE!"
echo if (Test-Path "$env:USERPROFILE\.ccs\ccs.ps1") { >> "!PS_PROFILE!"
echo     . "$env:USERPROFILE\.ccs\ccs.ps1" >> "!PS_PROFILE!"
echo     if (-not $env:CCS_CONFIG_FILE) { >> "!PS_PROFILE!"
echo         $env:CCS_CONFIG_FILE = "$env:USERPROFILE\.ccs_config.toml" >> "!PS_PROFILE!"
echo     } >> "!PS_PROFILE!"
echo } >> "!PS_PROFILE!"

call :print_success "Added ccs configuration to PowerShell profile"
goto :eof

REM Configure Windows PATH environment variable
:configure_path
call :print_message "Configuring Windows PATH environment variable..."

REM Check if already in PATH
echo %PATH% | findstr /I "!CCS_DIR!" >nul
if not errorlevel 1 (
    call :print_warning "ccs directory already in PATH"
    goto :eof
)

REM Add to PATH environment variable (user level)
if "%ADMIN_PRIVILEGES%"=="1" (
    REM Admin privileges: modify registry directly
    for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set USER_PATH=%%b
    if defined USER_PATH (
        reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "%USER_PATH%;!CCS_DIR!" /f >nul
    ) else (
        reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "!CCS_DIR!" /f >nul
    )
    call :print_success "Added ccs directory to user PATH"
) else (
    REM No admin privileges: prompt user to add manually
    call :print_warning "Cannot modify PATH automatically (admin required)"
    call :print_warning "Please manually add this directory to PATH:"
    set "msg=!CCS_DIR!"
    call :print_message "!msg!"
)
goto :eof

REM Installation complete
:install_complete
echo.
if "%REINSTALL%"=="1" (
    call :print_success "Reinstallation complete!"
) else (
    call :print_success "Installation complete!"
)
echo.

call :print_message "Usage:"
call :print_message "  ccs list              - List all available configurations"
call :print_message "  ccs [config-name]     - Switch to specified configuration"
call :print_message "  ccs current          - Show current configuration"
call :print_message "  ccs help             - Show help information"
echo.

if "%REINSTALL%"=="1" (
    call :print_warning "Scripts updated, please restart terminal"
) else (
    call :print_warning "Please restart terminal to apply configuration"
)

REM Check config file
if exist "!CONFIG_FILE!" (
    echo.
    set "msg=Config file location: !CONFIG_FILE!"
    call :print_message "!msg!"
    if "%REINSTALL%"=="1" (
        call :print_success "Existing config preserved"
    ) else (
        call :print_warning "Please edit config file and add your API keys"
    )
)
goto :eof

REM Uninstall function
:uninstall
call :print_message "Starting ccs uninstallation..."

REM Delete script files
if exist "!CCS_BAT!" (
    del "!CCS_BAT!"
    call :print_success "Deleted batch script"
)

if exist "%CCS_PS1%" (
    del "%CCS_PS1%"
    call :print_success "Deleted PowerShell script"
)

REM Delete directory if empty
if exist "!CCS_DIR!" (
    rmdir "!CCS_DIR!" 2>nul
    if not exist "!CCS_DIR!" (
        call :print_success "Deleted ccs directory"
    ) else (
        call :print_warning "ccs directory not empty, not deleted"
    )
)

REM Config file (optional)
if exist "!CONFIG_FILE!" (
    set "warning_msg=Config file still exists: !CONFIG_FILE!"
    call :print_warning "!warning_msg!"
    call :print_warning "Delete manually if complete removal desired"
)

call :print_success "Uninstallation complete!"
set "warning_msg=Please manually remove !CCS_DIR! from PATH"
call :print_warning "!warning_msg!"
call :print_warning "Please manually remove ccs config from PowerShell profile"
goto :eof

REM Show help
:show_help
echo.
echo Claude Code Configuration Switcher Windows Installer
echo.
echo Usage:
echo   install.bat                    - Install ccs (update if already installed)
echo   install.bat --uninstall        - Uninstall ccs
echo   install.bat --help             - Show this help
echo.
echo This script will:
echo   1. Create %CCS_DIR% directory
echo   2. Copy/update ccs.bat and ccs.ps1 scripts
echo   3. Create config file (if not exists)
echo   4. Configure PowerShell environment
echo   5. Try to add to PATH (requires admin privileges)
echo.
echo Reinstall behavior:
echo   - Force update all script files
echo   - Keep existing config files unchanged
echo   - Do not duplicate configurations
echo.
echo Note: Config files are never overwritten once they exist
echo.
goto :eof

REM Main function
:main
REM Set variables
call :set_variables

REM Handle command line arguments
if "%~1"=="--help" (
    call :show_help
    exit /b 0
)

if "%~1"=="--uninstall" (
    call :uninstall
    exit /b 0
)

REM Continue with installation if no matching arguments

REM Check PowerShell availability
call :check_powershell
if errorlevel 1 exit /b 1

REM Check if reinstall
call :check_existing_installation
if "%REINSTALL%"=="1" (
    call :print_message "Existing installation detected, updating..."
) else (
    call :print_message "Starting Claude Code Configuration Switcher installation..."
)

REM Execute installation steps
call :create_directories
if errorlevel 1 exit /b 1

call :copy_scripts
if errorlevel 1 exit /b 1

call :create_config_file
if errorlevel 1 exit /b 1

call :configure_powershell
if errorlevel 1 exit /b 1

call :configure_path
if errorlevel 1 exit /b 1

call :install_complete

exit /b 0