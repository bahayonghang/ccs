# 更新配置文件中的当前配置
function update_current_config --argument config_name
    set config_file "$HOME/.ccs_config.toml"
    
    # 创建临时文件
    set temp_file (mktemp)
    if test -z "$temp_file"
        echo "❌ 无法创建临时文件" >&2
        return 1
    end
    
    # 检查current_config字段是否存在
    if grep -q "^current_config" "$config_file"
        # 字段存在,执行替换
        echo "🔄 current_config字段存在,执行更新" >&2
        sed "s/^current_config *= *\"[^\"]*\"/current_config = \"$config_name\"/" "$config_file" > "$temp_file"
        sed -i "s/^current_config *= *'[^']*'/current_config = \"$config_name\"/" "$temp_file"
        
        # 验证更新是否成功
        if grep -q "^current_config = \"$config_name\"" "$temp_file"
            if mv "$temp_file" "$config_file"
                echo "✅ 配置文件已更新,当前配置: $config_name" >&2
                return 0
            else
                echo "❌ 无法保存配置文件" >&2
                rm -f "$temp_file"
                return 1
            end
        else
            echo "❌ 配置文件更新验证失败" >&2
            rm -f "$temp_file"
            return 1
        end
    else
        # 字段不存在,自动修复：在文件开头添加current_config字段
        echo "🔧 current_config字段不存在,执行自动修复" >&2
        
        # 获取默认配置名称作为初始值
        set default_config (grep "^default_config" "$config_file" | cut -d'"' -f2 | cut -d"'" -f2)
        if test -z "$default_config"
            set default_config "anyrouter"  # 回退到硬编码默认值
        end
        
        # 创建修复后的配置文件
        echo "# 当前使用的配置（自动添加）" > "$temp_file"
        echo "current_config = \"$config_name\"" >> "$temp_file"
        echo "" >> "$temp_file"
        cat "$config_file" >> "$temp_file"
        
        # 验证修复结果
        if grep -q "^current_config = \"$config_name\"" "$temp_file"
            if mv "$temp_file" "$config_file"
                echo "✅ 配置文件已自动修复并更新,当前配置: $config_name" >&2
                return 0
            else
                echo "❌ 无法保存修复后的配置文件" >&2
                rm -f "$temp_file"
                return 1
            end
        else
            echo "❌ 配置文件自动修复验证失败" >&2
            rm -f "$temp_file"
            return 1
        end
    end
end

# 自动加载当前配置
function load_current_config
    set config_file "$HOME/.ccs_config.toml"
    
    # 检查配置文件是否存在
    if not test -f "$config_file"
        return 0
    end
    
    # 获取当前配置
    set current_config (grep "^current_config" "$config_file" | cut -d'"' -f2 | cut -d"'" -f2)
    
    # 如果没有当前配置,尝试使用默认配置
    if test -z "$current_config"
        set current_config (grep "^default_config" "$config_file" | cut -d'"' -f2 | cut -d"'" -f2)
    end
    
    # 如果找到了配置,则加载它
    if test -n "$current_config"
        # 检查配置是否存在
        if grep -q "^\[$current_config\]" "$config_file"
            set_config_env "$current_config" true
        else
            # 当前配置不存在,回退到默认配置
            set default_config (grep "^default_config" "$config_file" | cut -d'"' -f2 | cut -d"'" -f2)
            if test -n "$default_config"; and grep -q "^\[$default_config\]" "$config_file"
                set_config_env "$default_config" true
                # 更新current_config为默认配置
                update_current_config "$default_config"
            end
        end
    end
end

# 设置配置环境变量（静默模式）
function set_config_env --argument profile_name silent_mode
    set config_file "$HOME/.ccs_config.toml"
    
    # 解析配置项
    set base_url (sed -n "/^\[$profile_name\]/,/^\[/p" "$config_file" | sed -n '/^base_url[[:space:]]*=/{s/.*"\([^"]*\)".*/\1/;p;q}')
    set auth_token (sed -n "/^\[$profile_name\]/,/^\[/p" "$config_file" | sed -n '/^auth_token[[:space:]]*=/{s/.*"\([^"]*\)".*/\1/;p;q}')
    set model (sed -n "/^\[$profile_name\]/,/^\[/p" "$config_file" | sed -n '/^model[[:space:]]*=/{s/.*"\([^"]*\)".*/\1/;p;q}')
    set small_fast_model (sed -n "/^\[$profile_name\]/,/^\[/p" "$config_file" | sed -n '/^small_fast_model[[:space:]]*=/{s/.*"\([^"]*\)".*/\1/;p;q}')
    
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
    if test -n "$auth_token"
        set -gx ANTHROPIC_AUTH_TOKEN "$auth_token"
    end
    
    if test -n "$base_url"
        set -gx ANTHROPIC_BASE_URL "$base_url"
    end
    
    if test -n "$model"; and test "$model" != ""
        set -gx ANTHROPIC_MODEL "$model"
    end
    
    if test -n "$small_fast_model"; and test "$small_fast_model" != ""
        set -gx ANTHROPIC_SMALL_FAST_MODEL "$small_fast_model"
    end
end

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
        echo "  ccs version       - 显示版本信息"
        echo "  ccs uninstall     - 卸载ccs工具"
        echo "  ccs help          - 显示此帮助信息"
        echo ""
        echo "示例:"
        echo "  ccs anyrouter     - 切换到anyrouter配置"
        echo "  ccs glm           - 切换到智谱GLM配置"
        echo "  ccs list          - 查看所有可用配置"
        echo "  ccs web           - 打开web配置界面"
        echo "  ccs version       - 查看版本信息"
        echo "  ccs uninstall     - 完全卸载ccs工具"
        return 0
    end
    
    if test -z "$profile_name"
        echo "Claude Code Configuration Switcher (ccs)"
        echo ""
        # 显示当前配置
        set current_config (grep '^current_config.*=' "$config_file" | cut -d'"' -f2 | head -1)
        if test -z "$current_config"
            set current_config (grep '^default_config.*=' "$config_file" | cut -d'"' -f2 | head -1)
        end
        if test -n "$current_config"
            echo "使用当前配置: $current_config"
            set_config_env "$current_config"
            update_current_config "$current_config"
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
            echo "❌ web界面文件不存在,请重新运行安装脚本"
            return 1
        end
        
        # 检查是否在远程环境（WSL/SSH）
        if test -n "$WSL_DISTRO_NAME" -o -n "$SSH_CLIENT" -o -n "$SSH_TTY"
            # 远程环境,启动HTTP服务器
             set port 8888
             echo "检测到远程环境,启动HTTP服务器..."
             
             # 检查端口是否被占用
             while netstat -ln 2>/dev/null | grep -q ":$port "
                 set port (math $port + 1)
             end
             
             # 复制用户配置文件到web目录,确保web页面能读取到正确的配置
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
            # 本地环境,直接打开浏览器
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
    
    # 处理uninstall子命令
    if test "$profile_name" = "uninstall"
        echo "正在卸载Claude Code Configuration Switcher..."
        echo ""
        
        echo "🔄 开始卸载ccs..."
        
        # 删除整个.ccs目录（除了配置文件）
        if test -d "$HOME/.ccs"
            # 删除脚本文件
            if test -f "$HOME/.ccs/ccs.sh"
                rm -f "$HOME/.ccs/ccs.sh"
                echo "✅ 删除bash脚本文件"
            end
            
            if test -f "$HOME/.ccs/ccs.fish"
                rm -f "$HOME/.ccs/ccs.fish"
                echo "✅ 删除fish脚本文件"
            end
            
            # 删除web文件
            if test -d "$HOME/.ccs/web"
                rm -rf "$HOME/.ccs/web"
                echo "✅ 删除web文件"
            end
            
            # 检查.ccs目录是否为空（除了配置文件）
            set remaining_files (find "$HOME/.ccs" -type f ! -name "*.toml" | wc -l)
            if test "$remaining_files" -eq 0
                # 如果没有配置文件,删除整个目录
                if not test -f "$config_file"
                    rm -rf "$HOME/.ccs"
                    echo "✅ 删除.ccs目录"
                else
                    echo "⚠️ 保留.ccs目录（包含配置文件）"
                end
            end
        end
        
        # 删除配置文件（询问用户）
        if test -f "$config_file"
            echo -n "是否要删除配置文件 $config_file? (y/N): "
            read -l reply
            if test "$reply" = "y" -o "$reply" = "Y"
                rm -f "$config_file"
                echo "✅ 删除配置文件"
                # 如果删除了配置文件且.ccs目录为空,删除目录
                if test -d "$HOME/.ccs" -a -z "(ls -A "$HOME/.ccs" 2>/dev/null)"
                    rm -rf "$HOME/.ccs"
                    echo "✅ 删除空的.ccs目录"
                end
            end
        end
        
        # 从所有shell配置文件中移除配置
        set removed_count 0
        set bashrc_file "$HOME/.bashrc"
        set zshrc_file "$HOME/.zshrc"
        
        # 处理bash配置
        if test -f "$bashrc_file"
            set temp_file (mktemp)
            # 移除ccs相关的配置块
            awk '
            /^# Claude Code Configuration Switcher/ { skip=1; next }
            /^if \[ -f "\$HOME\/\.ccs\/ccs\.sh" \]/ { skip=1; next }
            /^fi$/ && skip { skip=0; next }
            !skip { print }
            ' "$bashrc_file" > "$temp_file"
            
            # 检查是否有变化
            if not cmp -s "$bashrc_file" "$temp_file"
                mv "$temp_file" "$bashrc_file"
                echo "✅ 从 $bashrc_file 中移除配置"
                set removed_count (math $removed_count + 1)
            else
                rm -f "$temp_file"
            end
        end
        
        # 处理zsh配置
        if test -f "$zshrc_file"
            set temp_file (mktemp)
            awk '
            /^# Claude Code Configuration Switcher/ { skip=1; next }
            /^if \[ -f "\$HOME\/\.ccs\/ccs\.sh" \]/ { skip=1; next }
            /^fi$/ && skip { skip=0; next }
            !skip { print }
            ' "$zshrc_file" > "$temp_file"
            
            if not cmp -s "$zshrc_file" "$temp_file"
                mv "$temp_file" "$zshrc_file"
                echo "✅ 从 $zshrc_file 中移除配置"
                set removed_count (math $removed_count + 1)
            else
                rm -f "$temp_file"
            end
        end
        
        # 处理fish配置
        set fish_config "$HOME/.config/fish/config.fish"
        if test -f "$fish_config"
            set temp_file (mktemp)
            awk '
            /^# Claude Code Configuration Switcher/ { skip=1; next }
            /^if test -f "\$HOME\/\.ccs\/ccs\.fish"/ { skip=1; next }
            /^end$/ && skip { skip=0; next }
            !skip { print }
            ' "$fish_config" > "$temp_file"
            
            if not cmp -s "$fish_config" "$temp_file"
                mv "$temp_file" "$fish_config"
                echo "✅ 从 $fish_config 中移除配置"
                set removed_count (math $removed_count + 1)
            else
                rm -f "$temp_file"
            end
        end
        
        if test "$removed_count" -gt 0
            echo "✅ 已从 $removed_count 个shell配置文件中移除ccs配置"
        else
            echo "⚠️ 未在shell配置文件中找到ccs配置"
        end
        
        echo "✅ 卸载完成！请重新启动终端或重新加载shell配置"
        echo ""
        echo "⚠️ 注意：当前终端会话中的ccs函数仍然可用,直到重新启动终端"
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
            echo "  ANTHROPIC_AUTH_TOKEN=(已设置,长度: "(string length "$ANTHROPIC_AUTH_TOKEN")"字符)"
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
    
    # 处理version子命令
    if test "$profile_name" = "version" -o "$profile_name" = "-v" -o "$profile_name" = "--version"
        show_version
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
    
    if test -n "$model"; and test "$model" != ""
        set -gx ANTHROPIC_MODEL "$model"
    end
    
    if test -n "$small_fast_model"; and test "$small_fast_model" != ""
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
    
    # 更新配置文件中的当前配置
    update_current_config "$profile_name"
    
    return 0
end

# 在脚本被source时自动加载当前配置
load_current_config

# 显示版本信息
function show_version
    set script_dir (dirname (status --current-filename))
    set project_root (realpath "$script_dir/../..")
    
    # 优先查找.ccs目录中的package.json,然后查找项目根目录
    set package_json "$HOME/.ccs/package.json"
    if not test -f "$package_json"
        set package_json "$project_root/package.json"
    end
    
    echo "🔄 Claude Code Configuration Switcher (CCS)"
    echo "═══════════════════════════════════════════════════════════════════════════════════"
    echo ""
    
    if test -f "$package_json"
        set app_version (grep '"version"' "$package_json" | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        set app_description (grep '"description"' "$package_json" | sed 's/.*"description"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        set app_author (grep '"author"' "$package_json" | sed 's/.*"author"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        set app_homepage (grep '"homepage"' "$package_json" | sed 's/.*"homepage"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        set app_license (grep '"license"' "$package_json" | sed 's/.*"license"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        
        echo "📦 基本信息:"
        if test -n "$app_version"
            echo "   📌 版本: $app_version"
        else
            echo "   ⚠️  版本: 未知 (建议在package.json中补充version字段)"
        end
        
        if test -n "$app_author"
            echo "   👤 作者: $app_author"
        else
            echo "   ⚠️  作者: 未知 (建议在package.json中补充author字段)"
        end
        
        echo ""
        echo "📝 项目描述:"
        if test -n "$app_description"
            # 处理长描述,进行换行显示
            echo "$app_description" | fold -w 75 -s | sed 's/^/   /'
        else
            echo "   ⚠️  描述: 未知 (建议在package.json中补充description字段)"
        end
        
        echo ""
        echo "🔗 项目链接:"
        if test -n "$app_homepage"
            echo "   🌐 项目主页: $app_homepage"
        else
            echo "   🌐 项目主页: https://github.com/bahayonghang/ccs (默认)"
        end
        
        if test -n "$app_license"
            echo "   📄 许可证: $app_license"
        else
            echo "   📄 许可证: MIT (默认)"
        end
        
        echo ""
        echo "📁 文件信息:"
        echo "   📍 配置文件路径: $package_json_path"
        echo "   ✅ 文件复制操作: 无需执行 (直接读取源文件)"
        
    else
        echo "⚠️  警告: 未找到package.json文件"
        echo "📍 预期路径: $package_json_path"
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
    end
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════════════"
    echo "🚀 感谢使用 CCS！如有问题请访问项目主页获取帮助。"
end

# Fish 自动补全
function __ccs_complete
    if test -f "$HOME/.ccs_config.toml"
        command grep '^\[' "$HOME/.ccs_config.toml" | sed 's/\[\(.*\)\]/\1/' | grep -v '^default_config$' | sort
    end
end
complete -c ccs -f -a "(__ccs_complete)"