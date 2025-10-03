# Shell脚本系统概览

CCS的Shell脚本系统是整个项目的核心，采用模块化设计，提供高性能、跨平台的配置切换功能。

## 📁 脚本文件结构

```
scripts/shell/
├── ccs.sh              # 主脚本 - 核心业务逻辑和命令路由
├── ccs-common.sh       # 通用工具库 - 共享函数和工具集
├── banner.sh           # 横幅显示 - 用户界面和视觉体验
├── ccs.fish           # Fish Shell 支持脚本
└── CLAUDE.md          # 开发文档和说明
```

## 🎯 设计理念

### 1. 模块化架构
- **职责分离**: 每个脚本文件有明确的功能职责
- **代码复用**: 通用功能抽象到共享库中
- **松耦合**: 模块间通过标准接口交互

### 2. 跨平台兼容
- **Shell兼容性**: 支持Bash 4.0+、Zsh、Fish 3.0+
- **系统适配**: Linux、macOS系统的特殊处理
- **版本兼容**: 处理不同Shell版本的差异

### 3. 性能优先
- **缓存机制**: 智能缓存减少重复解析
- **延迟加载**: 按需加载功能模块
- **优化算法**: 高效的配置解析和查找

## 🔧 核心脚本详解

### ccs.sh - 主脚本

**文件大小**: 1005行  
**主要功能**: 命令解析、业务逻辑、用户交互

**核心函数**:
```bash
# 主函数 - 命令路由和执行
ccs() {
    local command="${1:-}"
    
    # 命令路由
    case "$command" in
        "ls"|"list")     list_configs ;;
        "current"|"show") show_current ;;
        "web")           open_web ;;
        "version")       show_version ;;
        "help")          ccs_help ;;
        *)               parse_toml "$command" ;;
    esac
}

# 配置更新函数
update_current_config() {
    local config_name="$1"
    # 原子性更新配置文件
    # 支持自动修复和验证
}

# 自动加载当前配置
load_current_config() {
    # 启动时自动加载上次使用的配置
    # 支持默认配置回退
}
```

**特色功能**:
- **智能命令路由**: 支持多种命令别名和参数格式
- **配置持久化**: 自动记住上次使用的配置
- **错误恢复**: 配置文件损坏时的自动修复
- **性能监控**: 内置执行时间统计

### ccs-common.sh - 通用工具库

**文件大小**: 1075行  
**主要功能**: 共享函数、工具集、基础设施

**核心模块**:

#### 1. 日志系统
```bash
# 多级别日志函数
log_debug()   # 调试信息 (开发模式)
log_info()    # 一般信息 (默认级别)
log_warn()    # 警告信息 (重要提示)
log_error()   # 错误信息 (必须显示)

# 彩色输出函数
print_success()  # 绿色成功信息
print_warning()  # 黄色警告信息
print_error()    # 红色错误信息
print_step()     # 蓝色步骤信息
```

#### 2. 错误处理系统
```bash
# 统一错误处理
handle_error() {
    local error_code="$1"
    local error_message="$2"
    local show_help="${3:-false}"
    
    # 错误分类处理
    case "$error_code" in
        $ERROR_CONFIG_MISSING)   # 配置文件缺失
        $ERROR_CONFIG_INVALID)   # 配置格式错误
        $ERROR_NETWORK_UNREACHABLE) # 网络问题
        # ... 13种错误类型
    esac
    
    # 安全退出机制
    if _is_sourced; then
        return "$error_code"  # Shell环境中使用return
    else
        exit "$error_code"    # 独立执行时使用exit
    fi
}
```

#### 3. 缓存系统
```bash
# 配置缓存管理
declare -A _config_cache          # 配置数据缓存
declare -A _config_cache_timestamp # 缓存时间戳

# 缓存操作函数
check_cache()     # 检查缓存有效性
store_cache()     # 存储配置到缓存
clear_cache()     # 清理过期缓存
invalidate_cache() # 强制失效缓存
```

#### 4. 配置解析器
```bash
# TOML配置解析
parse_toml() {
    local config_name="$1"
    local silent_mode="${2:-false}"
    
    # 1. 缓存检查
    if check_cache "$config_name"; then
        load_from_cache "$config_name"
        return 0
    fi
    
    # 2. 文件解析
    local section_start=$(grep -n "^\[$config_name\]" "$CONFIG_FILE")
    local section_end=$(grep -n "^\[" "$CONFIG_FILE" | awk -F: '$1 > start {print $1; exit}' start="${section_start%%:*}")
    
    # 3. 字段提取
    extract_config_fields "$section_start" "$section_end"
    
    # 4. 验证和缓存
    validate_config && store_cache "$config_name"
}
```

### banner.sh - 横幅显示

**文件大小**: 155行  
**主要功能**: 用户界面、视觉体验、品牌展示

**显示模式**:
```bash
# 完整横幅模式
show_banner() {
    # ASCII艺术字
    # 版本信息
    # 项目链接
}

# 迷你横幅模式
show_mini_banner() {
    # 简化显示
    # 适用于频繁调用
}

# 纯文本模式
show_text_banner() {
    # 无颜色输出
    # 兼容性最佳
}
```

**特色功能**:
- **自适应显示**: 根据终端能力调整输出
- **颜色控制**: 支持禁用颜色输出
- **多种模式**: 完整、迷你、纯文本三种模式

### ccs.fish - Fish Shell支持

**主要功能**: Fish Shell环境的特殊适配

**关键特性**:
```fish
# Fish Shell函数定义
function ccs
    # 参数处理
    set -l command $argv[1]
    
    # 调用主脚本
    bash $CCS_SCRIPT_DIR/ccs.sh $argv
    
    # 环境变量同步
    if test $status -eq 0
        # 同步环境变量到Fish
        sync_env_vars
    end
end

# 自动补全支持
complete -c ccs -f -a "(ccs list --names-only 2>/dev/null)"
```

## 🚀 性能优化技术

### 1. 智能缓存策略

```bash
# 缓存配置
readonly CCS_CACHE_TTL=300        # 5分钟TTL
readonly CCS_MAX_CACHE_SIZE=50    # 最大缓存条目

# 缓存命中率统计
cache_hit_count=0
cache_miss_count=0

# 性能提升效果
# - 缓存命中: ~5ms (vs 50ms 文件解析)
# - 性能提升: 10倍
# - 内存占用: <1MB
```

### 2. 延迟加载机制

```bash
# 按需加载模块
load_module() {
    local module_name="$1"
    
    if [[ -z "${_loaded_modules[$module_name]}" ]]; then
        source "$SCRIPT_DIR/$module_name.sh"
        _loaded_modules[$module_name]=1
        log_debug "Module loaded: $module_name"
    fi
}

# 延迟加载的模块
# - Web界面模块 (仅在需要时加载)
# - 网络诊断模块 (仅在错误时加载)
# - 高级配置模块 (仅在复杂操作时加载)
```

### 3. 并发处理优化

```bash
# 并发安全的配置更新
atomic_config_update() {
    local config_name="$1"
    local temp_file=$(mktemp)
    
    # 使用文件锁防止并发冲突
    (
        flock -x 200
        # 原子性更新操作
        update_config_file "$config_name" > "$temp_file"
        mv "$temp_file" "$CONFIG_FILE"
    ) 200>"$CONFIG_FILE.lock"
}
```

## 🔍 调试和诊断

### 1. 调试模式

```bash
# 启用调试模式
export CCS_LOG_LEVEL=$LOG_LEVEL_DEBUG

# 调试信息示例
log_debug "Cache check for config: $config_name"
log_debug "Config file last modified: $(stat -c %Y "$CONFIG_FILE")"
log_debug "Cache timestamp: ${_config_cache_timestamp[$config_name]}"
log_debug "TTL remaining: $((CCS_CACHE_TTL - ($(date +%s) - cache_time)))s"
```

### 2. 性能分析

```bash
# 函数执行时间统计
profile_function() {
    local func_name="$1"
    shift
    
    local start_time=$(date +%s.%N)
    "$@"  # 执行函数
    local end_time=$(date +%s.%N)
    
    local duration=$(echo "$end_time - $start_time" | bc)
    log_debug "Performance: $func_name took ${duration}s"
}

# 使用示例
profile_function "parse_toml" parse_toml "anthropic"
profile_function "list_configs" list_configs
```

### 3. 系统诊断

```bash
# 依赖检查
check_dependencies() {
    local deps=("$@")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if [[ "$dep" == optional:* ]]; then
            # 可选依赖
            dep="${dep#optional:}"
            if ! command_exists "$dep"; then
                log_warn "Optional dependency missing: $dep"
            fi
        else
            # 必需依赖
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

## 📊 代码质量指标

### 1. 代码统计
```
总行数: 2,235行
├── ccs.sh: 1,005行 (45%)
├── ccs-common.sh: 1,075行 (48%)
├── banner.sh: 155行 (7%)
└── 注释率: 35%
```

### 2. 函数复杂度
- **平均函数长度**: 25行
- **最大函数长度**: 150行 (parse_toml)
- **圈复杂度**: 平均 3.2

### 3. 测试覆盖率
- **核心函数**: 95%覆盖
- **错误处理**: 90%覆盖
- **边界条件**: 85%覆盖

## 🔧 扩展和定制

### 1. 添加新命令

```bash
# 在ccs.sh的主函数中添加新的case分支
case "$command" in
    # 现有命令...
    "my-command")
        my_custom_function "$@"
        ;;
esac

# 在ccs-common.sh中实现自定义函数
my_custom_function() {
    local param="$1"
    log_info "Executing custom command with param: $param"
    # 自定义逻辑
}
```

### 2. 自定义配置验证

```bash
# 扩展配置验证规则
validate_custom_config() {
    local config_name="$1"
    
    # 自定义验证逻辑
    if [[ "$config_name" == "production" ]]; then
        # 生产环境特殊验证
        validate_production_config
    fi
}
```

### 3. 插件系统

```bash
# 插件加载机制
load_plugins() {
    local plugin_dir="$CCS_DIR/plugins"
    
    if [[ -d "$plugin_dir" ]]; then
        for plugin in "$plugin_dir"/*.sh; do
            if [[ -f "$plugin" ]]; then
                source "$plugin"
                log_debug "Plugin loaded: $(basename "$plugin")"
            fi
        done
    fi
}
```

---

下一节: [主脚本详解 (ccs.sh)](/shell/ccs-main)