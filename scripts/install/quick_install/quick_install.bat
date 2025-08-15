@echo off
setlocal enabledelayedexpansion

REM CCS (Claude Code Configuration Switcher) Windows 一键安装脚本
REM GitHub: https://github.com/bahayonghang/ccs
REM 用法: 在Windows中下载并运行此脚本

set "REPO_URL=https://github.com/bahayonghang/ccs/raw/main"
set "TEMP_DIR=%TEMP%\ccs_install_%RANDOM%"

REM 检查PowerShell是否可用
powershell -Command "Exit 0" >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: PowerShell 不可用，无法完成安装
    pause
    exit /b 1
)

REM 检查管理员权限
net session >nul 2>&1
if %errorlevel% == 0 (
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

REM 打印消息函数
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

REM 主安装函数
:main
call :print_message "%BLUE%" "开始一键安装 Claude Code Configuration Switcher (Windows版本)..."
echo.

REM 创建临时目录
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

call :print_message "%BLUE%" "下载安装文件..."

REM 下载必要文件
set "files=install.bat ccs.bat ccs.ps1 package.json"

for %%f in (%files%) do (
    call :print_message "%BLUE%" "下载 %%f..."
    
    REM 使用PowerShell下载文件
    powershell -Command "& {try {Invoke-WebRequest -Uri '%REPO_URL%/%%f' -OutFile '%TEMP_DIR%\%%f' -UseBasicParsing; exit 0} catch {exit 1}}"
    
    if %errorlevel% neq 0 (
        call :print_error "下载 %%f 失败"
        rmdir /s /q "%TEMP_DIR%"
        pause
        exit /b 1
    )
    call :print_success "下载 %%f 完成"
)

REM 创建示例配置文件
call :print_message "%BLUE%" "创建示例配置文件..."
(
echo # Claude Code Configuration Switcher 配置文件
echo # 请根据您的需要修改以下配置
echo.
echo default_config = "anyrouter"
echo.
echo [anyrouter]
echo description = "AnyRouter API服务"
echo base_url = "https://anyrouter.top"
echo auth_token = "sk-your-anyrouter-api-key-here"
echo model = "claude-3-5-sonnet-20241022"
echo.
echo [glm]
echo description = "智谱GLM API服务"
echo base_url = "https://open.bigmodel.cn/api/paas/v4"
echo auth_token = "your-glm-api-key-here"
echo model = "glm-4"
echo.
echo [anthropic]
echo description = "Anthropic官方API"
echo base_url = "https://api.anthropic.com"
echo auth_token = "sk-ant-your-api-key-here"
echo model = "claude-3-5-sonnet-20241022"
echo.
echo [openai]
echo description = "OpenAI API配置"
echo base_url = "https://api.openai.com/v1"
echo auth_token = "sk-your-openai-api-key-here"
echo model = "gpt-4"
echo.
echo [aicodemirror]
echo description = "AICodeMirror API服务"
echo base_url = "https://aicodemirror.com/api"
echo auth_token = "your-aicodemirror-api-key-here"
echo model = "claude-3-5-sonnet-20241022"
echo.
echo [wenwen]
echo description = "文文AI API服务"
echo base_url = "https://api.wenwen.ai"
echo auth_token = "your-wenwen-api-key-here"
echo model = "claude-3-5-sonnet-20241022"
echo.
echo [moonshot]
echo description = "月之暗面API服务"
echo base_url = "https://api.moonshot.cn/v1"
echo auth_token = "sk-your-moonshot-api-key-here"
echo model = "moonshot-v1-8k"
echo.
echo [siliconflow]
echo description = "SiliconFlow API服务"
echo base_url = "https://api.siliconflow.cn/v1"
echo auth_token = "sk-your-siliconflow-api-key-here"
echo model = "anthropic/claude-3-5-sonnet-20241022"
) > "%TEMP_DIR%\.ccs_config.toml.example"
call :print_success "创建示例配置文件完成"

REM 设置权限
attrib +r "%TEMP_DIR%\install.bat" >nul 2>&1
attrib +r "%TEMP_DIR%\ccs.bat" >nul 2>&1
attrib +r "%TEMP_DIR%\ccs.ps1" >nul 2>&1

REM 切换到临时目录并运行安装脚本
call :print_message "%BLUE%" "运行安装脚本..."
echo.
cd /d "%TEMP_DIR%"

REM 运行安装
call install.bat
if %errorlevel% neq 0 (
    call :print_error "安装失败"
    rmdir /s /q "%TEMP_DIR%"
    pause
    exit /b 1
)

REM 清理临时文件
rmdir /s /q "%TEMP_DIR%"

call :print_success "CCS 一键安装完成！感谢使用！"
echo.
call :print_message "%BLUE%" "项目地址: https://github.com/bahayonghang/ccs"
call :print_message "%BLUE%" "如有问题请提交Issue或PR"
echo.
call :print_message "%BLUE%" "下一步操作："
echo 1. 重新启动命令提示符或PowerShell
echo 2. 编辑配置文件：
echo    notepad %USERPROFILE%\.ccs_config.toml
echo 3. 填入您的API密钥后，开始使用：
echo    ccs list        # 查看所有配置
echo    ccs [配置名]    # 切换配置
echo    ccs current     # 查看当前配置
echo.
call :print_warning "请务必编辑配置文件并填入正确的API密钥！"
echo.
call :print_message "%YELLOW%" "按任意键退出..."
pause >nul
goto :eof

REM 运行主函数
call :main %*