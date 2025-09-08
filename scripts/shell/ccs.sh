#!/bin/bash

# Claude Code Configuration Switcher (ccs) - 主脚本 v2.0 优化版
# 此脚本用于快速切换不同的Claude Code API配置
# 优化特性: 缓存系统、性能提升、增强的错误处理

# 配置文件路径
CONFIG_FILE="$HOME/.ccs_config.toml"

# 加载通用工具库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/ccs-common.sh" ]]; then
    source "$SCRIPT_DIR/ccs-common.sh"
else
    echo "错误: 无法加载工具库 $SCRIPT_DIR/ccs-common.sh" >&2
    echo "请确保文件存在或重新安装CCS" >&2
    exit 1
fi

# 检查核心依赖
check_dependencies "grep" "sed" "awk" "cut" "optional:curl" "optional:wget"

# 检查配置文件是否存在（使用新的验证函数）
if [[ ! -f "$CONFIG_FILE" ]]; then
    handle_error $ERROR_CONFIG_MISSING "配置文件 $CONFIG_FILE 不存在,请先运行安装脚本来创建配置文件" "true"
fi

# 静默验证配置文件（不输出任何信息）
if [[ -f "$CONFIG_FILE" ]] && [[ -r "$CONFIG_FILE" ]]; then
    # 配置文件存在且可读，继续执行
    true
fi

# 更新配置文件中的当前配置
update_current_config() {
    local config_name="$1"
    
    log_debug "更新当前配置为: $config_name"
    
    # 创建临时文件
    local temp_file
    temp_file=$(create_temp_file "ccs_config_update")
    if [[ -z "$temp_file" ]]; then
        log_error "无法创建临时文件"
        return 1
    fi
    
    # 检查current_config字段是否存在
    if grep -q "^current_config" "$CONFIG_FILE"; then
        # 字段存在,执行替换
        log_debug "current_config字段存在,执行更新"
        if sed "s/^current_config *= *\"[^\"]*\"/current_config = \"$config_name\"/" "$CONFIG_FILE" > "$temp_file" && \
           sed -i "s/^current_config *= *'[^']*'/current_config = \"$config_name\"/" "$temp_file"; then
            
            # 验证更新是否成功
            local updated_config=$(grep "^current_config" "$temp_file" | cut -d'"' -f2 | cut -d"'" -f2)
            if [[ "$updated_config" == "$config_name" ]]; then
                if mv "$temp_file" "$CONFIG_FILE"; then
                    log_debug "配置文件已更新,当前配置: $config_name"
                    return 0
                else
                    log_error "无法保存配置文件"
                    rm -f "$temp_file"
                    return 1
                fi
            else
                log_error "配置文件更新验证失败"
                rm -f "$temp_file"
                return 1
            fi
        else
            log_error "配置文件更新失败"
            rm -f "$temp_file"
            return 1
        fi
    else
        # 字段不存在,自动修复：在文件开头添加current_config字段
        log_debug "current_config字段不存在,执行自动修复"
        
        # 获取默认配置名称作为初始值
        local default_config=$(grep "^default_config" "$CONFIG_FILE" | cut -d'"' -f2 | cut -d"'" -f2)
        if [[ -z "$default_config" ]]; then
            default_config="anyrouter"  # 回退到硬编码默认值
        fi
        
        # 创建修复后的配置文件
        {
            echo "# 当前使用的配置（自动添加）"
            echo "current_config = \"$config_name\""
            echo ""
            cat "$CONFIG_FILE"
        } > "$temp_file"
        
        # 验证修复结果
        local updated_config=$(grep "^current_config" "$temp_file" | cut -d'"' -f2 | cut -d"'" -f2)
        if [[ "$updated_config" == "$config_name" ]]; then
            if mv "$temp_file" "$CONFIG_FILE"; then
                log_info "配置文件已自动修复并更新,当前配置: $config_name"
                return 0
            else
                log_error "无法保存修复后的配置文件"
                rm -f "$temp_file"
                return 1
            fi
        else
            log_error "配置文件自动修复验证失败"
            rm -f "$temp_file"
            return 1
        fi
    fi
}

# 自动加载当前配置
load_current_config() {
    # 检查配置文件是否存在
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_debug "配置文件不存在,跳过自动加载"
        return 0
    fi
    
    # 获取当前配置
    local current_config=$(grep "^current_config" "$CONFIG_FILE" | cut -d'"' -f2 | cut -d"'" -f2)
    
    # 如果没有当前配置,尝试使用默认配置
    if [[ -z "$current_config" ]]; then
        current_config=$(grep "^default_config" "$CONFIG_FILE" | cut -d'"' -f2 | cut -d"'" -f2)
        log_debug "未找到当前配置,使用默认配置: $current_config"
    else
        log_debug "自动加载当前配置: $current_config"
    fi
    
    # 如果找到了配置,则加载它
    if [[ -n "$current_config" ]]; then
        # 检查配置是否存在
        if grep -q "^\[$current_config\]" "$CONFIG_FILE"; then
            parse_toml "$current_config" "silent"
        else
            log_warn "当前配置 '$current_config' 不存在,回退到默认配置"
            local default_config=$(grep "^default_config" "$CONFIG_FILE" | cut -d'"' -f2 | cut -d"'" -f2)
            if [[ -n "$default_config" ]] && grep -q "^\[$default_config\]" "$CONFIG_FILE"; then
                parse_toml "$default_config" "silent"
                # 更新current_config为默认配置
                update_current_config "$default_config"
            fi
        fi
    fi
}
# 帮助信息（优化版）
ccs_help() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}🔄 Claude Code Configuration Switcher (CCS) v2.0${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}📋 基本用法:${NC}"
    echo "  ccs [配置名称]          - 切换到指定配置"
    echo "  ccs list               - 列出所有可用配置"
    echo "  ccs current            - 显示当前配置状态"
    echo ""
    echo -e "${GREEN}🔧 管理命令:${NC}"
    echo "  ccs web                - 启动Web配置界面"
    echo "  ccs update             - 自动更新CCS到最新版本"
    echo "  ccs backup             - 备份当前配置文件"
    echo "  ccs verify             - 验证配置文件完整性"
    echo "  ccs clear-cache        - 清理配置缓存"
    echo "  ccs uninstall          - 卸载CCS工具"
    echo ""
    echo -e "${GREEN}ℹ️  信息命令:${NC}"
    echo "  ccs version            - 显示版本信息"
    echo "  ccs help               - 显示此帮助信息"
    echo ""
    echo -e "${GREEN}🔍 调试命令:${NC}"
    echo "  ccs --debug [命令]      - 启用调试模式运行命令"
    echo ""
    echo -e "${CYAN}💡 使用示例:${NC}"
    echo "  ccs anyrouter          - 切换到anyrouter配置"
    echo "  ccs glm                - 切换到智谱GLM配置"
    echo "  ccs list               - 查看所有可用配置"
    echo "  ccs current            - 查看当前配置状态"
    echo "  ccs web                - 打开图形化配置界面"
    echo "  ccs backup             - 备份配置文件"
    echo "  ccs --debug list       - 以调试模式列出配置"
    echo ""
    echo -e "${YELLOW}🔗 配置文件:${NC}"
    echo "  位置: ~/.ccs_config.toml"
    echo "  格式: TOML"
    echo "  示例: 参考 config/.ccs_config.toml.example"
    echo ""
    echo -e "${YELLOW}📝 新功能 (v2.0):${NC}"
    echo "  • 配置缓存系统 - 提升解析性能"
    echo "  • 增强的错误处理和诊断"
    echo "  • 配置文件完整性验证"
    echo "  • 自动备份和恢复系统"
    echo "  • 性能监控和调试模式"
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
}

# 显示版本信息
show_version() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local project_root="$(cd "$script_dir/../.." && pwd)"
    
    # 优先查找.ccs目录中的package.json,然后查找项目根目录
    local package_json="$HOME/.ccs/package.json"
    if [[ ! -f "$package_json" ]]; then
        package_json="$project_root/package.json"
    fi
    
    echo "🔄 Claude Code Configuration Switcher (CCS)"
    echo "═══════════════════════════════════════════════════════════════════════════════════"
    echo ""
    
    # 尝试从package.json读取版本信息
    if [[ -f "$package_json" ]]; then
        local version=$(grep '"version"' "$package_json" | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        local description=$(grep '"description"' "$package_json" | sed 's/.*"description"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        local author=$(grep '"author"' "$package_json" | sed 's/.*"author"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        local homepage=$(grep '"homepage"' "$package_json" | sed 's/.*"homepage"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        local license=$(grep '"license"' "$package_json" | sed 's/.*"license"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        
        echo "📦 基本信息:"
        if [[ -n "$version" ]]; then
            echo "   📌 版本: $version"
        else
            echo "   ⚠️  版本: 未知 (建议在package.json中补充version字段)"
        fi
        
        if [[ -n "$author" ]]; then
            echo "   👤 作者: $author"
        else
            echo "   ⚠️  作者: 未知 (建议在package.json中补充author字段)"
        fi
        
        echo ""
        echo "📝 项目描述:"
        if [[ -n "$description" ]]; then
            # 处理长描述,进行换行显示
            echo "$description" | fold -w 75 -s | sed 's/^/   /'
        else
            echo "   ⚠️  描述: 未知 (建议在package.json中补充description字段)"
        fi
        
        echo ""
        echo "🔗 项目链接:"
        if [[ -n "$homepage" ]]; then
            echo "   🌐 项目主页: $homepage"
        else
            echo "   🌐 项目主页: https://github.com/bahayonghang/ccs (默认)"
        fi
        
        if [[ -n "$license" ]]; then
            echo "   📄 许可证: $license"
        else
            echo "   📄 许可证: MIT (默认)"
        fi
        
        echo ""
        echo "📁 文件信息:"
        echo "   📍 配置文件路径: $package_json"
        echo "   ✅ 文件复制操作: 无需执行 (直接读取源文件)"
        
    else
        echo "⚠️  警告: 未找到package.json文件"
        echo "📍 预期路径: $package_json"
        echo ""
        echo "📦 使用默认信息:"
        echo "   📌 版本: 1.0.0"
        echo "   👤 作者: 未知"
        echo "   📝 描述: Claude Code Configuration Switcher - 多平台配置管理工具"
        echo "   🌐 项目主页: https://github.com/bahayonghang/ccs"
        echo "   📄 许可证: MIT"
        echo ""
        echo "💡 建议: 请确保package.json文件存在并包含完整的项目信息"
        echo "📁 文件复制操作: 未执行 (源文件不存在)"
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════════════"
    echo "🚀 感谢使用 CCS！如有问题请访问项目主页获取帮助。"
}

# 解析TOML配置文件（优化版，使用缓存）
parse_toml() {
    local config_name="$1"
    local silent_mode="$2"  # 如果为"silent",减少输出
    
    log_debug "解析配置: $config_name (模式: ${silent_mode:-normal})"
    
    # 使用高效解析器
    local config_content
    config_content=$(parse_toml_fast "$CONFIG_FILE" "$config_name")
    
    if [[ $? -ne 0 ]] || [[ -z "$config_content" ]]; then
        handle_error $ERROR_CONFIG_INVALID "配置 '$config_name' 不存在或为空"
    fi
    
    # 清理环境变量
    unset ANTHROPIC_BASE_URL ANTHROPIC_AUTH_TOKEN ANTHROPIC_MODEL ANTHROPIC_SMALL_FAST_MODEL
    
    # 使用关联数组优化解析
    declare -A config_vars
    while IFS='=' read -r key value; do
        # 清理键值对
        key=$(echo "$key" | tr -d ' ')
        # 去除末尾注释并进行值规范化（支持引号/单引号/反引号包裹以及外层空白）
        value=$(echo "$value" | sed 's/[[:space:]]#.*$//')
        value=$(normalize_config_value "$value")
        config_vars["$key"]="$value"
    done <<< "$config_content"
    
    # 设置环境变量
    local vars_set=0
    
    if [[ -n "${config_vars[base_url]}" ]]; then
        export ANTHROPIC_BASE_URL="${config_vars[base_url]}"
        ((vars_set++))
        [[ "$silent_mode" != "silent" ]] && print_success "设置 ANTHROPIC_BASE_URL=${config_vars[base_url]}"
    else
        log_warn "配置 '$config_name' 缺少 base_url"
    fi
    
    if [[ -n "${config_vars[auth_token]}" ]]; then
        export ANTHROPIC_AUTH_TOKEN="${config_vars[auth_token]}"
        ((vars_set++))
        [[ "$silent_mode" != "silent" ]] && print_success "设置 ANTHROPIC_AUTH_TOKEN=$(mask_sensitive_info "${config_vars[auth_token]}")"
    else
        log_warn "配置 '$config_name' 缺少 auth_token"
    fi
    
    if [[ -n "${config_vars[model]}" && "${config_vars[model]}" != "" ]]; then
        export ANTHROPIC_MODEL="${config_vars[model]}"
        ((vars_set++))
        [[ "$silent_mode" != "silent" ]] && print_success "设置 ANTHROPIC_MODEL=${config_vars[model]}"
    else
        [[ "$silent_mode" != "silent" ]] && log_info "配置 '$config_name' 使用默认模型"
    fi
    
    if [[ -n "${config_vars[small_fast_model]}" && "${config_vars[small_fast_model]}" != "" ]]; then
        export ANTHROPIC_SMALL_FAST_MODEL="${config_vars[small_fast_model]}"
        ((vars_set++))
        [[ "$silent_mode" != "silent" ]] && print_success "设置 ANTHROPIC_SMALL_FAST_MODEL=${config_vars[small_fast_model]}"
    fi
    
    if (( vars_set == 0 )); then
        handle_error $ERROR_CONFIG_INVALID "配置 '$config_name' 没有设置任何有效的环境变量"
    fi
    
    if [[ "$silent_mode" != "silent" ]]; then
        print_success "已切换到配置: $config_name ($vars_set 个变量已设置)"
        
        # 更新配置文件中的当前配置（非静默模式下才更新）
        update_current_config "$config_name"
    fi
}

# 列出所有可用配置（优化版）
list_configs() {
    print_step "扫描可用的配置..."
    echo ""
    
    # 使用高效方法提取所有配置节
    local configs
    configs=$(awk '/^\[.*\]/ { gsub(/\[|\]/, ""); print }' "$CONFIG_FILE")
    
    if [[ -z "$configs" ]]; then
        log_warn "未找到任何配置节"
        return 1
    fi
    
    # 获取当前配置
    local current_config
    current_config=$(grep "^current_config" "$CONFIG_FILE" | cut -d'"' -f2 | cut -d"'" -f2)
    
    # 计算最大长度用于对齐
    local max_length=0
    for config in $configs; do
        [[ "$config" != "default_config" ]] && (( ${#config} > max_length )) && max_length=${#config}
    done
    
    local config_count=0
    for config in $configs; do
        # 跳过内部配置
        [[ "$config" == "default_config" ]] && continue
        
        ((config_count++))
        
        # 获取配置描述
        local description
        description=$(parse_toml_fast "$CONFIG_FILE" "$config" | grep "^description" | cut -d'=' -f2- | sed 's/^[[:space:]]*["'\'']\(.*\)["'\'']*[[:space:]]*$/\1/')
        
        # 格式化输出
        local marker=" "
        local color="$NC"
        if [[ "$config" == "$current_config" ]]; then
            marker="▶"
            color="$GREEN"
        fi
        
        printf "${color}%s %-*s${NC}" "$marker" "$max_length" "$config"
        if [[ -n "$description" ]]; then
            echo " - $description"
        else
            echo " - (无描述)"
        fi
    done
    
    echo ""
    
    # 显示统计信息
    print_step "配置统计: $config_count 个配置可用"
    
    # 显示默认配置
    local default_config
    default_config=$(grep "^default_config" "$CONFIG_FILE" | cut -d'"' -f2 | cut -d"'" -f2)
    if [[ -n "$default_config" ]]; then
        echo "默认配置: $default_config"
    fi
    
    # 显示当前配置
    if [[ -n "$current_config" ]]; then
        echo "当前配置: ${GREEN}$current_config${NC}"
    else
        echo "当前配置: ${YELLOW}未设置${NC}"
    fi
}

# 显示当前配置（优化版）
show_current() {
    print_step "检查当前环境配置..."
    echo ""
    
    # 定义环境变量配置
    declare -A env_vars=(
        ["ANTHROPIC_BASE_URL"]="API端点"
        ["ANTHROPIC_AUTH_TOKEN"]="认证令牌"
        ["ANTHROPIC_MODEL"]="模型"
        ["ANTHROPIC_SMALL_FAST_MODEL"]="快速模型"
    )
    
    local vars_set=0
    local max_name_length=25
    
    # 显示环境变量状态
    for var_name in "${!env_vars[@]}"; do
        local var_value="${!var_name}"
        local description="${env_vars[$var_name]}"
        
        printf "  %-*s: " "$max_name_length" "$description"
        
        if [[ -n "$var_value" ]]; then
            ((vars_set++))
            if [[ "$var_name" == "ANTHROPIC_AUTH_TOKEN" ]]; then
                echo "${GREEN}$(mask_sensitive_info "$var_value")${NC}"
            else
                echo "${GREEN}$var_value${NC}"
            fi
        else
            echo "${YELLOW}(未设置)${NC}"
        fi
    done
    
    echo ""
    
    # 获取并显示配置文件中的当前配置
    local current_config
    current_config=$(grep "^current_config" "$CONFIG_FILE" | cut -d'"' -f2 | cut -d"'" -f2)
    
    if [[ -n "$current_config" ]]; then
        print_step "配置文件中的活跃配置: ${GREEN}$current_config${NC}"
    else
        print_warning "配置文件中未找到 current_config 字段"
    fi
    
    # 显示统计信息
    echo ""
    if (( vars_set > 0 )); then
        print_success "环境状态: $vars_set/4 个环境变量已设置"
    else
        print_warning "环境状态: 没有设置任何CCS环境变量"
        echo "建议运行: ccs <配置名称> 来设置配置"
    fi
    
    # 配置文件信息
    echo ""
    print_step "配置文件信息:"
    echo "  路径: $CONFIG_FILE"
    if [[ -f "$CONFIG_FILE" ]]; then
        local file_size
        file_size=$(stat -c%s "$CONFIG_FILE" 2>/dev/null || stat -f%z "$CONFIG_FILE" 2>/dev/null)
        local file_mtime
        file_mtime=$(stat -c%Y "$CONFIG_FILE" 2>/dev/null || stat -f%m "$CONFIG_FILE" 2>/dev/null)
        local modified_time
        modified_time=$(date -d "@$file_mtime" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -r "$file_mtime" '+%Y-%m-%d %H:%M:%S' 2>/dev/null)
        
        echo "  大小: $file_size 字节"
        echo "  修改时间: $modified_time"
        
        # 配置节统计
        local config_count
        config_count=$(grep -c "^\[.*\]" "$CONFIG_FILE")
        echo "  配置节数量: $config_count 个"
    else
        print_error "配置文件不存在"
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
            # 如果没有配置文件,删除整个目录
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
            # 如果删除了配置文件且.ccs目录为空,删除目录
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
    print_warning "注意：当前终端会话中的ccs函数仍然可用,直到重新启动终端"
}

# 打开web配置界面
open_web() {
    local web_dir="$HOME/.ccs/web"
    local web_path="$web_dir/index.html"
    
    if [[ ! -f "$web_path" ]]; then
        handle_error $ERROR_FILE_NOT_FOUND "web界面文件不存在,请重新运行安装脚本"
    fi
    
    # 检查是否在远程环境（WSL/SSH）
    if [[ -n "$WSL_DISTRO_NAME" ]] || [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
        # 远程环境,启动HTTP服务器
        local port=8888
        print_step "检测到远程环境,启动HTTP服务器..."
        
        # 检查端口是否被占用
        while netstat -ln 2>/dev/null | grep -q ":$port "; do
            port=$((port + 1))
        done
        
        # 复制用户配置文件到web目录,确保web页面能读取到正确的配置
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
        
        log_info "启动web服务器在端口 $port"
        log_info "请在浏览器中访问: http://localhost:$port"
        
        # 启动Python HTTP服务器
        if command_exists python3; then
            cd "$web_dir" && python3 -m http.server "$port"
        elif command_exists python; then
            cd "$web_dir" && python -m SimpleHTTPServer "$port"
        else
            handle_error $ERROR_FILE_NOT_FOUND "需要Python来启动HTTP服务器,请手动打开 $web_path"
        fi
    else
        # 本地环境,直接打开浏览器
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
            handle_error $ERROR_FILE_NOT_FOUND "无法找到可用的浏览器,请手动打开 $web_path"
        fi
    fi
}

# CCS自更新功能
ccs_update() {
    print_step "🔄 开始CCS自更新..."
    
    # 检查是否在CCS项目目录中
    local current_dir="$(pwd)"
    local install_script=""
    
    # 多路径检测安装脚本
    local possible_paths=(
        "./scripts/install/install.sh"          # 在项目根目录
        "../scripts/install/install.sh"         # 在子目录中
        "../../scripts/install/install.sh"      # 在更深的子目录中
        "$HOME/Documents/Github/ccs/scripts/install/install.sh"  # 默认路径
        "$HOME/.ccs/install.sh"                 # 备用路径
    )
    
    print_info "正在搜索安装脚本..."
    
    for path in "${possible_paths[@]}"; do
        if [[ -f "$path" ]]; then
            install_script="$path"
            print_success "找到安装脚本: $install_script"
            break
        fi
    done
    
    if [[ -z "$install_script" ]]; then
        print_error "❌ 未找到安装脚本！"
        print_info "请确保您在CCS项目目录中，或者手动运行安装脚本："
        print_info "  cd /path/to/ccs && ./scripts/install/install.sh"
        return 1
    fi
    
    # 备份当前配置
    print_step "📦 备份当前配置..."
    local backup_file
    backup_file=$(auto_backup "$CONFIG_FILE")
    if [[ $? -eq 0 ]]; then
        print_success "配置已备份: $backup_file"
    else
        print_warning "配置备份失败，但继续更新"
    fi
    
    # 执行安装脚本
    print_step "🚀 执行更新安装..."
    print_info "运行命令: $install_script"
    
    if bash "$install_script"; then
        print_success "✅ CCS更新完成！"
        print_info "更新内容："
        print_info "  • 脚本文件已更新到最新版本"
        print_info "  • Web界面文件已更新"
        print_info "  • 配置文件已保留"
        print_info "  • Shell环境配置已刷新"
        echo ""
        print_warning "⚠️  请重新启动终端或运行以下命令来应用更新："
        if [[ "$SHELL" == *"fish"* ]]; then
            print_info "  source ~/.config/fish/config.fish"
        elif [[ "$SHELL" == *"zsh"* ]]; then
            print_info "  source ~/.zshrc"
        else
            print_info "  source ~/.bashrc"
        fi
        echo ""
        print_step "🎉 感谢使用CCS！更新后请运行 'ccs version' 查看版本信息。"
    else
        print_error "❌ 更新失败！"
        print_info "如果问题持续存在，请："
        print_info "  1. 检查网络连接"
        print_info "  2. 确保有足够的磁盘空间"
        print_info "  3. 手动运行安装脚本"
        print_info "  4. 查看项目文档获取帮助"
        return 1
    fi
}

# 主函数（优化版）
ccs() {
    # 参数验证
    local command="${1:-}"
    local start_time
    start_time=$(date +%s.%N 2>/dev/null || date +%s)
    
    log_debug "CCS 主函数调用: 命令='$command', 参数个数=$#"
    
    # 检查配置文件完整性（只在需要时检查）
    if [[ "$command" != "help" && "$command" != "-h" && "$command" != "--help" && "$command" != "version" ]]; then
        if [[ ! -f "$CONFIG_FILE" ]]; then
            handle_error $ERROR_CONFIG_MISSING "配置文件 $CONFIG_FILE 不存在,请先运行安装脚本来创建配置文件" "true"
        fi
        
        if ! verify_config_integrity "$CONFIG_FILE" 2>/dev/null; then
            log_warn "配置文件完整性检查失败，尝试基本验证"
            if ! validate_config_file "$CONFIG_FILE"; then
                handle_error $ERROR_CONFIGURATION_CORRUPT "配置文件验证失败" "true"
            fi
        fi
    fi
    
    # 命令路由（优化的case结构）
    case "$command" in
        "ls"|"list")
            profile_function list_configs
            ;;
        "current"|"show"|"status")
            profile_function show_current
            ;;
        "web")
            if command_exists python3 || command_exists python; then
                profile_function open_web
            else
                handle_error $ERROR_DEPENDENCY_MISSING "启动Web界面需要Python支持" "true"
            fi
            ;;
        "version"|"-v"|"--version")
            profile_function show_version
            ;;
        "uninstall"|"remove")
            if ask_confirmation "确定要卸载CCS吗？这将删除所有脚本文件" "N"; then
                profile_function ccs_uninstall
            else
                print_step "取消卸载操作"
            fi
            ;;
        "help"|"-h"|"--help")
            profile_function ccs_help
            ;;
        "clear-cache"|"cache-clear")
            clear_all_cache
            print_success "配置缓存已清理"
            ;;
        "verify"|"check")
            log_info "验证配置文件完整性..."
            if verify_config_integrity "$CONFIG_FILE"; then
                print_success "配置文件验证通过"
            else
                handle_error $ERROR_CONFIGURATION_CORRUPT "配置文件验证失败"
            fi
            ;;
        "backup")
            local backup_file
            backup_file=$(auto_backup "$CONFIG_FILE")
            if [[ $? -eq 0 ]]; then
                print_success "配置文件已备份: $backup_file"
            else
                handle_error $ERROR_UNKNOWN "备份失败"
            fi
            ;;
        "update")
            profile_function ccs_update
            ;;
        "")
            # 如果没有参数,使用默认配置或当前配置
            local target_config
            target_config=$(grep "^current_config" "$CONFIG_FILE" | cut -d'"' -f2 | cut -d"'" -f2)
            
            if [[ -z "$target_config" ]]; then
                target_config=$(grep "^default_config" "$CONFIG_FILE" | cut -d'"' -f2 | cut -d"'" -f2)
            fi
            
            if [[ -n "$target_config" ]]; then
                log_info "使用配置: $target_config"
                profile_function parse_toml "$target_config"
            else
                handle_error $ERROR_CONFIG_INVALID "没有指定配置名称且没有默认配置" "true"
            fi
            ;;
        --debug)
            # 启用调试模式
            export CCS_LOG_LEVEL=$LOG_LEVEL_DEBUG
            log_info "调试模式已启用"
            shift
            ccs "$@"  # 递归调用处理剩余参数
            ;;
        --*)
            # 处理其他选项
            handle_error $ERROR_INVALID_ARGUMENT "未知选项: $command" "true"
            ;;
        *)
            # 指定的配置名称
            if [[ -n "$command" ]]; then
                # 验证配置名称是否存在
                if ! grep -q "^\[$command\]" "$CONFIG_FILE"; then
                    log_error "配置 '$command' 不存在"
                    echo ""
                    print_step "可用的配置:"
                    list_configs
                    exit $ERROR_CONFIG_INVALID
                fi
                
                profile_function parse_toml "$command"
            else
                handle_error $ERROR_INVALID_ARGUMENT "无效的参数" "true"
            fi
            ;;
    esac
    
    # 性能统计（仅在调试模式下）
    if [[ $CCS_LOG_LEVEL -le $LOG_LEVEL_DEBUG ]]; then
        local end_time
        end_time=$(date +%s.%N 2>/dev/null || date +%s)
        local duration
        if command -v bc >/dev/null 2>&1; then
            duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "unknown")
        else
            duration="unknown"
        fi
        log_debug "CCS 命令执行完成 (耗时: ${duration}s)"
    fi
}

# 如果直接运行此脚本（而不是source）,则执行主函数
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    ccs "$@"
else
    # 如果是被source的,自动加载当前配置（已禁用以避免启动时输出）
    # load_current_config
    true
fi