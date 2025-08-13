#!/bin/bash

# CCS (Claude Code Configuration Switcher) 通用工具函数库
# 此文件包含跨平台的共享功能，用于减少代码重复并提高一致性

# 颜色输出定义
if [[ -n "$TERM" && "$TERM" != "dumb" ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly NC='\033[0m' # No Color
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly CYAN=''
    readonly NC=''
fi

# 错误码定义
readonly ERROR_SUCCESS=0
readonly ERROR_CONFIG_MISSING=1
readonly ERROR_CONFIG_INVALID=2
readonly ERROR_DOWNLOAD_FAILED=3
readonly ERROR_PERMISSION_DENIED=4
readonly ERROR_FILE_NOT_FOUND=5
readonly ERROR_INVALID_ARGUMENT=6
readonly ERROR_NETWORK_UNREACHABLE=7
readonly ERROR_UNKNOWN=99

# 日志级别
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3
readonly LOG_LEVEL_OFF=4

# 当前日志级别（默认为INFO）
CCS_LOG_LEVEL=${CCS_LOG_LEVEL:-$LOG_LEVEL_INFO}

# 统一错误处理函数
# 用法: handle_error <错误码> <错误信息> [是否显示帮助]
handle_error() {
    local error_code="$1"
    local error_message="$2"
    local show_help="${3:-false}"
    
    log_error "错误[$error_code]: $error_message"
    
    case "$error_code" in
        $ERROR_CONFIG_MISSING)
            log_info "解决方案: 请运行安装脚本创建配置文件"
            ;;
        $ERROR_CONFIG_INVALID)
            log_info "解决方案: 请检查配置文件格式和必需字段"
            ;;
        $ERROR_DOWNLOAD_FAILED)
            log_info "解决方案: 请检查网络连接或稍后重试"
            ;;
        $ERROR_PERMISSION_DENIED)
            log_info "解决方案: 请检查文件权限或使用管理员权限运行"
            ;;
        $ERROR_NETWORK_UNREACHABLE)
            log_info "解决方案: 请检查网络连接和防火墙设置"
            ;;
    esac
    
    if [[ "$show_help" == "true" ]]; then
        echo
        echo "使用 'ccs help' 查看帮助信息"
    fi
    
    exit "$error_code"
}

# 日志函数
log_debug() {
    if [[ $CCS_LOG_LEVEL -le $LOG_LEVEL_DEBUG ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $*" >&2
    fi
}

log_info() {
    if [[ $CCS_LOG_LEVEL -le $LOG_LEVEL_INFO ]]; then
        echo -e "${BLUE}[INFO]${NC} $*" >&2
    fi
}

log_warn() {
    if [[ $CCS_LOG_LEVEL -le $LOG_LEVEL_WARN ]]; then
        echo -e "${YELLOW}[WARN]${NC} $*" >&2
    fi
}

log_error() {
    if [[ $CCS_LOG_LEVEL -le $LOG_LEVEL_ERROR ]]; then
        echo -e "${RED}[ERROR]${NC} $*" >&2
    fi
}

# 带颜色的消息输出函数
print_message() {
    local color="$1"
    local message="$2"
    echo -e "${color}[*]${NC} $message"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[→]${NC} $1"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检查文件是否可读
file_readable() {
    [[ -r "$1" ]]
}

# 检查文件是否可写
file_writable() {
    [[ -w "$1" ]] || ([[ -f "$1" ]] && touch "$1" 2>/dev/null)
}

# 检查目录是否可写
dir_writable() {
    [[ -w "$1" ]] || (mkdir -p "$1/test_dir" 2>/dev/null && rmdir "$1/test_dir" 2>/dev/null)
}

# 创建目录（如果不存在）
ensure_dir_exists() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        if ! mkdir -p "$dir" 2>/dev/null; then
            handle_error $ERROR_PERMISSION_DENIED "无法创建目录: $dir"
        fi
        log_debug "创建目录: $dir"
    fi
}

# 配置文件验证函数
validate_config_file() {
    local config_file="$1"
    
    # 检查文件是否存在
    if [[ ! -f "$config_file" ]]; then
        handle_error $ERROR_CONFIG_MISSING "配置文件不存在: $config_file" "true"
    fi
    
    # 检查文件是否可读
    if ! file_readable "$config_file"; then
        handle_error $ERROR_PERMISSION_DENIED "配置文件不可读: $config_file"
    fi
    
    # 检查文件格式（基本TOML验证）
    if ! validate_toml_syntax "$config_file"; then
        handle_error $ERROR_CONFIG_INVALID "配置文件格式错误: $config_file"
    fi
    
    # 检查必需字段
    validate_required_fields "$config_file"
    
    log_debug "配置文件验证通过: $config_file"
}

# 基本TOML语法验证
validate_toml_syntax() {
    local config_file="$1"
    
    # 检查基本的TOML语法
    if ! grep -q "^default_config.*=" "$config_file" 2>/dev/null; then
        log_warn "配置文件缺少 default_config 字段"
    fi
    
    # 检查是否有配置节
    if ! grep -q "^\[.*\]" "$config_file" 2>/dev/null; then
        log_error "配置文件中没有找到配置节"
        return 1
    fi
    
    # 检查引号匹配
    local quote_count=$(grep -o '"' "$config_file" | wc -l)
    if (( quote_count % 2 != 0 )); then
        log_error "配置文件中引号不匹配"
        return 1
    fi
    
    return 0
}

# 验证配置节中的必需字段
validate_required_fields() {
    local config_file="$1"
    
    # 提取所有配置节名称
    local configs=$(grep "^\\[" "$config_file" | sed 's/\[\(.*\)\]/\1/')
    
    for config in $configs; do
        # 跳过default_config
        if [[ "$config" == "default_config" ]]; then
            continue
        fi
        
        # 提取配置节内容（处理最后一个配置节的情况）
        local config_content
        if [[ "$config" == $(grep "^\\[" "$config_file" | sed 's/\[\(.*\)\]/\1/' | tail -1) ]]; then
            # 如果是最后一个配置节，读取到文件末尾
            config_content=$(sed -n "/^\\[$config\\]/,\$p" "$config_file" | tail -n +2)
        else
            # 否则读取到下一个配置节
            config_content=$(sed -n "/^\\[$config\\]/,/^\\[/p" "$config_file" | tail -n +2 | head -n -1)
        fi
        
        # 检查必需字段
        local missing_fields=()
        
        if ! echo "$config_content" | grep -q "^base_url"; then
            missing_fields+=("base_url")
        fi
        
        if ! echo "$config_content" | grep -q "^auth_token"; then
            missing_fields+=("auth_token")
        fi
        
        # model字段现在是可选的，如果为空或不存在，则使用默认模型
        
        if [[ ${#missing_fields[@]} -gt 0 ]]; then
            log_error "配置节 '$config' 缺少必需字段: ${missing_fields[*]}"
            return 1
        fi
    done
}

# 带重试机制的下载函数
download_with_retry() {
    local url="$1"
    local output="$2"
    local max_retries="${3:-3}"
    local retry_delay="${4:-1}"
    
    log_info "下载文件: $url"
    
    local retry_count=0
    while (( retry_count < max_retries )); do
        if download_file "$url" "$output"; then
            log_debug "下载成功: $output"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        if (( retry_count < max_retries )); then
            log_warn "下载失败，$retry_delay 秒后重试 ($retry_count/$max_retries)"
            sleep "$retry_delay"
        fi
    done
    
    log_error "下载失败，已达到最大重试次数: $url"
    return $ERROR_DOWNLOAD_FAILED
}

# 下载文件（尝试多种方法）
download_file() {
    local url="$1"
    local output="$2"
    
    # 尝试使用 curl
    if command_exists curl; then
        if curl -sSL --connect-timeout 10 --max-time 30 "$url" -o "$output" 2>/dev/null; then
            return 0
        fi
    fi
    
    # 尝试使用 wget
    if command_exists wget; then
        if wget --timeout=10 --tries=1 "$url" -O "$output" 2>/dev/null; then
            return 0
        fi
    fi
    
    # 尝试使用 PowerShell (WSL)
    if command_exists powershell.exe; then
        if powershell.exe -Command "Invoke-WebRequest -Uri '$url' -OutFile '$output' -UseBasicParsing -TimeoutSec 30" 2>/dev/null; then
            return 0
        fi
    fi
    
    return 1
}

# 检查网络连接
check_network_connectivity() {
    local test_url="${1:-https://github.com}"
    
    if command_exists curl; then
        if curl -sSL --connect-timeout 5 --max-time 10 "$test_url" >/dev/null 2>&1; then
            return 0
        fi
    elif command_exists wget; then
        if wget --timeout=5 --tries=1 "$test_url" -O /dev/null 2>/dev/null; then
            return 0
        fi
    fi
    
    return 1
}

# 清理临时文件
cleanup_temp_files() {
    local temp_dir="${1:-${TEMP:-/tmp}}"
    local pattern="${2:-ccs_*}"
    
    find "$temp_dir" -name "$pattern" -type f -delete 2>/dev/null || true
    find "$temp_dir" -name "$pattern" -type d -exec rm -rf {} + 2>/dev/null || true
    
    log_debug "清理临时文件: $temp_dir/$pattern"
}

# 备份文件
backup_file() {
    local source="$1"
    local backup_dir="${2:-${HOME}/.ccs/backups}"
    
    if [[ ! -f "$source" ]]; then
        return 1
    fi
    
    ensure_dir_exists "$backup_dir"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$backup_dir/$(basename "$source").$timestamp.bak"
    
    if cp "$source" "$backup_file" 2>/dev/null; then
        log_debug "备份文件: $source -> $backup_file"
        echo "$backup_file"
        return 0
    fi
    
    return 1
}

# 恢复文件
restore_file() {
    local backup_file="$1"
    local target="$2"
    
    if [[ ! -f "$backup_file" ]]; then
        log_error "备份文件不存在: $backup_file"
        return 1
    fi
    
    if cp "$backup_file" "$target" 2>/dev/null; then
        log_debug "恢复文件: $backup_file -> $target"
        return 0
    fi
    
    return 1
}

# 获取系统信息
get_system_info() {
    local info="unknown"
    
    if [[ -n "$OSTYPE" ]]; then
        case "$OSTYPE" in
            linux-gnu*)  info="linux" ;;
            darwin*)     info="macos" ;;
            cygwin*)     info="windows" ;;
            msys*)       info="windows" ;;
            win32*)      info="windows" ;;
            freebsd*)    info="freebsd" ;;
            *)           info="unknown" ;;
        esac
    fi
    
    echo "$info"
}

# 获取shell类型
get_shell_type() {
    local shell="unknown"
    
    if [[ -n "$SHELL" ]]; then
        shell=$(basename "$SHELL")
    elif [[ -n "$BASH" ]]; then
        shell="bash"
    elif [[ -n "$ZSH_NAME" ]]; then
        shell="zsh"
    elif [[ -n "$FISH_VERSION" ]]; then
        shell="fish"
    fi
    
    echo "$shell"
}

# 显示进度条
show_progress() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    
    printf "\r["
    printf "%*s" "$completed" | tr ' ' '='
    printf "%*s" $((width - completed)) | tr ' ' '-'
    printf "] %d%% (%d/%d)" "$percentage" "$current" "$total"
    
    if (( current >= total )); then
        echo
    fi
}

# 用户确认函数
ask_confirmation() {
    local question="$1"
    local default="${2:-N}"
    
    printf "%s [%s]: " "$question" "$default"
    read -r REPLY
    
    case "$REPLY" in
        [yY][eE][sS]|[yY]) return 0 ;;
        [nN][oO]|[nN]) return 1 ;;
        *) [[ "$default" =~ ^[yY]$ ]] && return 0 || return 1 ;;
    esac
}

# 敏感信息处理
mask_sensitive_info() {
    local input="$1"
    local prefix_length="${2:-10}"
    
    if [[ ${#input} -le $prefix_length ]]; then
        echo "${input:0:1}..."
    else
        echo "${input:0:$prefix_length}..."
    fi
}

# 设置文件权限
set_file_permissions() {
    local file="$1"
    local permissions="${2:-644}"
    
    if [[ -f "$file" ]]; then
        chmod "$permissions" "$file" 2>/dev/null || log_warn "无法设置文件权限: $file"
    fi
}

# 创建安全的临时文件
create_temp_file() {
    local prefix="${1:-ccs}"
    local temp_dir="${TEMP:-/tmp}"
    
    ensure_dir_exists "$temp_dir"
    
    local temp_file
    temp_file=$(mktemp "${temp_dir}/${prefix}_XXXXXX" 2>/dev/null)
    
    if [[ -z "$temp_file" ]]; then
        temp_file="${temp_dir}/${prefix}_$$_$(date +%s)"
        touch "$temp_file" 2>/dev/null
    fi
    
    if [[ -f "$temp_file" ]]; then
        set_file_permissions "$temp_file" "600"
        echo "$temp_file"
    else
        return 1
    fi
}

# 版本比较函数
version_compare() {
    local version1="$1"
    local version2="$2"
    
    # 简单的版本比较（支持主版本号.次版本号.修订号）
    local IFS=.
    local v1_parts=($version1)
    local v2_parts=($version2)
    
    # 填充缺失的版本号部分
    while (( ${#v1_parts[@]} < 3 )); do
        v1_parts+=(0)
    done
    while (( ${#v2_parts[@]} < 3 )); do
        v2_parts+=(0)
    done
    
    # 比较版本号
    for (( i=0; i<3; i++ )); do
        local num1=$((10#${v1_parts[i]}))
        local num2=$((10#${v2_parts[i]}))
        
        if (( num1 > num2 )); then
            echo "greater"
            return
        elif (( num1 < num2 )); then
            echo "less"
            return
        fi
    done
    
    echo "equal"
}

# 加载工具库完成
log_debug "CCS工具库加载完成"