#!/bin/bash

# CCS (Claude Code Configuration Switcher) 通用工具函数库
# 版本: 2.0 - 优化版
# 此文件包含跨平台的共享功能,用于减少代码重复并提高一致性
# 包含: 性能优化、缓存机制、增强的安全性和错误处理

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

# 错误码定义（扩展版）
readonly ERROR_SUCCESS=0
readonly ERROR_CONFIG_MISSING=1
readonly ERROR_CONFIG_INVALID=2
readonly ERROR_DOWNLOAD_FAILED=3
readonly ERROR_PERMISSION_DENIED=4
readonly ERROR_FILE_NOT_FOUND=5
readonly ERROR_INVALID_ARGUMENT=6
readonly ERROR_NETWORK_UNREACHABLE=7
readonly ERROR_DEPENDENCY_MISSING=8
readonly ERROR_CONFIGURATION_CORRUPT=9
readonly ERROR_RESOURCE_BUSY=10
readonly ERROR_TIMEOUT=11
readonly ERROR_AUTHENTICATION_FAILED=12
readonly ERROR_UNKNOWN=99

# 版本信息
readonly CCS_COMMON_VERSION="2.0.0"

# 性能配置
readonly CCS_CACHE_TTL="${CCS_CACHE_TTL:-300}"  # 缓存生存时间(秒)
readonly CCS_MAX_RETRIES="${CCS_MAX_RETRIES:-3}"  # 最大重试次数  
readonly CCS_TIMEOUT="${CCS_TIMEOUT:-30}"  # 默认超时时间(秒)

# 缓存相关变量
declare -A _config_cache
declare -A _config_cache_timestamp

# 日志级别
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3
readonly LOG_LEVEL_OFF=4

# 当前日志级别（默认为INFO）
CCS_LOG_LEVEL=${CCS_LOG_LEVEL:-$LOG_LEVEL_INFO}

# 统一错误处理函数（增强版）
# 用法: handle_error <错误码> <错误信息> [是否显示帮助]
handle_error() {
    local error_code="$1"
    local error_message="$2"
    local show_help="${3:-false}"
    
    log_error "错误[$error_code]: $error_message"
    
    case "$error_code" in
        $ERROR_CONFIG_MISSING)
            log_info "解决方案: 请运行安装脚本创建配置文件"
            log_info "  命令: ccs --install 或 ./scripts/install/install.sh"
            ;;
        $ERROR_CONFIG_INVALID)
            log_info "解决方案: 请检查配置文件格式和必需字段"
            log_info "  参考: ~/.ccs_config.toml 必须包含 [section] 和 base_url、auth_token 字段"
            ;;
        $ERROR_DOWNLOAD_FAILED)
            log_info "解决方案: 请检查网络连接或稍后重试"
            log_info "  检查: 防火墙设置、代理配置、DNS设置"
            ;;
        $ERROR_PERMISSION_DENIED)
            log_info "解决方案: 请检查文件权限或使用管理员权限运行"
            log_info "  命令: chmod 755 <script_file> 或 sudo <command>"
            ;;
        $ERROR_NETWORK_UNREACHABLE)
            log_info "解决方案: 请检查网络连接和防火墙设置"
            log_info "  测试: ping github.com 或 curl -I https://github.com"
            ;;
        $ERROR_DEPENDENCY_MISSING)
            log_info "解决方案: 安装缺少的依赖程序"
            log_info "  检查: 使用 check_dependencies 函数检查所需依赖"
            ;;
        $ERROR_CONFIGURATION_CORRUPT)
            log_info "解决方案: 恢复或重新创建配置文件"
            log_info "  备份: 检查 ~/.ccs/backups/ 目录中的备份文件"
            ;;
        $ERROR_RESOURCE_BUSY)
            log_info "解决方案: 等待资源释放或终止占用的进程"
            log_info "  检查: ps aux | grep ccs 查找相关进程"
            ;;
        $ERROR_TIMEOUT)
            log_info "解决方案: 检查网络连接或增加超时时间"
            log_info "  设置: 使用 CCS_TIMEOUT 环境变量调整超时时间"
            ;;
        $ERROR_AUTHENTICATION_FAILED)
            log_info "解决方案: 检查API认证令牌是否正确"
            log_info "  验证: 确保 auth_token 字段包含有效的API密钥"
            ;;
    esac
    
    if [[ "$show_help" == "true" ]]; then
        echo
        echo "使用 'ccs help' 查看帮助信息"
        echo "使用 'ccs --debug' 启用调试模式获取更多信息"
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
            # 如果是最后一个配置节,读取到文件末尾
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
        
        # model字段现在是可选的,如果为空或不存在,则使用默认模型
        
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
            log_warn "下载失败,$retry_delay 秒后重试 ($retry_count/$max_retries)"
            sleep "$retry_delay"
        fi
    done
    
    log_error "下载失败,已达到最大重试次数: $url"
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

# ============================================================================
# 高级功能模块 (v2.0 新增)
# ============================================================================

# 配置缓存系统
# 用法: cache_config <config_name> <config_data>
cache_config() {
    local config_name="$1"
    local config_data="$2"
    local timestamp=$(date +%s)
    
    _config_cache["$config_name"]="$config_data"
    _config_cache_timestamp["$config_name"]="$timestamp"
    
    log_debug "缓存配置: $config_name"
}

# 获取缓存的配置
# 用法: get_cached_config <config_name>
# 返回: 如果缓存有效返回配置数据，否则返回空
get_cached_config() {
    local config_name="$1"
    local current_time=$(date +%s)
    local cache_timestamp="${_config_cache_timestamp[$config_name]}"
    
    if [[ -n "$cache_timestamp" ]]; then
        local age=$((current_time - cache_timestamp))
        if (( age < CCS_CACHE_TTL )); then
            log_debug "使用缓存配置: $config_name (age: ${age}s)"
            echo "${_config_cache[$config_name]}"
            return 0
        else
            log_debug "缓存过期，清理: $config_name (age: ${age}s)"
            unset _config_cache["$config_name"]
            unset _config_cache_timestamp["$config_name"]
        fi
    fi
    
    return 1
}

# 清理所有缓存
clear_all_cache() {
    _config_cache=()
    _config_cache_timestamp=()
    log_debug "清理所有配置缓存"
}

# 高效的TOML解析器（改进版）
# 用法: parse_toml_fast <config_file> <section_name>
parse_toml_fast() {
    local config_file="$1"
    local section_name="$2"
    local cache_key="${config_file}:${section_name}"
    
    # 检查缓存
    local cached_result
    cached_result=$(get_cached_config "$cache_key")
    if [[ -n "$cached_result" ]]; then
        echo "$cached_result"
        return 0
    fi
    
    # 解析配置文件（优化的单次读取）
    local result
    result=$(awk -v section="$section_name" '
        BEGIN { in_section = 0; found = 0 }
        /^\[.*\]/ { 
            if ($0 == "[" section "]") { 
                in_section = 1; found = 1 
            } else { 
                in_section = 0 
            }
            next
        }
        in_section && /^[^#]/ && NF > 0 { 
            gsub(/^[ \t]+|[ \t]+$/, ""); 
            print 
        }
        END { if (!found) exit 1 }
    ' "$config_file")
    
    if [[ $? -eq 0 ]] && [[ -n "$result" ]]; then
        # 缓存结果
        cache_config "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    return 1
}

# 批量操作支持
# 用法: batch_operation <operation> <items...>
batch_operation() {
    local operation="$1"
    shift
    local items=("$@")
    local total=${#items[@]}
    local completed=0
    local failed=0
    
    log_info "开始批量操作: $operation (总计: $total 项)"
    
    for item in "${items[@]}"; do
        completed=$((completed + 1))
        show_progress "$completed" "$total" 30
        
        if ! "$operation" "$item"; then
            failed=$((failed + 1))
            log_warn "批量操作失败: $item"
        fi
    done
    
    echo
    if (( failed > 0 )); then
        log_warn "批量操作完成，成功: $((completed - failed))，失败: $failed"
        return 1
    else
        log_info "批量操作全部成功完成"
        return 0
    fi
}

# 智能文件监控
# 用法: monitor_file_changes <file> <callback_function>
monitor_file_changes() {
    local file="$1"
    local callback="$2"
    local last_mtime
    
    if [[ ! -f "$file" ]]; then
        log_error "监控的文件不存在: $file"
        return 1
    fi
    
    last_mtime=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null)
    
    while true; do
        local current_mtime
        current_mtime=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null)
        
        if [[ "$current_mtime" != "$last_mtime" ]]; then
            log_debug "检测到文件变化: $file"
            if command -v "$callback" >/dev/null 2>&1; then
                "$callback" "$file"
            fi
            last_mtime="$current_mtime"
        fi
        
        sleep 1
    done
}

# 配置文件完整性检查
# 用法: verify_config_integrity <config_file>
verify_config_integrity() {
    local config_file="$1"
    local errors=()
    
    log_info "检查配置文件完整性: $config_file"
    
    # 检查文件存在性和权限
    if [[ ! -f "$config_file" ]]; then
        errors+=("配置文件不存在")
    elif [[ ! -r "$config_file" ]]; then
        errors+=("配置文件不可读")
    fi
    
    # 检查TOML语法
    if ! validate_toml_syntax "$config_file"; then
        errors+=("TOML语法错误")
    fi
    
    # 检查字符编码（确保是UTF-8）
    if command_exists file; then
        local encoding
        encoding=$(file -bi "$config_file" | grep -o 'charset=[^;]*' | cut -d= -f2)
        if [[ "$encoding" != "utf-8" ]] && [[ "$encoding" != "us-ascii" ]]; then
            errors+=("文件编码非UTF-8: $encoding")
        fi
    fi
    
    # 检查文件大小（防止异常大文件）
    local file_size
    file_size=$(stat -c%s "$config_file" 2>/dev/null || stat -f%z "$config_file" 2>/dev/null)
    if (( file_size > 1048576 )); then  # 1MB
        errors+=("配置文件过大: ${file_size} bytes")
    fi
    
    # 输出检查结果
    if [[ ${#errors[@]} -eq 0 ]]; then
        log_info "配置文件完整性检查通过"
        return 0
    else
        log_error "配置文件完整性检查失败:"
        for error in "${errors[@]}"; do
            log_error "  - $error"
        done
        return 1
    fi
}

# 自动备份和恢复系统
# 用法: auto_backup <file> [backup_count]
auto_backup() {
    local file="$1"
    local max_backups="${2:-5}"
    local backup_dir="${HOME}/.ccs/backups/auto"
    
    if [[ ! -f "$file" ]]; then
        log_warn "要备份的文件不存在: $file"
        return 1
    fi
    
    ensure_dir_exists "$backup_dir"
    
    local basename_file
    basename_file=$(basename "$file")
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$backup_dir/${basename_file}_${timestamp}.bak"
    
    # 创建备份
    if cp "$file" "$backup_file"; then
        log_info "自动备份创建: $backup_file"
        
        # 清理旧备份，保留最新的N个
        local old_backups
        old_backups=$(find "$backup_dir" -name "${basename_file}_*.bak" -type f | sort -r | tail -n +$((max_backups + 1)))
        
        if [[ -n "$old_backups" ]]; then
            echo "$old_backups" | xargs rm -f
            local cleaned_count
            cleaned_count=$(echo "$old_backups" | wc -l)
            log_debug "清理旧备份: $cleaned_count 个文件"
        fi
        
        echo "$backup_file"
        return 0
    else
        log_error "自动备份失败: $file"
        return 1
    fi
}

# 配置迁移工具
# 用法: migrate_config <old_config> <new_config> [version]
migrate_config() {
    local old_config="$1" 
    local new_config="$2"
    local version="${3:-2.0}"
    
    log_info "迁移配置文件: $old_config -> $new_config"
    
    if [[ ! -f "$old_config" ]]; then
        log_error "源配置文件不存在: $old_config"
        return 1
    fi
    
    # 创建自动备份
    auto_backup "$old_config" >/dev/null
    
    # 基本复制并添加版本信息
    {
        echo "# 配置文件版本: $version"
        echo "# 迁移时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        cat "$old_config"
    } > "$new_config"
    
    # 验证新配置文件
    if verify_config_integrity "$new_config"; then
        log_info "配置迁移成功"
        return 0
    else
        log_error "配置迁移后验证失败"
        rm -f "$new_config"
        return 1
    fi
}

# 性能监控
# 用法: profile_function <function_name> [args...]
profile_function() {
    local func_name="$1"
    shift
    local start_time
    start_time=$(date +%s.%N)
    
    log_debug "开始执行函数: $func_name"
    
    # 执行函数
    "$func_name" "$@"
    local result=$?
    
    local end_time
    end_time=$(date +%s.%N)
    local duration
    duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "unknown")
    
    log_debug "函数执行完成: $func_name (耗时: ${duration}s, 结果: $result)"
    
    return $result
}

# 依赖检查工具
# 用法: check_dependencies <cmd1> <cmd2> ...
check_dependencies() {
    local missing_deps=()
    local optional_deps=()
    
    for cmd in "$@"; do
        if [[ "$cmd" == "optional:"* ]]; then
            local opt_cmd="${cmd#optional:}"
            if ! command_exists "$opt_cmd"; then
                optional_deps+=("$opt_cmd")
            fi
        else
            if ! command_exists "$cmd"; then
                missing_deps+=("$cmd")
            fi
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "缺少必需的依赖: ${missing_deps[*]}"
        log_info "请安装缺少的依赖后重试"
        return 1
    fi
    
    if [[ ${#optional_deps[@]} -gt 0 ]]; then
        log_warn "缺少可选依赖: ${optional_deps[*]}"
        log_info "这些依赖不是必需的，但安装后可获得更好的体验"
    fi
    
    return 0
}

# 简单的日志记录函数，避免循环依赖
simple_log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [[ -d "${CCS_LOG_DIR:-$HOME/.ccs/logs}" ]]; then
        echo "[$timestamp] [$level] $message" >> "${INSTALLATION_LOG:-$HOME/.ccs/logs/install.log}"
    fi
}

# 增强的消息输出函数
print_message() {
    local color=$1
    local message=$2
    local prefix="${3:-[*]}"
    printf "%b%s%b %s\n" "$color" "$prefix" "$NC" "$message"
    simple_log "INFO" "$message"
}

print_success() {
    printf "%b✅%b %s\n" "$GREEN" "$NC" "$1"
    simple_log "SUCCESS" "$1"
}

print_warning() {
    printf "%b⚠️ %b %s\n" "$YELLOW" "$NC" "$1"
    simple_log "WARN" "$1"
}

print_error() {
    printf "%b❌%b %s\n" "$RED" "$NC" "$1"
    simple_log "ERROR" "$1"
}

print_step() {
    printf "%b🔧%b %s\n" "$BLUE" "$NC" "$1"
    simple_log "INFO" "Step: $1"
}

print_info() {
    printf "%bℹ️ %b %s\n" "$CYAN" "$NC" "$1"
    simple_log "INFO" "$1"
}

print_debug() {
    if [[ "${LOG_LEVEL:-INFO}" == "DEBUG" ]]; then
        printf "%b🐛%b %s\n" "${MAGENTA:-\033[0;35m}" "$NC" "$1"
        simple_log "DEBUG" "$1"
    fi
}

# 加载工具库完成
log_debug "CCS工具库加载完成 (版本: $CCS_COMMON_VERSION)"