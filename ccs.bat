@echo off
setlocal enabledelayedexpansion

REM Claude Code Configuration Switcher (CCS) for Windows
REM 此脚本用于切换不同的Claude Code API配置

REM 配置文件路径
set CONFIG_FILE=%USERPROFILE%\.ccs_config.toml

REM 检查配置文件是否存在
if not exist "%CONFIG_FILE%" (
    echo 错误: 配置文件 %CONFIG_FILE% 不存在
    echo 请先运行安装脚本来创建配置文件
    exit /b 1
)

REM 显示帮助信息
:ccs_help
echo Claude Code Configuration Switcher (CCS)
echo.
echo 用法:
echo   ccs [配置名称]    - 切换到指定配置
echo   ccs list          - 列出所有可用配置
echo   ccs current       - 显示当前配置
echo   ccs help          - 显示此帮助信息
echo.
echo 示例:
echo   ccs anyrouter     - 切换到anyrouter配置
echo   ccs glm           - 切换到智谱GLM配置
echo   ccs list          - 查看所有可用配置
exit /b 0

REM 解析TOML配置文件
:parse_toml
set config_name=%~1
set config_content=

REM 使用findstr提取配置节内容
for /f "usebackq tokens=*" %%a in (`findstr /n "^" "%CONFIG_FILE%" ^| findstr "^\[%config_name%\]"`) do (
    set start_line=%%a
)
if not defined start_line (
    echo 错误: 配置 '%config_name%' 不存在
    exit /b 1
)

REM 提取行号
set start_line=%start_line:*:=%

REM 读取配置节内容
set in_section=0
for /f "usebackq tokens=*" %%a in (`findstr /n "^" "%CONFIG_FILE%"`) do (
    set line=%%a
    set line_num=!line:*:=!
    set line_content=!line:*:=!
    
    if "!line_num!"=="%start_line%" (
        set in_section=1
    ) else if "!line_content:~0,1!"=="[" (
        if !in_section!==1 (
            goto end_section
        )
    ) else if !in_section!==1 (
        set config_content=!config_content!!line_content!^
)
)

:end_section

REM 清理环境变量
set ANTHROPIC_BASE_URL=
set ANTHROPIC_AUTH_TOKEN=
set ANTHROPIC_MODEL=
set ANTHROPIC_SMALL_FAST_MODEL=

REM 解析配置项
for %%a in ("%config_content:~0,-1%") do (
    set line=%%a
    set line=!line:^
=!
    
    for /f "tokens=1,2 delims==" %%b in ("!line!") do (
        set key=%%b
        set value=%%c
        set key=!key: =!
        set value=!value: =!
        
        REM 移除引号
        if "!value:~0,1!"=="""" set value=!value:~1,-1!
        if "!value:~0,1!"=="'" set value=!value:~1,-1!
        
        if "!key!"=="base_url" (
            set ANTHROPIC_BASE_URL=!value!
            echo 设置 ANTHROPIC_BASE_URL=!value!
        ) else if "!key!"=="auth_token" (
            set ANTHROPIC_AUTH_TOKEN=!value!
            echo 设置 ANTHROPIC_AUTH_TOKEN=!value:~0,10!...
        ) else if "!key!"=="model" (
            set ANTHROPIC_MODEL=!value!
            echo 设置 ANTHROPIC_MODEL=!value!
        ) else if "!key!"=="small_fast_model" (
            set ANTHROPIC_SMALL_FAST_MODEL=!value!
            echo 设置 ANTHROPIC_SMALL_FAST_MODEL=!value!
        )
    )
)

REM 设置环境变量
if defined ANTHROPIC_BASE_URL setx ANTHROPIC_BASE_URL "%ANTHROPIC_BASE_URL%" >nul
if defined ANTHROPIC_AUTH_TOKEN setx ANTHROPIC_AUTH_TOKEN "%ANTHROPIC_AUTH_TOKEN%" >nul
if defined ANTHROPIC_MODEL setx ANTHROPIC_MODEL "%ANTHROPIC_MODEL%" >nul
if defined ANTHROPIC_SMALL_FAST_MODEL setx ANTHROPIC_SMALL_FAST_MODEL "%ANTHROPIC_SMALL_FAST_MODEL%" >nul

echo 已切换到配置: %config_name%
exit /b 0

REM 列出所有可用配置
:list_configs
echo 可用的配置:
echo.

REM 查找所有配置节
for /f "usebackq tokens=*" %%a in (`findstr /r "^\[.*\]" "%CONFIG_FILE%"`) do (
    set line=%%a
    set line=!line:[=!
    set line=!line:]=!
    
    REM 跳过default_config
    if not "!line!"=="default_config" (
        set config_name=!line!
        
        REM 获取配置描述
        set description=
        for /f "usebackq tokens=*" %%b in (`findstr /n "^" "%CONFIG_FILE%" ^| findstr /n "description"`) do (
            set desc_line=%%b
            for /f "tokens=1,2 delims=:" %%c in ("!desc_line!") do (
                set desc_num=%%c
                set desc_content=%%d
                set desc_content=!desc_content:~1!
                
                REM 检查是否在当前配置节内
                set found=0
                for /f "usebackq tokens=*" %%d in (`findstr /n "^" "%CONFIG_FILE%" ^| findstr /n "^\[!config_name!\]"`) do (
                    set config_line_num=%%d
                    for /f "tokens=1 delims=:" %%e in ("!config_line_num!") do (
                        if "!desc_num!" gtr "%%e" (
                            set found=1
                        )
                    )
                )
                
                if !found!==1 (
                    REM 检查是否在下一个配置节之前
                    set next_section=0
                    for /f "usebackq tokens=*" %%e in (`findstr /n "^" "%CONFIG_FILE%" ^| findstr /r "^\[.*\]"`) do (
                        set next_line=%%e
                        for /f "tokens=1 delims=:" %%f in ("!next_line!") do (
                            if "!desc_num!" lss "%%f" (
                                set next_section=1
                            )
                        )
                    )
                    
                    if !next_section!==0 (
                        for /f "tokens=2 delims==" %%f in ("!desc_content!") do (
                            set desc_value=%%f
                            set desc_value=!desc_value: =!
                            if "!desc_value:~0,1!"=="""" set desc_value=!desc_value:~1,-1!
                            if "!desc_value:~0,1!"=="'" set desc_value=!desc_value:~1,-1!
                            set description=!desc_value!
                        )
                    )
                )
            )
        )
        
        if defined description (
            echo   !config_name! - !description!
        ) else (
            echo   !config_name!
        )
    )
)

echo.

REM 显示默认配置
for /f "usebackq tokens=2 delims==" %%a in (`findstr "default_config" "%CONFIG_FILE%"`) do (
    set default_config=%%a
    set default_config=!default_config: =!
    if "!default_config:~0,1!"=="""" set default_config=!default_config:~1,-1!
    if "!default_config:~0,1!"=="'" set default_config=!default_config:~1,-1!
    echo 默认配置: !default_config!
)
exit /b 0

REM 显示当前配置
:show_current
echo 当前配置:

if defined ANTHROPIC_BASE_URL (
    echo   ANTHROPIC_BASE_URL=%ANTHROPIC_BASE_URL%
) else (
    echo   ANTHROPIC_BASE_URL=(未设置)
)

if defined ANTHROPIC_AUTH_TOKEN (
    echo   ANTHROPIC_AUTH_TOKEN=%ANTHROPIC_AUTH_TOKEN:~0,10%...
) else (
    echo   ANTHROPIC_AUTH_TOKEN=(未设置)
)

if defined ANTHROPIC_MODEL (
    echo   ANTHROPIC_MODEL=%ANTHROPIC_MODEL%
) else (
    echo   ANTHROPIC_MODEL=(未设置)
)

if defined ANTHROPIC_SMALL_FAST_MODEL (
    echo   ANTHROPIC_SMALL_FAST_MODEL=%ANTHROPIC_SMALL_FAST_MODEL%
) else (
    echo   ANTHROPIC_SMALL_FAST_MODEL=(未设置)
)
exit /b 0

REM 主函数
if "%~1"=="" (
    REM 如果没有参数，使用默认配置
    for /f "usebackq tokens=2 delims==" %%a in (`findstr "default_config" "%CONFIG_FILE%"`) do (
        set default_config=%%a
        set default_config=!default_config: =!
        if "!default_config:~0,1!"=="""" set default_config=!default_config:~1,-1!
        if "!default_config:~0,1!"=="'" set default_config=!default_config:~1,-1!
        if defined default_config (
            call :parse_toml !default_config!
        ) else (
            echo 错误: 没有指定配置名称且没有默认配置
            call :ccs_help
            exit /b 1
        )
    )
) else if "%~1"=="list" (
    call :list_configs
) else if "%~1"=="current" (
    call :show_current
) else if "%~1"=="help" (
    call :ccs_help
) else if "%~1"=="-h" (
    call :ccs_help
) else if "%~1"=="--help" (
    call :ccs_help
) else (
    call :parse_toml %~1
)