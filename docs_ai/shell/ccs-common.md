# 通用工具库详解 (ccs-common.sh)

`ccs-common.sh` 是CCS系统的核心工具库，提供跨平台的共享功能、基础设施和工具集。本文档深入分析其技术架构和实现细节。

## 📋 基本信息

- **文件路径**: `scripts/shell/ccs-common.sh`
- **文件大小**: 1,075行
- **主要功能**: 共享函数库、基础设施、工具集
- **设计理念**: 模块化、可复用、高性能

## 🏗️ 模块架构

```bash
#!/bin/bash
# CCS 通用工具函数库 v2.0

# 1. 全局常量和配置 (1-80行)
readonly RED='\033[0;31m'
readonly ERROR_SUCCESS=0
readonly CCS_COMMON_VERSION="2.0.0"

# 2. 日志系统 (81-200行)
log_debug(), log_info(), log_warn(), log_error()
print_success(), print_warning(), print_error()

# 3. 错误处理系统 (201-350行)
handle_error(), _is_sourced()

# 4. 工具函数集 (351-600行)
command_exists(), ask_confirmation(), create_temp_file()

# 5. 配置管理系统 (601-800行)
parse_toml(), validate_config_file(), verify_config_integrity()

# 6. 缓存系统 (801-950行)
check_cache(), store_cache(), clear_cache()

# 7. 性能监控 (951-1075行)
profile_function(), performance_metrics()
```

## 🎨 颜色和输出系统

### 1. 智能颜色检测

```bash
# 颜色输出定义 - 智能检测终端能力
if [[ -n "$TERM" && "$TERM" != "dumb" ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly NC='\033[0m' # No Color
else
    # 不支持颜色的终端
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly CYAN=''
    readonly NC=''
fi
```

**关键特性**:
- **自动检测**: 根据`$TERM`环境变量自动检测颜色支持
- **优雅降级**: 不支持颜色时自动禁用
- **兼容性**: 支持各种终端和Shell环境

### 2. 多级别日志系统

```bash
# 日志级别定义
readonly LOG_LEVEL_DEBUG=0   # 详细调试信息
readonly LOG_LEVEL_INFO=1    # 一般信息
readonly LOG_LEVEL_WARN=2    # 警告信息
readonly LOG_LEVEL_ERROR=3   # 错误信息
readonly LOG_LEVEL_OFF=4     # 关闭日志

# 当前日志级别（默认为INFO）
if [[ -z "${CCS_LOG_LEVEL:-}" ]]; then
    if [[ "${SHELL:-}" == *"fish"* ]]; then
        set -g CCS_LOG_LEVEL $LOG_LEVEL_INFO  # Fish Shell语法
    else
        CCS_LOG_LEVEL=$LOG_LEVEL_INFO         # Bash/Zsh语法
    fi
fi

# 日志函数实现
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
```

**关键特性**:
- **级别控制**: 可动态调整日志输出级别
- **Shell兼容**: 特殊处理Fish Shell的语法差异
- **标准错误**: 日志输出到stderr，避免干扰正常输出
- **格式统一**: 统一的日志格式和颜色标识

### 3. 用户友好的消息函数

```bash
# 带颜色的消息输出函数
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

print_message() {
    local color="$1"
    local message="$2"
    echo -e "${color}[*]${NC} $message"
}
```

## 🛡️ 错误处理系统

### 1. 统一错误处理框架

```bash
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

# 统一错误处理函数
handle_error() {
    local error_code="$1"
    local error_message="$2"
    local show_help="${3:-false}"
    
    log_error "错误[$error_code]: $error_message"
    
    # 根据错误类型提供具体的解决方案
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
        # ... 其他错误类型的处理
    esac
    
    if [[ "$show_help" == "true" ]]; then
        echo
        echo "使用 'ccs help' 查看帮助信息"
        echo "使用 'ccs --debug' 启用调试模式获取更多信息"
    fi
    
    # 安全退出机制
    if _is_sourced; then
        log_warn "检测到在Shell环境中运行，使用安全退出模式"
        return "$error_code" 2>/dev/null || true
    else
        exit "$error_code"
    fi
}
```

### 2. Shell环境检测

```bash
# 检测是否在被source的环境中
_is_sourced() {
    # 检查调用栈，如果脚本被source则BASH_SOURCE[0]不等于$0
    [[ "${BASH_SOURCE[0]}" != "${0}" ]] 2>/dev/null || 
    # 检查是否在函数调用栈中
    [[ "${FUNCNAME[1]}" != "main" ]] 2>/dev/null ||
    # 检查$0是否包含bash或shell
    [[ "$0" =~ (bash|shell|fish|zsh)$ ]] 2>/dev/null
}
```

**关键特性**:
- **环境感知**: 智能检测脚本运行环境
- **安全退出**: 在Shell环境中使用return而非exit
- **兼容性**: 支持多种Shell环境的检测

## 🔧 工具函数集

### 1. 命令存在性检查

```bash
# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 依赖检查函数
check_dependencies() {
    local deps=("$@")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if [[ "$dep" == optional:* ]]; then
            # 可选依赖处理
            dep="${dep#optional:}"
            if ! command_exists "$dep"; then
                log_warn "Optional dependency missing: $dep"
            fi
        else
            # 必需依赖处理
            if ! command_exists "$dep"; then
                missing_deps+=("$dep")
            fi
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        handle_error $ERROR_DEPENDENCY_MISSING "Missing dependencies: ${missing_deps[*]}"
    fi
}
```

### 2. 用户交互函数

```bash
# 用户确认函数
ask_confirmation() {
    local message="$1"
    local default="${2:-Y}"
    local response
    
    if [[ "$default" == "Y" ]]; then
        echo -n "$message [Y/n]: "
    else
        echo -n "$message [y/N]: "
    fi
    
    read -r response
    
    case "$response" in
        [Yy]|[Yy][Ee][Ss])
            return 0
            ;;
        [Nn]|[Nn][Oo])
            return 1
            ;;
        "")
            # 使用默认值
            [[ "$default" == "Y" ]]
            ;;
        *)
            echo "请输入 y 或 n"
            ask_confirmation "$message" "$default"
            ;;
    esac
}
```

### 3. 临时文件管理

```bash
# 创建临时文件
create_temp_file() {
    local prefix="${1:-ccs_temp}"
    local temp_file
    
    # 尝试使用mktemp
    if command_exists mktemp; then
        temp_file=$(mktemp -t "${prefix}.XXXXXX")
    else
        # 回退方案
        temp_file="/tmp/${prefix}_$$_$(date +%s)"
        touch "$temp_file"
    fi
    
    if [[ -f "$temp_file" ]]; then
        echo "$temp_file"
        return 0
    else
        log_error "无法创建临时文件"
        return 1
    fi
}

# 清理临时文件
cleanup_temp_files() {
    local temp_pattern="${1:-ccs_temp}"
    
    # 清理临时文件
    find /tmp -name "${temp_pattern}*" -user "$(whoami)" -mtime +1 -delete 2>/dev/null || true
}
```

## 📊 配置管理系统

### 1. TOML配置解析器

```bash
# TOML配置解析主函数
parse_toml() {
    local config_name="$1"
    local silent_mode="${2:-false}"
    
    log_debug "开始解析配置: $config_name"
    
    # 1. 缓存检查
    if check_cache "$config_name"; then
        log_debug "配置缓存命中: $config_name"
        load_from_cache "$config_name"
        return 0
    fi
    
    # 2. 配置文件存在性检查
    if [[ ! -f "$CONFIG_FILE" ]]; then
        handle_error $ERROR_CONFIG_MISSING "配置文件不存在: $CONFIG_FILE"
    fi
    
    # 3. 查找配置段
    local section_start=$(grep -n "^\[$config_name\]" "$CONFIG_FILE" | head -1 | cut -d: -f1)
    if [[ -z "$section_start" ]]; then
        handle_error $ERROR_CONFIG_INVALID "配置段 [$config_name] 不存在"
    fi
    
    # 4. 确定配置段结束位置
    local section_end=$(awk -v start="$section_start" '
        NR > start && /^\[.*\]/ { print NR-1; exit }
        END { if (NR >= start) print NR }
    ' "$CONFIG_FILE")
    
    # 5. 提取配置字段
    local config_content=$(sed -n "${section_start},${section_end}p" "$CONFIG_FILE")
    
    # 6. 解析关键字段
    local base_url=$(echo "$config_content" | grep "^base_url" | cut -d'"' -f2 | cut -d"'" -f2)
    local auth_token=$(echo "$config_content" | grep "^auth_token" | cut -d'"' -f2 | cut -d"'" -f2)
    local model=$(echo "$config_content" | grep "^model" | cut -d'"' -f2 | cut -d"'" -f2)
    local description=$(echo "$config_content" | grep "^description" | cut -d'"' -f2 | cut -d"'" -f2)
    
    # 7. 字段验证
    if [[ -z "$base_url" ]]; then
        handle_error $ERROR_CONFIG_INVALID "配置 [$config_name] 缺少 base_url 字段"
    fi
    
    if [[ -z "$auth_token" ]]; then
        handle_error $ERROR_CONFIG_INVALID "配置 [$config_name] 缺少 auth_token 字段"
    fi
    
    # 8. 设置环境变量
    export ANTHROPIC_API_KEY="$auth_token"
    export ANTHROPIC_BASE_URL="$base_url"
    
    # 可选字段
    if [[ -n "$model" ]]; then
        export ANTHROPIC_MODEL="$model"
    fi
    
    # 9. 缓存配置
    store_cache "$config_name" "$base_url" "$auth_token" "$model" "$description"
    
    # 10. 更新当前配置记录
    update_current_config "$config_name"
    
    # 11. 输出结果（非静默模式）
    if [[ "$silent_mode" != "silent" ]]; then
        print_success "已切换到配置: $config_name"
        if [[ -n "$description" ]]; then
            print_info "描述: $description"
        fi
        print_info "API地址: $base_url"
        print_info "认证令牌: ${auth_token:0:20}..."
        if [[ -n "$model" ]]; then
            print_info "模型: $model"
        fi
    fi
    
    log_debug "配置解析完成: $config_name"
    return 0
}
```

### 2. 配置验证系统

```bash
# 配置文件完整性验证
verify_config_integrity() {
    local config_file="$1"
    
    log_debug "验证配置文件完整性: $config_file"
    
    # 1. 文件存在性检查
    if [[ ! -f "$config_file" ]]; then
        log_error "配置文件不存在: $config_file"
        return 1
    fi
    
    # 2. 文件可读性检查
    if [[ ! -r "$config_file" ]]; then
        log_error "配置文件不可读: $config_file"
        return 1
    fi
    
    # 3. 基本格式检查
    if ! grep -q "^\[.*\]" "$config_file"; then
        log_error "配置文件格式错误: 缺少配置段"
        return 1
    fi
    
    # 4. 必需字段检查
    local sections=$(grep "^\[.*\]" "$config_file" | sed 's/\[//g' | sed 's/\]//g')
    local invalid_sections=()
    
    while IFS= read -r section; do
        if [[ -n "$section" ]]; then
            # 检查每个配置段的必需字段
            local section_content=$(sed -n "/^\[$section\]/,/^\[/p" "$config_file" | head -n -1)
            
            if ! echo "$section_content" | grep -q "^base_url"; then
                invalid_sections+=("$section: 缺少 base_url")
            fi
            
            if ! echo "$section_content" | grep -q "^auth_token"; then
                invalid_sections+=("$section: 缺少 auth_token")
            fi
        fi
    done <<< "$sections"
    
    # 5. 报告验证结果
    if [[ ${#invalid_sections[@]} -gt 0 ]]; then
        log_error "配置验证失败:"
        for error in "${invalid_sections[@]}"; do
            log_error "  - $error"
        done
        return 1
    fi
    
    log_debug "配置文件验证通过"
    return 0
}

# 基本配置文件验证（回退方案）
validate_config_file() {
    local config_file="$1"
    
    # 简化的验证逻辑
    [[ -f "$config_file" ]] && [[ -r "$config_file" ]] && grep -q "^\[.*\]" "$config_file"
}
```

## 💾 缓存系统

### 1. 智能缓存机制

```bash
# 缓存相关变量
declare -A _config_cache          # 配置数据缓存
declare -A _config_cache_timestamp # 缓存时间戳

# 性能配置
readonly CCS_CACHE_TTL="${CCS_CACHE_TTL:-300}"  # 缓存生存时间(秒)

# 检查缓存有效性
check_cache() {
    local config_name="$1"
    local current_time=$(date +%s)
    local cache_time="${_config_cache_timestamp[$config_name]:-0}"
    
    # TTL检查
    if [[ $((current_time - cache_time)) -lt $CCS_CACHE_TTL ]]; then
        log_debug "缓存命中: $config_name (剩余TTL: $((CCS_CACHE_TTL - (current_time - cache_time)))s)"
        return 0  # 缓存有效
    else
        log_debug "缓存过期: $config_name"
        return 1  # 缓存过期
    fi
}

# 存储配置到缓存
store_cache() {
    local config_name="$1"
    local base_url="$2"
    local auth_token="$3"
    local model="$4"
    local description="$5"
    
    # 构建缓存数据
    local cache_data="base_url=$base_url|auth_token=$auth_token|model=$model|description=$description"
    
    _config_cache[$config_name]="$cache_data"
    _config_cache_timestamp[$config_name]=$(date +%s)
    
    log_debug "配置已缓存: $config_name"
}

# 从缓存加载配置
load_from_cache() {
    local config_name="$1"
    local cache_data="${_config_cache[$config_name]}"
    
    if [[ -n "$cache_data" ]]; then
        # 解析缓存数据
        local base_url=$(echo "$cache_data" | cut -d'|' -f1 | cut -d'=' -f2)
        local auth_token=$(echo "$cache_data" | cut -d'|' -f2 | cut -d'=' -f2)
        local model=$(echo "$cache_data" | cut -d'|' -f3 | cut -d'=' -f2)
        local description=$(echo "$cache_data" | cut -d'|' -f4 | cut -d'=' -f2)
        
        # 设置环境变量
        export ANTHROPIC_API_KEY="$auth_token"
        export ANTHROPIC_BASE_URL="$base_url"
        
        if [[ -n "$model" && "$model" != "" ]]; then
            export ANTHROPIC_MODEL="$model"
        fi
        
        log_debug "从缓存加载配置: $config_name"
        return 0
    else
        log_debug "缓存数据为空: $config_name"
        return 1
    fi
}

# 清理所有缓存
clear_all_cache() {
    _config_cache=()
    _config_cache_timestamp=()
    log_debug "所有缓存已清理"
}

# 清理过期缓存
cleanup_expired_cache() {
    local current_time=$(date +%s)
    local expired_configs=()
    
    for config_name in "${!_config_cache_timestamp[@]}"; do
        local cache_time="${_config_cache_timestamp[$config_name]}"
        if [[ $((current_time - cache_time)) -ge $CCS_CACHE_TTL ]]; then
            expired_configs+=("$config_name")
        fi
    done
    
    for config_name in "${expired_configs[@]}"; do
        unset _config_cache[$config_name]
        unset _config_cache_timestamp[$config_name]
        log_debug "清理过期缓存: $config_name"
    done
}
```

## 📈 性能监控系统

### 1. 函数性能分析

```bash
# 性能分析函数
profile_function() {
    local func_name="$1"
    shift
    
    local start_time=$(date +%s.%N 2>/dev/null || date +%s)
    
    # 执行函数
    "$@"
    local exit_code=$?
    
    local end_time=$(date +%s.%N 2>/dev/null || date +%s)
    
    # 计算执行时间
    if command -v bc >/dev/null 2>&1; then
        local duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "unknown")
    else
        local duration="unknown"
    fi
    
    # 记录性能数据
    if [[ $CCS_LOG_LEVEL -le $LOG_LEVEL_DEBUG ]]; then
        log_debug "Performance: $func_name took ${duration}s (exit_code: $exit_code)"
    fi
    
    return $exit_code
}
```

### 2. 系统资源监控

```bash
# 内存使用监控
monitor_memory_usage() {
    if command_exists ps; then
        local memory_kb=$(ps -o rss= -p $$ 2>/dev/null | tr -d ' ')
        if [[ -n "$memory_kb" ]]; then
            local memory_mb=$((memory_kb / 1024))
            log_debug "Memory usage: ${memory_mb}MB"
        fi
    fi
}

# 缓存统计
cache_statistics() {
    local total_configs=${#_config_cache[@]}
    local total_timestamps=${#_config_cache_timestamp[@]}
    
    log_debug "Cache statistics: $total_configs configs cached, $total_timestamps timestamps"
    
    if [[ $total_configs -gt 0 ]]; then
        local current_time=$(date +%s)
        local valid_cache_count=0
        
        for config_name in "${!_config_cache_timestamp[@]}"; do
            local cache_time="${_config_cache_timestamp[$config_name]}"
            if [[ $((current_time - cache_time)) -lt $CCS_CACHE_TTL ]]; then
                ((valid_cache_count++))
            fi
        done
        
        log_debug "Valid cache entries: $valid_cache_count/$total_configs"
    fi
}
```

## 🔧 扩展接口

### 1. 插件系统支持

```bash
# 插件钩子函数
call_plugin_hook() {
    local hook_name="$1"
    shift
    
    # 检查插件目录
    local plugin_dir="$CCS_DIR/plugins"
    if [[ -d "$plugin_dir" ]]; then
        for plugin_file in "$plugin_dir"/*.sh; do
            if [[ -f "$plugin_file" ]]; then
                # 检查插件是否实现了该钩子
                if grep -q "^${hook_name}()" "$plugin_file"; then
                    log_debug "Calling plugin hook: $hook_name in $(basename "$plugin_file")"
                    source "$plugin_file"
                    "$hook_name" "$@"
                fi
            fi
        done
    fi
}

# 预定义的钩子点
# - before_config_parse
# - after_config_parse
# - before_cache_store
# - after_cache_store
```

### 2. 自定义验证器

```bash
# 注册自定义验证器
register_validator() {
    local validator_name="$1"
    local validator_function="$2"
    
    if [[ -z "${_custom_validators[$validator_name]}" ]]; then
        _custom_validators[$validator_name]="$validator_function"
        log_debug "Registered custom validator: $validator_name"
    fi
}

# 执行自定义验证
run_custom_validators() {
    local config_name="$1"
    
    for validator_name in "${!_custom_validators[@]}"; do
        local validator_function="${_custom_validators[$validator_name]}"
        log_debug "Running custom validator: $validator_name"
        
        if ! "$validator_function" "$config_name"; then
            log_error "Custom validation failed: $validator_name"
            return 1
        fi
    done
    
    return 0
}
```

---

下一节: [横幅显示详解 (banner.sh)](/shell/banner)