#!/bin/bash

# Claude Code Configuration Switcher (ccs)
# 此函数用于切换不同的Claude Code API配置

# 配置文件路径
CONFIG_FILE="$HOME/.ccs_config.toml"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误: 配置文件 $CONFIG_FILE 不存在"
    echo "请先运行安装脚本来创建配置文件"
    return 1
fi

# 显示帮助信息
ccs_help() {
    echo "Claude Code Configuration Switcher (ccs)"
    echo ""
    echo "用法:"
    echo "  ccs [配置名称]    - 切换到指定配置"
    echo "  ccs list          - 列出所有可用配置"
    echo "  ccs current       - 显示当前配置"
    echo "  ccs web           - 打开web配置界面"
    echo "  ccs help          - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  ccs anyrouter     - 切换到anyrouter配置"
    echo "  ccs glm           - 切换到智谱GLM配置"
    echo "  ccs list          - 查看所有可用配置"
    echo "  ccs web           - 打开web配置界面"
}

# 解析TOML配置文件
parse_toml() {
    local config_name="$1"
    local config_content=$(sed -n "/^\[$config_name\]/,/^\[/p" "$CONFIG_FILE" | tail -n +2 | head -n -1 | grep -v "^#")
    
    if [ -z "$config_content" ]; then
        echo "错误: 配置 '$config_name' 不存在"
        return 1
    fi
    
    # 清理环境变量
    unset ANTHROPIC_BASE_URL
    unset ANTHROPIC_AUTH_TOKEN
    unset ANTHROPIC_MODEL
    unset ANTHROPIC_SMALL_FAST_MODEL
    
    # 提取base_url
    local base_url_line=$(echo "$config_content" | grep "^base_url")
    if [ -n "$base_url_line" ]; then
        local base_url=$(echo "$base_url_line" | sed 's/.*base_url *= *"\([^"]*\)".*/\1/' | sed "s/.*base_url *= *'\([^']*\)'.*/\1/")
        if [ -n "$base_url" ]; then
            export ANTHROPIC_BASE_URL="$base_url"
            echo "设置 ANTHROPIC_BASE_URL=$base_url"
        fi
    fi
    
    
    # 提取auth_token
    local auth_token_line=$(echo "$config_content" | grep "^auth_token")
    if [ -n "$auth_token_line" ]; then
        local auth_token=$(echo "$auth_token_line" | sed 's/.*auth_token *= *"\([^"]*\)".*/\1/' | sed "s/.*auth_token *= *'\([^']*\)'.*/\1/")
        if [ -n "$auth_token" ]; then
            export ANTHROPIC_AUTH_TOKEN="$auth_token"
            echo "设置 ANTHROPIC_AUTH_TOKEN=${auth_token:0:10}..."
        fi
    fi
    
    # 提取model
    local model_line=$(echo "$config_content" | grep "^model")
    if [ -n "$model_line" ]; then
        local model=$(echo "$model_line" | sed 's/.*model *= *"\([^"]*\)".*/\1/' | sed "s/.*model *= *'\([^']*\)'.*/\1/")
        if [ -n "$model" ]; then
            export ANTHROPIC_MODEL="$model"
            echo "设置 ANTHROPIC_MODEL=$model"
        fi
    fi
    
    # 提取small_fast_model
    local small_fast_model_line=$(echo "$config_content" | grep "^small_fast_model")
    if [ -n "$small_fast_model_line" ]; then
        local small_fast_model=$(echo "$small_fast_model_line" | sed 's/.*small_fast_model *= *"\([^"]*\)".*/\1/' | sed "s/.*small_fast_model *= *'\([^']*\)'.*/\1/")
        if [ -n "$small_fast_model" ]; then
            export ANTHROPIC_SMALL_FAST_MODEL="$small_fast_model"
            echo "设置 ANTHROPIC_SMALL_FAST_MODEL=$small_fast_model"
        fi
    fi
    
    echo "已切换到配置: $config_name"
}

# 列出所有可用配置
list_configs() {
    echo "可用的配置:"
    echo ""
    
    # 提取所有配置节
    local configs=$(grep "^\[" "$CONFIG_FILE" | sed 's/\[\(.*\)\]/\1/')
    
    for config in $configs; do
        # 跳过default_config
        if [ "$config" = "default_config" ]; then
            continue
        fi
        
        # 获取配置描述
        local description=$(sed -n "/^\[$config\]/,/^$/p" "$CONFIG_FILE" | grep "description" | cut -d'"' -f2 | cut -d"'" -f2)
        
        if [ -n "$description" ]; then
            echo "  $config - $description"
        else
            echo "  $config"
        fi
    done
    
    echo ""
    
    # 显示默认配置
    local default_config=$(grep "default_config" "$CONFIG_FILE" | cut -d'"' -f2 | cut -d"'" -f2)
    if [ -n "$default_config" ]; then
        echo "默认配置: $default_config"
    fi
}

# 显示当前配置
show_current() {
    echo "当前配置:"
    
    if [ -n "$ANTHROPIC_BASE_URL" ]; then
        echo "  ANTHROPIC_BASE_URL=$ANTHROPIC_BASE_URL"
    else
        echo "  ANTHROPIC_BASE_URL=(未设置)"
    fi
    
    
    if [ -n "$ANTHROPIC_AUTH_TOKEN" ]; then
        echo "  ANTHROPIC_AUTH_TOKEN=${ANTHROPIC_AUTH_TOKEN:0:10}..."
    else
        echo "  ANTHROPIC_AUTH_TOKEN=(未设置)"
    fi
    
    if [ -n "$ANTHROPIC_MODEL" ]; then
        echo "  ANTHROPIC_MODEL=$ANTHROPIC_MODEL"
    else
        echo "  ANTHROPIC_MODEL=(未设置)"
    fi
    
    if [ -n "$ANTHROPIC_SMALL_FAST_MODEL" ]; then
        echo "  ANTHROPIC_SMALL_FAST_MODEL=$ANTHROPIC_SMALL_FAST_MODEL"
    else
        echo "  ANTHROPIC_SMALL_FAST_MODEL=(未设置)"
    fi
}

# 打开web配置界面
open_web() {
    local web_dir="$HOME/.ccs/web"
    local web_path="$web_dir/index.html"
    
    if [ ! -f "$web_path" ]; then
        echo "错误: web界面文件不存在，请重新运行安装脚本"
        return 1
    fi
    
    # 检查是否在远程环境（WSL/SSH）
    if [ -n "$WSL_DISTRO_NAME" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        # 远程环境，启动HTTP服务器
        local port=8888
        echo "检测到远程环境，启动HTTP服务器..."
        
        # 检查端口是否被占用
        while netstat -ln 2>/dev/null | grep -q ":$port "; do
            port=$((port + 1))
        done
        
        # 复制用户配置文件到web目录，确保web页面能读取到正确的配置
        local user_config="$HOME/.ccs_config.toml"
        if [ -f "$user_config" ]; then
            cp "$user_config" "$web_dir/.ccs_config.toml"
            echo "已复制用户配置文件到web目录"
        else
            echo "警告: 未找到用户配置文件 $user_config"
        fi
        
        echo "启动web服务器在端口 $port"
        echo "请在浏览器中访问: http://localhost:$port"
        
        # 启动Python HTTP服务器
        if command -v python3 >/dev/null 2>&1; then
            cd "$web_dir" && python3 -m http.server $port
        elif command -v python >/dev/null 2>&1; then
            cd "$web_dir" && python -m SimpleHTTPServer $port
        else
            echo "错误: 需要Python来启动HTTP服务器"
            echo "请手动打开 $web_path"
            return 1
        fi
    else
        # 本地环境，直接打开浏览器
        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$web_path"
        elif command -v open >/dev/null 2>&1; then
            open "$web_path"
        elif command -v google-chrome >/dev/null 2>&1; then
            google-chrome "$web_path"
        elif command -v firefox >/dev/null 2>&1; then
            firefox "$web_path"
        elif command -v safari >/dev/null 2>&1; then
            safari "$web_path"
        else
            echo "错误: 无法找到可用的浏览器"
            echo "请手动打开 $web_path"
            return 1
        fi
        echo "正在打开web配置界面..."
    fi
}

# 主函数
ccs() {
    case "${1:-}" in
        "list")
            list_configs
            ;;
        "current")
            show_current
            ;;
        "web")
            open_web
            ;;
        "help"|"-h"|"--help")
            ccs_help
            ;;
        "")
            # 如果没有参数，使用默认配置
            local default_config=$(grep "default_config" "$CONFIG_FILE" | cut -d'"' -f2 | cut -d"'" -f2)
            if [ -n "$default_config" ]; then
                parse_toml "$default_config"
            else
                echo "错误: 没有指定配置名称且没有默认配置"
                ccs_help
                return 1
            fi
            ;;
        *)
            parse_toml "$1"
            ;;
    esac
}

# 如果直接运行此脚本（而不是source），则执行主函数
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    ccs "$@"
fi