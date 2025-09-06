# Claude Code Configuration Switcher (ccs) - Fish Shell v2.0 优化版
# 此脚本用于在Fish Shell中快速切换不同的Claude Code API配置
# 优化特性: 简化代码、提升性能、增强错误处理

set -g CONFIG_FILE "$HOME/.ccs_config.toml"
set -g CCS_VERSION "2.0.0"

# 日志函数
function _ccs_log_error
    echo -e "\033[0;31m[ERROR]\033[0m $argv" >&2
end

function _ccs_log_warn  
    echo -e "\033[1;33m[WARN]\033[0m $argv" >&2
end

function _ccs_log_info
    echo -e "\033[0;34m[INFO]\033[0m $argv" >&2
end

function _ccs_log_success
    echo -e "\033[0;32m[✓]\033[0m $argv"
end

function _ccs_print_step
    echo -e "\033[0;36m[→]\033[0m $argv"
end

# 检查配置文件是否存在
function _ccs_check_config_file
    if not test -f $CONFIG_FILE
        _ccs_log_error "配置文件不存在: $CONFIG_FILE"
        _ccs_log_info "请先运行安装脚本创建配置文件"
        return 1
    end
    return 0
end

# 验证配置节是否存在
function _ccs_validate_config --argument config_name
    if not grep -q "^\[$config_name\]" $CONFIG_FILE
        _ccs_log_error "配置 '$config_name' 不存在"
        return 1
    end
    return 0
end

# 高效解析配置节（使用awk）
function _ccs_parse_config_section --argument config_name
    awk -v section="$config_name" '
        BEGIN { in_section = 0 }
        /^\[.*\]/ { 
            if ($0 == "[" section "]") { 
                in_section = 1 
            } else { 
                in_section = 0 
            }
            next
        }
        in_section && /^[^#]/ && NF > 0 { 
            gsub(/^[ \t]+|[ \t]+$/, ""); 
            print 
        }
    ' $CONFIG_FILE
end

# 从配置内容中提取值
function _ccs_extract_value --argument key content
    echo $content | string match -r "^$key\s*=\s*(.*)" | string replace -r "^$key\s*=\s*[\"']?([^\"']*)[\"']?.*" '$1'
end

# 更新当前配置
function _ccs_update_current_config --argument config_name
    set temp_file (mktemp)
    
    if grep -q "^current_config" $CONFIG_FILE
        sed "s/^current_config\s*=.*/current_config = \"$config_name\"/" $CONFIG_FILE > $temp_file
    else
        echo "# 当前激活配置" > $temp_file
        echo "current_config = \"$config_name\"" >> $temp_file
        echo "" >> $temp_file
        cat $CONFIG_FILE >> $temp_file
    end
    
    mv $temp_file $CONFIG_FILE
    _ccs_log_info "已更新当前配置: $config_name"
end

# 设置环境变量
function _ccs_set_env_vars --argument config_name
    # 严格以换行分割，保留每一行原样，避免 echo 导致换行丢失
    set -l config_lines (string split -n \n -- (_ccs_parse_config_section $config_name))
    
    if test (count $config_lines) -eq 0
        _ccs_log_error "配置 '$config_name' 内容为空"
        return 1
    end
    
    # 清理现有环境变量
    set -e ANTHROPIC_BASE_URL ANTHROPIC_AUTH_TOKEN ANTHROPIC_MODEL ANTHROPIC_SMALL_FAST_MODEL
    
    set -l vars_set 0
    
    # 解析并设置环境变量（逐行）
    for line in $config_lines
        set line (string trim -- $line)
        if string match -rq "^base_url\s*=" -- $line
            set base_url (echo $line | string replace -r ".*=\s*[\"']?([^\"']*)[\"']?" '$1')
            if test -n "$base_url"
                set -gx ANTHROPIC_BASE_URL $base_url
                _ccs_log_success "设置 ANTHROPIC_BASE_URL=$base_url"
                set vars_set (math $vars_set + 1)
            end
        else if string match -rq "^auth_token\s*=" -- $line
            set auth_token (echo $line | string replace -r ".*=\s*[\"']?([^\"']*)[\"']?" '$1')
            if test -n "$auth_token"
                set -gx ANTHROPIC_AUTH_TOKEN $auth_token
                set masked_token (string sub -l 10 $auth_token)...
                _ccs_log_success "设置 ANTHROPIC_AUTH_TOKEN=$masked_token"
                set vars_set (math $vars_set + 1)
            end
        else if string match -rq "^model\s*=" -- $line
            set model (echo $line | string replace -r ".*=\s*[\"']?([^\"']*)[\"']?" '$1')
            if test -n "$model"; and test "$model" != ""
                set -gx ANTHROPIC_MODEL $model
                _ccs_log_success "设置 ANTHROPIC_MODEL=$model"
                set vars_set (math $vars_set + 1)
            end
        else if string match -rq "^small_fast_model\s*=" -- $line
            set small_fast_model (echo $line | string replace -r ".*=\s*[\"']?([^\"']*)[\"']?" '$1')
            if test -n "$small_fast_model"; and test "$small_fast_model" != ""
                set -gx ANTHROPIC_SMALL_FAST_MODEL $small_fast_model
                _ccs_log_success "设置 ANTHROPIC_SMALL_FAST_MODEL=$small_fast_model"
                set vars_set (math $vars_set + 1)
            end
        end
    end
    
    if test $vars_set -eq 0
        _ccs_log_error "配置 '$config_name' 没有设置任何有效的环境变量"
        return 1
    end
    
    _ccs_log_success "已切换到配置: $config_name ($vars_set 个变量已设置)"
    return 0
end

# 列出所有配置
function _ccs_list_configs
    _ccs_print_step "扫描可用的配置..."
    echo ""
    
    set configs (grep '^\[' $CONFIG_FILE | string replace -r '^\[(.*)\]$' '$1' | grep -v '^default_config$')
    set config_count (count $configs)
    
    if test $config_count -eq 0
        _ccs_log_warn "未找到任何配置节"
        return 1
    end
    
    # 获取当前配置
    set current_config (grep "^current_config" $CONFIG_FILE | string replace -r ".*=\s*[\"']?([^\"']*)[\"']?" '$1')
    
    # 显示配置列表
    for config in $configs
        set description (_ccs_parse_config_section $config | grep "^description" | string replace -r ".*=\s*[\"']?([^\"']*)[\"']?" '$1')
        
        if test "$config" = "$current_config"
            printf "\033[0;32m▶ %-15s\033[0m" $config
        else
            printf "  %-15s" $config  
        end
        
        if test -n "$description"
            echo " - $description"
        else
            echo " - (无描述)"
        end
    end
    
    echo ""
    _ccs_print_step "配置统计: $config_count 个配置可用"
    
    if test -n "$current_config"
        echo "当前配置: $current_config"
    else
        echo "当前配置: 未设置"
    end
end

# 显示当前配置状态
function _ccs_show_current
    _ccs_print_step "检查当前环境配置..."
    echo ""
    
    set vars_info "API端点:ANTHROPIC_BASE_URL,认证令牌:ANTHROPIC_AUTH_TOKEN,模型:ANTHROPIC_MODEL,快速模型:ANTHROPIC_SMALL_FAST_MODEL"
    set vars_set 0
    
    for var_info in (string split ',' $vars_info)
        set var_desc (string split ':' $var_info)[1]
        set var_name (string split ':' $var_info)[2]
        
        printf "  %-15s: " $var_desc
        
        if set -q $var_name
            set vars_set (math $vars_set + 1)
            set -l value (eval echo \$$var_name)
            if test $var_name = "ANTHROPIC_AUTH_TOKEN"
                set masked_value (string sub -l 10 $value)...
                echo -e "\033[0;32m$masked_value\033[0m"
            else
                echo -e "\033[0;32m$value\033[0m"
            end
        else
            echo -e "\033[1;33m(未设置)\033[0m"
        end
    end
    
    echo ""
    if test $vars_set -gt 0
        _ccs_log_success "环境状态: $vars_set/4 个环境变量已设置"
    else
        _ccs_log_warn "环境状态: 没有设置任何CCS环境变量"
        echo "建议运行: ccs <配置名称> 来设置配置"
    end
end

# 显示帮助信息
function _ccs_show_help
    echo -e "\033[0;34m════════════════════════════════════════════════════════════════\033[0m"
    echo -e "\033[0;34m🔄 Claude Code Configuration Switcher (CCS) v$CCS_VERSION (Fish)\033[0m"  
    echo -e "\033[0;34m════════════════════════════════════════════════════════════════\033[0m"
    echo ""
    echo -e "\033[0;32m📋 基本用法:\033[0m"
    echo "  ccs [配置名称]          - 切换到指定配置"
    echo "  ccs list               - 列出所有可用配置" 
    echo "  ccs current            - 显示当前配置状态"
    echo ""
    echo -e "\033[0;32m🔧 管理命令:\033[0m"
    echo "  ccs help               - 显示此帮助信息"
    echo "  ccs version            - 显示版本信息"
    echo ""
    echo -e "\033[0;36m💡 使用示例:\033[0m"
    echo "  ccs anyrouter          - 切换到anyrouter配置"
    echo "  ccs glm                - 切换到智谱GLM配置" 
    echo "  ccs list               - 查看所有可用配置"
    echo "  ccs current            - 查看当前配置状态"
    echo ""
    echo -e "\033[1;33m🔗 配置文件:\033[0m"
    echo "  位置: ~/.ccs_config.toml"
    echo "  格式: TOML"
    echo ""
    echo -e "\033[1;33m📝 Fish Shell 优化特性 (v2.0):\033[0m"
    echo "  • 高性能配置解析"
    echo "  • 智能错误处理"
    echo "  • 彩色输出和状态显示"
    echo "  • 自动补全支持"
    echo ""
    echo -e "\033[0;34m════════════════════════════════════════════════════════════════\033[0m"
end

# 显示版本信息
function _ccs_show_version
    echo "🔄 Claude Code Configuration Switcher (CCS) - Fish Shell Edition"
    echo "版本: $CCS_VERSION"
    echo "Shell: Fish "(fish --version | string replace 'fish, version ' '')
    echo "配置文件: $CONFIG_FILE"
    echo ""
    echo "🚀 感谢使用 CCS Fish版！"
end

# 自动加载当前配置（静默模式）
function _ccs_auto_load_current
    if not _ccs_check_config_file
        return
    end
    
    set current_config (grep "^current_config" $CONFIG_FILE | string replace -r ".*=\s*[\"']?([^\"']*)[\"']?" '$1')
    
    if test -z "$current_config"
        set current_config (grep "^default_config" $CONFIG_FILE | string replace -r ".*=\s*[\"']?([^\"']*)[\"']?" '$1')
    end
    
    if test -n "$current_config"; and _ccs_validate_config $current_config >/dev/null 2>&1
        _ccs_set_env_vars $current_config >/dev/null 2>&1
    end
end

# 主函数
function ccs --description "Claude Code Configuration Switcher for Fish shell v2.0"
    set command $argv[1]
    
    # 处理帮助命令（无需检查配置文件）
    if test "$command" = "help" -o "$command" = "-h" -o "$command" = "--help"
        _ccs_show_help
        return 0
    end
    
    # 处理版本命令
    if test "$command" = "version" -o "$command" = "-v" -o "$command" = "--version"
        _ccs_show_version
        return 0
    end
    
    # 检查配置文件
    if not _ccs_check_config_file
        return 1
    end
    
    # 命令路由
    switch $command
        case "list" "ls"
            _ccs_list_configs
        case "current" "show" "status"
            _ccs_show_current
        case ""
            # 无参数时使用当前或默认配置
            set target_config (grep "^current_config" $CONFIG_FILE | string replace -r ".*=\s*[\"']?([^\"']*)[\"']?" '$1')
            
            if test -z "$target_config"
                set target_config (grep "^default_config" $CONFIG_FILE | string replace -r ".*=\s*[\"']?([^\"']*)[\"']?" '$1')
            end
            
            if test -n "$target_config"
                _ccs_log_info "使用配置: $target_config"
                if _ccs_validate_config $target_config; and _ccs_set_env_vars $target_config
                    _ccs_update_current_config $target_config
                end
            else
                _ccs_log_error "没有指定配置名称且没有默认配置"
                _ccs_show_help
                return 1
            end
        case "*"
            # 指定的配置名称
            if _ccs_validate_config $command; and _ccs_set_env_vars $command
                _ccs_update_current_config $command
            else
                echo ""
                _ccs_print_step "可用的配置:"
                _ccs_list_configs
                return 1
            end
    end
    
    return 0
end

# Fish 自动补全
function __ccs_complete
    if test -f $CONFIG_FILE
        grep '^\[' $CONFIG_FILE | string replace -r '^\[(.*)\]$' '$1' | grep -v '^default_config$' | sort
    end
end

complete -c ccs -f -a "(__ccs_complete)" -d "配置名称"
complete -c ccs -f -a "list ls" -d "列出所有配置"
complete -c ccs -f -a "current show status" -d "显示当前配置"
complete -c ccs -f -a "help" -d "显示帮助信息"
complete -c ccs -f -a "version" -d "显示版本信息"

# 脚本加载时自动加载当前配置（已禁用以避免启动时输出）
# _ccs_auto_load_current