#!/bin/bash

# CCS (Claude Code Configuration Switcher) 一键安装脚本
# GitHub: https://github.com/bahayonghang/ccs
# 用法: curl -L https://github.com/bahayonghang/ccs/raw/main/quick_install.sh | bash

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

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 下载文件
download_file() {
    local url="$1"
    local output="$2"
    
    if command_exists curl; then
        curl -fsSL "$url" -o "$output"
    elif command_exists wget; then
        wget -q "$url" -O "$output"
    else
        print_error "需要 curl 或 wget 来下载文件"
        return 1
    fi
}

# 主安装函数
main() {
    print_message "$BLUE" "开始一键安装 Claude Code Configuration Switcher..."
    echo ""
    
    # 检查必要的命令
    if ! command_exists curl && ! command_exists wget; then
        print_error "请安装 curl 或 wget"
        exit 1
    fi
    
    # 创建临时目录
    local temp_dir=$(mktemp -d)
    local repo_url="https://github.com/bahayonghang/ccs/raw/main"
    
    print_message "$BLUE" "下载安装文件..."
    
    # 下载必要文件
    local files=(
        "scripts/install/install.sh"
        "scripts/shell/ccs.sh"
        "scripts/shell/ccs.fish"
        "scripts/shell/ccs-common.sh"
        "package.json"
    )
    
    for file in "${files[@]}"; do
        print_message "$BLUE" "下载 $file..."
        if ! download_file "$repo_url/$file" "$temp_dir/$(basename $file)"; then
            print_error "下载 $file 失败"
            rm -rf "$temp_dir"
            exit 1
        fi
        print_success "下载 $file 完成"
    done
    
    # 创建示例配置文件
    print_message "$BLUE" "创建示例配置文件..."
    cat > "$temp_dir/.ccs_config.toml.example" << 'EOF'
# Claude Code Configuration Switcher 配置文件
# 请根据您的需要修改以下配置

default_config = "anyrouter"

[anyrouter]
description = "AnyRouter API服务"
base_url = "https://anyrouter.top"
auth_token = "sk-your-anyrouter-api-key-here"
model = "claude-3-5-sonnet-20241022"

[glm]
description = "智谱GLM API服务"
base_url = "https://open.bigmodel.cn/api/paas/v4"
auth_token = "your-glm-api-key-here"
model = "glm-4"

[anthropic]
description = "Anthropic官方API"
base_url = "https://api.anthropic.com"
auth_token = "sk-ant-your-api-key-here"
model = "claude-3-5-sonnet-20241022"

[openai]
description = "OpenAI API配置"
base_url = "https://api.openai.com/v1"
auth_token = "sk-your-openai-api-key-here"
model = "gpt-4"

[aicodemirror]
description = "AICodeMirror API服务"
base_url = "https://aicodemirror.com/api"
auth_token = "your-aicodemirror-api-key-here"
model = "claude-3-5-sonnet-20241022"

[wenwen]
description = "文文AI API服务"
base_url = "https://api.wenwen.ai"
auth_token = "your-wenwen-api-key-here"
model = "claude-3-5-sonnet-20241022"

[moonshot]
description = "月之暗面API服务"
base_url = "https://api.moonshot.cn/v1"
auth_token = "sk-your-moonshot-api-key-here"
model = "moonshot-v1-8k"

[siliconflow]
description = "SiliconFlow API服务"
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
        echo "3. 填入您的API密钥后,开始使用："
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
    
    print_success "CCS 一键安装完成！感谢使用！"
    echo ""
    print_message "$BLUE" "项目地址: https://github.com/bahayonghang/ccs"
    print_message "$BLUE" "如有问题请提交Issue或PR"
}

# 运行主函数
main "$@"