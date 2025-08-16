@echo off
setlocal enabledelayedexpansion

REM Claude Code Configuration Switcher (CCS) for Windows
REM 此脚本用于切换不同的Claude Code API配置

REM 配置文件路径
set CONFIG_FILE=%USERPROFILE%\.ccs_config.toml

REM 错误码定义
set ERROR_SUCCESS=0
set ERROR_CONFIG_MISSING=1
set ERROR_CONFIG_INVALID=2
set ERROR_FILE_NOT_FOUND=5

REM 检查配置文件是否存在
if not exist "%CONFIG_FILE%" (
    echo [错误] 配置文件 %CONFIG_FILE% 不存在
    echo 解决方案: 请先运行安装脚本来创建配置文件
    echo 使用 'ccs help' 查看帮助信息
    exit /b %ERROR_CONFIG_MISSING%
)

REM 基本的配置文件验证
call :validate_config_file
if errorlevel 1 (
    exit /b %ERROR_CONFIG_INVALID%
)

REM 显示帮助信息
:ccs_help
echo Claude Code Configuration Switcher (CCS)
echo.
echo 用法:
echo   ccs [配置名称]    - 切换到指定配置
echo   ccs list          - 列出所有可用配置
echo   ccs current       - 显示当前配置
echo   ccs uninstall     - 卸载ccs工具
echo   ccs help          - 显示此帮助信息
echo.
echo 示例:
echo   ccs anyrouter     - 切换到anyrouter配置
echo   ccs glm           - 切换到智谱GLM配置
echo   ccs list          - 查看所有可用配置
echo   ccs uninstall     - 完全卸载ccs工具
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
    echo [错误] 配置 '%config_name%' 不存在
    echo 解决方案: 使用 'ccs list' 查看所有可用配置
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

REM 卸载ccs工具
:ccs_uninstall
echo 正在卸载Claude Code Configuration Switcher...
echo.
echo [*] 开始卸载ccs...

REM 删除整个.ccs目录（除了配置文件）
if exist "%USERPROFILE%\.ccs" (
    REM 删除脚本文件
    if exist "%USERPROFILE%\.ccs\ccs.bat" (
        del /f "%USERPROFILE%\.ccs\ccs.bat"
        echo [✓] 删除bat脚本文件
    )
    
    if exist "%USERPROFILE%\.ccs\ccs.ps1" (
        del /f "%USERPROFILE%\.ccs\ccs.ps1"
        echo [✓] 删除PowerShell脚本文件
    )
    
    REM 删除web文件
    if exist "%USERPROFILE%\.ccs\web" (
        rmdir /s /q "%USERPROFILE%\.ccs\web"
        echo [✓] 删除web文件
    )
    
    REM 检查.ccs目录是否为空（除了配置文件）
    set remaining_files=0
    for %%f in ("%USERPROFILE%\.ccs\*") do (
        if not "%%~nxf"==".ccs_config.toml" (
            set /a remaining_files+=1
        )
    )
    
    if !remaining_files! equ 0 (
        REM 如果没有配置文件,删除整个目录
        if not exist "%CONFIG_FILE%" (
            rmdir /s /q "%USERPROFILE%\.ccs"
            echo [✓] 删除.ccs目录
        ) else (
            echo [!] 保留.ccs目录（包含配置文件）
        )
    )
)

REM 删除配置文件（询问用户）
if exist "%CONFIG_FILE%" (
    set /p "reply=是否要删除配置文件 %CONFIG_FILE%? (y/N): "
    if /i "!reply!"=="y" (
        del /f "%CONFIG_FILE%"
        echo [✓] 删除配置文件
        REM 如果删除了配置文件且.ccs目录为空,删除目录
        if exist "%USERPROFILE%\.ccs" (
            dir /b "%USERPROFILE%\.ccs" | findstr /r "^" >nul
            if errorlevel 1 (
                rmdir /s /q "%USERPROFILE%\.ccs"
                echo [✓] 删除空的.ccs目录
            )
        )
    )
)

REM 从PATH环境变量中移除ccs目录
set "ccs_path=%USERPROFILE%\.ccs"
for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do (
    set "current_path=%%b"
)
if defined current_path (
    set "new_path=!current_path!"
    set "new_path=!new_path:%ccs_path%;=!"
    set "new_path=!new_path:;%ccs_path%=!"
    set "new_path=!new_path:%ccs_path%=!"
    if not "!new_path!"=="!current_path!" (
        reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "!new_path!" /f >nul
        echo [✓] 从PATH环境变量中移除ccs目录
    ) else (
        echo [!] 未在PATH环境变量中找到ccs目录
    )
)

echo [✓] 卸载完成！请重新打开命令提示符或PowerShell
echo.
echo [!] 注意：当前命令提示符会话中的ccs命令仍然可用,直到重新打开
exit /b 0

REM 主函数
if "%~1"=="" (
    REM 如果没有参数,使用默认配置
    for /f "usebackq tokens=2 delims==" %%a in (`findstr "default_config" "%CONFIG_FILE%"`) do (
        set default_config=%%a
        set default_config=!default_config: =!
        if "!default_config:~0,1!"=="""" set default_config=!default_config:~1,-1!
        if "!default_config:~0,1!"=="'" set default_config=!default_config:~1,-1!
        if defined default_config (
            call :parse_toml !default_config!
        ) else (
            echo [错误] 没有指定配置名称且没有默认配置
            echo 解决方案: 使用 'ccs help' 查看帮助信息
            call :ccs_help
            exit /b 1
        )
    )
) else if "%~1"=="list" (
    call :list_configs
) else if "%~1"=="current" (
    call :show_current
) else if "%~1"=="uninstall" (
    call :ccs_uninstall
) else if "%~1"=="help" (
    call :ccs_help
) else if "%~1"=="-h" (
    call :ccs_help
) else if "%~1"=="--help" (
    call :ccs_help
) else (
    call :parse_toml %~1
)

REM 配置文件验证函数
:validate_config_file
REM 检查文件是否可读
type "%CONFIG_FILE%" >nul 2>&1
if errorlevel 1 (
    echo [错误] 配置文件不可读: %CONFIG_FILE%
    exit /b 1
)

REM 检查基本的TOML语法
findstr /r "^default_config.*=" "%CONFIG_FILE%" >nul 2>&1
if errorlevel 1 (
    echo [警告] 配置文件缺少 default_config 字段
)

REM 检查是否有配置节
findstr /r "^\[.*\]" "%CONFIG_FILE%" >nul 2>&1
if errorlevel 1 (
    echo [错误] 配置文件中没有找到配置节
    exit /b 1
)

REM 检查必需字段
for /f "usebackq tokens=*" %%a in (`findstr /r "^\[.*\]" "%CONFIG_FILE%"`) do (
    set line=%%a
    set line=!line:[=!
    set line=!line:]=!
    
    REM 跳过default_config
    if not "!line!"=="default_config" (
        REM 检查必需字段
        findstr /r "^base_url" "%CONFIG_FILE%" | findstr /n "!line!" >nul 2>&1
        if errorlevel 1 (
            echo [错误] 配置节 '!line!' 缺少必需字段: base_url
            exit /b 1
        )
        
        findstr /r "^auth_token" "%CONFIG_FILE%" | findstr /n "!line!" >nul 2>&1
        if errorlevel 1 (
            echo [错误] 配置节 '!line!' 缺少必需字段: auth_token
            exit /b 1
        )
        
        findstr /r "^model" "%CONFIG_FILE%" | findstr /n "!line!" >nul 2>&1
        if errorlevel 1 (
            echo [错误] 配置节 '!line!' 缺少必需字段: model
            exit /b 1
        )
    )
)

exit /b 0