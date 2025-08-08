@echo off
setlocal enabledelayedexpansion

REM Claude Code Configuration Switcher Windows 安装脚本
REM 此脚本用于安装和配置ccs命令（Windows版本）

set "CONFIG_FILE=%USERPROFILE%\.ccs_config.toml"
set "CCS_DIR=%USERPROFILE%\.ccs"
set "CCS_BAT=%CCS_DIR%\ccs.bat"
set "CCS_PS1=%CCS_DIR%\ccs.ps1"

REM 检查是否以管理员权限运行
net session >nul 2>&1
if %errorLevel% == 0 (
    set ADMIN_PRIVILEGES=1
) else (
    set ADMIN_PRIVILEGES=0
)

REM 颜色输出（Windows 10+）
if %ADMIN_PRIVILEGES%==1 (
    set "RED=[91m"
    set "GREEN=[92m"
    set "YELLOW=[93m"
    set "BLUE=[94m"
    set "NC=[0m"
) else (
    set "RED="
    set "GREEN="
    set "YELLOW="
    set "BLUE="
    set "NC="
)

REM 打印带颜色的消息
:print_message
set color=%~1
set message=%~2
echo %color%[*]%NC% %message%
goto :eof

:print_success
echo %GREEN%[✓]%NC% %~1
goto :eof

:print_warning
echo %YELLOW%[!]%NC% %~1
goto :eof

:print_error
echo %RED%[✗]%NC% %~1
goto :eof

REM 检查命令是否存在
:command_exists
where %~1 >nul 2>&1
exit /b %errorlevel%

REM 检查PowerShell是否可用
:check_powershell
powershell -Command "Exit 0" >nul 2>&1
if %errorlevel% neq 0 (
    call :print_error "PowerShell 不可用，无法完成安装"
    exit /b 1
)
goto :eof

REM 创建目录
:create_directories
call :print_message "%BLUE%" "创建必要的目录..."

if not exist "%CCS_DIR%" (
    mkdir "%CCS_DIR%"
    call :print_success "创建目录 %CCS_DIR%"
) else (
    call :print_warning "目录 %CCS_DIR% 已存在"
)
goto :eof

REM 检查是否已安装
:check_installed
if exist "%CCS_BAT%" (
    exit /b 0
) else (
    exit /b 1
)
goto :eof

REM 复制脚本文件
:copy_script
set reinstall=0

REM 检查是否为重新安装
call :check_installed
if %errorlevel%==0 (
    call :print_message "%YELLOW%" "检测到ccs已安装，将更新所有脚本..."
    set reinstall=1
) else (
    call :print_message "%BLUE%" "复制ccs脚本..."
)

REM 获取当前脚本所在目录
set script_dir=%~dp0
set source_bat="%script_dir%ccs.bat"
set source_ps1="%script_dir%ccs.ps1"

if not exist %source_bat% (
    call :print_error "找不到源脚本文件: %source_bat%"
    exit /b 1
)

REM 复制批处理脚本
if exist "%CCS_BAT%" (
    if %reinstall%==1 (
        call :print_message "%BLUE%" "更新批处理脚本..."
    )
)
copy %source_bat% "%CCS_BAT%" >nul
if %reinstall%==1 (
    call :print_success "更新批处理脚本到 %CCS_BAT%"
) else (
    call :print_success "复制批处理脚本到 %CCS_BAT%"
)

REM 复制PowerShell脚本
if exist %source_ps1% (
    if exist "%CCS_PS1%" (
        if %reinstall%==1 (
            call :print_message "%BLUE%" "更新PowerShell脚本..."
        )
    )
    copy %source_ps1% "%CCS_PS1%" >nul
    if %reinstall%==1 (
        call :print_success "更新PowerShell脚本到 %CCS_PS1%"
    ) else (
        call :print_success "复制PowerShell脚本到 %CCS_PS1%"
    )
)

REM 如果是重新安装，提供额外提示
if %reinstall%==1 (
    call :print_warning "已更新所有脚本，配置文件保持不变"
)
goto :eof

REM 创建配置文件
:create_config_file
call :print_message "%BLUE%" "检查配置文件..."

if exist "%CONFIG_FILE%" (
    call :print_warning "配置文件 %CONFIG_FILE% 已存在，跳过创建"
    goto :eof
)

REM 获取示例配置文件路径
set script_dir=%~dp0
set example_config="%script_dir%.ccs_config.toml.example"

if exist %example_config% (
    copy %example_config% "%CONFIG_FILE%" >nul
    call :print_success "创建配置文件 %CONFIG_FILE%"
    call :print_warning "请编辑 %CONFIG_FILE% 文件，填入您的API密钥"
) else (
    call :print_error "找不到示例配置文件: %example_config%"
    exit /b 1
)
goto :eof

REM 配置PowerShell环境
:configure_powershell
call :print_message "%BLUE%" "配置PowerShell环境..."

REM 检查PowerShell配置文件
set "PS_PROFILE=%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
set "PS_PROFILE_DIR=%USERPROFILE%\Documents\WindowsPowerShell"

REM 创建PowerShell配置目录
if not exist "%PS_PROFILE_DIR%" (
    mkdir "%PS_PROFILE_DIR%"
    call :print_success "创建PowerShell配置目录"
)

REM 检查是否已经配置
if exist "%PS_PROFILE%" (
    findstr /c:"ccs.ps1" "%PS_PROFILE%" >nul 2>&1
    if %errorlevel%==0 (
        call :print_warning "ccs已经在PowerShell配置中配置过了"
        goto :eof
    )
)

REM 添加配置到PowerShell配置文件
echo. >> "%PS_PROFILE%"
echo # Claude Code Configuration Switcher (CCS) >> "%PS_PROFILE%"
echo if (Test-Path "%CCS_PS1%") { >> "%PS_PROFILE%"
echo     . "%CCS_PS1%" >> "%PS_PROFILE%"
echo     # 初始化默认配置 >> "%PS_PROFILE%"
echo     if (Get-Command ccs -ErrorAction SilentlyContinue) { >> "%PS_PROFILE%"
echo         ccs 2^>$null ^| Out-Null >> "%PS_PROFILE%"
echo     } >> "%PS_PROFILE%"
echo } >> "%PS_PROFILE%"

call :print_success "已添加ccs配置到PowerShell配置文件"
goto :eof

REM 配置Windows路径环境变量
:configure_path
call :print_message "%BLUE%" "配置Windows路径环境变量..."

REM 检查是否已经在PATH中
echo %PATH% | findstr /c:"%CCS_DIR%" >nul 2>&1
if %errorlevel%==0 (
    call :print_warning "ccs目录已经在PATH环境变量中"
    goto :eof
)

REM 添加到PATH环境变量（用户级别）
if %ADMIN_PRIVILEGES%==1 (
    REM 管理员权限：直接修改注册表
    for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v PATH') do set "USER_PATH=%%b"
    if defined USER_PATH (
        set "NEW_PATH=%USER_PATH%;%CCS_DIR%"
    ) else (
        set "NEW_PATH=%CCS_DIR%"
    )
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "%NEW_PATH%" /f >nul
    call :print_success "已添加ccs目录到用户PATH环境变量"
) else (
    REM 非管理员权限：提示用户手动添加
    call :print_warning "无法自动修改PATH环境变量（需要管理员权限）"
    call :print_warning "请手动将以下目录添加到系统PATH环境变量："
    call :print_warning "  %CCS_DIR%"
)
goto :eof

REM 安装完成
:install_complete
call :check_installed
if %errorlevel%==0 (
    set reinstall=1
) else (
    set reinstall=0
)

if %reinstall%==1 (
    call :print_success "重新安装完成！"
) else (
    call :print_success "安装完成！"
)

echo.
call :print_message "%BLUE%" "使用方法:"
echo   ccs list              - 列出所有可用配置
echo   ccs [配置名称]       - 切换到指定配置
echo   ccs current          - 显示当前配置
echo   ccs help             - 显示帮助信息
echo.

if %reinstall%==1 (
    call :print_warning "脚本已更新，请重新启动终端或重新打开PowerShell来使新版本生效"
) else (
    call :print_warning "请重新启动终端或重新打开PowerShell来使配置生效"
)

REM 检查配置文件是否存在
if exist "%CONFIG_FILE%" (
    echo.
    call :print_message "%BLUE%" "配置文件位置: %CONFIG_FILE%"
    if %reinstall%==1 (
        call :print_success "现有配置文件已保留，无需重新配置"
    ) else (
        call :print_warning "请编辑配置文件，确保您的API密钥正确"
    )
)
goto :eof

REM 卸载函数
:uninstall
call :print_message "%BLUE%" "开始卸载ccs..."

REM 删除脚本文件
if exist "%CCS_BAT%" (
    del "%CCS_BAT%"
    call :print_success "删除批处理脚本文件"
)

if exist "%CCS_PS1%" (
    del "%CCS_PS1%"
    call :print_success "删除PowerShell脚本文件"
)

REM 删除配置文件（询问用户）
set /p answer="是否要删除配置文件 %CONFIG_FILE%? (y/N): "
if /i "%answer%"=="y" (
    if exist "%CONFIG_FILE%" (
        del "%CONFIG_FILE%"
        call :print_success "删除配置文件"
    )
)

REM 从PowerShell配置文件中移除配置
set "PS_PROFILE=%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
if exist "%PS_PROFILE%" (
    REM 创建临时文件
    set "temp_file=%TEMP%\ps_profile_temp.ps1"
    
    REM 移除ccs相关的配置行
    findstr /v /c:"Claude Code Configuration Switcher" "%PS_PROFILE%" | findstr /v /c:"ccs.ps1" > "%temp_file%"
    
    REM 替换原文件
    move /y "%temp_file%" "%PS_PROFILE%" >nul
    call :print_success "从PowerShell配置文件中移除配置"
)

REM 从PATH中移除（如果有管理员权限）
if %ADMIN_PRIVILEGES%==1 (
    for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v PATH') do set "USER_PATH=%%b"
    if defined USER_PATH (
        set "NEW_PATH=!USER_PATH:%CCS_DIR%=!"
        set "NEW_PATH=!NEW_PATH:;;=;!"
        if "!NEW_PATH:~-1!"==";" set "NEW_PATH=!NEW_PATH:~0,-1!"
        reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "!NEW_PATH!" /f >nul
        call :print_success "从PATH环境变量中移除ccs目录"
    )
)

call :print_success "卸载完成！请重新启动终端"
goto :eof

REM 显示帮助
:show_help
echo Claude Code Configuration Switcher Windows 安装脚本
echo.
echo 用法:
echo   %~nx0                    - 安装ccs（如果已安装则更新脚本文件）
echo   %~nx0 --uninstall        - 卸载ccs
echo   %~nx0 --help             - 显示此帮助
echo.
echo 此脚本将:
echo   1. 创建 %CCS_DIR% 目录
echo   2. 复制/更新ccs.bat和ccs.ps1脚本到 %CCS_DIR%\
echo   3. 创建配置文件 %CONFIG_FILE%（如果不存在）
echo   4. 配置PowerShell环境
echo   5. 尝试添加到PATH环境变量（需要管理员权限）
echo.
echo 重新安装行为:
echo   - 强制更新所有脚本文件
echo   - 保留现有配置文件不变
echo   - 不重复添加配置
echo.
echo 注意: 配置文件一旦存在就不会被覆盖
goto :eof

REM 主函数
:main
if "%~1"=="--uninstall" (
    call :uninstall
    goto :eof
) else if "%~1"=="--help" (
    call :show_help
    goto :eof
) else if "%~1"=="-h" (
    call :show_help
    goto :eof
)

REM 检查PowerShell是否可用
call :check_powershell

REM 检查是否为重新安装
call :check_installed
if %errorlevel%==0 (
    call :print_message "%YELLOW%" "检测到ccs已安装，开始更新..."
    echo.
) else (
    call :print_message "%BLUE%" "开始安装Claude Code Configuration Switcher (Windows版本)..."
    echo.
)

call :create_directories
call :copy_script
call :create_config_file
call :configure_powershell
call :configure_path
echo.
call :install_complete
goto :eof

REM 运行主函数
call :main %*