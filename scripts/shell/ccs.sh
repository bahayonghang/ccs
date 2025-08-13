#!/bin/bash

# Claude Code Configuration Switcher (ccs)
# 此函数用于切换不同的Claude Code API配置

# 配置文件路径
CONFIG_FILE="$HOME/.ccs_config.toml"

# 加载通用工具库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/ccs-common.sh" ]]; then
    source "$SCRIPT_DIR/ccs-common.sh"
else
    # 简单的错误处理，如果工具库不存在
    handle_error() {
        echo "错误: $1" >&2
        return "${2:-1}"
    }
fi

# 检查配置文件是否存在
if [[ ! -f "$CONFIG_FILE" ]]; then
    handle_error $ERROR_CONFIG_MISSING "配置文件 $CONFIG_FILE 不存在，请先运行安装脚本来创建配置文件" "true"
fi

# 验证配置文件
validate_config_file "$CONFIG_FILE"

# 显示帮助信息
ccs_help() {
    echo "Claude Code Configuration Switcher (ccs)"
    echo ""
    echo "用法:"
    echo "  ccs [配置名称]    - 切换到指定配置"
    echo "  ccs list          - 列出所有可用配置"
    echo "  ccs current       - 显示当前配置"
    echo "  ccs web           - 打开web配置界面"
    echo "  ccs uninstall     - 卸载ccs工具"
    echo "  ccs help          - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  ccs anyrouter     - 切换到anyrouter配置"
    echo "  ccs glm           - 切换到智谱GLM配置"
    echo "  ccs list          - 查看所有可用配置"
    echo "  ccs web           - 打开web配置界面"
    echo "  ccs uninstall     - 完全卸载ccs工具"
}

# 解析TOML配置文件
parse_toml() {
    local config_name="$1"
    
    log_debug "解析配置: $config_name"
    
    # 检查配置是否存在
    if ! grep -q "^\[$config_name\]" "$CONFIG_FILE"; then
        handle_error $ERROR_CONFIG_INVALID "配置 '$config_name' 不存在"
    fi
    
    # 获取配置节内容
    local config_content=$(sed -n "/^\[$config_name\]/,/^\[/p" "$CONFIG_FILE" | tail -n +2 | head -n -1 | grep -v "^#")
    
    if [[ -z "$config_content" ]]; then
        handle_error $ERROR_CONFIG_INVALID "配置 '$config_name' 内容为空"
    fi
    
    # 清理环境变量
    unset ANTHROPIC_BASE_URL
    unset ANTHROPIC_AUTH_TOKEN
    unset ANTHROPIC_MODEL
    unset ANTHROPIC_SMALL_FAST_MODEL
    
    # 解析配置项
    local base_url auth_token model small_fast_model
    
    # 提取base_url
    base_url=$(echo "$config_content" | grep "^base_url" | sed 's/.*base_url *= *"\([^"]*\)".*/\1/' | sed "s/.*base_url *= *'\([^']*\)'.*/\1/")
    if [[ -n "$base_url" ]]; then
        export ANTHROPIC_BASE_URL="$base_url"
        print_success "设置 ANTHROPIC_BASE_URL=$base_url"
    else
        log_warn "配置 '$config_name' 缺少 base_url"
    fi
    
    # 提取auth_token
    auth_token=$(echo "$config_content" | grep "^auth_token" | sed 's/.*auth_token *= *"\([^"]*\)".*/\1/' | sed "s/.*auth_token *= *'\([^']*\)'.*/\1/")
    if [[ -n "$auth_token" ]]; then
        export ANTHROPIC_AUTH_TOKEN="$auth_token"
        print_success "设置 ANTHROPIC_AUTH_TOKEN=$(mask_sensitive_info "$auth_token")"
    else
        log_warn "配置 '$config_name' 缺少 auth_token"
    fi
    
    # 提取model
    model=$(echo "$config_content" | grep "^model" | sed 's/.*model *= *"\([^"]*\)".*/\1/' | sed "s/.*model *= *'\([^']*\)'.*/\1/")
    if [[ -n "$model" ]]; then
        export ANTHROPIC_MODEL="$model"
        print_success "设置 ANTHROPIC_MODEL=$model"
    else
        log_warn "配置 '$config_name' 缺少 model"
    fi
    
    # 提取small_fast_model（可选）
    small_fast_model=$(echo "$config_content" | grep "^small_fast_model" | sed 's/.*small_fast_model *= *"\([^"]*\)".*/\1/' | sed "s/.*small_fast_model *= *'\([^']*\)'.*/\1/")
    if [[ -n "$small_fast_model" ]]; then
        export ANTHROPIC_SMALL_FAST_MODEL="$small_fast_model"
        print_success "设置 ANTHROPIC_SMALL_FAST_MODEL=$small_fast_model"
    fi
    
    print_success "已切换到配置: $config_name"
}

# 列出所有可用配置
list_configs() {
    echo "可用的配置:"
    echo ""
    
    # 提取所有配置节
    local configs=$(grep "^\[" "$CONFIG_FILE" | sed 's/\[\(.*\)\]/\1/')
    
    if [[ -z "$configs" ]]; then
        log_warn "未找到任何配置节"
        return 1
    fi
    
    for config in $configs; do
        # 跳过default_config
        if [[ "$config" == "default_config" ]]; then
            continue
        fi
        
        # 获取配置描述
        local description=$(sed -n "/^\[$config\]/,/^$/p" "$CONFIG_FILE" | grep "description" | cut -d'"' -f2 | cut -d"'" -f2)
        
        if [[ -n "$description" ]]; then
            echo "  $config - $description"
        else
            echo "  $config"
        fi
    done
    
    echo ""
    
    # 显示默认配置
    local default_config=$(grep "default_config" "$CONFIG_FILE" | cut -d'"' -f2 | cut -d"'" -f2)
    if [[ -n "$default_config" ]]; then
        echo "默认配置: $default_config"
    fi
}

# 显示当前配置
show_current() {
    echo "当前配置:"
    
    if [[ -n "$ANTHROPIC_BASE_URL" ]]; then
        echo "  ANTHROPIC_BASE_URL=$ANTHROPIC_BASE_URL"
    else
        echo "  ANTHROPIC_BASE_URL=(未设置)"
    fi
    
    if [[ -n "$ANTHROPIC_AUTH_TOKEN" ]]; then
        echo "  ANTHROPIC_AUTH_TOKEN=$(mask_sensitive_info "$ANTHROPIC_AUTH_TOKEN")"
    else
        echo "  ANTHROPIC_AUTH_TOKEN=(未设置)"
    fi
    
    if [[ -n "$ANTHROPIC_MODEL" ]]; then
        echo "  ANTHROPIC_MODEL=$ANTHROPIC_MODEL"
    else
        echo "  ANTHROPIC_MODEL=(未设置)"
    fi
    
    if [[ -n "$ANTHROPIC_SMALL_FAST_MODEL" ]]; then
        echo "  ANTHROPIC_SMALL_FAST_MODEL=$ANTHROPIC_SMALL_FAST_MODEL"
    else
        echo "  ANTHROPIC_SMALL_FAST_MODEL=(未设置)"
    fi
}

# 卸载ccs工具
ccs_uninstall() {
    print_message "$BLUE" "正在卸载Claude Code Configuration Switcher..."
    echo ""
    
    print_step "开始卸载ccs..."
    
    # 创建备份
    if [[ -f "$CONFIG_FILE" ]]; then
        local backup_file
        backup_file=$(backup_file "$CONFIG_FILE" "$HOME/.ccs/backups")
        if [[ -n "$backup_file" ]]; then
            log_info "已备份配置文件: $backup_file"
        fi
    fi
    
    # 删除整个.ccs目录（除了配置文件）
    if [[ -d "$HOME/.ccs" ]]; then
        # 删除脚本文件
        if [[ -f "$HOME/.ccs/ccs.sh" ]]; then
            rm -f "$HOME/.ccs/ccs.sh"
            print_success "删除bash脚本文件"
        fi
        
        if [[ -f "$HOME/.ccs/ccs.fish" ]]; then
            rm -f "$HOME/.ccs/ccs.fish"
            print_success "删除fish脚本文件"
        fi
        
        # 删除web文件
        if [[ -d "$HOME/.ccs/web" ]]; then
            rm -rf "$HOME/.ccs/web"
            print_success "删除web文件"
        fi
        
        # 删除通用工具库
        if [[ -f "$HOME/.ccs/ccs-common.sh" ]]; then
            rm -f "$HOME/.ccs/ccs-common.sh"
            print_success "删除通用工具库文件"
        fi
        
        # 检查.ccs目录是否为空（除了配置文件）
        local remaining_files=$(find "$HOME/.ccs" -type f ! -name "*.toml" 2>/dev/null | wc -l)
        if [[ "$remaining_files" -eq 0 ]]; then
            # 如果没有配置文件，删除整个目录
            if [[ ! -f "$CONFIG_FILE" ]]; then
                rm -rf "$HOME/.ccs"
                print_success "删除.ccs目录"
            else
                print_warning "保留.ccs目录（包含配置文件）"
            fi
        fi
    fi
    
    # 删除配置文件（询问用户）
    if [[ -f "$CONFIG_FILE" ]]; then
        if ask_confirmation "是否要删除配置文件 $CONFIG_FILE" "N"; then
            rm -f "$CONFIG_FILE"
            print_success "删除配置文件"
            # 如果删除了配置文件且.ccs目录为空，删除目录
            if [[ -d "$HOME/.ccs" ]] && [[ -z "$(ls -A "$HOME/.ccs" 2>/dev/null)" ]]; then
                rm -rf "$HOME/.ccs"
                print_success "删除空的.ccs目录"
            fi
        fi
    fi
    
    # 从所有shell配置文件中移除配置
    local removed_count=0
    local BASHRC_FILE="$HOME/.bashrc"
    local ZSHRC_FILE="$HOME/.zshrc"
    
    # 处理bash配置
    if [[ -f "$BASHRC_FILE" ]]; then
        local temp_file
        temp_file=$(create_temp_file "ccs_bashrc")
        if [[ -n "$temp_file" ]]; then
            # 移除ccs相关的配置块
            awk '
            /^# Claude Code Configuration Switcher/ { skip=1; next }
            /^if \[ -f "\$HOME\/\.ccs\/ccs\.sh" \]/ { skip=1; next }
            /^fi$/ && skip { skip=0; next }
            !skip { print }
            ' "$BASHRC_FILE" > "$temp_file"
            
            # 检查是否有变化
            if ! cmp -s "$BASHRC_FILE" "$temp_file"; then
                if mv "$temp_file" "$BASHRC_FILE"; then
                    print_success "从 $BASHRC_FILE 中移除配置"
                    removed_count=$((removed_count + 1))
                else
                    log_error "无法更新 $BASHRC_FILE"
                fi
            else
                rm -f "$temp_file"
            fi
        fi
    fi
    
    # 处理zsh配置
    if [[ -f "$ZSHRC_FILE" ]]; then
        local temp_file
        temp_file=$(create_temp_file "ccs_zshrc")
        if [[ -n "$temp_file" ]]; then
            awk '
            /^# Claude Code Configuration Switcher/ { skip=1; next }
            /^if \[ -f "\$HOME\/\.ccs\/ccs\.sh" \]/ { skip=1; next }
            /^fi$/ && skip { skip=0; next }
            !skip { print }
            ' "$ZSHRC_FILE" > "$temp_file"
            
            if ! cmp -s "$ZSHRC_FILE" "$temp_file"; then
                if mv "$temp_file" "$ZSHRC_FILE"; then
                    print_success "从 $ZSHRC_FILE 中移除配置"
                    removed_count=$((removed_count + 1))
                else
                    log_error "无法更新 $ZSHRC_FILE"
                fi
            else
                rm -f "$temp_file"
            fi
        fi
    fi
    
    # 处理fish配置
    local fish_config="$HOME/.config/fish/config.fish"
    if [[ -f "$fish_config" ]]; then
        local temp_file
        temp_file=$(create_temp_file "ccs_fish")
        if [[ -n "$temp_file" ]]; then
            awk '
            /^# Claude Code Configuration Switcher/ { skip=1; next }
            /^if test -f "\$HOME\/\.ccs\/ccs\.fish"/ { skip=1; next }
            /^end$/ && skip { skip=0; next }
            !skip { print }
            ' "$fish_config" > "$temp_file"
            
            if ! cmp -s "$fish_config" "$temp_file"; then
                if mv "$temp_file" "$fish_config"; then
                    print_success "从 $fish_config 中移除配置"
                    removed_count=$((removed_count + 1))
                else
                    log_error "无法更新 $fish_config"
                fi
            else
                rm -f "$temp_file"
            fi
        fi
    fi
    
    if [[ "$removed_count" -gt 0 ]]; then
        print_success "已从 $removed_count 个shell配置文件中移除ccs配置"
    else
        print_warning "未在shell配置文件中找到ccs配置"
    fi
    
    # 清理临时文件
    cleanup_temp_files
    
    print_success "卸载完成！请重新启动终端或重新加载shell配置"
    echo ""
    print_warning "注意：当前终端会话中的ccs函数仍然可用，直到重新启动终端"
}

# 打开web配置界面
open_web() {
    local web_dir="$HOME/.ccs/web"
    local web_path="$web_dir/index.html"
    
    if [[ ! -f "$web_path" ]]; then
        handle_error $ERROR_FILE_NOT_FOUND "web界面文件不存在，请重新运行安装脚本"
    fi
    
    # 检查是否在远程环境（WSL/SSH）
    if [[ -n "$WSL_DISTRO_NAME" ]] || [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
        # 远程环境，启动HTTP服务器
        local port=8888
        print_step "检测到远程环境，启动HTTP服务器..."
        
        # 检查端口是否被占用
        while netstat -ln 2>/dev/null | grep -q ":$port "; do
            port=$((port + 1))
        done
        
        # 复制用户配置文件到web目录，确保web页面能读取到正确的配置
        local user_config="$HOME/.ccs_config.toml"
        if [[ -f "$user_config" ]]; then
            if cp "$user_config" "$web_dir/.ccs_config.toml"; then
                print_success "已复制用户配置文件到web目录"
            else
                log_warn "无法复制配置文件到web目录"
            fi
        else
            log_warn "未找到用户配置文件 $user_config"
        fi
        
        print_info "启动web服务器在端口 $port"
        print_info "请在浏览器中访问: http://localhost:$port"
        
        # 启动Python HTTP服务器
        if command_exists python3; then
            cd "$web_dir" && python3 -m http.server "$port"
        elif command_exists python; then
            cd "$web_dir" && python -m SimpleHTTPServer "$port"
        else
            handle_error $ERROR_FILE_NOT_FOUND "需要Python来启动HTTP服务器，请手动打开 $web_path"
        fi
    else
        # 本地环境，直接打开浏览器
        local browser_found=false
        
        if command_exists xdg-open; then
            xdg-open "$web_path"
            browser_found=true
        elif command_exists open; then
            open "$web_path"
            browser_found=true
        elif command_exists google-chrome; then
            google-chrome "$web_path"
            browser_found=true
        elif command_exists firefox; then
            firefox "$web_path"
            browser_found=true
        elif command_exists safari; then
            safari "$web_path"
            browser_found=true
        fi
        
        if [[ "$browser_found" == "true" ]]; then
            print_success "正在打开web配置界面..."
        else
            handle_error $ERROR_FILE_NOT_FOUND "无法找到可用的浏览器，请手动打开 $web_path"
        fi
    fi
}

# 主函数
ccs() {
    # 验证配置文件是否存在
    if [[ ! -f "$CONFIG_FILE" ]]; then
        handle_error $ERROR_CONFIG_MISSING "配置文件 $CONFIG_FILE 不存在，请先运行安装脚本来创建配置文件" "true"
    fi
    
    # 验证配置文件
    validate_config_file "$CONFIG_FILE"
    
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
        "uninstall")
            ccs_uninstall
            ;;
        "help"|"-h"|"--help")
            ccs_help
            ;;
        "")
            # 如果没有参数，使用默认配置
            local default_config=$(grep "default_config" "$CONFIG_FILE" | cut -d'"' -f2 | cut -d"'" -f2)
            if [[ -n "$default_config" ]]; then
                parse_toml "$default_config"
            else
                handle_error $ERROR_CONFIG_INVALID "没有指定配置名称且没有默认配置" "true"
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