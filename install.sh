#!/bin/bash

# Claude Code Configuration Switcher 安装脚本
# 此脚本用于安装和配置ccs命令

set -e

# 颜色输出（兼容性处理）
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# 配置文件路径
CONFIG_FILE="$HOME/.ccs_config.toml"
CCS_SCRIPT_PATH="$HOME/.ccs/ccs.sh"
BASHRC_FILE="$HOME/.bashrc"
ZSHRC_FILE="$HOME/.zshrc"

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
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

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检测shell类型
detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    elif [ "$SHELL" = "/bin/bash" ] || [ "$SHELL" = "/usr/bin/bash" ] || [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
        case "$SHELL" in
            *bash) echo "bash" ;;
            *zsh) echo "zsh" ;;
        esac
    elif [ "$0" = "bash" ] || [ "$0" = "-bash" ] || [[ "$0" == *bash ]]; then
        echo "bash"
    elif [ "$0" = "zsh" ] || [ "$0" = "-zsh" ] || [[ "$0" == *zsh ]]; then
        echo "zsh"
    elif echo "$0" | grep -q "fish"; then
        echo "fish"
    elif [ "$SHELL" = "/bin/fish" ] || [ "$SHELL" = "/usr/bin/fish" ]; then
        echo "fish"
    else
        echo "unknown"
    fi
}

# 检查shell配置文件是否存在
shell_config_exists() {
    local shell_type="$1"
    case $shell_type in
        "bash")
            [ -f "$BASHRC_FILE" ]
            ;;
        "zsh")
            [ -f "$ZSHRC_FILE" ]
            ;;
        "fish")
            [ -d "$HOME/.config/fish" ]
            ;;
        *)
            false
            ;;
    esac
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
    
    print_message "$BLUE" "配置 $shell_type 环境..."
    
    # 检查是否已经配置
    if grep -q "ccs\.fish" "$config_file" 2>/dev/null || grep -q "ccs\.sh" "$config_file" 2>/dev/null; then
        print_warning "ccs已经在 $config_file 中配置过了"
        return 0
    fi
    
    # 确保配置文件目录存在
    local config_dir=$(dirname "$config_file")
    if [ ! -d "$config_dir" ]; then
        mkdir -p "$config_dir"
        print_success "创建目录 $config_dir"
    fi
    
    # 添加配置到shell配置文件
    if [ "$shell_type" = "fish" ]; then
        cat >> "$config_file" << 'EOF'

# Claude Code Configuration Switcher (ccs)
if [ -f "$HOME/.ccs/ccs.fish" ]
    source "$HOME/.ccs/ccs.fish"
    # 初始化ccs函数
    if type -q ccs
        # 设置默认配置
        ccs >/dev/null 2>&1; or true
    end
end
EOF
    else
        cat >> "$config_file" << 'EOF'

# Claude Code Configuration Switcher (ccs)
if [ -f "$HOME/.ccs/ccs.sh" ]; then
    source "$HOME/.ccs/ccs.sh"
    # 初始化ccs函数
    if command -v ccs >/dev/null 2>&1; then
        # 设置默认配置
        ccs >/dev/null 2>&1 || true
    fi
fi
EOF
    fi
    
    print_success "已添加ccs配置到 $config_file"
}

# 创建目录
create_directories() {
    print_message "$BLUE" "创建必要的目录..."
    
    if [ ! -d "$HOME/.ccs" ]; then
        mkdir -p "$HOME/.ccs"
        print_success "创建目录 $HOME/.ccs"
    else
        print_warning "目录 $HOME/.ccs 已存在"
    fi
}

# 复制脚本文件
copy_script() {
    print_message "$BLUE" "复制ccs脚本..."
    
    # 获取当前脚本所在目录
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    local source_script="$script_dir/ccs.sh"
    
    if [ ! -f "$source_script" ]; then
        print_error "找不到源脚本文件: $source_script"
        exit 1
    fi
    
    cp "$source_script" "$CCS_SCRIPT_PATH"
    chmod +x "$CCS_SCRIPT_PATH"
    print_success "复制脚本到 $CCS_SCRIPT_PATH"
}

# 创建配置文件
create_config_file() {
    print_message "$BLUE" "检查配置文件..."
    
    if [ -f "$CONFIG_FILE" ]; then
        print_warning "配置文件 $CONFIG_FILE 已存在，跳过创建"
        return
    fi
    
    # 获取示例配置文件路径
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    local example_config="$script_dir/.ccs_config.toml.example"
    
    if [ -f "$example_config" ]; then
        cp "$example_config" "$CONFIG_FILE"
        print_success "创建配置文件 $CONFIG_FILE"
        print_warning "请编辑 $CONFIG_FILE 文件，填入您的API密钥"
    else
        print_error "找不到示例配置文件: $example_config"
        exit 1
    fi
}

# 配置shell环境
configure_shell() {
    local current_shell=$(detect_shell)
    local configured_count=0
    
    print_message "$BLUE" "检测到当前shell: $current_shell"
    
    # 为所有支持的shell配置
    for shell in bash zsh fish; do
        if shell_config_exists "$shell"; then
            configure_shell_for_type "$shell"
            configured_count=$((configured_count + 1))
        else
            print_warning "未找到 $shell 配置文件，跳过"
        fi
    done
    
    # 如果没有找到任何shell配置文件，至少为当前shell创建配置
    if [ $configured_count -eq 0 ]; then
        print_warning "未找到任何shell配置文件，为当前shell创建配置"
        if [ "$current_shell" != "unknown" ]; then
            configure_shell_for_type "$current_shell"
            configured_count=$((configured_count + 1))
        else
            print_error "无法识别shell类型，请手动配置"
            exit 1
        fi
    fi
    
    print_success "已配置 $configured_count 个shell环境"
}

# 安装完成
install_complete() {
    print_success "安装完成！"
    echo ""
    print_message "$BLUE" "使用方法:"
    echo "  ccs list              - 列出所有可用配置"
    echo "  ccs [配置名称]       - 切换到指定配置"
    echo "  ccs current          - 显示当前配置"
    echo "  ccs help             - 显示帮助信息"
    echo ""
    print_warning "请重新启动终端或运行 'source ~/.bashrc' (或 ~/.zshrc) 来使配置生效"
    
    # 检查配置文件是否存在
    if [ -f "$CONFIG_FILE" ]; then
        echo ""
        print_message "$BLUE" "配置文件位置: $CONFIG_FILE"
        print_warning "请编辑配置文件，确保您的API密钥正确"
    fi
}

# 卸载函数
uninstall() {
    print_message "$BLUE" "开始卸载ccs..."
    
    # 删除脚本文件
    if [[ -f "$CCS_SCRIPT_PATH" ]]; then
        rm -f "$CCS_SCRIPT_PATH"
        print_success "删除脚本文件"
    fi
    
    # 删除配置文件（询问用户）
    if [ -f "$CONFIG_FILE" ]; then
        read -p "是否要删除配置文件 $CONFIG_FILE? (y/N): " -n 1 -r
        echo
        if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
            rm -f "$CONFIG_FILE"
            print_success "删除配置文件"
        fi
    fi
    
    # 从shell配置文件中移除配置
    local shell_type=$(detect_shell)
    local config_file=""
    
    case $shell_type in
        "zsh")
            config_file="$ZSHRC_FILE"
            ;;
        "bash")
            config_file="$BASHRC_FILE"
            ;;
    esac
    
    if [ -f "$config_file" ]; then
        # 创建临时文件
        local temp_file=$(mktemp)
        
        # 移除ccs相关的配置行
        grep -v "Claude Code Configuration Switcher" "$config_file" | \
        grep -v "source.*ccs.sh" > "$temp_file"
        
        # 替换原文件
        mv "$temp_file" "$config_file"
        print_success "从 $config_file 中移除配置"
    fi
    
    print_success "卸载完成！请重新启动终端或重新加载shell配置"
}

# 显示帮助
show_help() {
    echo "Claude Code Configuration Switcher 安装脚本"
    echo ""
    echo "用法:"
    echo "  $0                    - 安装ccs"
    echo "  $0 --uninstall        - 卸载ccs"
    echo "  $0 --help             - 显示此帮助"
    echo ""
    echo "此脚本将:"
    echo "  1. 创建 $HOME/.ccs 目录"
    echo "  2. 复制ccs.sh脚本到 $HOME/.ccs/"
    echo "  3. 创建配置文件 $HOME/.ccs_config.toml"
    echo "  4. 配置shell环境"
    echo ""
    echo "注意: 如果配置文件已存在，则不会覆盖"
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
            print_message "$BLUE" "开始安装Claude Code Configuration Switcher..."
            echo ""
            
            create_directories
            copy_script
            create_config_file
            configure_shell
            echo ""
            install_complete
            ;;
    esac
}

# 运行主函数
main "$@"