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
    printf "%b[*]%b %s\n" "$color" "$NC" "$message"
}

print_success() {
    printf "%b[✓]%b %s\n" "$GREEN" "$NC" "$1"
}

print_warning() {
    printf "%b[!]%b %s\n" "$YELLOW" "$NC" "$1"
}

print_error() {
    printf "%b[✗]%b %s\n" "$RED" "$NC" "$1"
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
    elif [ "$0" = "bash" ] || [ "$0" = "-bash" ] || echo "$0" | grep -q "bash"; then
        echo "bash"
    elif [ "$0" = "zsh" ] || [ "$0" = "-zsh" ] || echo "$0" | grep -q "zsh"; then
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
if test -f "$HOME/.ccs/ccs.fish"
    source "$HOME/.ccs/ccs.fish"
    # 初始化ccs函数
    if type -q ccs
        # 设置默认配置
        ccs >/dev/null 2>&1; and true
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

# 检查是否已安装
check_installed() {
    if [ -f "$CCS_SCRIPT_PATH" ] || [ -f "$HOME/.ccs/ccs.fish" ]; then
        return 0
    fi
    return 1
}

# 复制脚本文件
copy_script() {
    local reinstall=false
    
    # 检查是否为重新安装
    if check_installed; then
        print_message "$YELLOW" "检测到ccs已安装，将更新所有shell脚本..."
        reinstall=true
    else
        print_message "$BLUE" "复制ccs脚本..."
    fi
    
    # 获取当前脚本所在目录
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    local source_sh="$script_dir/../shell/ccs.sh"
    local source_fish="$script_dir/../shell/ccs.fish"
    local source_web="$script_dir/../../web"
    
    if [ ! -f "$source_sh" ]; then
        print_error "找不到源脚本文件: $source_sh"
        exit 1
    fi
    
    # 复制bash脚本
    if [ -f "$CCS_SCRIPT_PATH" ] && [ "$reinstall" = true ]; then
        print_message "$BLUE" "更新bash脚本..."
    fi
    cp "$source_sh" "$CCS_SCRIPT_PATH"
    chmod +x "$CCS_SCRIPT_PATH"
    if [ "$reinstall" = true ]; then
        print_success "更新bash脚本到 $CCS_SCRIPT_PATH"
    else
        print_success "复制bash脚本到 $CCS_SCRIPT_PATH"
    fi
    
    # 复制fish脚本（如果存在）
    if [ -f "$source_fish" ]; then
        local fish_path="$HOME/.ccs/ccs.fish"
        if [ -f "$fish_path" ] && [ "$reinstall" = true ]; then
            print_message "$BLUE" "更新fish脚本..."
        fi
        cp "$source_fish" "$fish_path"
        chmod +x "$fish_path"
        if [ "$reinstall" = true ]; then
            print_success "更新fish脚本到 $fish_path"
        else
            print_success "复制fish脚本到 $fish_path"
        fi
    fi
    
    # 复制web文件
    if [ -d "$source_web" ]; then
        local web_path="$HOME/.ccs/web"
        if [ -d "$web_path" ] && [ "$reinstall" = true ]; then
            print_message "$BLUE" "更新web文件..."
            rm -rf "$web_path"
        fi
        cp -r "$source_web" "$web_path"
        if [ "$reinstall" = true ]; then
            print_success "更新web文件到 $web_path"
        else
            print_success "复制web文件到 $web_path"
        fi
    else
        print_warning "未找到web文件夹，跳过复制web文件"
    fi
    
    # 如果是重新安装，提供额外提示
    if [ "$reinstall" = true ]; then
        print_warning "已更新所有shell脚本，配置文件保持不变"
    fi
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
    local example_config="$script_dir/../../config/.ccs_config.toml.example"
    
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
    local is_reinstall=false
    if check_installed; then
        is_reinstall=true
    fi
    
    if [ "$is_reinstall" = true ]; then
        print_success "重新安装完成！"
    else
        print_success "安装完成！"
    fi
    
    echo ""
    print_message "$BLUE" "使用方法:"
    echo "  ccs list              - 列出所有可用配置"
    echo "  ccs [配置名称]       - 切换到指定配置"
    echo "  ccs current          - 显示当前配置"
    echo "  ccs web              - 打开web配置界面"
    echo "  ccs help             - 显示帮助信息"
    echo ""
    
    if [ "$is_reinstall" = true ]; then
        print_warning "脚本已更新，请重新启动终端或运行 'source ~/.bashrc' (或 ~/.zshrc/~/.config/fish/config.fish) 来使新版本生效"
    else
        print_warning "请重新启动终端或运行 'source ~/.bashrc' (或 ~/.zshrc/~/.config/fish/config.fish) 来使配置生效"
    fi
    
    # 检查配置文件是否存在
    if [ -f "$CONFIG_FILE" ]; then
        echo ""
        print_message "$BLUE" "配置文件位置: $CONFIG_FILE"
        if [ "$is_reinstall" = true ]; then
            print_success "现有配置文件已保留，无需重新配置"
        else
            print_warning "请编辑配置文件，确保您的API密钥正确"
        fi
    fi
}

# 卸载函数
uninstall() {
    print_message "$BLUE" "开始卸载ccs..."
    
    # 删除整个.ccs目录（除了配置文件）
    if [ -d "$HOME/.ccs" ]; then
        # 删除脚本文件
        if [ -f "$HOME/.ccs/ccs.sh" ]; then
            rm -f "$HOME/.ccs/ccs.sh"
            print_success "删除bash脚本文件"
        fi
        
        if [ -f "$HOME/.ccs/ccs.fish" ]; then
            rm -f "$HOME/.ccs/ccs.fish"
            print_success "删除fish脚本文件"
        fi
        
        # 删除web文件
        if [ -d "$HOME/.ccs/web" ]; then
            rm -rf "$HOME/.ccs/web"
            print_success "删除web文件"
        fi
        
        # 检查.ccs目录是否为空（除了配置文件）
        local remaining_files=$(find "$HOME/.ccs" -type f ! -name "*.toml" | wc -l)
        if [ "$remaining_files" -eq 0 ]; then
            # 如果没有配置文件，删除整个目录
            if [ ! -f "$CONFIG_FILE" ]; then
                rm -rf "$HOME/.ccs"
                print_success "删除.ccs目录"
            else
                print_warning "保留.ccs目录（包含配置文件）"
            fi
        fi
    fi
    
    # 删除配置文件（询问用户）
    if [ -f "$CONFIG_FILE" ]; then
        printf "是否要删除配置文件 $CONFIG_FILE? (y/N): "
        read -r REPLY
        echo
        if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
            rm -f "$CONFIG_FILE"
            print_success "删除配置文件"
            # 如果删除了配置文件且.ccs目录为空，删除目录
            if [ -d "$HOME/.ccs" ] && [ -z "$(ls -A "$HOME/.ccs" 2>/dev/null)" ]; then
                rm -rf "$HOME/.ccs"
                print_success "删除空的.ccs目录"
            fi
        fi
    fi
    
    # 从所有shell配置文件中移除配置
    local removed_count=0
    
    # 处理bash配置
    if [ -f "$BASHRC_FILE" ]; then
        local temp_file=$(mktemp)
        # 移除ccs相关的配置块（从注释开始到EOF结束的整个块）
        awk '
        /^# Claude Code Configuration Switcher/ { skip=1; next }
        /^if \[ -f "\$HOME\/\.ccs\/ccs\.sh" \]/ { skip=1; next }
        /^fi$/ && skip { skip=0; next }
        !skip { print }
        ' "$BASHRC_FILE" > "$temp_file"
        
        # 检查是否有变化
        if ! cmp -s "$BASHRC_FILE" "$temp_file"; then
            mv "$temp_file" "$BASHRC_FILE"
            print_success "从 $BASHRC_FILE 中移除配置"
            removed_count=$((removed_count + 1))
        else
            rm -f "$temp_file"
        fi
    fi
    
    # 处理zsh配置
    if [ -f "$ZSHRC_FILE" ]; then
        local temp_file=$(mktemp)
        awk '
        /^# Claude Code Configuration Switcher/ { skip=1; next }
        /^if \[ -f "\$HOME\/\.ccs\/ccs\.sh" \]/ { skip=1; next }
        /^fi$/ && skip { skip=0; next }
        !skip { print }
        ' "$ZSHRC_FILE" > "$temp_file"
        
        if ! cmp -s "$ZSHRC_FILE" "$temp_file"; then
            mv "$temp_file" "$ZSHRC_FILE"
            print_success "从 $ZSHRC_FILE 中移除配置"
            removed_count=$((removed_count + 1))
        else
            rm -f "$temp_file"
        fi
    fi
    
    # 处理fish配置
    local fish_config="$HOME/.config/fish/config.fish"
    if [ -f "$fish_config" ]; then
        local temp_file=$(mktemp)
        awk '
        /^# Claude Code Configuration Switcher/ { skip=1; next }
        /^if test -f "\$HOME\/\.ccs\/ccs\.fish"/ { skip=1; next }
        /^end$/ && skip { skip=0; next }
        !skip { print }
        ' "$fish_config" > "$temp_file"
        
        if ! cmp -s "$fish_config" "$temp_file"; then
            mv "$temp_file" "$fish_config"
            print_success "从 $fish_config 中移除配置"
            removed_count=$((removed_count + 1))
        else
            rm -f "$temp_file"
        fi
    fi
    
    if [ "$removed_count" -gt 0 ]; then
        print_success "已从 $removed_count 个shell配置文件中移除ccs配置"
    else
        print_warning "未在shell配置文件中找到ccs配置"
    fi
    
    print_success "卸载完成！请重新启动终端或重新加载shell配置"
}

# 显示帮助
show_help() {
    echo "Claude Code Configuration Switcher 安装脚本"
    echo ""
    echo "用法:"
    echo "  $0                    - 安装ccs（如果已安装则更新脚本文件）"
    echo "  $0 --uninstall        - 卸载ccs"
    echo "  $0 --help             - 显示此帮助"
    echo ""
    echo "此脚本将:"
    echo "  1. 创建 $HOME/.ccs 目录"
    echo "  2. 复制/更新ccs.sh和ccs.fish脚本到 $HOME/.ccs/"
    echo "  3. 复制web文件到 $HOME/.ccs/web/"
    echo "  4. 创建配置文件 $HOME/.ccs_config.toml（如果不存在）"
    echo "  5. 配置shell环境"
    echo ""
    echo "重新安装行为:"
    echo "  - 强制更新所有shell脚本文件"
    echo "  - 保留现有配置文件不变"
    echo "  - 不重复添加shell配置"
    echo ""
    echo "注意: 配置文件一旦存在就不会被覆盖"
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
            # 检查是否为重新安装
            if check_installed; then
                print_message "$YELLOW" "检测到ccs已安装，开始更新..."
                echo ""
            else
                print_message "$BLUE" "开始安装Claude Code Configuration Switcher..."
                echo ""
            fi
            
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