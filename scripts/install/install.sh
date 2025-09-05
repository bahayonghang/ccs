#!/bin/bash

# Claude Code Configuration Switcher 安装脚本 v2.0 增强版
# 此脚本用于安装和配置ccs命令
# 增强特性: 高级系统检测、性能优化、智能诊断、安全增强、用户体验提升
# 作者: CCS 开发团队
# 许可证: MIT
# 版本: 2.0.0 增强版 (2025-09-05)

set -euo pipefail

# 版本信息
readonly CCS_VERSION="2.0.0"
readonly INSTALL_SCRIPT_VERSION="2.0.0"
readonly BUILD_DATE="2025-09-05"

# 性能和安全设置
readonly ENABLE_PERFORMANCE_MONITOR=1
readonly ENABLE_SECURITY_CHECK=1
readonly ENABLE_BACKUP=1
readonly MAX_BACKUP_FILES=10
readonly LOG_LEVEL="INFO"

# 增强的日志和性能监控函数
init_installation() {
    SCRIPT_START_TIME=$(date +%s)
    INSTALLATION_LOG="$CCS_LOG_DIR/install_$(date +%Y%m%d_%H%M%S).log"
    
    # 创建日志目录
    mkdir -p "$CCS_LOG_DIR" 2>/dev/null || true
    
    # 记录安装开始
    log_message "INFO" "CCS Installation Script v$INSTALL_SCRIPT_VERSION started"
    log_message "INFO" "Build date: $BUILD_DATE"
    log_message "INFO" "User: $USER"
    log_message "INFO" "Home: $HOME"
}

log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # 输出到日志文件
    if [[ -d "$CCS_LOG_DIR" ]]; then
        echo "[$timestamp] [$level] $message" >> "$INSTALLATION_LOG"
    fi
    
    # 如果启用了调试模式，也输出到控制台
    if [[ "$LOG_LEVEL" == "DEBUG" ]]; then
        case "$level" in
            "ERROR") print_error "$message" ;;
            "WARN") print_warning "$message" ;;
            "INFO") print_info "$message" ;;
            "DEBUG") print_debug "$message" ;;
            "SUCCESS") print_success "$message" ;;
        esac
    fi
}

print_performance_metric() {
    local operation="$1"
    local start_time="$2"
    local end_time="$3"
    local duration=$((end_time - start_time))
    
    PERFORMANCE_METRICS+=("$operation: ${duration}s")
    log_message "DEBUG" "Performance: $operation took ${duration}s"
}

show_performance_summary() {
    if [[ ${#PERFORMANCE_METRICS[@]} -gt 0 ]]; then
        print_step "Performance Summary"
        for metric in "${PERFORMANCE_METRICS[@]}"; do
            print_info "  $metric"
        done
        echo ""
    fi
}

# 安全增强函数
check_security_requirements() {
    if [[ "$ENABLE_SECURITY_CHECK" != "1" ]]; then
        return 0
    fi
    
    print_step "Security Check"
    
    # 检查文件权限
    local script_perms=$(stat -c "%a" "$0" 2>/dev/null || stat -f "%OLp" "$0" 2>/dev/null || echo "unknown")
    if [[ "$script_perms" == "777" ]]; then
        print_warning "Script has overly permissive permissions (777)"
        print_info "Consider: chmod 755 $0"
    fi
    
    # 检查PATH安全性
    if [[ ":$PATH:" == *"::"* ]]; then
        print_warning "PATH contains empty elements, potential security risk"
    fi
    
    # 检查可疑的环境变量
    if [[ -n "${LD_PRELOAD:-}" ]]; then
        print_warning "LD_PRELOAD is set, potential security concern"
        log_message "WARN" "LD_PRELOAD detected: $LD_PRELOAD"
    fi
    
    print_success "Security check completed"
}

# 加载通用工具库并增强功能
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ -f "$SCRIPT_DIR/../shell/ccs-common.sh" ]]; then
    source "$SCRIPT_DIR/../shell/ccs-common.sh"
elif [[ -f "$SCRIPT_DIR/ccs-common.sh" ]]; then
    source "$SCRIPT_DIR/ccs-common.sh"
else
    # 增强的错误处理,如果工具库不存在
    handle_error() {
        local message="$1"
        local code="${2:-1}"
        log_message "ERROR" "$message (exit code: $code)"
        echo "❌ Error: $message" >&2
        exit "$code"
    }
    
    # 增强的颜色输出定义
    if [[ -t 1 ]]; then
        readonly RED='\033[0;31m'
        readonly GREEN='\033[0;32m'
        readonly YELLOW='\033[1;33m'
        readonly BLUE='\033[0;34m'
        readonly CYAN='\033[0;36m'
        readonly MAGENTA='\033[0;35m'
        readonly BOLD='\033[1m'
        readonly NC='\033[0m'
    else
        readonly RED=''
        readonly GREEN=''
        readonly YELLOW=''
        readonly BLUE=''
        readonly CYAN=''
        readonly MAGENTA=''
        readonly BOLD=''
        readonly NC=''
    fi
    
    # 增强的消息输出函数
    print_message() {
        local color=$1
        local message=$2
        local prefix="${3:-[*]}"
        printf "%b%s%b %s\n" "$color" "$prefix" "$NC" "$message"
        log_message "INFO" "$message"
    }
    
    print_success() {
        printf "%b✅%b %s\n" "$GREEN" "$NC" "$1"
        log_message "SUCCESS" "$1"
    }
    
    print_warning() {
        printf "%b⚠️ %b %s\n" "$YELLOW" "$NC" "$1"
        log_message "WARN" "$1"
    }
    
    print_error() {
        printf "%b❌%b %s\n" "$RED" "$NC" "$1"
        log_message "ERROR" "$1"
    }
    
    print_step() {
        printf "%b🔧%b %s\n" "$BLUE" "$NC" "$1"
        log_message "INFO" "Step: $1"
    }
    
    print_info() {
        printf "%bℹ️ %b %s\n" "$CYAN" "$NC" "$1"
        log_message "INFO" "$1"
    }
    
    print_debug() {
        if [[ "$LOG_LEVEL" == "DEBUG" ]]; then
            printf "%b🐛%b %s\n" "$MAGENTA" "$NC" "$1"
            log_message "DEBUG" "$1"
        fi
    }
    
    command_exists() {
        command -v "$1" >/dev/null 2>&1
    }
fi

# 配置文件路径
CONFIG_FILE="$HOME/.ccs_config.toml"
CCS_SCRIPT_PATH="$HOME/.ccs/ccs.sh"
BASHRC_FILE="$HOME/.bashrc"
ZSHRC_FILE="$HOME/.zshrc"

# 增强的目录结构
CCS_DIR="$HOME/.ccs"
CCS_BACKUP_DIR="$CCS_DIR/backups"
CCS_CACHE_DIR="$CCS_DIR/cache"
CCS_LOG_DIR="$CCS_DIR/logs"
CCS_TEMP_DIR="$CCS_DIR/temp"
CCS_WEB_DIR="$CCS_DIR/web"

# 全局变量
SCRIPT_START_TIME=""
INSTALLATION_LOG=""
SYSTEM_INFO=""
PERFORMANCE_METRICS=()

# 增强的系统检测和诊断
detect_system_info() {
    local start_time=$(date +%s)
    print_step "🔍 Performing comprehensive system detection..."
    
    local os_info=""
    local arch_info=""
    local kernel_info=""
    local cpu_info=""
    local memory_info=""
    local disk_info=""
    local system_uptime=""
    
    # 操作系统检测（增强版）
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /etc/os-release ]]; then
            os_info=$(grep "^PRETTY_NAME=" /etc/os-release | cut -d'"' -f2)
            local os_id=$(grep "^ID=" /etc/os-release | cut -d'"' -f2)
            local os_version=$(grep "^VERSION_ID=" /etc/os-release | cut -d'"' -f2)
            SYSTEM_INFO="OS: $os_info ($os_id $os_version)"
        elif [[ -f /etc/lsb-release ]]; then
            os_info=$(grep "^DISTRIB_DESCRIPTION=" /etc/lsb-release | cut -d'"' -f2)
            SYSTEM_INFO="OS: $os_info"
        else
            os_info="Linux"
            SYSTEM_INFO="OS: Linux (Unknown Distribution)"
        fi
        
        # WSL检测（增强版）
        if grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
            local wsl_version=""
            if [[ -n "$WSL_DISTRO_NAME" ]]; then
                wsl_version=" (WSL2: $WSL_DISTRO_NAME)"
            else
                wsl_version=" (WSL)"
            fi
            os_info="${os_info}${wsl_version}"
            SYSTEM_INFO="$SYSTEM_INFO (WSL Environment)"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        local mac_version=$(sw_vers -productVersion)
        local mac_build=$(sw_vers -buildVersion)
        os_info="macOS $mac_version ($mac_build)"
        SYSTEM_INFO="OS: macOS $mac_version ($mac_build)"
    else
        os_info="$OSTYPE"
        SYSTEM_INFO="OS: $OSTYPE"
    fi
    
    # CPU信息
    if command_exists lscpu; then
        cpu_info=$(lscpu | grep "Model name:" | cut -d':' -f2 | sed 's/^ *//' | head -1)
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        cpu_info=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")
    else
        cpu_info=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//' || echo "Unknown")
    fi
    
    # 内存信息
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local total_memory=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}')
        memory_info="${total_memory}GB"
    elif command_exists free; then
        local total_memory=$(free -g | awk 'NR==2{print $2}')
        memory_info="${total_memory}GB"
    else
        memory_info="Unknown"
    fi
    
    # 磁盘空间
    local home_disk=$(df -h "$HOME" 2>/dev/null | tail -1 | awk '{print $4}' || echo "Unknown")
    disk_info="$home_disk available"
    
    # 系统运行时间
    if [[ -f /proc/uptime ]]; then
        local uptime_seconds=$(cat /proc/uptime | cut -d' ' -f1)
        local uptime_days=$(echo "$uptime_seconds / 86400" | bc -l | cut -d'.' -f1)
        system_uptime="${uptime_days} days"
    elif command_exists uptime; then
        system_uptime=$(uptime | grep -o 'up .*' | cut -d',' -f1 || echo "Unknown")
    else
        system_uptime="Unknown"
    fi
    
    # 架构和内核信息
    arch_info=$(uname -m)
    kernel_info=$(uname -r)
    
    # 输出增强的系统信息
    print_info "🏗️  System: $os_info"
    print_info "🔧 Architecture: $arch_info"
    print_info "🐧 Kernel: $kernel_info"
    print_info "💻 CPU: $cpu_info"
    print_info "💾 Memory: $memory_info"
    print_info "💿 Disk: $disk_info"
    print_info "⏱️  Uptime: $system_uptime"
    
    # 记录到日志
    log_message "INFO" "System detection completed: $SYSTEM_INFO"
    
    local end_time=$(date +%s)
    print_performance_metric "System Detection" "$start_time" "$end_time"
}

# 系统兼容性检查
check_system_compatibility() {
    print_step "🔧 Checking system compatibility..."
    
    local compatibility_issues=()
    
    # 检查Shell兼容性
    if [[ "$BASH_VERSION" ]]; then
        local bash_major=$(echo "$BASH_VERSION" | cut -d'.' -f1)
        if [[ "$bash_major" -lt 4 ]]; then
            compatibility_issues+=("Bash version $BASH_VERSION is too old (requires 4.0+)")
        fi
    fi
    
    # 检查文件系统权限
    if [[ ! -w "$HOME" ]]; then
        compatibility_issues+=("Home directory is not writable")
    fi
    
    # 检查PATH长度（避免Windows PATH过长问题）
    local path_length=${#PATH}
    if [[ "$path_length" -gt 4096 ]]; then
        compatibility_issues+=("PATH environment variable is too long ($path_length chars)")
    fi
    
    # 检查磁盘空间
    local available_space=$(df "$HOME" 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
    if [[ "$available_space" != "0" ]] && [[ "$available_space" -lt 10000 ]]; then
        compatibility_issues+=("Insufficient disk space (less than 10MB available)")
    fi
    
    # 报告兼容性问题
    if [[ ${#compatibility_issues[@]} -gt 0 ]]; then
        print_warning "⚠️  System compatibility issues detected:"
        for issue in "${compatibility_issues[@]}"; do
            print_info "  • $issue"
        done
        
        read -p "Continue despite compatibility issues? (y/N): " -r reply
        if [[ ! $reply =~ ^[Yy]$ ]]; then
            print_error "Installation cancelled due to compatibility issues"
            exit 1
        fi
    else
        print_success "✅ System compatibility check passed"
    fi
    
    log_message "INFO" "Compatibility check completed"
}

# 检测shell类型
detect_shell() {
    local current_shell=""
    local shell_version=""
    
    if [[ -n "$ZSH_VERSION" ]]; then
        current_shell="zsh"
        shell_version="$ZSH_VERSION"
    elif [[ -n "$BASH_VERSION" ]]; then
        current_shell="bash"
        shell_version="$BASH_VERSION"
    elif [[ -n "$FISH_VERSION" ]]; then
        current_shell="fish"
        shell_version="$FISH_VERSION"
    elif [[ "$SHELL" == *"bash"* ]]; then
        current_shell="bash"
        if command_exists bash; then
            shell_version=$(bash --version | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
        fi
    elif [[ "$SHELL" == *"zsh"* ]]; then
        current_shell="zsh"
        if command_exists zsh; then
            shell_version=$(zsh --version | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
        fi
    elif [[ "$SHELL" == *"fish"* ]]; then
        current_shell="fish"
        if command_exists fish; then
            shell_version=$(fish --version | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
        fi
    else
        current_shell="unknown"
    fi
    
    if [[ "$shell_version" ]]; then
        print_info "Shell: $current_shell v$shell_version"
    else
        print_info "Shell: $current_shell"
    fi
    
    echo "$current_shell"
}

# 增强的依赖检查和网络验证
check_dependencies() {
    local start_time=$(date +%s)
    print_step "🔍 Performing comprehensive dependency analysis..."
    
    local required_deps=("curl" "grep" "sed" "awk" "basename" "dirname" "chmod" "cp" "mkdir")
    local optional_deps=("python3" "python" "git" "bc" "lscpu" "free" "df")
    local network_deps=("curl" "wget")
    local missing_deps=()
    local available_optional=()
    local network_tools=()
    local critical_missing=()
    
    # 检查必需依赖
    for dep in "${required_deps[@]}"; do
        local dep_start=$(date +%s)
        if command_exists "$dep"; then
            print_success "$dep is available"
            log_message "DEBUG" "Dependency check: $dep - available"
        else
            missing_deps+=("$dep")
            print_error "$dep is missing (required)"
            log_message "ERROR" "Missing required dependency: $dep"
            
            # 标记关键依赖
            if [[ "$dep" == "curl" ]] || [[ "$dep" == "grep" ]] || [[ "$dep" == "sed" ]]; then
                critical_missing+=("$dep")
            fi
        fi
        local dep_end=$(date +%s)
        print_performance_metric "Dependency check: $dep" "$dep_start" "$dep_end"
    done
    
    # 检查网络工具
    print_step "🌐 Checking network connectivity tools..."
    for dep in "${network_deps[@]}"; do
        if command_exists "$dep"; then
            network_tools+=("$dep")
            print_success "$dep is available (network tool)"
            
            # 测试网络连接
            if [[ "$dep" == "curl" ]]; then
                test_network_connectivity "curl"
            elif [[ "$dep" == "wget" ]]; then
                test_network_connectivity "wget"
            fi
        else
            print_info "$dep is not available (optional network tool)"
        fi
    done
    
    # 检查可选依赖
    print_step "🔧 Checking optional dependencies..."
    for dep in "${optional_deps[@]}"; do
        local dep_start=$(date +%s)
        if command_exists "$dep"; then
            case "$dep" in
                "python3"|"python")
                    local python_version=""
                    local python_path=""
                    if [[ "$dep" == "python3" ]]; then
                        python_version=$(python3 --version 2>&1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "unknown")
                        python_path=$(command -v python3)
                    else
                        python_version=$(python --version 2>&1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "unknown")
                        python_path=$(command -v python)
                    fi
                    print_success "$dep v$python_version is available (web interface)"
                    log_message "INFO" "Python found: $python_path v$python_version"
                    
                    # 检查Python模块
                    check_python_modules
                    ;;
                "git")
                    local git_version=$(git --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 || echo "unknown")
                    local git_path=$(command -v git)
                    print_success "git v$git_version is available (updates)"
                    log_message "INFO" "Git found: $git_path v$git_version"
                    
                    # 检查Git配置
                    check_git_configuration
                    ;;
                "bc")
                    print_success "$dep is available (calculations)"
                    ;;
                "lscpu"|"free"|"df")
                    print_success "$dep is available (system info)"
                    ;;
                *)
                    print_success "$dep is available"
                    ;;
            esac
            available_optional+=("$dep")
        else
            print_info "$dep is not available (optional)"
        fi
        local dep_end=$(date +%s)
        print_performance_metric "Optional check: $dep" "$dep_start" "$dep_end"
    done
    
    # 网络连接测试
    if [[ ${#network_tools[@]} -gt 0 ]]; then
        test_internet_connectivity
    fi
    
    # 处理缺失的依赖
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo ""
        print_error "❌ Missing required dependencies: ${missing_deps[*]}"
        print_info "💡 Installation suggestions:"
        
        # 根据系统提供详细的安装命令建议
        local install_cmd=""
        if command_exists apt; then
            install_cmd="sudo apt update && sudo apt install"
            print_info "  Ubuntu/Debian: $install_cmd ${missing_deps[*]}"
        elif command_exists yum; then
            install_cmd="sudo yum install"
            print_info "  RHEL/CentOS 7: $install_cmd ${missing_deps[*]}"
        elif command_exists dnf; then
            install_cmd="sudo dnf install"
            print_info "  Fedora/RHEL 8+: $install_cmd ${missing_deps[*]}"
        elif command_exists pacman; then
            install_cmd="sudo pacman -S"
            print_info "  Arch Linux: $install_cmd ${missing_deps[*]}"
        elif command_exists brew; then
            install_cmd="brew install"
            print_info "  macOS: $install_cmd ${missing_deps[*]}"
        elif command_exists apk; then
            install_cmd="sudo apk add"
            print_info "  Alpine: $install_cmd ${missing_deps[*]}"
        fi
        
        # 特别处理关键缺失依赖
        if [[ ${#critical_missing[@]} -gt 0 ]]; then
            print_error "🚨 Critical dependencies missing: ${critical_missing[*]}"
            print_info "These are essential for CCS to function properly"
        fi
        
        exit 1
    fi
    
    # 显示依赖状态摘要
    echo ""
    print_success "✅ All required dependencies are available"
    if [[ ${#available_optional[@]} -gt 0 ]]; then
        print_info "🎯 Optional features enabled: ${available_optional[*]}"
    fi
    if [[ ${#network_tools[@]} -gt 0 ]]; then
        print_info "🌐 Network tools available: ${network_tools[*]}"
    fi
    
    local end_time=$(date +%s)
    print_performance_metric "Dependency Analysis" "$start_time" "$end_time"
    log_message "INFO" "Dependency check completed successfully"
}

# 网络连接测试
test_network_connectivity() {
    local tool="$1"
    local test_url="https://httpbin.org/status/200"
    
    print_debug "Testing network connectivity using $tool..."
    
    local start_time=$(date +%s)
    local result=""
    
    if [[ "$tool" == "curl" ]]; then
        result=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$test_url" 2>/dev/null || echo "failed")
    elif [[ "$tool" == "wget" ]]; then
        result=$(wget -q -O /dev/null --timeout=5 --tries=1 "$test_url" 2>/dev/null && echo "200" || echo "failed")
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ "$result" == "200" ]]; then
        print_success "✅ Network connectivity test passed (${duration}s)"
        log_message "INFO" "Network test successful using $tool (${duration}s)"
    else
        print_warning "⚠️  Network connectivity test failed"
        log_message "WARN" "Network test failed using $tool"
    fi
}

# 互联网连接测试
test_internet_connectivity() {
    print_step "🌍 Testing internet connectivity..."
    
    local test_urls=(
        "https://httpbin.org/status/200"
        "https://www.google.com/generate_204"
        "https://www.cloudflare.com/cdn-cgi/trace"
    )
    
    local connectivity_ok=false
    for url in "${test_urls[@]}"; do
        if command_exists curl; then
            if curl -s -o /dev/null --max-time 5 "$url" 2>/dev/null; then
                connectivity_ok=true
                print_success "✅ Internet connectivity confirmed via $url"
                log_message "INFO" "Internet test successful: $url"
                break
            fi
        elif command_exists wget; then
            if wget -q -O /dev/null --timeout=5 "$url" 2>/dev/null; then
                connectivity_ok=true
                print_success "✅ Internet connectivity confirmed via $url"
                log_message "INFO" "Internet test successful: $url"
                break
            fi
        fi
    done
    
    if [[ "$connectivity_ok" == false ]]; then
        print_warning "⚠️  Limited internet connectivity detected"
        print_info "Some features (like web interface) may not work properly"
        log_message "WARN" "Internet connectivity test failed"
    fi
}

# Python模块检查
check_python_modules() {
    if command_exists python3; then
        local python_cmd="python3"
    elif command_exists python; then
        local python_cmd="python"
    else
        return
    fi
    
    print_debug "Checking Python modules..."
    
    local required_modules=("http.server" "json" "urllib")
    local missing_modules=()
    
    for module in "${required_modules[@]}"; do
        if ! $python_cmd -c "import $module" 2>/dev/null; then
            missing_modules+=("$module")
        fi
    done
    
    if [[ ${#missing_modules[@]} -gt 0 ]]; then
        print_warning "⚠️  Missing Python modules: ${missing_modules[*]}"
        print_info "Web interface functionality may be limited"
    else
        print_success "✅ All required Python modules are available"
    fi
}

# Git配置检查
check_git_configuration() {
    if ! command_exists git; then
        return
    fi
    
    print_debug "Checking Git configuration..."
    
    # 检查Git用户配置
    local git_user=$(git config --global user.name 2>/dev/null || echo "")
    local git_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -z "$git_user" ]] || [[ -z "$git_email" ]]; then
        print_info "💡 Git user configuration not set (optional)"
        print_info "  Configure with: git config --global user.name 'Your Name'"
        print_info "  Configure with: git config --global user.email 'your@email.com'"
    else
        print_success "✅ Git user configured: $git_user <$git_email>"
    fi
    
    # 检查Git版本
    local git_version=$(git --version | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
    local git_major=$(echo "$git_version" | cut -d'.' -f1)
    local git_minor=$(echo "$git_version" | cut -d'.' -f2)
    
    if [[ "$git_major" -ge 2 ]] || ([[ "$git_major" -eq 2 ]] && [[ "$git_minor" -ge 20 ]]); then
        print_success "✅ Git version $git_version is modern and fully supported"
    else
        print_info "ℹ️  Git version $git_version detected (some features may be limited)"
    fi
}

# 检查shell配置文件是否存在
shell_config_exists() {
    local shell_type="$1"
    case $shell_type in
        "bash")
            [[ -f "$BASHRC_FILE" ]]
            ;;
        "zsh")
            [[ -f "$ZSHRC_FILE" ]]
            ;;
        "fish")
            [[ -d "$HOME/.config/fish" ]]
            ;;
        *)
            false
            ;;
    esac
}

# 检查可用的shell环境
detect_available_shells() {
    print_step "Detecting available shell environments..."
    
    local shells=("bash" "zsh" "fish")
    local available_shells=()
    local config_files=()
    
    for shell in "${shells[@]}"; do
        if command_exists "$shell"; then
            local shell_version=""
            case "$shell" in
                "bash")
                    shell_version=$(bash --version | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
                    if shell_config_exists "$shell"; then
                        print_success "$shell v$shell_version is installed (config: $BASHRC_FILE)"
                        available_shells+=("$shell")
                        config_files+=("$BASHRC_FILE")
                    else
                        print_info "$shell v$shell_version is installed (no config file)"
                    fi
                    ;;
                "zsh")
                    shell_version=$(zsh --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 || echo "unknown")
                    if shell_config_exists "$shell"; then
                        print_success "$shell v$shell_version is installed (config: $ZSHRC_FILE)"
                        available_shells+=("$shell")
                        config_files+=("$ZSHRC_FILE")
                    else
                        print_info "$shell v$shell_version is installed (no config file)"
                    fi
                    ;;
                "fish")
                    shell_version=$(fish --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 || echo "unknown")
                    if shell_config_exists "$shell"; then
                        print_success "$shell v$shell_version is installed (config: $HOME/.config/fish/config.fish)"
                        available_shells+=("$shell")
                        config_files+=("$HOME/.config/fish/config.fish")
                    else
                        print_info "$shell v$shell_version is installed (no config file)"
                    fi
                    ;;
            esac
        else
            print_info "$shell is not installed"
        fi
    done
    
    if [[ ${#available_shells[@]} -eq 0 ]]; then
        print_warning "No shell configuration files found, will create for current shell"
    else
        print_info "Will configure ${#available_shells[@]} shell environment(s): ${available_shells[*]}"
    fi
    
    echo "${available_shells[@]}"
}

# 配置指定shell
configure_shell_for_type() {
    local shell_type="$1"
    local config_file=""
    
    case $shell_type in
        "bash")
            config_file="$BASHRC_FILE"
            ;;
        "zsh")
            config_file="$ZSHRC_FILE"
            ;;
        "fish")
            config_file="$HOME/.config/fish/config.fish"
            ;;
        *)
            return 1
            ;;
    esac
    
    print_step "Configuring $shell_type environment..."
    
    # 检查是否已经配置
    if grep -q "ccs\.fish" "$config_file" 2>/dev/null || grep -q "ccs\.sh" "$config_file" 2>/dev/null; then
        print_success "CCS is already configured in $config_file"
        return 0
    fi
    
    # 确保配置文件目录存在
    local config_dir=$(dirname "$config_file")
    if [[ ! -d "$config_dir" ]]; then
        mkdir -p "$config_dir"
        print_success "Created directory $config_dir"
    fi
    
    # 添加配置到shell配置文件
    if [[ "$shell_type" = "fish" ]]; then
        cat >> "$config_file" << 'EOF'

# Claude Code Configuration Switcher (CCS) v2.0
if test -f "$HOME/.ccs/ccs.fish"
    source "$HOME/.ccs/ccs.fish"
    # Initialize ccs function
    if type -q ccs
        # Set default configuration silently
        ccs >/dev/null 2>&1; and true
    end
end
EOF
    else
        cat >> "$config_file" << 'EOF'

# Claude Code Configuration Switcher (CCS) v2.0
if [ -f "$HOME/.ccs/ccs.sh" ]; then
    source "$HOME/.ccs/ccs.sh"
    # Initialize ccs function
    if command -v ccs >/dev/null 2>&1; then
        # Set default configuration silently
        ccs >/dev/null 2>&1 || true
    fi
fi
EOF
    fi
    
    print_success "Added CCS configuration to $config_file"
}

# 创建目录
create_directories() {
    print_step "Creating necessary directories..."
    
    local dirs=("$HOME/.ccs" "$HOME/.ccs/backups" "$HOME/.ccs/cache" "$HOME/.ccs/temp")
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            if mkdir -p "$dir"; then
                print_success "Created directory $(basename "$dir")"
            else
                print_error "Failed to create directory $dir"
                exit 1
            fi
        else
            print_info "Directory $(basename "$dir") already exists"
        fi
    done
}

# 检查是否已安装
check_installed() {
    if [[ -f "$CCS_SCRIPT_PATH" ]] || [[ -f "$HOME/.ccs/ccs.fish" ]]; then
        return 0
    fi
    return 1
}

# 复制脚本文件
copy_script() {
    local reinstall=false
    
    # 检查是否为重新安装
    if check_installed; then
        print_step "Detected existing CCS installation, updating all components..."
        reinstall=true
    else
        print_step "Installing CCS scripts..."
    fi
    
    # 获取当前脚本所在目录
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    local source_sh="$script_dir/../shell/ccs.sh"
    local source_fish="$script_dir/../shell/ccs.fish"
    local source_common="$script_dir/../shell/ccs-common.sh"
    local source_web="$script_dir/../../web"
    
    # 检查源文件是否存在,如果不存在则检查当前目录
    if [[ ! -f "$source_sh" ]]; then
        source_sh="$script_dir/ccs.sh"
        source_fish="$script_dir/ccs.fish"
        source_common="$script_dir/ccs-common.sh"
        source_web="$script_dir/web"
        
        if [[ ! -f "$source_sh" ]]; then
            print_error "Source script files not found: $source_sh"
            exit 1
        fi
    fi
    
    # 复制通用工具库
    if [[ -f "$source_common" ]]; then
        local common_path="$HOME/.ccs/ccs-common.sh"
        if cp "$source_common" "$common_path"; then
            chmod 644 "$common_path"
            if [[ "$reinstall" == true ]]; then
                print_success "Updated common utilities library"
            else
                print_success "Installed common utilities library"
            fi
        else
            print_warning "Failed to copy common utilities library"
        fi
    fi
    
    # 复制bash脚本
    if cp "$source_sh" "$CCS_SCRIPT_PATH"; then
        chmod 755 "$CCS_SCRIPT_PATH"
        if [[ "$reinstall" == true ]]; then
            print_success "Updated bash script"
        else
            print_success "Installed bash script"
        fi
    else
        print_error "Failed to copy bash script to $CCS_SCRIPT_PATH"
        exit 1
    fi
    
    # 复制fish脚本（如果存在）
    if [[ -f "$source_fish" ]]; then
        local fish_path="$HOME/.ccs/ccs.fish"
        if cp "$source_fish" "$fish_path"; then
            chmod 755 "$fish_path"
            if [[ "$reinstall" == true ]]; then
                print_success "Updated fish script"
            else
                print_success "Installed fish script"
            fi
        else
            print_warning "Failed to copy fish script"
        fi
    fi
    
    # 复制web文件
    if [[ -d "$source_web" ]]; then
        local web_path="$HOME/.ccs/web"
        if [[ -d "$web_path" ]] && [[ "$reinstall" == true ]]; then
            rm -rf "$web_path"
        fi
        if cp -r "$source_web" "$web_path"; then
            if [[ "$reinstall" == true ]]; then
                print_success "Updated web interface files"
            else
                print_success "Installed web interface files"
            fi
        else
            print_warning "Failed to copy web interface files"
        fi
    else
        print_info "Web interface files not found, skipping"
    fi
    
    # 复制package.json文件
    local source_package="$script_dir/../../package.json"
    if [[ ! -f "$source_package" ]]; then
        source_package="$script_dir/package.json"
    fi
    
    if [[ -f "$source_package" ]]; then
        local package_path="$HOME/.ccs/package.json"
        if cp "$source_package" "$package_path"; then
            chmod 644 "$package_path"
            if [[ "$reinstall" == true ]]; then
                print_success "Updated project metadata"
            else
                print_success "Installed project metadata"
            fi
        else
            print_warning "Failed to copy project metadata"
        fi
    else
        print_info "Project metadata not found, skipping"
    fi
    
    # 如果是重新安装,提供额外提示
    if [[ "$reinstall" == true ]]; then
        print_info "All script components have been updated, configuration files preserved"
    fi
}

# 创建配置文件
create_config_file() {
    print_step "Checking configuration file..."
    
    if [[ -f "$CONFIG_FILE" ]]; then
        print_success "Configuration file already exists: $CONFIG_FILE"
        
        # 验证现有配置文件
        if grep -q "^\[.*\]" "$CONFIG_FILE" 2>/dev/null; then
            local config_count=$(grep -c "^\[.*\]" "$CONFIG_FILE" 2>/dev/null || echo "0")
            print_info "Found $config_count configuration section(s)"
        else
            print_warning "Configuration file exists but may be incomplete"
        fi
        return
    fi
    
    # 获取示例配置文件路径
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    local example_config="$script_dir/../../config/.ccs_config.toml.example"
    
    # 如果在标准路径找不到，检查当前目录（用于快速安装场景）
    if [[ ! -f "$example_config" ]]; then
        example_config="$script_dir/.ccs_config.toml.example"
    fi
    
    if [[ -f "$example_config" ]]; then
        if cp "$example_config" "$CONFIG_FILE"; then
            chmod 600 "$CONFIG_FILE"
            print_success "Created configuration file: $CONFIG_FILE"
            print_warning "Please edit the configuration file and add your API keys"
            
            # 显示配置文件内容概览
            local config_sections=$(grep "^\[.*\]" "$CONFIG_FILE" | wc -l)
            print_info "Configuration file contains $config_sections example section(s)"
        else
            print_error "Failed to create configuration file: $CONFIG_FILE"
            exit 1
        fi
    else
        print_error "Example configuration file not found: $example_config"
        exit 1
    fi
}

# 配置shell环境
configure_shell() {
    local current_shell=$(detect_shell)
    local available_shells_str=$(detect_available_shells)
    local available_shells=($available_shells_str)
    local configured_count=0
    
    echo ""
    print_step "Configuring shell environments..."
    print_info "Current shell: $current_shell"
    
    # 为所有支持的shell配置
    for shell in "${available_shells[@]}"; do
        configure_shell_for_type "$shell"
        configured_count=$((configured_count + 1))
    done
    
    # 如果没有找到任何shell配置文件,至少为当前shell创建配置
    if [[ $configured_count -eq 0 ]]; then
        print_warning "No shell configuration files found, creating for current shell"
        if [[ "$current_shell" != "unknown" ]]; then
            configure_shell_for_type "$current_shell"
            configured_count=$((configured_count + 1))
        else
            print_error "Cannot identify shell type, please configure manually"
            exit 1
        fi
    fi
    
    print_success "Configured $configured_count shell environment(s)"
}

# 安装完成
install_complete() {
    local is_reinstall=false
    if check_installed; then
        is_reinstall=true
    fi
    
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    if [[ "$is_reinstall" == true ]]; then
        echo "🎉 CCS Update Complete!"
    else
        echo "🎉 CCS Installation Complete!"
    fi
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    
    print_info "Usage examples:"
    echo "  ccs list              - List all available configurations"
    echo "  ccs [config_name]     - Switch to specified configuration"  
    echo "  ccs current           - Show current configuration"
    echo "  ccs web               - Open web configuration interface"
    echo "  ccs version           - Show version information"
    echo "  ccs help              - Show help information"
    echo ""
    
    # 显示配置文件信息
    if [[ -f "$CONFIG_FILE" ]]; then
        local config_sections=$(grep -c "^\[.*\]" "$CONFIG_FILE" 2>/dev/null || echo "0")
        print_info "Configuration file: $CONFIG_FILE ($config_sections sections)"
        
        if [[ "$is_reinstall" == true ]]; then
            print_success "Existing configuration preserved"
        else
            print_warning "Please edit the configuration file to add your API keys"
        fi
    fi
    
    # 重启提示
    echo ""
    if [[ "$is_reinstall" == true ]]; then
        print_warning "Please restart your terminal or run 'source ~/.bashrc' (or ~/.zshrc) to use the updated version"
    else
        print_warning "Please restart your terminal or run 'source ~/.bashrc' (or ~/.zshrc) to activate CCS"
    fi
    
    # 显示快速开始提示
    echo ""
    print_step "Quick start:"
    echo "  1. Edit $CONFIG_FILE with your API keys"
    echo "  2. Restart your terminal or source shell config"
    echo "  3. Run 'ccs list' to see available configurations"
    echo "  4. Run 'ccs [config_name]' to switch configurations"
    echo ""
}

# 卸载函数
uninstall() {
    echo "🗑️  Starting CCS uninstallation..."
    echo ""
    
    # 创建备份
    if [[ -f "$CONFIG_FILE" ]]; then
        local backup_dir="$HOME/.ccs/backups"
        if [[ ! -d "$backup_dir" ]]; then
            mkdir -p "$backup_dir"
        fi
        
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        local backup_file="$backup_dir/.ccs_config.toml.${timestamp}.bak"
        
        if cp "$CONFIG_FILE" "$backup_file"; then
            print_success "Configuration backed up to: $backup_file"
        fi
    fi
    
    # 删除整个.ccs目录（除了配置文件）
    if [[ -d "$HOME/.ccs" ]]; then
        local files_to_remove=("ccs.sh" "ccs.fish" "ccs-common.sh" "package.json")
        local dirs_to_remove=("web" "cache" "temp")
        
        # 删除脚本文件
        for file in "${files_to_remove[@]}"; do
            if [[ -f "$HOME/.ccs/$file" ]]; then
                rm -f "$HOME/.ccs/$file"
                print_success "Removed $file"
            fi
        done
        
        # 删除目录
        for dir in "${dirs_to_remove[@]}"; do
            if [[ -d "$HOME/.ccs/$dir" ]]; then
                rm -rf "$HOME/.ccs/$dir"
                print_success "Removed $dir directory"
            fi
        done
        
        # 检查.ccs目录是否为空（除了配置文件和备份）
        local remaining_files=$(find "$HOME/.ccs" -type f ! -name "*.toml" ! -path "*/backups/*" 2>/dev/null | wc -l)
        if [[ "$remaining_files" -eq 0 ]]; then
            if [[ ! -f "$CONFIG_FILE" ]]; then
                rm -rf "$HOME/.ccs"
                print_success "Removed .ccs directory"
            else
                print_info "Preserved .ccs directory (contains configuration file)"
            fi
        fi
    fi
    
    # 询问是否删除配置文件
    if [[ -f "$CONFIG_FILE" ]]; then
        echo ""
        read -p "Remove configuration file $CONFIG_FILE? (y/N): " -r reply
        if [[ $reply =~ ^[Yy]$ ]]; then
            rm -f "$CONFIG_FILE"
            print_success "Removed configuration file"
            # 如果删除了配置文件且.ccs目录为空,删除目录
            if [[ -d "$HOME/.ccs" ]] && [[ -z "$(ls -A "$HOME/.ccs" 2>/dev/null)" ]]; then
                rm -rf "$HOME/.ccs"
                print_success "Removed empty .ccs directory"
            fi
        else
            print_info "Configuration file preserved"
        fi
    fi
    
    # 从所有shell配置文件中移除配置
    local removed_count=0
    local shell_configs=("$BASHRC_FILE" "$ZSHRC_FILE" "$HOME/.config/fish/config.fish")
    
    for config_file in "${shell_configs[@]}"; do
        if [[ -f "$config_file" ]]; then
            if grep -q "Claude Code Configuration Switcher" "$config_file" 2>/dev/null; then
                # 创建临时文件移除配置
                local temp_file=$(mktemp)
                awk '
                /^# Claude Code Configuration Switcher/ { skip=1; next }
                /^if \[ -f "\$HOME\/\.ccs\/ccs\.sh" \]/ || /^if test -f "\$HOME\/\.ccs\/ccs\.fish"/ { skip=1; next }
                /^fi$/ && skip { skip=0; next }
                /^end$/ && skip { skip=0; next }
                !skip { print }
                ' "$config_file" > "$temp_file"
                
                if ! cmp -s "$config_file" "$temp_file"; then
                    mv "$temp_file" "$config_file"
                    print_success "Removed CCS configuration from $(basename "$config_file")"
                    removed_count=$((removed_count + 1))
                else
                    rm -f "$temp_file"
                fi
            fi
        fi
    done
    
    if [[ "$removed_count" -gt 0 ]]; then
        print_success "Removed CCS configuration from $removed_count shell config file(s)"
    else
        print_info "No CCS configuration found in shell config files"
    fi
    
    echo ""
    print_success "Uninstallation complete!"
    print_warning "Please restart your terminal or reload shell configuration to complete the removal"
}

# 显示帮助
show_help() {
    echo "Claude Code Configuration Switcher (CCS) Installer v$INSTALL_SCRIPT_VERSION"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    echo "Usage:"
    echo "  $0                    - Install CCS (or update if already installed)"
    echo "  $0 --uninstall        - Uninstall CCS"
    echo "  $0 --help             - Show this help"
    echo ""
    echo "This script will:"
    echo "  1. Detect system information and dependencies"
    echo "  2. Create $HOME/.ccs directory structure"
    echo "  3. Install CCS scripts (bash, fish, common utilities)"
    echo "  4. Install web interface files"
    echo "  5. Create configuration file $HOME/.ccs_config.toml (if not exists)"
    echo "  6. Configure shell environments automatically"
    echo ""
    echo "Update behavior:"
    echo "  - Updates all script files to latest version"
    echo "  - Preserves existing configuration files"
    echo "  - Does not duplicate shell configuration"
    echo ""
    echo "Features:"
    echo "  - Multi-shell support (bash, zsh, fish)"
    echo "  - Cross-platform compatibility (Linux, macOS, WSL)"
    echo "  - Web-based configuration interface"
    echo "  - Automatic dependency checking"
    echo "  - Safe uninstallation with backup"
    echo ""
    echo "Note: Configuration files are never overwritten once they exist"
}

# 主函数
main() {
    case "${1:-}" in
        "--uninstall")
            uninstall
            ;;
        "--help"|"-h")
            show_help
            ;;
        *)
            # 显示标题和版本信息
            echo "🔄 Claude Code Configuration Switcher (CCS) Installer v$INSTALL_SCRIPT_VERSION"
            echo "════════════════════════════════════════════════════════════════"
            echo ""
            
            # 系统信息检测
            detect_system_info
            local current_shell=$(detect_shell)
            echo ""
            
            # 检查依赖
            check_dependencies
            echo ""
            
            # 检查是否为重新安装
            if check_installed; then
                print_step "Existing CCS installation detected, starting update..."
            else
                print_step "Starting CCS installation..."
            fi
            echo ""
            
            create_directories
            copy_script
            create_config_file
            configure_shell
            install_complete
            ;;
    esac
}

# 运行主函数
main "$@"