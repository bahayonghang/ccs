#!/bin/bash

# CCS (Claude Code Configuration Switcher) 本地测试安装脚本
# 用于测试本地修复的安装脚本

set -e

# 颜色输出
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

# 打印消息函数
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

# 主安装函数
main() {
    print_message "$BLUE" "开始本地测试安装 Claude Code Configuration Switcher..."
    echo ""
    
    # 创建临时目录
    local temp_dir=$(mktemp -d)
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    
    print_message "$BLUE" "复制本地安装文件..."
    
    # 复制本地文件到临时目录
    cp "$script_dir/../install.sh" "$temp_dir/install.sh"
    cp "$script_dir/../../shell/ccs.sh" "$temp_dir/ccs.sh"
    cp "$script_dir/../../shell/ccs.fish" "$temp_dir/ccs.fish"
    cp "$script_dir/../../shell/ccs-common.sh" "$temp_dir/ccs-common.sh"
    
    print_success "复制本地文件完成"
    
    # 创建示例配置文件
    print_message "$BLUE" "创建示例配置文件..."
    cat > "$temp_dir/.ccs_config.toml.example" << 'EOF'
# Claude Code Configuration Switcher 配置文件
# 请根据需要修改以下配置

# 默认使用的配置名称
default_config = "siliconflow"

# SiliconFlow 配置（推荐）
[siliconflow]
base_url = "https://api.siliconflow.cn/v1"
auth_token = "sk-your-siliconflow-api-key-here"
model = "anthropic/claude-3-5-sonnet-20241022"
EOF
    print_success "创建示例配置文件完成"
    
    # 设置权限
    chmod +x "$temp_dir/install.sh"
    chmod +x "$temp_dir/ccs.sh" 
    chmod +x "$temp_dir/ccs.fish"
    chmod +x "$temp_dir/ccs-common.sh"
    
    # 切换到临时目录并运行安装脚本
    print_message "$BLUE" "运行安装脚本..."
    echo ""
    cd "$temp_dir"
    
    # 运行安装
    if ./install.sh; then
        print_success "安装完成！"
        echo ""
        print_message "$BLUE" "下一步操作："
        echo "1. 重新启动终端或运行以下命令之一："
        echo "   source ~/.bashrc"
        echo "   source ~/.zshrc" 
        echo "   source ~/.config/fish/config.fish"
        echo ""
        echo "2. 编辑配置文件："
        echo "   nano ~/.ccs_config.toml"
        echo "   或"
        echo "   vim ~/.ccs_config.toml"
        echo ""
        echo "3. 填入您的API密钥后，开始使用："
        echo "   ccs list        # 查看所有配置"
        echo "   ccs [配置名]    # 切换配置"
        echo "   ccs current     # 查看当前配置"
        echo ""
        print_warning "请务必编辑配置文件并填入正确的API密钥！"
    else
        print_error "安装失败"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # 清理临时文件
    rm -rf "$temp_dir"
    
    print_success "CCS 本地测试安装完成！"
    echo ""
    print_message "$BLUE" "项目地址: https://github.com/bahayonghang/ccs"
    print_message "$BLUE" "如有问题请提交Issue或PR"
}

# 运行主函数
main "$@"