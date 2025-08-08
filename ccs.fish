function ccs --description "Claude Code Configuration Switcher for Fish shell"
    set config_file "$HOME/.ccs_config.toml"
    set profile_name $argv[1]
    
    # 检查配置文件是否存在
    if not test -f "$config_file"
        echo "❌ 配置文件不存在: $config_file"
        echo "请运行 ./install.sh 或参考示例创建配置文件"
        return 1
    end
    
    # 显示帮助信息
    set show_help false
    if test "$profile_name" = "help" -o "$profile_name" = "-h" -o "$profile_name" = "--help"
        set show_help true
    end
    
    if test "$profile_name" = "help" -o "$profile_name" = "-h" -o "$profile_name" = "--help"
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
        return 0
    end
    
    if test -z "$profile_name"
        echo "Claude Code Configuration Switcher (ccs)"
        echo ""
        # 显示默认配置
        set default_config (grep 'default_config.*=' "$config_file" | cut -d'"' -f2 | head -1)
        if test -n "$default_config"
            echo "使用默认配置: $default_config"
            set profile_name "$default_config"
        else
            echo "用法:"
            echo "  ccs [配置名称]    - 切换到指定配置"
            echo "  ccs list          - 列出所有可用配置"
            return 0
        end
    end
    
    # 处理list子命令
    if test "$profile_name" = "list"
        echo "可用的配置:"
        echo ""
        
        # 提取所有配置节
        set configs (command grep '^\[' "$config_file" | sed 's/\[\(.*\)\]/\1/' | grep -v '^default_config$')
        
        for config in $configs
                # 跳过default_config
            if test "$config" = "default_config"
                continue
            end
            
            # 获取配置描述
            set description (sed -n '/^\['$config'\]/,/^\[/p' "$config_file" | grep 'description' | cut -d'"' -f2 | head -1)
            
            if test -n "$description"
                printf "  %-15s - %s\n" "$config" "$description"
            else
                printf "  %s\n" "$config"
            end
        end
        
        echo ""
        # 显示默认配置
        set default_config (grep 'default_config.*=' "$config_file" | cut -d'"' -f2 | head -1)
        if test -n "$default_config"
            echo "默认配置: $default_config"
        end
        return 0
    end
    
    # 处理web子命令
    if test "$profile_name" = "web"
        set web_dir "$HOME/.ccs/web"
        set web_path "$web_dir/index.html"
        
        if not test -f "$web_path"
            echo "❌ web界面文件不存在，请重新运行安装脚本"
            return 1
        end
        
        # 检查是否在远程环境（WSL/SSH）
        if test -n "$WSL_DISTRO_NAME" -o -n "$SSH_CLIENT" -o -n "$SSH_TTY"
            # 远程环境，启动HTTP服务器
             set port 8888
             echo "检测到远程环境，启动HTTP服务器..."
             
             # 检查端口是否被占用
             while netstat -ln 2>/dev/null | grep -q ":$port "
                 set port (math $port + 1)
             end
             
             # 复制用户配置文件到web目录，确保web页面能读取到正确的配置
             set user_config "$HOME/.ccs_config.toml"
             if test -f "$user_config"
                 cp "$user_config" "$web_dir/.ccs_config.toml"
                 echo "已复制用户配置文件到web目录"
             else
                 echo "⚠️ 未找到用户配置文件 $user_config"
             end
             
             echo "启动web服务器在端口 $port"
             echo "请在浏览器中访问: http://localhost:$port"
             
             # 启动Python HTTP服务器
             if command -v python3 >/dev/null 2>&1
                 cd "$web_dir" && python3 -m http.server $port
             else if command -v python >/dev/null 2>&1
                 cd "$web_dir" && python -m SimpleHTTPServer $port
             else
                 echo "❌ 需要Python来启动HTTP服务器"
                 echo "请手动打开 $web_path"
                 return 1
             end
        else
            # 本地环境，直接打开浏览器
            if command -v xdg-open >/dev/null 2>&1
                xdg-open "$web_path"
            else if command -v open >/dev/null 2>&1
                open "$web_path"
            else if command -v google-chrome >/dev/null 2>&1
                google-chrome "$web_path"
            else if command -v firefox >/dev/null 2>&1
                firefox "$web_path"
            else if command -v safari >/dev/null 2>&1
                safari "$web_path"
            else
                echo "❌ 无法找到可用的浏览器"
                echo "请手动打开 $web_path"
                return 1
            end
            echo "✅ 正在打开web配置界面..."
        end
        return 0
    end
    
    # 处理current子命令
    if test "$profile_name" = "current"
        echo "当前配置:"
        if test -n "$ANTHROPIC_BASE_URL"
            echo "  ANTHROPIC_BASE_URL=$ANTHROPIC_BASE_URL"
        else
            echo "  ANTHROPIC_BASE_URL=(未设置)"
        end
        
        if test -n "$ANTHROPIC_AUTH_TOKEN"
            echo "  ANTHROPIC_AUTH_TOKEN=(已设置，长度: "(string length "$ANTHROPIC_AUTH_TOKEN")"字符)"
        else
            echo "  ANTHROPIC_AUTH_TOKEN=(未设置)"
        end
        
        if test -n "$ANTHROPIC_MODEL"
            echo "  ANTHROPIC_MODEL=$ANTHROPIC_MODEL"
        else
            echo "  ANTHROPIC_MODEL=(未设置)"
        end
        
        if test -n "$ANTHROPIC_SMALL_FAST_MODEL"
            echo "  ANTHROPIC_SMALL_FAST_MODEL=$ANTHROPIC_SMALL_FAST_MODEL"
        else
            echo "  ANTHROPIC_SMALL_FAST_MODEL=(未设置)"
        end
        return 0
    end
    
    # 验证配置是否存在（但不针对特殊命令）
    if not grep -q "^\[$profile_name\]" "$config_file"
        echo "❌ 未找到配置文件: $profile_name"
        echo "可用的配置文件:"
        set configs (grep '^\[' "$config_file" | grep -v '^\[profiles\.' | sed 's/\[\(.*\)\]/\1/')
        for config in $configs
            if test "$config" != "default_config"
                echo "  $config"
            end
        end
        return 1
    end
    
    # 解析配置项
    set base_url (grep '^base_url[[:space:]]*=' "$config_file" | sed "s|base_url[[:space:]]*=[[:space:]]*\"\\?\([^\"\\]*\\)\\?\$|\1|" | head -1)
    set auth_token (grep '^auth_token[[:space:]]*=' "$config_file" | sed "s|auth_token[[:space:]]*=[[:space:]]*\"\\?\([^\"\\]*\\)\\?\$|\1|" | head -1)
    set model (grep '^model[[:space:]]*=' "$config_file" | sed "s|model[[:space:]]*=[[:space:]]*\"\\?\([^\"\\]*\\)\\?\$|\1|" | head -1)
    
    # 从指定profile中提取
    set base_url (sed -n "/^\[$profile_name\]/,/^\[/p" "$config_file" | sed -n '/^base_url[[:space:]]*=/{s/.*"\([^"]*\)".*/\1/;p;q}')
    set auth_token (sed -n "/^\[$profile_name\]/,/^\[/p" "$config_file" | sed -n '/^auth_token[[:space:]]*=/{s/.*"\([^"]*\)".*/\1/;p;q}')
    set model (sed -n "/^\[$profile_name\]/,/^\[/p" "$config_file" | sed -n '/^model[[:space:]]*=/{s/.*"\([^"]*\)".*/\1/;p;q}')
    set small_fast_model (sed -n "/^\[$profile_name\]/,/^\[/p" "$config_file" | sed -n '/^small_fast_model[[:space:]]*=/{s/.*"\([^"]*\)".*/\1/;p;q}')
    
    # 验证必需的配置项
    if test -z "$auth_token"
        echo "❌ 配置错误: auth_token 未设置"
        return 1
    end
    
    # 清理现有的环境变量
    if set -q ANTHROPIC_BASE_URL
        set -e ANTHROPIC_BASE_URL
    end
    if set -q ANTHROPIC_AUTH_TOKEN
        set -e ANTHROPIC_AUTH_TOKEN
    end
    if set -q ANTHROPIC_MODEL
        set -e ANTHROPIC_MODEL
    end
    if set -q ANTHROPIC_SMALL_FAST_MODEL
        set -e ANTHROPIC_SMALL_FAST_MODEL
    end
    
    # 设置新的环境变量
    set -gx ANTHROPIC_AUTH_TOKEN "$auth_token"
    
    if test -n "$base_url"
        set -gx ANTHROPIC_BASE_URL "$base_url"
    end
    
    if test -n "$model"
        set -gx ANTHROPIC_MODEL "$model"
    end
    
    if test -n "$small_fast_model"
        set -gx ANTHROPIC_SMALL_FAST_MODEL "$small_fast_model"
    end
    
    echo "✅ 已切换到配置: $profile_name"
    if test -n "$base_url"
        echo "🌐 ANTHROPIC_BASE_URL=$base_url"
    else
        echo "🌐 API端点: 默认"
    end
    if test -n "$model"
        echo "🤖 ANTHROPIC_MODEL=$model"
    else
        echo "🤖 模型: 默认"
    end
    
    if test -n "$small_fast_model"
        echo "⚡ ANTHROPIC_SMALL_FAST_MODEL=$small_fast_model"
    else
        echo "⚡ 快速模型: 默认"
    end
    
    return 0
end

# Fish 自动补全
function __ccs_complete
    if test -f "$HOME/.ccs_config.toml"
        command grep '^\[' "$HOME/.ccs_config.toml" | sed 's/\[\(.*\)\]/\1/' | grep -v '^default_config$' | sort
    end
end
complete -c ccs -f -a "(__ccs_complete)"