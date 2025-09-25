@echo off
REM CCS (Claude Code Configuration Switcher) Windows CMD 通用工具函数库
REM 版本: 2.0 - 优化版
REM 此文件包含Windows CMD的共享功能,用于减少代码重复并提高一致性
REM 包含: 性能优化、缓存机制、增强的安全性和错误处理

REM 检查是否已经初始化
if defined CCS_COMMON_LOADED exit /b 0
set CCS_COMMON_LOADED=1

REM 版本信息
set CCS_COMMON_VERSION=2.0.0

REM 全局变量和配置
if not defined CCS_DIR set CCS_DIR=%USERPROFILE%\.ccs
if not defined CACHE_DIR set CACHE_DIR=%CCS_DIR%\cache
if not defined TEMP_DIR set TEMP_DIR=%CCS_DIR%\temp
if not defined BACKUP_DIR set BACKUP_DIR=%CCS_DIR%\backups
if not defined LOG_DIR set LOG_DIR=%CCS_DIR%\logs

REM 性能配置
if not defined CCS_CACHE_TTL set CCS_CACHE_TTL=300
if not defined CCS_MAX_RETRIES set CCS_MAX_RETRIES=3
if not defined CCS_TIMEOUT set CCS_TIMEOUT=30

REM 错误码定义（扩展版）
set ERROR_SUCCESS=0
set ERROR_CONFIG_MISSING=1
set ERROR_CONFIG_INVALID=2
set ERROR_DOWNLOAD_FAILED=3
set ERROR_PERMISSION_DENIED=4
set ERROR_FILE_NOT_FOUND=5
set ERROR_INVALID_ARGUMENT=6
set ERROR_NETWORK_UNREACHABLE=7
set ERROR_DEPENDENCY_MISSING=8
set ERROR_CONFIGURATION_CORRUPT=9
set ERROR_RESOURCE_BUSY=10
set ERROR_TIMEOUT=11
set ERROR_AUTHENTICATION_FAILED=12
set ERROR_UNKNOWN=99

REM 日志级别
set LOG_LEVEL_DEBUG=0
set LOG_LEVEL_INFO=1
set LOG_LEVEL_WARN=2
set LOG_LEVEL_ERROR=3
set LOG_LEVEL_OFF=4

REM 当前日志级别（默认为INFO）
if not defined CCS_LOG_LEVEL set CCS_LOG_LEVEL=%LOG_LEVEL_INFO%

REM 初始化目录结构
call :init_directories

REM 清理旧临时文件
call :cleanup_temp_files

goto :eof

REM ============================================================================
REM 目录管理函数
REM ============================================================================

:init_directories
if not exist "%CCS_DIR%" mkdir "%CCS_DIR%" >nul 2>&1
if not exist "%CACHE_DIR%" mkdir "%CACHE_DIR%" >nul 2>&1
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%" >nul 2>&1
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%" >nul 2>&1
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
exit /b 0

:cleanup_temp_files
if not exist "%TEMP_DIR%" exit /b 0
REM 删除超过1小时的临时文件
forfiles /p "%TEMP_DIR%" /m "ccs_temp_*" /c "cmd /c del @path" /d -1 >nul 2>&1
exit /b 0

REM ============================================================================
REM 日志和输出函数
REM ============================================================================

:print_error
echo [❌ ERROR] %~1
if %CCS_LOG_LEVEL% leq %LOG_LEVEL_ERROR% call :write_log "ERROR" "%~1"
exit /b 0

:print_warning
echo [⚠️  WARN] %~1
if %CCS_LOG_LEVEL% leq %LOG_LEVEL_WARN% call :write_log "WARN" "%~1"
exit /b 0

:print_info
echo [ℹ️  INFO] %~1
if %CCS_LOG_LEVEL% leq %LOG_LEVEL_INFO% call :write_log "INFO" "%~1"
exit /b 0

:print_success
echo [✅ SUCCESS] %~1
if %CCS_LOG_LEVEL% leq %LOG_LEVEL_INFO% call :write_log "SUCCESS" "%~1"
exit /b 0

:print_step
echo [🔧 STEP] %~1
if %CCS_LOG_LEVEL% leq %LOG_LEVEL_INFO% call :write_log "STEP" "%~1"
exit /b 0

:print_debug
if %CCS_LOG_LEVEL% leq %LOG_LEVEL_DEBUG% (
    echo [🐛 DEBUG] %~1
    call :write_log "DEBUG" "%~1"
)
exit /b 0

:write_log
if %CCS_LOG_LEVEL% equ %LOG_LEVEL_OFF% exit /b 0
call :init_directories
set log_file=%LOG_DIR%\ccs_%date:~0,4%%date:~5,2%%date:~8,2%.log
echo [%date% %time%] [%~1] %~2 >> "%log_file%"

REM 清理旧日志文件
set log_count=0
for %%f in ("%LOG_DIR%\ccs_*.log") do set /a log_count+=1
if %log_count% gtr 10 (
    for /f "skip=10" %%f in ('dir /b /o-d "%LOG_DIR%\ccs_*.log"') do del "%LOG_DIR%\%%f" >nul 2>&1
)
exit /b 0

REM ============================================================================
REM 错误处理函数
REM ============================================================================

:handle_error
set error_code=%~1
set error_message=%~2
set show_help=%~3

call :print_error "错误[%error_code%]: %error_message%"

if "%error_code%"=="%ERROR_CONFIG_MISSING%" (
    call :print_info "解决方案: 请运行安装脚本创建配置文件"
    call :print_info "  命令: 运行 install.bat 或手动创建配置文件"
) else if "%error_code%"=="%ERROR_CONFIG_INVALID%" (
    call :print_info "解决方案: 请检查配置文件格式和必需字段"
    call :print_info "  参考: 配置文件必须包含 [section] 和 base_url、auth_token 字段"
) else if "%error_code%"=="%ERROR_DOWNLOAD_FAILED%" (
    call :print_info "解决方案: 请检查网络连接或稍后重试"
    call :print_info "  检查: 防火墙设置、代理配置、DNS设置"
) else if "%error_code%"=="%ERROR_PERMISSION_DENIED%" (
    call :print_info "解决方案: 请检查文件权限或使用管理员权限运行"
    call :print_info "  命令: 以管理员身份运行命令提示符"
) else if "%error_code%"=="%ERROR_NETWORK_UNREACHABLE%" (
    call :print_info "解决方案: 请检查网络连接和防火墙设置"
    call :print_info "  测试: ping github.com"
) else if "%error_code%"=="%ERROR_DEPENDENCY_MISSING%" (
    call :print_info "解决方案: 安装缺少的依赖程序"
    call :print_info "  检查: 使用 check_dependencies 函数检查所需依赖"
) else if "%error_code%"=="%ERROR_CONFIGURATION_CORRUPT%" (
    call :print_info "解决方案: 恢复或重新创建配置文件"
    call :print_info "  备份: 检查 %BACKUP_DIR% 目录中的备份文件"
) else if "%error_code%"=="%ERROR_FILE_NOT_FOUND%" (
    call :print_info "解决方案: 检查文件路径是否正确或重新安装"
    call :print_info "  检查: 确认文件是否存在，路径是否正确"
) else if "%error_code%"=="%ERROR_RESOURCE_BUSY%" (
    call :print_info "解决方案: 等待资源释放或终止占用的进程"
    call :print_info "  检查: tasklist | findstr ccs"
) else if "%error_code%"=="%ERROR_TIMEOUT%" (
    call :print_info "解决方案: 检查网络连接或增加超时时间"
    call :print_info "  设置: 使用 CCS_TIMEOUT 环境变量调整超时时间"
) else if "%error_code%"=="%ERROR_AUTHENTICATION_FAILED%" (
    call :print_info "解决方案: 检查API认证令牌是否正确"
    call :print_info "  验证: 确保 auth_token 字段包含有效的API密钥"
)

if "%show_help%"=="true" (
    echo.
    echo 使用 'ccs help' 查看帮助信息
    echo 使用 'ccs --debug' 启用调试模式获取更多信息
)

exit /b %error_code%

REM ============================================================================
REM 时间戳和缓存函数
REM ============================================================================

:get_current_timestamp
setlocal enabledelayedexpansion
REM 获取当前日期和时间
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do (
    set month=%%a
    set day=%%b
    set year=%%c
)
for /f "tokens=1-3 delims=: " %%a in ('time /t') do (
    set hour=%%a
    set minute=%%b
    set second=00
)
REM 简化的时间戳计算（基于天数）
set /a days_since_epoch=(!year!-1970)*365+(!month!-1)*30+!day!
set /a timestamp=!days_since_epoch!*86400+!hour!*3600+!minute!*60+!second!
endlocal & set %~1=%timestamp%
exit /b 0

:parse_timestamp
setlocal enabledelayedexpansion
set timestamp_str=%~1
REM 从时间戳字符串中提取数字部分
for /f "tokens=1-6 delims=/:. " %%a in ('echo %timestamp_str%') do (
    set month=%%a
    set day=%%b
    set year=%%c
    set hour=%%d
    set minute=%%e
    set second=%%f
)
REM 计算时间戳
set /a days_since_epoch=(!year!-1970)*365+(!month!-1)*30+!day!
set /a parsed_timestamp=!days_since_epoch!*86400+!hour!*3600+!minute!*60+!second!
endlocal & set %~2=%parsed_timestamp%
exit /b 0

REM ============================================================================
REM 缓存管理函数
REM ============================================================================

:get_cache_key
set cache_key=%~1
set cache_file=%CACHE_DIR%\config_%cache_key%.cache
set cache_meta=%CACHE_DIR%\config_%cache_key%.meta
exit /b 0

:check_cache_validity
set config_name=%~1
call :get_cache_key "%config_name%"
if not exist "%cache_file%" exit /b 1
if not exist "%cache_meta%" exit /b 1

REM 检查缓存时间 - 改进版时间差计算
for /f "tokens=*" %%a in ('type "%cache_meta%"') do set cache_timestamp=%%a
if not defined cache_timestamp exit /b 1

REM 获取当前时间戳（秒）
call :get_current_timestamp current_timestamp
call :parse_timestamp "%cache_timestamp%" cache_seconds

REM 计算时间差
set /a time_diff=%current_timestamp%-%cache_seconds%
if %time_diff% lss 0 set /a time_diff=-%time_diff%

REM 检查是否超过缓存TTL
if %time_diff% gtr %CCS_CACHE_TTL% (
    call :print_debug "缓存过期: %config_name% (age: %time_diff%s)"
    exit /b 1
) else (
    call :print_debug "缓存有效: %config_name% (age: %time_diff%s)"
    exit /b 0
)

:save_to_cache
set config_name=%~1
call :get_cache_key "%config_name%"
echo %config_base_url% > "%cache_file%"
echo %config_auth_token% >> "%cache_file%"
echo %config_model% >> "%cache_file%"
echo %config_small_fast_model% >> "%cache_file%"
echo %config_description% >> "%cache_file%"
REM 保存当前时间戳到元数据文件
call :get_current_timestamp current_timestamp
echo %date% %time% > "%cache_meta%"
call :print_debug "配置已缓存: %config_name%"
exit /b 0

:load_from_cache
set config_name=%~1
call :get_cache_key "%config_name%"
if not exist "%cache_file%" exit /b 1

set line_num=0
for /f "usebackq tokens=*" %%a in ("%cache_file%") do (
    set /a line_num+=1
    if !line_num!==1 set config_base_url=%%a
    if !line_num!==2 set config_auth_token=%%a
    if !line_num!==3 set config_model=%%a
    if !line_num!==4 set config_small_fast_model=%%a
    if !line_num!==5 set config_description=%%a
)
call :print_debug "从缓存加载配置: %config_name%"
exit /b 0

:clear_config_cache
if exist "%CACHE_DIR%\*.cache" del /q "%CACHE_DIR%\*.cache" >nul 2>&1
if exist "%CACHE_DIR%\*.meta" del /q "%CACHE_DIR%\*.meta" >nul 2>&1
call :print_success "配置缓存已清理"
exit /b 0

:get_cache_stats
set cache_files=0
set cache_size=0
for %%f in ("%CACHE_DIR%\*.cache") do (
    set /a cache_files+=1
    set /a cache_size+=%%~zf
)
echo 缓存文件数量: %cache_files%
echo 缓存总大小: %cache_size% 字节
exit /b 0

REM ============================================================================
REM 工具函数
REM ============================================================================

:mask_sensitive_info
set input_value=%~1
set prefix_length=10
if defined input_value (
    if "%input_value:~10%"=="" (
        set masked_value=%input_value:~0,1%...
    ) else (
        set masked_value=%input_value:~0,%prefix_length%...
    )
) else (
    set masked_value=
)
exit /b 0

:create_temp_file
set prefix=%~1
if not defined prefix set prefix=ccs_temp
call :init_directories
set temp_file=%TEMP_DIR%\%prefix%_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%_%random%.tmp
echo. > "%temp_file%"
set %~2=%temp_file%
exit /b 0

:check_command_exists
where %~1 >nul 2>&1
exit /b %errorlevel%

:verify_config_integrity
REM 检查文件是否存在
if not exist "%~1" exit /b 1

REM 检查文件是否可读
type "%~1" >nul 2>&1
if errorlevel 1 exit /b 1

REM 检查是否有配置节
findstr /r "^\[.*\]" "%~1" >nul 2>&1
if errorlevel 1 exit /b 1

REM 检查文件大小（防止异常大文件）
for %%i in ("%~1") do (
    if %%~zi gtr 1048576 (
        call :print_error "配置文件过大: %%~zi bytes"
        exit /b 1
    )
)

exit /b 0

REM ============================================================================
REM 初始化完成标记
REM ============================================================================
call :print_debug "CCS通用库已加载 (版本: %CCS_COMMON_VERSION%)"