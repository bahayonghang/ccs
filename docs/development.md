# 开发文档

本文档为 CCS (Claude Code Configuration Switcher) 项目的开发者提供详细的开发指南、代码结构说明和贡献流程。

## 📋 目录

- [开发环境搭建](#开发环境搭建)
- [项目结构](#项目结构)
- [代码规范](#代码规范)
- [开发工作流](#开发工作流)
- [测试指南](#测试指南)
- [调试技巧](#调试技巧)
- [性能优化](#性能优化)
- [贡献指南](#贡献指南)
- [发布流程](#发布流程)
- [常见开发问题](#常见开发问题)

## 🛠️ 开发环境搭建

### 1. 系统要求

**基本要求：**
```bash
# Linux/macOS
- Bash 4.0+ 或 Zsh 5.0+
- Fish Shell 3.0+ (可选)
- curl/wget
- git
- 文本编辑器 (VS Code, Vim, Emacs等)

# Windows
- PowerShell 5.0+ 或 PowerShell Core 6.0+
- Git for Windows
- Windows Subsystem for Linux (推荐)
```

**开发工具：**
```bash
# 必需工具
sudo apt install -y git curl wget jq

# TOML处理工具
pip install toml-cli
# 或
cargo install toml-cli

# 代码质量工具
sudo apt install shellcheck  # Shell脚本检查
pip install pre-commit      # Git钩子管理

# 文档工具
pip install mkdocs mkdocs-material  # 文档生成
npm install -g markdownlint-cli      # Markdown检查
```

### 2. 克隆项目

```bash
# 克隆主仓库
git clone https://github.com/user/ccs.git
cd ccs

# 设置开发分支
git checkout -b develop

# 安装开发依赖
./scripts/dev/setup-dev-env.sh

# 验证环境
./scripts/dev/check-env.sh
```

### 3. 开发环境配置

**VS Code配置：**
```json
// .vscode/settings.json
{
    "shellcheck.enable": true,
    "shellcheck.executablePath": "/usr/bin/shellcheck",
    "files.associations": {
        "*.sh": "shellscript",
        "*.fish": "fish",
        "*.toml": "toml"
    },
    "editor.rulers": [80, 120],
    "editor.insertSpaces": true,
    "editor.tabSize": 4,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true
}
```

**Git配置：**
```bash
# 设置Git钩子
pre-commit install

# 配置Git别名
git config alias.co checkout
git config alias.br branch
git config alias.ci commit
git config alias.st status

# 设置提交模板
git config commit.template .gitmessage
```

**环境变量：**
```bash
# 开发环境变量
export CCS_DEV_MODE=1
export CCS_DEBUG_LEVEL=3
export CCS_LOG_FILE="$PWD/logs/dev.log"
export CCS_TEST_CONFIG="$PWD/tests/fixtures/test_config.toml"

# 添加到Shell配置
echo 'source ~/path/to/ccs/scripts/dev/dev-env.sh' >> ~/.bashrc
```

## 📁 项目结构

### 1. 目录结构

```
ccs/
├── README.md                 # 项目说明
├── LICENSE                   # 许可证
├── CHANGELOG.md             # 变更日志
├── CONTRIBUTING.md          # 贡献指南
├── .gitignore              # Git忽略文件
├── .pre-commit-config.yaml # Pre-commit配置
├── Makefile                # 构建脚本
│
├── scripts/                # 核心脚本
│   ├── shell/             # Shell脚本
│   │   ├── ccs.sh         # Bash/Zsh主脚本
│   │   ├── ccs.fish       # Fish Shell脚本
│   │   └── ccs-common.sh  # 通用函数库
│   ├── windows/           # Windows脚本
│   │   ├── ccs.bat        # 批处理脚本
│   │   └── ccs.ps1        # PowerShell脚本
│   ├── install/           # 安装脚本
│   │   ├── install.sh     # 主安装脚本
│   │   ├── quick_install.sh # 快速安装
│   │   └── uninstall.sh   # 卸载脚本
│   └── dev/               # 开发工具
│       ├── setup-dev-env.sh
│       ├── check-env.sh
│       ├── run-tests.sh
│       └── build.sh
│
├── web/                   # Web界面
│   ├── index.html         # 主页面
│   ├── css/              # 样式文件
│   ├── js/               # JavaScript文件
│   └── assets/           # 静态资源
│
├── config/               # 配置文件
│   ├── .ccs_config.toml.example  # 配置示例
│   └── templates/        # 配置模板
│       ├── openai.toml
│       ├── anthropic.toml
│       └── google.toml
│
├── tests/                # 测试文件
│   ├── unit/             # 单元测试
│   ├── integration/      # 集成测试
│   ├── fixtures/         # 测试数据
│   └── helpers/          # 测试辅助函数
│
├── docs/                 # 文档
│   ├── README.md         # 文档入口
│   ├── installation.md   # 安装指南
│   ├── configuration.md  # 配置说明
│   ├── architecture.md   # 架构文档
│   └── development.md    # 开发文档
│
├── examples/             # 示例
│   ├── basic/            # 基础示例
│   ├── advanced/         # 高级示例
│   └── integrations/     # 集成示例
│
└── tools/                # 开发工具
    ├── linters/          # 代码检查工具
    ├── formatters/       # 代码格式化工具
    └── generators/       # 代码生成工具
```

### 2. 核心模块

**Shell脚本模块：**
```bash
# scripts/shell/ccs.sh - 主要功能模块
├── 配置管理模块
│   ├── load_config()      # 加载配置文件
│   ├── save_config()      # 保存配置文件
│   ├── validate_config()  # 验证配置
│   └── backup_config()    # 备份配置
│
├── 环境变量模块
│   ├── set_env_vars()     # 设置环境变量
│   ├── unset_env_vars()   # 清除环境变量
│   └── export_env_vars()  # 导出环境变量
│
├── API交互模块
│   ├── test_api_connection() # 测试API连接
│   ├── validate_api_key()    # 验证API密钥
│   └── get_model_list()      # 获取模型列表
│
├── 用户界面模块
│   ├── show_help()        # 显示帮助
│   ├── show_status()      # 显示状态
│   ├── show_list()        # 显示配置列表
│   └── interactive_mode() # 交互模式
│
└── 工具函数模块
    ├── log_message()      # 日志记录
    ├── handle_error()     # 错误处理
    ├── check_dependencies() # 依赖检查
    └── cleanup()          # 清理函数
```

**配置管理模块：**
```bash
# 配置文件结构
[default_config]
name = "openai-gpt4"        # 默认配置名称

[current_config]
name = "openai-gpt4"        # 当前激活配置
last_updated = "2024-01-15T10:30:00Z"

[openai-gpt4]               # 具体配置
description = "OpenAI GPT-4 配置"
base_url = "https://api.openai.com/v1"
auth_token = "sk-..."
model = "gpt-4"
small_fast_model = "gpt-3.5-turbo"
```

## 📝 代码规范

### 1. Shell脚本规范

**基本规范：**
```bash
#!/bin/bash
# 文件头注释
# 文件名: ccs-example.sh
# 描述: CCS示例脚本
# 作者: CCS开发团队
# 版本: 1.0.0
# 创建日期: 2024-01-15
# 最后修改: 2024-01-15

# 严格模式
set -euo pipefail

# 全局变量（大写,下划线分隔）
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_FILE="$HOME/.ccs_config.toml"
readonly LOG_LEVEL="${CCS_LOG_LEVEL:-INFO}"

# 函数定义（小写,下划线分隔）
function load_configuration() {
    local config_file="$1"
    local config_name="${2:-}"
    
    # 参数验证
    if [[ ! -f "$config_file" ]]; then
        log_error "配置文件不存在: $config_file"
        return 1
    fi
    
    # 函数逻辑
    log_info "加载配置文件: $config_file"
    # ...
    
    return 0
}

# 错误处理
function handle_error() {
    local exit_code="$?"
    local line_number="$1"
    
    log_error "脚本在第 $line_number 行发生错误,退出码: $exit_code"
    cleanup
    exit "$exit_code"
}

# 设置错误陷阱
trap 'handle_error $LINENO' ERR

# 主函数
function main() {
    # 参数解析
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                LOG_LEVEL="DEBUG"
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 主要逻辑
    load_configuration "$CONFIG_FILE"
}

# 清理函数
function cleanup() {
    # 清理临时文件
    rm -f /tmp/ccs-*
    
    # 恢复环境变量
    unset CCS_TEMP_VAR
}

# 脚本退出时执行清理
trap cleanup EXIT

# 执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

**集成测试：**
```bash
#!/bin/bash
# tests/integration/test-config-workflow.sh

source "$(dirname "$0")/../helpers/test-framework.sh"

function setup_test_env() {
    export CCS_TEST_MODE=1
    export CCS_CONFIG_FILE="/tmp/test_config_$$.toml"
    
    # 创建临时配置目录
    TEST_CCS_DIR="/tmp/ccs-test-$$"
    mkdir -p "$TEST_CCS_DIR"
    export CCS_HOME="$TEST_CCS_DIR"
}

function cleanup_test_env() {
    rm -rf "$TEST_CCS_DIR"
    rm -f "$CCS_CONFIG_FILE"
    unset CCS_TEST_MODE CCS_CONFIG_FILE CCS_HOME TEST_CCS_DIR
}

# 测试完整配置工作流
function test_config_lifecycle() {
    # 1. 初始化CCS
    run_command "ccs init --test-mode"
    assert_equals "0" "$?" "CCS初始化应该成功"
    
    # 2. 创建配置
    run_command "ccs create test-config --template openai"
    assert_equals "0" "$?" "创建配置应该成功"
    
    # 3. 验证配置存在
    local configs
    configs=$(ccs list --names-only)
    assert_true "echo '$configs' | grep -q 'test-config'" "配置应该出现在列表中"
    
    # 4. 编辑配置
    run_command "ccs edit test-config --field base_url --value 'https://api.test.com/v1'"
    assert_equals "0" "$?" "编辑配置应该成功"
    
    # 5. 验证配置值
    local base_url
    base_url=$(ccs get test-config base_url)
    assert_equals "https://api.test.com/v1" "$base_url" "配置值应该正确更新"
    
    # 6. 切换配置
    run_command "ccs switch test-config --no-verify"
    assert_equals "0" "$?" "切换配置应该成功"
    
    # 7. 验证当前配置
    local current
    current=$(ccs current)
    assert_equals "test-config" "$current" "当前配置应该是test-config"
    
    # 8. 备份配置
    run_command "ccs backup --output /tmp/backup-$$.toml"
    assert_equals "0" "$?" "备份配置应该成功"
    assert_file_exists "/tmp/backup-$$.toml" "备份文件应该存在"
    
    # 9. 删除配置
    run_command "ccs delete test-config --force"
    assert_equals "0" "$?" "删除配置应该成功"
    
    # 10. 验证配置已删除
    configs=$(ccs list --names-only)
    assert_true "! echo '$configs' | grep -q 'test-config'" "配置应该从列表中消失"
    
    # 清理备份文件
    rm -f "/tmp/backup-$$.toml"
}

function main() {
    echo "开始配置生命周期集成测试..."
    run_test test_config_lifecycle "配置完整生命周期"
    show_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

**性能测试：**
```bash
#!/bin/bash
# tests/performance/benchmark-config-operations.sh

source "$(dirname "$0")/../helpers/test-framework.sh"

# 性能测试配置
readonly BENCHMARK_ITERATIONS=100
readonly PERFORMANCE_THRESHOLD_MS=1000  # 1秒

function setup_test_env() {
    export CCS_TEST_MODE=1
    export CCS_CONFIG_FILE="/tmp/perf_test_$$.toml"
    
    # 创建大量测试配置
    create_large_config_file
}

function cleanup_test_env() {
    rm -f "$CCS_CONFIG_FILE"
    unset CCS_TEST_MODE CCS_CONFIG_FILE
}

function create_large_config_file() {
    {
        echo '[default_config]'
        echo 'name = "config-001"'
        echo
        echo '[current_config]'
        echo 'name = "config-001"'
        echo
        
        # 创建100个配置
        for i in $(seq -w 1 100); do
            echo "[config-$i]"
            echo "description = \"Test config $i\""
            echo "base_url = \"https://api-$i.example.com/v1\""
            echo "auth_token = \"sk-test-token-$i\""
            echo "model = \"gpt-4-$i\""
            echo
        done
    } > "$CCS_CONFIG_FILE"
}

# 测量执行时间
function measure_execution_time() {
    local command="$1"
    local iterations="${2:-1}"
    local total_time=0
    local start_time
    local end_time
    local duration
    
    for ((i=1; i<=iterations; i++)); do
        start_time=$(date +%s%3N)  # 毫秒精度
        eval "$command" >/dev/null 2>&1
        end_time=$(date +%s%3N)
        
        duration=$((end_time - start_time))
        total_time=$((total_time + duration))
    done
    
    local avg_time=$((total_time / iterations))
    echo "$avg_time"
}

# 配置加载性能测试
function test_config_load_performance() {
    local avg_time
    avg_time=$(measure_execution_time "ccs list" 10)
    
    echo "配置加载平均时间: ${avg_time}ms"
    
    if [[ $avg_time -lt $PERFORMANCE_THRESHOLD_MS ]]; then
        assert_equals "pass" "pass" "配置加载性能测试通过 (${avg_time}ms < ${PERFORMANCE_THRESHOLD_MS}ms)"
    else
        assert_equals "pass" "fail" "配置加载性能测试失败 (${avg_time}ms >= ${PERFORMANCE_THRESHOLD_MS}ms)"
    fi
}

# 配置切换性能测试
function test_config_switch_performance() {
    local avg_time
    avg_time=$(measure_execution_time "ccs switch config-050 --no-verify" 5)
    
    echo "配置切换平均时间: ${avg_time}ms"
    
    if [[ $avg_time -lt $PERFORMANCE_THRESHOLD_MS ]]; then
        assert_equals "pass" "pass" "配置切换性能测试通过 (${avg_time}ms < ${PERFORMANCE_THRESHOLD_MS}ms)"
    else
        assert_equals "pass" "fail" "配置切换性能测试失败 (${avg_time}ms >= ${PERFORMANCE_THRESHOLD_MS}ms)"
    fi
}

# 内存使用测试
function test_memory_usage() {
    local max_memory
    
    # 启动CCS进程并监控内存
    {
        for i in {1..10}; do
            ccs list >/dev/null
            ccs switch "config-$(printf "%03d" $((i % 100 + 1)))" --no-verify >/dev/null
        done
    } &
    
    local pid=$!
    max_memory=0
    
    while kill -0 "$pid" 2>/dev/null; do
        local current_memory
        current_memory=$(ps -o rss= -p "$pid" 2>/dev/null || echo 0)
        if [[ $current_memory -gt $max_memory ]]; then
            max_memory=$current_memory
        fi
        sleep 0.1
    done
    
    wait "$pid"
    
    echo "最大内存使用: ${max_memory}KB"
    
    # 内存使用应该小于50MB
    if [[ $max_memory -lt 51200 ]]; then
        assert_equals "pass" "pass" "内存使用测试通过 (${max_memory}KB < 50MB)"
    else
        assert_equals "pass" "fail" "内存使用测试失败 (${max_memory}KB >= 50MB)"
    fi
}

function main() {
    echo "开始性能基准测试..."
    echo "配置文件包含100个配置项"
    echo "性能阈值: ${PERFORMANCE_THRESHOLD_MS}ms"
    echo
    
    run_test test_config_load_performance "配置加载性能"
    run_test test_config_switch_performance "配置切换性能"
    run_test test_memory_usage "内存使用测试"
    
    show_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## 🐛 调试技巧

### 1. 调试模式

**启用详细调试：**
```bash
# 设置调试环境变量
export CCS_DEBUG=1
export CCS_DEBUG_LEVEL=4  # 0=关闭, 1=错误, 2=警告, 3=信息, 4=调试
export CCS_LOG_FILE="$HOME/.ccs/debug.log"

# 启用Shell调试
set -x  # 显示执行的命令
set -v  # 显示读取的输入

# 调试函数示例
function debug_log() {
    if [[ "${CCS_DEBUG_LEVEL:-0}" -ge 4 ]]; then
        echo "[DEBUG] $(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "${CCS_LOG_FILE:-/dev/stderr}"
    fi
}

# 函数调用跟踪
function trace_function() {
    local func_name="$1"
    shift
    
    debug_log "进入函数: $func_name($*)"
    "$func_name" "$@"
    local result=$?
    debug_log "退出函数: $func_name (返回值: $result)"
    
    return $result
}
```

**调试工具脚本：**
```bash
#!/bin/bash
# scripts/dev/debug-ccs.sh

# CCS调试工具
function debug_config_parsing() {
    local config_file="${1:-$HOME/.ccs_config.toml}"
    
    echo "=== 配置文件调试 ==="
    echo "文件: $config_file"
    echo "大小: $(wc -c < "$config_file") 字节"
    echo "行数: $(wc -l < "$config_file")"
    echo
    
    echo "=== TOML语法检查 ==="
    if command -v toml-test >/dev/null; then
        toml-test "$config_file"
    else
        python3 -c "import toml; print('语法正确' if toml.load('$config_file') else '语法错误')"
    fi
    echo
    
    echo "=== 配置段落 ==="
    grep -n '^\[' "$config_file"
    echo
    
    echo "=== 可能的问题 ==="
    # 检查常见问题
    if grep -q 'auth_token.*[^"]*$' "$config_file"; then
        echo "⚠️  发现未加引号的auth_token值"
    fi
    
    if grep -q '\\\\' "$config_file"; then
        echo "⚠️  发现可能的转义字符问题"
    fi
    
    if grep -q '[[:space:]]$' "$config_file"; then
        echo "⚠️  发现行尾空白字符"
    fi
}

function debug_environment() {
    echo "=== 环境变量调试 ==="
    echo "CCS相关环境变量:"
    env | grep -E "^CCS_" | sort
    echo
    
    echo "API相关环境变量:"
    env | grep -E "^(OPENAI|ANTHROPIC|GOOGLE)_" | sed 's/=.*/=***/' | sort
    echo
    
    echo "Shell信息:"
    echo "SHELL: $SHELL"
    echo "BASH_VERSION: ${BASH_VERSION:-N/A}"
    echo "ZSH_VERSION: ${ZSH_VERSION:-N/A}"
    echo
}

function debug_network() {
    echo "=== 网络连接调试 ==="
    
    local endpoints=(
        "api.openai.com"
        "api.anthropic.com"
        "generativelanguage.googleapis.com"
    )
    
    for endpoint in "${endpoints[@]}"; do
        echo -n "测试 $endpoint: "
        if curl -s --connect-timeout 5 "https://$endpoint" >/dev/null 2>&1; then
            echo "✅ 可达"
        else
            echo "❌ 不可达"
        fi
    done
    
    echo
    echo "代理设置:"
    echo "HTTP_PROXY: ${HTTP_PROXY:-未设置}"
    echo "HTTPS_PROXY: ${HTTPS_PROXY:-未设置}"
    echo "NO_PROXY: ${NO_PROXY:-未设置}"
}

function main() {
    case "${1:-all}" in
        config)
            debug_config_parsing "$2"
            ;;
        env)
            debug_environment
            ;;
        network)
            debug_network
            ;;
        all)
            debug_config_parsing
            debug_environment
            debug_network
            ;;
        *)
            echo "用法: $0 [config|env|network|all] [config_file]"
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### 2. 错误诊断

**错误收集脚本：**
```bash
#!/bin/bash
# scripts/dev/collect-error-info.sh

function collect_system_info() {
    echo "=== 系统信息 ==="
    echo "操作系统: $(uname -a)"
    echo "用户: $(whoami)"
    echo "当前目录: $(pwd)"
    echo "时间: $(date)"
    echo "Shell: $SHELL ($BASH_VERSION)"
    echo
}

function collect_ccs_info() {
    echo "=== CCS信息 ==="
    echo "版本: $(ccs --version 2>/dev/null || echo '未安装或无法执行')"
    echo "安装路径: $(which ccs 2>/dev/null || echo '未找到')"
    echo "配置文件: ${CCS_CONFIG_FILE:-$HOME/.ccs_config.toml}"
    
    if [[ -f "${CCS_CONFIG_FILE:-$HOME/.ccs_config.toml}" ]]; then
        echo "配置文件存在: 是"
        echo "配置文件大小: $(wc -c < "${CCS_CONFIG_FILE:-$HOME/.ccs_config.toml}") 字节"
        echo "配置文件权限: $(ls -l "${CCS_CONFIG_FILE:-$HOME/.ccs_config.toml}" | cut -d' ' -f1)"
    else
        echo "配置文件存在: 否"
    fi
    echo
}

function collect_error_logs() {
    echo "=== 错误日志 ==="
    
    local log_files=(
        "$HOME/.ccs/logs/error.log"
        "$HOME/.ccs/debug.log"
        "/tmp/ccs-error.log"
        "${CCS_LOG_FILE:-}"
    )
    
    for log_file in "${log_files[@]}"; do
        if [[ -n "$log_file" && -f "$log_file" ]]; then
            echo "--- $log_file (最后20行) ---"
            tail -20 "$log_file"
            echo
        fi
    done
    
    # 检查系统日志中的CCS相关错误
    if command -v journalctl >/dev/null; then
        echo "--- 系统日志中的CCS错误 ---"
        journalctl --user -u ccs* --since "1 hour ago" --no-pager 2>/dev/null || echo "无系统日志"
        echo
    fi
}

function collect_recent_commands() {
    echo "=== 最近的CCS命令 ==="
    
    # 从history中提取CCS命令
    if [[ -f "$HOME/.bash_history" ]]; then
        echo "--- Bash历史中的CCS命令 (最后10条) ---"
        grep "ccs " "$HOME/.bash_history" | tail -10
        echo
    fi
    
    if [[ -f "$HOME/.zsh_history" ]]; then
        echo "--- Zsh历史中的CCS命令 (最后10条) ---"
        grep "ccs " "$HOME/.zsh_history" | tail -10
        echo
    fi
}

function main() {
    local output_file="${1:-/tmp/ccs-error-report-$(date +%s).txt}"
    
    {
        echo "CCS 错误诊断报告"
        echo "生成时间: $(date)"
        echo "==========================================="
        echo
        
        collect_system_info
        collect_ccs_info
        collect_error_logs
        collect_recent_commands
        
        echo "==========================================="
        echo "报告结束"
        
    } > "$output_file"
    
    echo "错误诊断报告已生成: $output_file"
    echo "请将此文件附加到问题报告中"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## ⚡ 性能优化

### 1. 配置文件优化

**配置缓存机制：**
```bash
# 配置缓存实现
readonly CONFIG_CACHE_DIR="$HOME/.ccs/cache"
readonly CACHE_TTL=300  # 5分钟

function init_config_cache() {
    mkdir -p "$CONFIG_CACHE_DIR"
}

function get_cache_file() {
    local config_file="$1"
    local cache_key
    cache_key=$(echo "$config_file" | sha256sum | cut -d' ' -f1)
    echo "$CONFIG_CACHE_DIR/config-$cache_key.cache"
}

function is_cache_valid() {
    local config_file="$1"
    local cache_file="$2"
    
    # 检查缓存文件是否存在
    [[ -f "$cache_file" ]] || return 1
    
    # 检查缓存是否过期
    local cache_time
    cache_time=$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)
    local current_time
    current_time=$(date +%s)
    
    [[ $((current_time - cache_time)) -lt $CACHE_TTL ]] || return 1
    
    # 检查原文件是否被修改
    local config_time
    config_time=$(stat -c %Y "$config_file" 2>/dev/null || echo 0)
    
    [[ $cache_time -gt $config_time ]]
}

function load_config_cached() {
    local config_file="$1"
    local cache_file
    cache_file=$(get_cache_file "$config_file")
    
    init_config_cache
    
    # 尝试使用缓存
    if is_cache_valid "$config_file" "$cache_file"; then
        debug_log "使用配置缓存: $cache_file"
        source "$cache_file"
        return 0
    fi
    
    # 重新加载配置
    debug_log "重新加载配置: $config_file"
    load_config "$config_file"
    
    # 保存到缓存
    {
        echo "# CCS配置缓存 - $(date)"
        echo "# 原文件: $config_file"
        declare -p | grep "^declare.*CCS_CONFIG_"
    } > "$cache_file"
    
    debug_log "配置已缓存: $cache_file"
}

function clear_config_cache() {
    rm -rf "$CONFIG_CACHE_DIR"
    debug_log "配置缓存已清理"
}
```

### 2. 并发处理优化

**并行配置验证：**
```bash
# 并行处理框架
readonly MAX_PARALLEL_JOBS=4

function run_parallel() {
    local jobs=("$@")
    local pids=()
    local results_dir
    results_dir=$(mktemp -d)
    
    # 启动并行任务
    for i in "${!jobs[@]}"; do
        # 控制并发数
        while [[ ${#pids[@]} -ge $MAX_PARALLEL_JOBS ]]; do
            wait_for_any_job pids
        done
        
        # 启动新任务
        {
            eval "${jobs[i]}"
            echo "$?" > "$results_dir/job-$i.result"
        } &
        
        pids+=("$!")
    done
    
    # 等待所有任务完成
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
    
    # 收集结果
    local all_success=true
    for i in "${!jobs[@]}"; do
        local result
        result=$(cat "$results_dir/job-$i.result" 2>/dev/null || echo 1)
        if [[ $result -ne 0 ]]; then
            all_success=false
        fi
    done
    
    # 清理
    rm -rf "$results_dir"
    
    $all_success
}

function wait_for_any_job() {
    local -n pids_ref=$1
    
    # 等待任意一个任务完成
    wait -n
    
    # 从数组中移除已完成的进程
    local new_pids=()
    for pid in "${pids_ref[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            new_pids+=("$pid")
        fi
    done
    
    pids_ref=("${new_pids[@]}")
}

# 并行验证配置
function validate_configs_parallel() {
    local configs=("$@")
    local jobs=()
    
    # 准备验证任务
    for config in "${configs[@]}"; do
        jobs+=("validate_config '$config'")
    done
    
    # 并行执行
    run_parallel "${jobs[@]}"
}
```

### 3. 内存优化

**内存使用优化：**
```bash
# 内存优化配置
readonly MEMORY_OPTIMIZE=${CCS_MEMORY_OPTIMIZE:-0}

function optimize_memory_usage() {
    if [[ $MEMORY_OPTIMIZE -eq 1 ]]; then
        # 限制历史记录大小
        export HISTSIZE=100
        export HISTFILESIZE=100
        
        # 禁用不必要的功能
        export CCS_DISABLE_AUTOCOMPLETE=1
        export CCS_DISABLE_HISTORY=1
        
        # 使用更小的缓冲区
        ulimit -v 102400  # 限制虚拟内存为100MB
    fi
}

# 内存清理函数
function cleanup_memory() {
    # 清理临时变量
    unset $(compgen -v | grep "^CCS_TEMP_")
    
    # 清理函数缓存
    unset -f $(compgen -A function | grep "^_ccs_cache_")
    
    # 强制垃圾回收（如果支持）
    if command -v gc >/dev/null; then
        gc
    fi
}

# 在脚本退出时清理内存
trap cleanup_memory EXIT
```

## 🤝 贡献指南

### 1. 贡献流程

**首次贡献步骤：**
```bash
# 1. Fork项目到你的GitHub账户
# 2. 克隆你的Fork
git clone https://github.com/your-username/ccs.git
cd ccs

# 3. 添加上游仓库
git remote add upstream https://github.com/original-owner/ccs.git

# 4. 创建开发分支
git checkout -b feature/your-feature-name

# 5. 安装开发依赖
./scripts/dev/setup-dev-env.sh

# 6. 进行开发
# ... 编写代码、测试 ...

# 7. 运行测试和检查
./scripts/dev/run-tests.sh
./scripts/dev/lint.sh

# 8. 提交更改
git add .
git commit -m "feat: 添加新功能描述"

# 9. 推送到你的Fork
git push origin feature/your-feature-name

# 10. 在GitHub上创建Pull Request
```

**代码审查清单：**
```markdown
## Pull Request 检查清单

### 功能性
- [ ] 功能按预期工作
- [ ] 处理了边界条件
- [ ] 错误处理完善
- [ ] 性能影响可接受

### 代码质量
- [ ] 遵循项目代码规范
- [ ] 函数和变量命名清晰
- [ ] 注释充分且准确
- [ ] 没有重复代码
- [ ] 通过了静态代码检查

### 测试
- [ ] 包含适当的单元测试
- [ ] 包含集成测试（如需要）
- [ ] 测试覆盖率足够
- [ ] 所有测试通过
- [ ] 没有破坏现有功能

### 文档
- [ ] 更新了相关文档
- [ ] API变更有文档说明
- [ ] 示例代码正确
- [ ] 更新了CHANGELOG.md

### 兼容性
- [ ] 向后兼容
- [ ] 多平台兼容性测试
- [ ] 依赖版本兼容
```

### 2. 发布流程

**版本发布步骤：**
```bash
# 1. 准备发布分支
git checkout develop
git pull upstream develop
git checkout -b release/v1.4.0

# 2. 更新版本信息
# 更新 scripts/shell/ccs.sh 中的 VERSION 变量
# 更新 package.json 中的 version 字段
# 更新文档中的版本引用

# 3. 更新变更日志
vim CHANGELOG.md

# 4. 运行完整测试套件
./scripts/dev/run-tests.sh --full
./scripts/dev/run-performance-tests.sh

# 5. 构建发布包
./scripts/dev/build-release.sh

# 6. 提交发布准备
git add .
git commit -m "chore(release): 准备 v1.4.0 发布"

# 7. 合并到主分支
git checkout main
git merge release/v1.4.0

# 8. 创建发布标签
git tag -a v1.4.0 -m "Release v1.4.0

新功能:
- 配置文件加密支持
- 性能优化
- Web界面改进

修复:
- 修复配置验证问题
- 改进错误处理"

# 9. 推送发布
git push upstream main
git push upstream v1.4.0

# 10. 合并回开发分支
git checkout develop
git merge main
git push upstream develop

# 11. 创建GitHub Release
# 在GitHub上基于标签创建Release,上传构建产物
```

---

**相关文档**：
- [项目架构](architecture.md) - 系统架构设计
- [组件说明](components.md) - 核心组件详解
- [故障排除](troubleshooting.md) - 常见问题解决
- [API参考](api-reference.md) - API接口文档
```

**命名规范：**
```bash
# 变量命名
local_variable="value"           # 局部变量：小写+下划线
GLOBAL_VARIABLE="value"          # 全局变量：大写+下划线
readonly CONSTANT_VALUE="value"  # 常量：readonly+大写+下划线

# 函数命名
function simple_function() { }    # 简单函数：小写+下划线
function _private_function() { }  # 私有函数：下划线开头
function CCS::public_api() { }    # 公共API：命名空间+双冒号

# 文件命名
ccs-main.sh                      # 主脚本：连字符分隔
ccs-common.sh                    # 通用库：连字符分隔
test-config-validation.sh        # 测试脚本：test-开头
```

### 2. 文档规范

**函数文档：**
```bash
# 函数文档模板
#######################################
# 切换到指定的配置
# 参数:
#   $1 - 配置名称 (必需)
#   $2 - 是否验证配置 (可选,默认true)
# 返回值:
#   0 - 成功
#   1 - 配置不存在
#   2 - 配置验证失败
# 示例:
#   switch_config "openai-gpt4" true
#   switch_config "local-model" false
#######################################
function switch_config() {
    local config_name="$1"
    local validate="${2:-true}"
    
    # 函数实现...
}
```

**注释规范：**
```bash
# 单行注释：解释下一行代码的作用
config_file="$HOME/.ccs_config.toml"  # 配置文件路径

# 多行注释：解释复杂逻辑
# 这里使用复杂的正则表达式来解析TOML格式
# 因为某些系统可能没有安装toml解析器
# 所以我们使用sed和awk来手动解析
config_value=$(sed -n '/^\[/,/^\[/p' "$config_file")
```

### 3. 提交规范

**提交信息格式：**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**类型说明：**
```
feat:     新功能
fix:      修复bug
docs:     文档更新
style:    代码格式调整
refactor: 重构代码
test:     测试相关
chore:    构建过程或辅助工具的变动
perf:     性能优化
```

**示例：**
```
feat(config): 添加配置验证功能

- 添加配置文件格式验证
- 支持API密钥有效性检查
- 改进错误提示信息

Closes #123
```

## 🧪 测试指南

### 1. 测试框架

**测试框架结构：**
```bash
#!/bin/bash
# tests/helpers/test-framework.sh

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# 测试计数器
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# 测试工具函数
function run_command() {
    local cmd="$1"
    local expected_exit_code="${2:-0}"
    
    echo "[CMD] $cmd" >&2
    eval "$cmd"
    local actual_exit_code=$?
    
    if [[ $actual_exit_code -eq $expected_exit_code ]]; then
        return 0
    else
        echo "[ERROR] 命令退出码不匹配: 期望 $expected_exit_code, 实际 $actual_exit_code" >&2
        return 1
    fi
}

# 断言函数
function assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    
    ((TEST_COUNT++))
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓${NC} $message"
        ((PASS_COUNT++))
        return 0
    else
        echo -e "${RED}✗${NC} $message"
        echo -e "  Expected: $expected"
        echo -e "  Actual:   $actual"
        ((FAIL_COUNT++))
        return 1
    fi
}

function assert_true() {
    local condition="$1"
    local message="${2:-Condition should be true}"
    
    if eval "$condition"; then
        assert_equals "true" "true" "$message"
    else
        assert_equals "true" "false" "$message"
    fi
}

function assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"
    
    assert_true "[[ -f '$file' ]]" "$message"
}

# 测试运行器
function run_test() {
    local test_function="$1"
    local test_name="${2:-$test_function}"
    
    echo -e "\n${YELLOW}Running: $test_name${NC}"
    
    # 设置测试环境
    setup_test_env
    
    # 运行测试
    if "$test_function"; then
        echo -e "${GREEN}PASS${NC}: $test_name"
    else
        echo -e "${RED}FAIL${NC}: $test_name"
    fi
    
    # 清理测试环境
    cleanup_test_env
}

# 测试报告
function show_test_summary() {
    echo -e "\n=== 测试结果 ==="
    echo -e "总计: $TEST_COUNT"
    echo -e "${GREEN}通过: $PASS_COUNT${NC}"
    echo -e "${RED}失败: $FAIL_COUNT${NC}"
    
    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo -e "\n${GREEN}所有测试通过！${NC}"
        return 0
    else
        echo -e "\n${RED}有测试失败！${NC}"
        return 1
    fi
}
```

### 2. 测试类型

**单元测试：**
```bash
#!/bin/bash
# tests/unit/test-utils.sh

source "$(dirname "$0")/../helpers/test-framework.sh"
source "$(dirname "$0")/../../scripts/shell/ccs-common.sh"

function setup_test_env() {
    export CCS_TEST_MODE=1
    TEST_DIR="/tmp/ccs-test-$$"
    mkdir -p "$TEST_DIR"
}

function cleanup_test_env() {
    rm -rf "$TEST_DIR"
    unset CCS_TEST_MODE TEST_DIR
}

# 测试日志函数
function test_log_functions() {
    local log_file="$TEST_DIR/test.log"
    export CCS_LOG_FILE="$log_file"
    
    log_info "测试信息"
    assert_file_exists "$log_file" "日志文件应该被创建"
    
    local content
    content=$(cat "$log_file")
    assert_true "echo '$content' | grep -q '测试信息'" "日志应该包含测试信息"
}

# 测试配置验证
function test_validate_config_name() {
    # 有效配置名
    assert_true "validate_config_name 'openai-gpt4'" "有效配置名应该通过验证"
    assert_true "validate_config_name 'test_config'" "下划线配置名应该通过验证"
    
    # 无效配置名
    assert_true "! validate_config_name 'invalid name'" "包含空格的配置名应该失败"
    assert_true "! validate_config_name ''" "空配置名应该失败"
}

# 测试URL验证
function test_validate_url() {
    # 有效URL
    assert_true "validate_url 'https://api.openai.com/v1'" "HTTPS URL应该有效"
    assert_true "validate_url 'http://localhost:8080'" "本地HTTP URL应该有效"
    
    # 无效URL
    assert_true "! validate_url 'not-a-url'" "无效URL应该失败"
    assert_true "! validate_url ''" "空URL应该失败"
}

function main() {
    echo "开始工具函数测试..."
    
    run_test test_log_functions "日志函数测试"
    run_test test_validate_config_name "配置名验证测试"
    run_test test_validate_url "URL验证测试"
    
    show_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi