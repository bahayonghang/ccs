@echo off
setlocal enabledelayedexpansion

REM CCS Banner Display Script for Windows
REM 为Claude Code Configuration Switcher显示启动横幅
REM 支持彩色输出和多种显示模式

REM 版本信息
set "CCS_VERSION=2.0.1"
set "PROJECT_URL=https://github.com/bahayonghang/ccs"

REM 颜色定义 (Windows Console Colors)
set "CYAN=[96m"
set "BRIGHT_CYAN=[96m"
set "WHITE=[97m"
set "GRAY=[37m"
set "RESET=[0m"

REM 检查是否支持ANSI颜色
set "COLORS_ENABLED=true"
if "%NO_COLOR%"=="1" set "COLORS_ENABLED=false"
if "%CCS_DISABLE_COLORS%"=="true" set "COLORS_ENABLED=false"

goto :main

:show_banner
    set "use_colors=%~1"
    if "%use_colors%"=="" set "use_colors=true"
    
    if "%use_colors%"=="false" (
        set "CYAN="
        set "BRIGHT_CYAN="
        set "WHITE="
        set "GRAY="
        set "RESET="
    )
    
    echo.
    echo !BRIGHT_CYAN!██████╗ ██████╗ ███████╗!RESET!
    echo !BRIGHT_CYAN!██╔════╝██╔════╝██╔════╝!RESET!
    echo !BRIGHT_CYAN!██║     ██║     ███████╗!RESET!
    echo !BRIGHT_CYAN!██║     ██║          ██║!RESET!
    echo !BRIGHT_CYAN!╚██████╗╚██████╗███████║!RESET!
    echo !BRIGHT_CYAN! ╚═════╝ ╚═════╝╚══════╝!RESET!
    echo.
    echo !WHITE!Claude Code Configuration Switcher!RESET!
    echo.
    echo !GRAY!Version: !WHITE!%CCS_VERSION%!GRAY!  ^|  !WHITE!%PROJECT_URL%!RESET!
    echo.
goto :eof

:show_mini_banner
    set "use_colors=%~1"
    if "%use_colors%"=="" set "use_colors=true"
    
    if "%use_colors%"=="false" (
        set "CYAN="
        set "WHITE="
        set "RESET="
    )
    
    echo !CYAN!██████╗ ██████╗ ███████╗!RESET!
    echo !CYAN!██╔════╝██╔════╝██╔════╝!RESET!
    echo !CYAN!██║     ██║     ███████╗!RESET!
    echo !CYAN!██║     ██║          ██║!RESET!
    echo !CYAN!╚██████╗╚██████╗███████║!RESET!
    echo !CYAN! ╚═════╝ ╚═════╝╚══════╝!RESET!
    echo !WHITE!Claude Code Configuration Switcher v%CCS_VERSION%!RESET!
    echo.
goto :eof

:show_plain_banner
    echo.
    echo ██████╗ ██████╗ ███████╗
    echo ██╔════╝██╔════╝██╔════╝
    echo ██║     ██║     ███████╗
    echo ██║     ██║          ██║
    echo ╚██████╗╚██████╗███████║
    echo  ╚═════╝ ╚═════╝╚══════╝
    echo.
    echo Claude Code Configuration Switcher
    echo.
    echo Version: %CCS_VERSION%  ^|  %PROJECT_URL%
    echo.
goto :eof

:show_help
    echo CCS Banner Display Script for Windows
    echo.
    echo Usage: %~nx0 [OPTIONS]
    echo.
    echo Options:
    echo   --full, -f        显示完整banner（默认）
    echo   --mini, -m        显示简化版banner
    echo   --plain, -p       显示纯文本banner（无颜色）
    echo   --no-color        禁用颜色输出
    echo   --help, -h        显示此帮助信息
    echo.
    echo Environment Variables:
    echo   NO_COLOR          设置为1禁用颜色输出
    echo   CCS_DISABLE_COLORS 设置为true禁用颜色输出
    echo.
goto :eof

:main
    set "mode=full"
    set "use_colors=true"
    
    REM 解析命令行参数
    :parse_args
    if "%~1"=="" goto :execute
    
    if /i "%~1"=="--full" (
        set "mode=full"
        shift
        goto :parse_args
    )
    if /i "%~1"=="-f" (
        set "mode=full"
        shift
        goto :parse_args
    )
    if /i "%~1"=="--mini" (
        set "mode=mini"
        shift
        goto :parse_args
    )
    if /i "%~1"=="-m" (
        set "mode=mini"
        shift
        goto :parse_args
    )
    if /i "%~1"=="--plain" (
        set "mode=plain"
        shift
        goto :parse_args
    )
    if /i "%~1"=="-p" (
        set "mode=plain"
        shift
        goto :parse_args
    )
    if /i "%~1"=="--no-color" (
        set "use_colors=false"
        shift
        goto :parse_args
    )
    if /i "%~1"=="--help" (
        call :show_help
        exit /b 0
    )
    if /i "%~1"=="-h" (
        call :show_help
        exit /b 0
    )
    
    echo 未知选项: %~1 >&2
    echo 使用 --help 查看帮助信息 >&2
    exit /b 1
    
    :execute
    REM 根据模式显示相应的banner
    if "%mode%"=="full" (
        call :show_banner "%use_colors%"
    ) else if "%mode%"=="mini" (
        call :show_mini_banner "%use_colors%"
    ) else if "%mode%"=="plain" (
        call :show_plain_banner
    )

endlocal