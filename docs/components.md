# 核心组件详解

本文档详细介绍 CCS 项目的各个核心组件，包括其功能、实现原理、接口设计和使用方法。

## 📋 目录

- [脚本引擎组件](#脚本引擎组件)
- [配置管理组件](#配置管理组件)
- [环境变量管理组件](#环境变量管理组件)
- [用户界面组件](#用户界面组件)
- [工具库组件](#工具库组件)
- [安装部署组件](#安装部署组件)

## 🐚 脚本引擎组件

### 1. Bash/Zsh 脚本引擎 (`ccs.sh`)

#### 功能概述
- **主要职责**：Linux/macOS 平台的核心配置管理
- **支持Shell**：Bash 4.0+、Zsh 5.0+
- **文件位置**：`~/.ccs/ccs.sh`

#### 核心函数

##### 配置解析函数
```bash
# 解析TOML配置文件中的特定配置节
parse_toml() {
    local config_name="$1"     # 配置名称
    local config_file="$2"     # 配置文件路径
    local field="$3"           # 字段名（可选）
    
    # 实现逻辑：
    # 1. 检查配置文件存在性
    # 2. 查找配置节 [config_name]
    # 3. 提取字段值
    # 4. 处理特殊字符和转义
    # 5. 返回解析结果
}
```

**使用示例**：
```bash
# 获取配置的base_url
base_url=$(parse_toml "anthropic" "$CONFIG_FILE" "base_url")

# 获取配置的完整信息
config_info=$(parse_toml "anthropic" "$CONFIG_FILE")
```

##### 环境变量设置函数
```bash
# 设置当前配置的环境变量
set_config_env() {
    local config_name="$1"
    
    # 实现步骤：
    # 1. 解析配置信息
    # 2. 验证配置有效性
    # 3. 清除旧环境变量
    # 4. 设置新环境变量
    # 5. 导出环境变量
    
    # 环境变量映射：
    export ANTHROPIC_BASE_URL="$base_url"
    export ANTHROPIC_AUTH_TOKEN="$auth_token"
    export ANTHROPIC_MODEL="$model"
    export ANTHROPIC_SMALL_FAST_MODEL="$small_fast_model"
}
```

##### 配置更新函数
```bash
# 更新当前配置设置
update_current_config() {
    local config_name="$1"
    
    # 实现逻辑：
    # 1. 验证配置名称格式
    # 2. 检查配置是否存在
    # 3. 备份原配置文件
    # 4. 更新current_config字段
    # 5. 验证更新结果
    # 6. 错误回滚机制
}
```

#### 错误处理机制

```bash
# 错误码定义
ERROR_CONFIG_NOT_FOUND=1      # 配置不存在
ERROR_CONFIG_INVALID=2        # 配置格式无效
ERROR_FILE_NOT_FOUND=3        # 文件不存在
ERROR_PERMISSION_DENIED=4     # 权限不足
ERROR_NETWORK_ERROR=5         # 网络错误

# 统一错误处理
handle_error() {
    local error_code="$1"
    local error_message="$2"
    local context="$3"  # 可选的上下文信息
    
    # 记录错误日志
    log_error "错误码: $error_code, 消息: $error_message"
    
    # 显示用户友好的错误信息
    case $error_code in
        $ERROR_CONFIG_NOT_FOUND)
            echo "❌ 配置 '$context' 不存在，请检查配置名称"
            echo "💡 使用 'ccs list' 查看可用配置"
            ;;
        $ERROR_CONFIG_INVALID)
            echo "❌ 配置文件格式无效: $error_message"
            echo "💡 请检查 TOML 语法是否正确"
            ;;
        *)
            echo "❌ 未知错误: $error_message"
            ;;
    esac
    
    exit $error_code
}
```

#### 性能优化特性

```bash
# 配置缓存机制
declare -A CONFIG_CACHE
CACHE_TIMEOUT=300  # 5分钟缓存

# 缓存配置信息
cache_config() {
    local config_name="$1"
    local config_data="$2"
    local timestamp=$(date +%s)
    
    CONFIG_CACHE["${config_name}_data"]="$config_data"
    CONFIG_CACHE["${config_name}_time"]="$timestamp"
}

# 获取缓存配置
get_cached_config() {
    local config_name="$1"
    local current_time=$(date +%s)
    local cache_time="${CONFIG_CACHE["${config_name}_time"]}"
    
    if [[ -n "$cache_time" ]] && [[ $((current_time - cache_time)) -lt $CACHE_TIMEOUT ]]; then
        echo "${CONFIG_CACHE["${config_name}_data"]}"
        return 0
    fi
    
    return 1
}
```

### 2. Fish Shell 脚本引擎 (`ccs.fish`)

#### 功能概述
- **主要职责**：Fish Shell 环境的配置管理
- **支持版本**：Fish 3.0+
- **语法特点**：Fish 原生语法，更现代化的脚本结构

#### 核心函数实现

##### Fish 特定的配置解析
```fish
# Fish语法的TOML解析函数
function parse_toml_fish
    set config_name $argv[1]
    set config_file $argv[2]
    set field $argv[3]
    
    # Fish特定的实现：
    # 1. 使用Fish的字符串处理函数
    # 2. 利用Fish的数组和关联数组
    # 3. 更好的错误处理和用户反馈
    
    if not test -f $config_file
        echo "❌ 配置文件不存在: $config_file" >&2
        return 1
    end
    
    # 查找配置节
    set section_found false
    set in_section false
    
    while read -l line
        # 处理配置节标题
        if string match -q "[$config_name]" $line
            set in_section true
            set section_found true
            continue
        end
        
        # 检查是否进入新的配置节
        if string match -q '[*]' $line; and test $in_section = true
            set in_section false
            continue
        end
        
        # 在目标配置节中提取字段值
        if test $in_section = true; and test -n "$field"
            if string match -q "$field = *" $line
                string replace "$field = " '' $line | string trim -c '"'
                return 0
            end
        end
    end < $config_file
    
    if test $section_found = false
        echo "❌ 配置 '$config_name' 不存在" >&2
        return 1
    end
end
```

##### Fish 环境变量管理
```fish
# 设置环境变量（Fish语法）
function set_config_env_fish
    set config_name $argv[1]
    
    # 解析配置信息
    set base_url (parse_toml_fish $config_name $CONFIG_FILE "base_url")
    set auth_token (parse_toml_fish $config_name $CONFIG_FILE "auth_token")
    set model (parse_toml_fish $config_name $CONFIG_FILE "model")
    set small_fast_model (parse_toml_fish $config_name $CONFIG_FILE "small_fast_model")
    
    # 验证必需字段
    if test -z "$base_url"; or test -z "$auth_token"
        echo "❌ 配置 '$config_name' 缺少必需字段" >&2
        return 1
    end
    
    # 设置环境变量（Fish的set -gx语法）
    set -gx ANTHROPIC_BASE_URL $base_url
    set -gx ANTHROPIC_AUTH_TOKEN $auth_token
    set -gx ANTHROPIC_MODEL $model
    set -gx ANTHROPIC_SMALL_FAST_MODEL $small_fast_model
    
    echo "✅ 已切换到配置: $config_name"
end
```

##### Fish 特定的用户交互
```fish
# Fish风格的配置列表显示
function list_configs_fish
    set config_file $CONFIG_FILE
    
    if not test -f $config_file
        echo "❌ 配置文件不存在，请先运行安装脚本"
        return 1
    end
    
    echo "📋 可用配置列表:"
    echo "=================="
    
    set current_config (parse_toml_fish "global" $config_file "current_config")
    set configs (string match -r '\[([^\]]+)\]' < $config_file | string replace -r '\[([^\]]+)\]' '$1' | grep -v "global")
    
    for config in $configs
        set description (parse_toml_fish $config $config_file "description")
        
        if test "$config" = "$current_config"
            echo "🟢 $config (当前) - $description"
        else
            echo "⚪ $config - $description"
        end
    end
end
```

### 3. Windows 脚本引擎

#### 批处理脚本 (`ccs.bat`)

##### 功能概述
- **主要职责**：Windows CMD 环境的基础配置管理
- **兼容性**：Windows 7+ 的 CMD
- **限制**：功能相对简化，主要提供基本的配置切换

##### 核心实现
```batch
@echo off
setlocal enabledelayedexpansion

REM 配置文件路径
set "CONFIG_FILE=%USERPROFILE%\.ccs_config.toml"

REM 错误码定义
set ERROR_CONFIG_NOT_FOUND=1
set ERROR_CONFIG_INVALID=2
set ERROR_FILE_NOT_FOUND=3

REM 主函数
:main
if "%~1"=="" goto show_help
if "%~1"=="list" goto list_configs
if "%~1"=="current" goto show_current
if "%~1"=="help" goto show_help

REM 切换配置
set "config_name=%~1"
call :switch_config "%config_name%"
goto :eof

REM 切换配置函数
:switch_config
set "config_name=%~1"

REM 检查配置文件存在
if not exist "%CONFIG_FILE%" (
    echo ❌ 配置文件不存在: %CONFIG_FILE%
    exit /b %ERROR_FILE_NOT_FOUND%
)

REM 简化的TOML解析（仅支持基本格式）
call :parse_config "%config_name%"
if errorlevel 1 (
    echo ❌ 配置 '%config_name%' 不存在或无效
    exit /b %ERROR_CONFIG_NOT_FOUND%
)

REM 设置环境变量
set "ANTHROPIC_BASE_URL=%base_url%"
set "ANTHROPIC_AUTH_TOKEN=%auth_token%"
set "ANTHROPIC_MODEL=%model%"
set "ANTHROPIC_SMALL_FAST_MODEL=%small_fast_model%"

echo ✅ 已切换到配置: %config_name%
goto :eof

REM 简化的TOML解析函数
:parse_config
set "config_name=%~1"
set "in_section=false"
set "section_found=false"

for /f "usebackq delims=" %%a in ("%CONFIG_FILE%") do (
    set "line=%%a"
    
    REM 检查配置节标题
    echo !line! | findstr /r "^\[%config_name%\]$" >nul
    if !errorlevel! equ 0 (
        set "in_section=true"
        set "section_found=true"
    ) else (
        REM 检查其他配置节
        echo !line! | findstr /r "^\[.*\]$" >nul
        if !errorlevel! equ 0 (
            set "in_section=false"
        )
    )
    
    REM 在目标配置节中解析字段
    if "!in_section!"=="true" (
        call :parse_field "!line!"
    )
)

if "%section_found%"=="false" exit /b 1
goto :eof

REM 解析配置字段
:parse_field
set "line=%~1"

REM 解析base_url
echo %line% | findstr /r "^base_url" >nul
if %errorlevel% equ 0 (
    for /f "tokens=2 delims==" %%b in ("%line%") do (
        set "base_url=%%b"
        set "base_url=!base_url: =!"
        set "base_url=!base_url:"=!"
    )
)

REM 解析auth_token
echo %line% | findstr /r "^auth_token" >nul
if %errorlevel% equ 0 (
    for /f "tokens=2 delims==" %%b in ("%line%") do (
        set "auth_token=%%b"
        set "auth_token=!auth_token: =!"
        set "auth_token=!auth_token:"=!"
    )
)

REM 类似地解析其他字段...
goto :eof
```

#### PowerShell 脚本 (`ccs.ps1`)

##### 功能概述
- **主要职责**：Windows PowerShell 环境的高级配置管理
- **支持版本**：PowerShell 5.0+、PowerShell Core 6.0+
- **特性**：完整功能实现，与 Bash 版本功能对等

##### 核心实现
```powershell
# PowerShell配置管理脚本

# 全局变量定义
$script:ConfigFile = "$env:USERPROFILE\.ccs_config.toml"
$script:ErrorCodes = @{
    ConfigNotFound = 1
    ConfigInvalid = 2
    FileNotFound = 3
    PermissionDenied = 4
}

# TOML解析函数（PowerShell实现）
function Parse-TomlConfig {
    param(
        [string]$ConfigName,
        [string]$ConfigFile = $script:ConfigFile,
        [string]$Field = $null
    )
    
    if (-not (Test-Path $ConfigFile)) {
        throw "配置文件不存在: $ConfigFile"
    }
    
    $content = Get-Content $ConfigFile -Raw
    $sections = @{}
    $currentSection = $null
    
    # 解析TOML内容
    $lines = $content -split "`n"
    foreach ($line in $lines) {
        $line = $line.Trim()
        
        # 跳过空行和注释
        if ($line -eq "" -or $line.StartsWith("#")) {
            continue
        }
        
        # 解析配置节
        if ($line -match '^\[(.+)\]$') {
            $currentSection = $matches[1]
            $sections[$currentSection] = @{}
            continue
        }
        
        # 解析键值对
        if ($line -match '^([^=]+)\s*=\s*(.+)$' -and $currentSection) {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim().Trim('"')
            $sections[$currentSection][$key] = $value
        }
    }
    
    # 返回请求的配置
    if ($sections.ContainsKey($ConfigName)) {
        if ($Field) {
            return $sections[$ConfigName][$Field]
        } else {
            return $sections[$ConfigName]
        }
    } else {
        throw "配置 '$ConfigName' 不存在"
    }
}

# 设置环境变量函数
function Set-ConfigEnvironment {
    param([string]$ConfigName)
    
    try {
        $config = Parse-TomlConfig -ConfigName $ConfigName
        
        # 验证必需字段
        if (-not $config['base_url'] -or -not $config['auth_token']) {
            throw "配置 '$ConfigName' 缺少必需字段"
        }
        
        # 设置环境变量
        [Environment]::SetEnvironmentVariable('ANTHROPIC_BASE_URL', $config['base_url'], 'Process')
        [Environment]::SetEnvironmentVariable('ANTHROPIC_AUTH_TOKEN', $config['auth_token'], 'Process')
        [Environment]::SetEnvironmentVariable('ANTHROPIC_MODEL', $config['model'], 'Process')
        [Environment]::SetEnvironmentVariable('ANTHROPIC_SMALL_FAST_MODEL', $config['small_fast_model'], 'Process')
        
        # 更新当前配置
        Update-CurrentConfig -ConfigName $ConfigName
        
        Write-Host "✅ 已切换到配置: $ConfigName" -ForegroundColor Green
        
    } catch {
        Write-Host "❌ 错误: $($_.Exception.Message)" -ForegroundColor Red
        exit $script:ErrorCodes.ConfigInvalid
    }
}

# 更新当前配置函数
function Update-CurrentConfig {
    param([string]$ConfigName)
    
    try {
        $content = Get-Content $script:ConfigFile -Raw
        
        # 更新current_config字段
        $pattern = '(current_config\s*=\s*)["'']?[^"''\r\n]*["'']?'
        $replacement = "current_config = `"$ConfigName`""
        
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $replacement
        } else {
            # 如果不存在，添加到global节
            $content = $content -replace '(\[global\])', "`$1`ncurrent_config = `"$ConfigName`""
        }
        
        Set-Content $script:ConfigFile -Value $content -Encoding UTF8
        
    } catch {
        Write-Warning "无法更新配置文件: $($_.Exception.Message)"
    }
}

# 列出所有配置函数
function Get-AllConfigs {
    try {
        $content = Get-Content $script:ConfigFile -Raw
        $sections = @()
        
        # 提取所有配置节名称
        $matches = [regex]::Matches($content, '\[([^\]]+)\]')
        foreach ($match in $matches) {
            $sectionName = $match.Groups[1].Value
            if ($sectionName -ne 'global') {
                $sections += $sectionName
            }
        }
        
        return $sections
        
    } catch {
        Write-Host "❌ 无法读取配置文件: $($_.Exception.Message)" -ForegroundColor Red
        exit $script:ErrorCodes.FileNotFound
    }
}

# 显示配置列表函数
function Show-ConfigList {
    try {
        $configs = Get-AllConfigs
        $currentConfig = Parse-TomlConfig -ConfigName 'global' -Field 'current_config'
        
        Write-Host "📋 可用配置列表:" -ForegroundColor Cyan
        Write-Host "==================" -ForegroundColor Cyan
        
        foreach ($config in $configs) {
            try {
                $description = Parse-TomlConfig -ConfigName $config -Field 'description'
                if ($config -eq $currentConfig) {
                    Write-Host "🟢 $config (当前) - $description" -ForegroundColor Green
                } else {
                    Write-Host "⚪ $config - $description" -ForegroundColor White
                }
            } catch {
                Write-Host "⚪ $config - (无描述)" -ForegroundColor Gray
            }
        }
        
    } catch {
        Write-Host "❌ 无法列出配置: $($_.Exception.Message)" -ForegroundColor Red
        exit $script:ErrorCodes.ConfigInvalid
    }
}

# 主函数
function Main {
    param([string[]]$Args)
    
    if ($Args.Count -eq 0 -or $Args[0] -eq 'help') {
        Show-Help
        return
    }
    
    switch ($Args[0]) {
        'list' { Show-ConfigList }
        'current' { Show-CurrentConfig }
        default { Set-ConfigEnvironment -ConfigName $Args[0] }
    }
}

# 帮助信息函数
function Show-Help {
    Write-Host @"
🔧 CCS (Claude Code Configuration Switcher) - PowerShell版本

用法:
    ccs <配置名>     切换到指定配置
    ccs list         列出所有可用配置
    ccs current      显示当前配置
    ccs help         显示此帮助信息

示例:
    ccs anthropic    # 切换到anthropic配置
    ccs openai       # 切换到openai配置
    ccs list         # 查看所有配置

配置文件位置: $script:ConfigFile
"@ -ForegroundColor Yellow
}

# 脚本入口点
if ($MyInvocation.InvocationName -ne '.') {
    Main -Args $args
}
```

## 📁 配置管理组件

### 1. TOML 配置文件结构

#### 文件格式规范
```toml
# CCS配置文件示例
# 文件位置: ~/.ccs_config.toml

# 全局设置
[global]
default_config = "anthropic"     # 默认配置名称
current_config = "anthropic"     # 当前激活的配置

# Anthropic官方API配置
[anthropic]
description = "Anthropic官方API"  # 配置描述
base_url = "https://api.anthropic.com"  # API端点
auth_token = "sk-ant-api03-..."  # API密钥
model = "claude-3-5-sonnet-20241022"  # 默认模型
small_fast_model = "claude-3-haiku-20240307"  # 快速模型

# 第三方API服务配置
[anyrouter]
description = "AnyRouter代理服务"
base_url = "https://api.anyrouter.ai"
auth_token = "your-anyrouter-token"
model = "claude-3-5-sonnet-20241022"
small_fast_model = "claude-3-haiku-20240307"

# 智谱GLM配置
[glm]
description = "智谱GLM API"
base_url = "https://open.bigmodel.cn/api/paas/v4"
auth_token = "your-glm-token"
model = "glm-4-plus"
small_fast_model = "glm-4-flash"
```

#### 配置字段说明

| 字段名 | 类型 | 必需 | 说明 |
|--------|------|------|------|
| `description` | String | 否 | 配置的描述信息，用于用户识别 |
| `base_url` | String | 是 | API服务的基础URL地址 |
| `auth_token` | String | 是 | API认证令牌或密钥 |
| `model` | String | 否 | 默认使用的模型名称 |
| `small_fast_model` | String | 否 | 快速响应场景使用的轻量模型 |

#### 配置验证规则

```bash
# 配置验证函数
validate_config() {
    local config_name="$1"
    local config_file="$2"
    
    # 1. 检查必需字段
    local base_url=$(parse_toml "$config_name" "$config_file" "base_url")
    local auth_token=$(parse_toml "$config_name" "$config_file" "auth_token")
    
    if [[ -z "$base_url" ]]; then
        handle_error $ERROR_CONFIG_INVALID "配置 '$config_name' 缺少 base_url 字段"
    fi
    
    if [[ -z "$auth_token" ]]; then
        handle_error $ERROR_CONFIG_INVALID "配置 '$config_name' 缺少 auth_token 字段"
    fi
    
    # 2. 验证URL格式
    if ! validate_url "$base_url"; then
        handle_error $ERROR_CONFIG_INVALID "配置 '$config_name' 的 base_url 格式无效: $base_url"
    fi
    
    # 3. 验证API密钥格式（基本检查）
    if [[ ${#auth_token} -lt 10 ]]; then
        handle_error $ERROR_CONFIG_INVALID "配置 '$config_name' 的 auth_token 长度过短"
    fi
    
    # 4. 检查模型名称格式（如果存在）
    local model=$(parse_toml "$config_name" "$config_file" "model")
    if [[ -n "$model" ]] && ! validate_model_name "$model"; then
        log_warn "配置 '$config_name' 的模型名称可能无效: $model"
    fi
    
    return 0
}

# URL格式验证
validate_url() {
    local url="$1"
    
    # 基本URL格式检查
    if [[ "$url" =~ ^https?://[a-zA-Z0-9.-]+(/.*)?$ ]]; then
        return 0
    fi
    
    return 1
}

# 模型名称验证
validate_model_name() {
    local model="$1"
    
    # 检查模型名称格式（允许字母、数字、连字符、下划线、点）
    if [[ "$model" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        return 0
    fi
    
    return 1
}
```

### 2. 配置文件操作

#### 配置文件读取
```bash
# 安全读取配置文件
read_config_file() {
    local config_file="$1"
    
    # 检查文件存在性
    if [[ ! -f "$config_file" ]]; then
        handle_error $ERROR_FILE_NOT_FOUND "配置文件不存在: $config_file"
    fi
    
    # 检查文件权限
    if [[ ! -r "$config_file" ]]; then
        handle_error $ERROR_PERMISSION_DENIED "无法读取配置文件: $config_file"
    fi
    
    # 检查文件大小（防止过大文件）
    local file_size=$(stat -c%s "$config_file" 2>/dev/null || echo 0)
    if [[ $file_size -gt 1048576 ]]; then  # 1MB限制
        handle_error $ERROR_CONFIG_INVALID "配置文件过大: $config_file"
    fi
    
    # 读取文件内容
    cat "$config_file"
}
```

#### 配置文件写入
```bash
# 安全写入配置文件
write_config_file() {
    local config_file="$1"
    local content="$2"
    local backup_file="${config_file}.backup.$(date +%s)"
    
    # 创建备份
    if [[ -f "$config_file" ]]; then
        cp "$config_file" "$backup_file" || {
            handle_error $ERROR_PERMISSION_DENIED "无法创建配置文件备份"
        }
    fi
    
    # 写入新内容
    echo "$content" > "$config_file" || {
        # 恢复备份
        if [[ -f "$backup_file" ]]; then
            mv "$backup_file" "$config_file"
        fi
        handle_error $ERROR_PERMISSION_DENIED "无法写入配置文件: $config_file"
    }
    
    # 设置适当的文件权限
    chmod 600 "$config_file"
    
    # 验证写入的内容
    if ! validate_toml_syntax "$config_file"; then
        # 恢复备份
        if [[ -f "$backup_file" ]]; then
            mv "$backup_file" "$config_file"
        fi
        handle_error $ERROR_CONFIG_INVALID "写入的配置文件格式无效"
    fi
    
    # 清理旧备份（保留最近5个）
    cleanup_old_backups "$config_file"
    
    log_info "配置文件已更新: $config_file"
}
```

#### 配置备份管理
```bash
# 清理旧备份文件
cleanup_old_backups() {
    local config_file="$1"
    local backup_pattern="${config_file}.backup.*"
    local keep_count=5
    
    # 查找所有备份文件，按时间排序
    local backups=($(ls -t $backup_pattern 2>/dev/null))
    
    # 删除超出保留数量的备份
    if [[ ${#backups[@]} -gt $keep_count ]]; then
        for ((i=$keep_count; i<${#backups[@]}; i++)); do
            rm -f "${backups[$i]}"
            log_debug "已删除旧备份: ${backups[$i]}"
        done
    fi
}

# 恢复配置文件备份
restore_config_backup() {
    local config_file="$1"
    local backup_timestamp="$2"  # 可选，指定备份时间戳
    
    if [[ -n "$backup_timestamp" ]]; then
        local backup_file="${config_file}.backup.${backup_timestamp}"
    else
        # 使用最新的备份
        local backup_file=$(ls -t "${config_file}.backup."* 2>/dev/null | head -n1)
    fi
    
    if [[ -z "$backup_file" ]] || [[ ! -f "$backup_file" ]]; then
        handle_error $ERROR_FILE_NOT_FOUND "找不到配置文件备份"
    fi
    
    # 恢复备份
    cp "$backup_file" "$config_file" || {
        handle_error $ERROR_PERMISSION_DENIED "无法恢复配置文件备份"
    }
    
    log_info "已恢复配置文件备份: $backup_file"
}
```

## 🌍 环境变量管理组件

### 1. 环境变量映射

#### 标准环境变量
```bash
# CCS管理的环境变量列表
CCS_ENV_VARS=(
    "ANTHROPIC_BASE_URL"           # API端点地址
    "ANTHROPIC_AUTH_TOKEN"         # API认证令牌
    "ANTHROPIC_MODEL"              # 默认模型
    "ANTHROPIC_SMALL_FAST_MODEL"   # 快速模型
)

# 环境变量与配置字段的映射关系
declare -A ENV_FIELD_MAP=(
    ["ANTHROPIC_BASE_URL"]="base_url"
    ["ANTHROPIC_AUTH_TOKEN"]="auth_token"
    ["ANTHROPIC_MODEL"]="model"
    ["ANTHROPIC_SMALL_FAST_MODEL"]="small_fast_model"
)
```

#### 环境变量设置函数
```bash
# 设置单个环境变量
set_env_var() {
    local var_name="$1"
    local var_value="$2"
    local export_global="$3"  # 是否全局导出
    
    # 验证变量名
    if [[ ! "$var_name" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
        handle_error $ERROR_CONFIG_INVALID "无效的环境变量名: $var_name"
    fi
    
    # 设置环境变量
    if [[ "$export_global" == "true" ]]; then
        export "$var_name"="$var_value"
    else
        declare -g "$var_name"="$var_value"
    fi
    
    log_debug "设置环境变量: $var_name=[已隐藏]"
}

# 批量设置环境变量
set_config_env_vars() {
    local config_name="$1"
    local config_file="$2"
    
    # 清除旧的环境变量
    clear_ccs_env_vars
    
    # 设置新的环境变量
    for env_var in "${CCS_ENV_VARS[@]}"; do
        local field_name="${ENV_FIELD_MAP[$env_var]}"
        local field_value=$(parse_toml "$config_name" "$config_file" "$field_name")
        
        if [[ -n "$field_value" ]]; then
            set_env_var "$env_var" "$field_value" "true"
        fi
    done
    
    # 设置CCS元信息环境变量
    export CCS_CURRENT_CONFIG="$config_name"
    export CCS_CONFIG_FILE="$config_file"
    export CCS_LAST_SWITCH="$(date -Iseconds)"
    
    log_info "已设置配置 '$config_name' 的环境变量"
}

# 清除CCS相关环境变量
clear_ccs_env_vars() {
    for env_var in "${CCS_ENV_VARS[@]}"; do
        unset "$env_var"
    done
    
    # 清除元信息环境变量
    unset CCS_CURRENT_CONFIG
    unset CCS_CONFIG_FILE
    unset CCS_LAST_SWITCH
    
    log_debug "已清除CCS环境变量"
}
```

### 2. 环境变量持久化

#### Shell配置文件集成
```bash
# 添加CCS到Shell配置文件
integrate_with_shell() {
    local shell_type="$1"
    local ccs_script_path="$2"
    
    case "$shell_type" in
        "bash")
            integrate_with_bash "$ccs_script_path"
            ;;
        "zsh")
            integrate_with_zsh "$ccs_script_path"
            ;;
        "fish")
            integrate_with_fish "$ccs_script_path"
            ;;
        *)
            log_warn "不支持的Shell类型: $shell_type"
            return 1
            ;;
    esac
}

# Bash集成
integrate_with_bash() {
    local ccs_script_path="$1"
    local bashrc="$HOME/.bashrc"
    local bash_profile="$HOME/.bash_profile"
    
    # CCS初始化代码
    local ccs_init_code="
# CCS (Claude Code Configuration Switcher) 初始化
if [[ -f \"$ccs_script_path\" ]]; then
    source \"$ccs_script_path\"
    # 自动加载当前配置
    if [[ -n \"\$CCS_AUTO_LOAD\" ]] && [[ \"\$CCS_AUTO_LOAD\" != \"false\" ]]; then
        load_current_config 2>/dev/null
    fi
fi
"
    
    # 添加到.bashrc
    if [[ -f "$bashrc" ]] && ! grep -q "CCS (Claude Code Configuration Switcher)" "$bashrc"; then
        echo "$ccs_init_code" >> "$bashrc"
        log_info "已添加CCS初始化代码到 $bashrc"
    fi
    
    # 添加到.bash_profile（如果存在）
    if [[ -f "$bash_profile" ]] && ! grep -q "CCS (Claude Code Configuration Switcher)" "$bash_profile"; then
        echo "$ccs_init_code" >> "$bash_profile"
        log_info "已添加CCS初始化代码到 $bash_profile"
    fi
}

# Zsh集成
integrate_with_zsh() {
    local ccs_script_path="$1"
    local zshrc="$HOME/.zshrc"
    
    local ccs_init_code="
# CCS (Claude Code Configuration Switcher) 初始化
if [[ -f \"$ccs_script_path\" ]]; then
    source \"$ccs_script_path\"
    # 自动加载当前配置
    if [[ -n \"\$CCS_AUTO_LOAD\" ]] && [[ \"\$CCS_AUTO_LOAD\" != \"false\" ]]; then
        load_current_config 2>/dev/null
    fi
fi
"
    
    if [[ -f "$zshrc" ]] && ! grep -q "CCS (Claude Code Configuration Switcher)" "$zshrc"; then
        echo "$ccs_init_code" >> "$zshrc"
        log_info "已添加CCS初始化代码到 $zshrc"
    fi
}

# Fish集成
integrate_with_fish() {
    local ccs_script_path="$1"
    local fish_config="$HOME/.config/fish/config.fish"
    
    # 创建Fish配置目录
    mkdir -p "$(dirname "$fish_config")"
    
    local ccs_init_code="
# CCS (Claude Code Configuration Switcher) 初始化
if test -f \"$ccs_script_path\"
    source \"$ccs_script_path\"
    # 自动加载当前配置
    if test -n \"\$CCS_AUTO_LOAD\"; and test \"\$CCS_AUTO_LOAD\" != \"false\"
        load_current_config 2>/dev/null
    end
end
"
    
    if [[ -f "$fish_config" ]] && ! grep -q "CCS (Claude Code Configuration Switcher)" "$fish_config"; then
        echo "$ccs_init_code" >> "$fish_config"
        log_info "已添加CCS初始化代码到 $fish_config"
    fi
}
```

#### 自动配置加载
```bash
# 自动加载当前配置
load_current_config() {
    local config_file="$HOME/.ccs_config.toml"
    local silent_mode="$1"  # 是否静默模式
    
    # 检查配置文件存在
    if [[ ! -f "$config_file" ]]; then
        if [[ "$silent_mode" != "silent" ]]; then
            log_warn "配置文件不存在，跳过自动加载"
        fi
        return 1
    fi
    
    # 获取当前配置
    local current_config=$(parse_toml "global" "$config_file" "current_config" 2>/dev/null)
    
    if [[ -z "$current_config" ]]; then
        # 尝试使用默认配置
        current_config=$(parse_toml "global" "$config_file" "default_config" 2>/dev/null)
    fi
    
    if [[ -n "$current_config" ]]; then
        # 验证配置存在
        if validate_config "$current_config" "$config_file" 2>/dev/null; then
            set_config_env_vars "$current_config" "$config_file"
            
            if [[ "$silent_mode" != "silent" ]]; then
                log_info "已自动加载配置: $current_config"
            fi
        else
            if [[ "$silent_mode" != "silent" ]]; then
                log_warn "配置 '$current_config' 无效，跳过自动加载"
            fi
        fi
    else
        if [[ "$silent_mode" != "silent" ]]; then
            log_warn "未找到当前配置，跳过自动加载"
        fi
    fi
}
```

---

**相关文档**：
- [项目架构](architecture.md) - 整体架构设计
- [数据流程](data-flow.md) - 数据处理流程
- [API参考](api-reference.md) - 函数和接口文档