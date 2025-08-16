# 故障排除指南

本文档提供 CCS (Claude Code Configuration Switcher) 常见问题的诊断方法和解决方案。

## 📋 目录

- [快速诊断](#快速诊断)
- [安装问题](#安装问题)
- [配置问题](#配置问题)
- [连接问题](#连接问题)
- [环境变量问题](#环境变量问题)
- [权限问题](#权限问题)
- [性能问题](#性能问题)
- [平台特定问题](#平台特定问题)
- [高级诊断](#高级诊断)
- [获取帮助](#获取帮助)

## 🔍 快速诊断

### 1. 系统健康检查

**一键诊断：**
```bash
# 运行完整系统诊断
ccs diagnose

# 快速健康检查
ccs status --health

# 验证所有配置
ccs validate --all
```

**诊断输出示例：**
```bash
$ ccs diagnose
🔍 CCS 系统诊断报告

📊 系统信息:
   ✅ 操作系统: Linux 5.15.0-91-generic
   ✅ Shell: bash 5.1.16
   ✅ CCS版本: 1.2.3
   ✅ 安装路径: /home/user/.ccs/

📁 配置文件:
   ✅ 配置文件存在: ~/.ccs_config.toml
   ✅ 格式正确
   ✅ 权限正常 (644)
   📊 配置数量: 5个

🌍 环境变量:
   ✅ CCS_CURRENT_CONFIG=openai-gpt4
   ✅ OPENAI_API_KEY=sk-***
   ✅ OPENAI_BASE_URL=https://api.openai.com/v1

🔗 网络连接:
   ✅ DNS解析正常
   ✅ 互联网连接正常
   ⚠️  API端点响应慢 (>2s)

📊 诊断结果: 系统基本正常,存在性能问题
💡 建议: 检查网络连接或考虑使用代理
```

### 2. 常见问题快速检查

**检查清单：**
```bash
# 1. CCS是否正确安装？
which ccs
ccs --version

# 2. 配置文件是否存在？
ls -la ~/.ccs_config.toml

# 3. 当前配置是否有效？
ccs status

# 4. 环境变量是否正确设置？
env | grep -E "(CCS|OPENAI|ANTHROPIC|GOOGLE)_"

# 5. 网络连接是否正常？
ping -c 3 api.openai.com
```

## 🔧 安装问题

### 1. 安装失败

**问题：安装脚本执行失败**
```bash
# 错误信息
$ curl -sSL https://raw.githubusercontent.com/user/ccs/main/scripts/install/quick_install.sh | bash
curl: (7) Failed to connect to raw.githubusercontent.com port 443: Connection refused
```

**解决方案：**
```bash
# 方案1: 检查网络连接
ping github.com
ping raw.githubusercontent.com

# 方案2: 使用代理
export https_proxy=http://proxy.example.com:8080
curl -sSL https://raw.githubusercontent.com/user/ccs/main/scripts/install/quick_install.sh | bash

# 方案3: 手动下载安装
wget https://github.com/user/ccs/archive/main.zip
unzip main.zip
cd ccs-main
./scripts/install/install.sh

# 方案4: 使用镜像源
curl -sSL https://gitee.com/user/ccs/raw/main/scripts/install/quick_install.sh | bash
```

**问题：权限不足**
```bash
# 错误信息
$ ./scripts/install/install.sh
permission denied: cannot create directory '/usr/local/bin'
```

**解决方案：**
```bash
# 方案1: 使用sudo权限
sudo ./scripts/install/install.sh

# 方案2: 安装到用户目录
./scripts/install/install.sh --user

# 方案3: 指定安装路径
./scripts/install/install.sh --prefix ~/local

# 方案4: 手动安装
mkdir -p ~/.local/bin
cp scripts/shell/ccs.sh ~/.local/bin/ccs
chmod +x ~/.local/bin/ccs
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

### 2. 安装后无法使用

**问题：命令未找到**
```bash
$ ccs --version
bash: ccs: command not found
```

**解决方案：**
```bash
# 检查安装路径
find /usr/local/bin /usr/bin ~/.local/bin -name "ccs*" 2>/dev/null

# 检查PATH环境变量
echo $PATH

# 添加到PATH（临时）
export PATH="/usr/local/bin:$PATH"

# 添加到PATH（永久）
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 重新安装
curl -sSL https://raw.githubusercontent.com/user/ccs/main/scripts/install/quick_install.sh | bash
```

**问题：Shell集成失败**
```bash
# 环境变量未自动加载
$ echo $CCS_CURRENT_CONFIG
# 输出为空
```

**解决方案：**
```bash
# 检查Shell配置文件
ls -la ~/.bashrc ~/.zshrc ~/.config/fish/config.fish

# 手动添加CCS初始化
echo 'source ~/.ccs/scripts/shell/ccs.sh' >> ~/.bashrc
source ~/.bashrc

# 对于Fish Shell
echo 'source ~/.ccs/scripts/shell/ccs.fish' >> ~/.config/fish/config.fish

# 对于Zsh
echo 'source ~/.ccs/scripts/shell/ccs.sh' >> ~/.zshrc
source ~/.zshrc
```

## ⚙️ 配置问题

### 1. 配置文件错误

**问题：TOML格式错误**
```bash
# 错误信息
$ ccs list
❌ 错误: 配置文件格式无效
📁 文件: ~/.ccs_config.toml
📍 行号: 15
💡 详情: Expected '=' after key
```

**解决方案：**
```bash
# 验证TOML格式
ccs validate --format

# 使用在线TOML验证器
# https://www.toml-lint.com/

# 备份并重新创建配置文件
cp ~/.ccs_config.toml ~/.ccs_config.toml.backup
ccs init --reset

# 手动修复常见错误
# 错误示例和修复：

# 错误: 缺少引号
# description = My OpenAI config
# 修复:
# description = "My OpenAI config"

# 错误: 多余的逗号
# model = "gpt-4",
# 修复:
# model = "gpt-4"

# 错误: 未转义的特殊字符
# auth_token = "sk-abc\def"
# 修复:
# auth_token = "sk-abc\\def"
```

**问题：配置字段缺失**
```bash
# 错误信息
$ ccs switch openai-gpt4
❌ 错误: 配置 'openai-gpt4' 缺少必需字段 'base_url'
```

**解决方案：**
```bash
# 检查配置完整性
ccs validate openai-gpt4 --detailed

# 编辑配置添加缺失字段
ccs edit openai-gpt4

# 或使用命令行直接设置
ccs edit openai-gpt4 --field base_url --value "https://api.openai.com/v1"

# 从模板重新创建
ccs delete openai-gpt4 --backup
ccs create openai-gpt4 --template openai
```

### 2. 配置切换失败

**问题：配置不存在**
```bash
# 错误信息
$ ccs switch nonexistent-config
❌ 错误: 配置 'nonexistent-config' 不存在
```

**解决方案：**
```bash
# 列出所有可用配置
ccs list

# 搜索相似配置名
ccs list | grep -i "nonexistent"

# 创建缺失的配置
ccs create nonexistent-config

# 或使用正确的配置名
ccs switch existing-config
```

**问题：配置验证失败**
```bash
# 错误信息
$ ccs switch openai-gpt4
❌ 错误: 配置验证失败
🔗 API连接测试失败: 401 Unauthorized
```

**解决方案：**
```bash
# 检查API密钥
ccs edit openai-gpt4 --field auth_token

# 测试API连接
ccs test openai-gpt4

# 跳过验证强制切换（不推荐）
ccs switch openai-gpt4 --force --no-verify

# 检查API密钥格式
echo $OPENAI_API_KEY | wc -c  # OpenAI密钥通常51字符
```

## 🌐 连接问题

### 1. API连接失败

**问题：网络超时**
```bash
# 错误信息
$ ccs test openai-gpt4
❌ 连接测试失败: 请求超时
🔗 地址: https://api.openai.com/v1
⏱️  超时时间: 30秒
```

**解决方案：**
```bash
# 检查网络连接
ping api.openai.com
curl -I https://api.openai.com/v1

# 增加超时时间
export CCS_TIMEOUT=60
ccs test openai-gpt4

# 使用代理
export https_proxy=http://proxy.example.com:8080
ccs test openai-gpt4

# 检查防火墙设置
sudo ufw status
sudo iptables -L

# 使用备用DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

**问题：SSL证书错误**
```bash
# 错误信息
$ ccs test openai-gpt4
❌ SSL证书验证失败
🔒 证书错误: certificate verify failed
```

**解决方案：**
```bash
# 更新CA证书
sudo apt update && sudo apt install ca-certificates

# 对于CentOS/RHEL
sudo yum update ca-certificates

# 临时跳过SSL验证（不推荐）
export CCS_SKIP_SSL_VERIFY=1
ccs test openai-gpt4

# 检查系统时间
date
sudo ntpdate -s time.nist.gov

# 手动下载证书
openssl s_client -connect api.openai.com:443 -showcerts
```

### 2. API认证失败

**问题：API密钥无效**
```bash
# 错误信息
$ ccs test openai-gpt4
❌ 认证失败: 401 Unauthorized
💡 错误详情: Invalid API key provided
```

**解决方案：**
```bash
# 检查API密钥格式
echo $OPENAI_API_KEY
# OpenAI: sk-开头,51字符
# Anthropic: sk-ant-开头
# Google: 39字符

# 重新设置API密钥
ccs edit openai-gpt4 --field auth_token

# 验证密钥有效性
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     https://api.openai.com/v1/models

# 检查密钥权限
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     https://api.openai.com/v1/usage
```

**问题：API配额超限**
```bash
# 错误信息
$ ccs test openai-gpt4
❌ API请求失败: 429 Too Many Requests
💡 错误详情: Rate limit exceeded
```

**解决方案：**
```bash
# 检查API使用情况
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     https://api.openai.com/v1/usage

# 等待配额重置
echo "等待配额重置,通常每分钟或每小时重置"
sleep 60
ccs test openai-gpt4

# 切换到备用配置
ccs switch backup-config

# 升级API计划
echo "考虑升级您的API计划以获得更高配额"
```

## 🌍 环境变量问题

### 1. 环境变量未设置

**问题：CCS环境变量缺失**
```bash
# 检查环境变量
$ env | grep CCS
# 输出为空
```

**解决方案：**
```bash
# 手动加载CCS环境
source ~/.ccs/scripts/shell/ccs.sh

# 检查Shell配置
grep -n "ccs" ~/.bashrc ~/.zshrc ~/.config/fish/config.fish

# 重新初始化CCS
ccs init --reload

# 手动设置环境变量
export CCS_CURRENT_CONFIG="openai-gpt4"
export CCS_CONFIG_FILE="$HOME/.ccs_config.toml"

# 永久添加到Shell配置
echo 'source ~/.ccs/scripts/shell/ccs.sh' >> ~/.bashrc
source ~/.bashrc
```

### 2. 环境变量冲突

**问题：多个工具设置相同环境变量**
```bash
# 检查环境变量来源
$ env | grep OPENAI_API_KEY
OPENAI_API_KEY=sk-from-other-tool

$ echo $OPENAI_API_KEY
sk-from-other-tool  # 不是CCS设置的值
```

**解决方案：**
```bash
# 查找环境变量设置位置
grep -r "OPENAI_API_KEY" ~/.bashrc ~/.zshrc ~/.profile ~/.config/

# 临时清除冲突变量
unset OPENAI_API_KEY
ccs switch openai-gpt4

# 设置CCS优先级
# 在Shell配置文件末尾添加CCS初始化
echo 'source ~/.ccs/scripts/shell/ccs.sh' >> ~/.bashrc

# 使用CCS专用前缀
export CCS_OPENAI_API_KEY="your-ccs-key"

# 检查变量优先级
echo "系统: $OPENAI_API_KEY"
ccs env show OPENAI_API_KEY
```

## 🔐 权限问题

### 1. 文件权限错误

**问题：无法写入配置文件**
```bash
# 错误信息
$ ccs switch openai-gpt4
❌ 错误: 无法写入配置文件
📁 文件: ~/.ccs_config.toml
💡 权限: -r--r--r--
```

**解决方案：**
```bash
# 检查文件权限
ls -la ~/.ccs_config.toml

# 修复文件权限
chmod 644 ~/.ccs_config.toml

# 检查目录权限
ls -ld ~/.ccs/
chmod 755 ~/.ccs/

# 检查文件所有者
sudo chown $USER:$USER ~/.ccs_config.toml
sudo chown -R $USER:$USER ~/.ccs/

# 重新创建配置文件
mv ~/.ccs_config.toml ~/.ccs_config.toml.backup
ccs init
```

### 2. 目录权限问题

**问题：无法创建备份目录**
```bash
# 错误信息
$ ccs backup
❌ 错误: 无法创建备份目录
📁 目录: ~/.ccs/backups/
💡 权限不足
```

**解决方案：**
```bash
# 检查父目录权限
ls -ld ~/.ccs/

# 创建备份目录
mkdir -p ~/.ccs/backups/
chmod 755 ~/.ccs/backups/

# 检查磁盘空间
df -h ~

# 使用其他备份位置
ccs backup --output ~/Documents/ccs-backup.toml

# 修复CCS目录权限
sudo chown -R $USER:$USER ~/.ccs/
chmod -R 755 ~/.ccs/
chmod 644 ~/.ccs_config.toml
```

## ⚡ 性能问题

### 1. 启动缓慢

**问题：CCS命令响应慢**
```bash
# 测试响应时间
$ time ccs list
# real    0m5.234s  # 太慢了
```

**解决方案：**
```bash
# 启用性能分析
export CCS_PROFILE=1
ccs list

# 禁用网络检查
export CCS_SKIP_NETWORK_CHECK=1
ccs list

# 使用缓存
export CCS_CACHE_CONFIG=1
ccs list

# 清理配置文件
ccs cleanup --optimize

# 减少配置数量
ccs list --count
ccs delete unused-config-1 unused-config-2

# 检查磁盘I/O
iostat -x 1 5
```

### 2. 内存使用过高

**问题：CCS占用内存过多**
```bash
# 检查内存使用
$ ps aux | grep ccs
user  1234  5.2  2.1  102400  87552  # 内存使用过高
```

**解决方案：**
```bash
# 启用内存优化
export CCS_MEMORY_OPTIMIZE=1

# 限制并发操作
export CCS_MAX_CONCURRENT=2

# 清理缓存
ccs cache clear

# 重启CCS服务
ccs restart

# 检查内存泄漏
valgrind --leak-check=full ccs list

# 使用轻量级模式
export CCS_LIGHTWEIGHT=1
ccs list
```

## 🖥️ 平台特定问题

### 1. Windows问题

**问题：PowerShell执行策略**
```powershell
# 错误信息
PS> .\ccs.ps1
无法加载文件,因为在此系统上禁止运行脚本
```

**解决方案：**
```powershell
# 检查执行策略
Get-ExecutionPolicy

# 临时允许脚本执行
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# 永久设置（需要管理员权限）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 使用批处理文件
ccs.bat list

# 或使用WSL
wsl ccs list
```

**问题：路径分隔符**
```batch
# 错误信息
REM Windows路径问题
set CCS_CONFIG_FILE=C:\Users\User\.ccs_config.toml
REM 路径中的反斜杠导致问题
```

**解决方案：**
```batch
REM 使用正斜杠
set CCS_CONFIG_FILE=C:/Users/User/.ccs_config.toml

REM 或使用环境变量
set CCS_CONFIG_FILE=%USERPROFILE%\.ccs_config.toml

REM 转义反斜杠
set CCS_CONFIG_FILE=C:\\Users\\User\\.ccs_config.toml
```

### 2. macOS问题

**问题：Gatekeeper阻止执行**
```bash
# 错误信息
$ ./ccs
"ccs" cannot be opened because it is from an unidentified developer
```

**解决方案：**
```bash
# 方案1: 允许执行
sudo xattr -rd com.apple.quarantine ./ccs

# 方案2: 系统偏好设置
# 系统偏好设置 > 安全性与隐私 > 通用 > 允许从以下位置下载的应用

# 方案3: 使用Homebrew安装
brew install ccs

# 方案4: 手动编译
git clone https://github.com/user/ccs.git
cd ccs
make install
```

**问题：SIP（系统完整性保护）**
```bash
# 错误信息
$ sudo cp ccs /usr/bin/
cp: /usr/bin/ccs: Operation not permitted
```

**解决方案：**
```bash
# 安装到用户目录
cp ccs ~/.local/bin/
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# 或使用/usr/local/bin
sudo cp ccs /usr/local/bin/

# 检查SIP状态
csrutil status
```

### 3. Linux发行版特定问题

**Ubuntu/Debian问题：**
```bash
# 缺少依赖
$ ccs list
bash: curl: command not found

# 安装依赖
sudo apt update
sudo apt install curl wget jq toml-cli

# 权限问题
sudo usermod -a -G sudo $USER
```

**CentOS/RHEL问题：**
```bash
# 缺少EPEL仓库
$ yum install jq
No package jq available

# 启用EPEL
sudo yum install epel-release
sudo yum install jq

# 或使用dnf（较新版本）
sudo dnf install jq
```

**Arch Linux问题：**
```bash
# 使用AUR安装
yay -S ccs-git

# 或手动安装
git clone https://aur.archlinux.org/ccs.git
cd ccs
makepkg -si
```

## 🔬 高级诊断

### 1. 调试模式

**启用详细调试：**
```bash
# 设置调试级别
export CCS_DEBUG_LEVEL=3  # 0=关闭, 1=错误, 2=警告, 3=信息, 4=调试

# 启用跟踪模式
export CCS_TRACE=1
ccs switch openai-gpt4

# 输出到文件
export CCS_LOG_FILE=~/ccs-debug.log
ccs list 2>&1 | tee ~/ccs-debug.log

# 启用性能分析
export CCS_PROFILE=1
time ccs validate --all
```

**调试输出示例：**
```bash
$ CCS_DEBUG_LEVEL=4 ccs switch openai-gpt4
[DEBUG] 2024-01-15 14:30:25 - 开始配置切换
[DEBUG] 2024-01-15 14:30:25 - 加载配置文件: ~/.ccs_config.toml
[DEBUG] 2024-01-15 14:30:25 - 解析TOML配置
[DEBUG] 2024-01-15 14:30:25 - 验证配置: openai-gpt4
[DEBUG] 2024-01-15 14:30:25 - 设置环境变量: OPENAI_API_KEY
[DEBUG] 2024-01-15 14:30:25 - 设置环境变量: OPENAI_BASE_URL
[DEBUG] 2024-01-15 14:30:26 - 测试API连接
[DEBUG] 2024-01-15 14:30:26 - API响应: 200 OK (245ms)
[DEBUG] 2024-01-15 14:30:26 - 更新当前配置
[DEBUG] 2024-01-15 14:30:26 - 保存配置文件
[INFO]  2024-01-15 14:30:26 - 配置切换完成
✅ 已切换到配置: openai-gpt4
```

### 2. 网络诊断

**详细网络测试：**
```bash
# 创建网络诊断脚本
cat > ccs-network-test.sh << 'EOF'
#!/bin/bash

echo "🔍 CCS 网络诊断"
echo "================="

# 基本连接测试
echo "📡 基本连接测试:"
ping -c 3 8.8.8.8 && echo "✅ 互联网连接正常" || echo "❌ 互联网连接失败"

# DNS解析测试
echo "🔍 DNS解析测试:"
nslookup api.openai.com && echo "✅ DNS解析正常" || echo "❌ DNS解析失败"

# API端点测试
echo "🔗 API端点测试:"
for endpoint in "api.openai.com" "api.anthropic.com" "generativelanguage.googleapis.com"; do
    echo -n "测试 $endpoint: "
    if curl -s --connect-timeout 10 "https://$endpoint" > /dev/null; then
        echo "✅ 可达"
    else
        echo "❌ 不可达"
    fi
done

# 代理检测
echo "🔄 代理设置:"
echo "HTTP_PROXY: ${HTTP_PROXY:-未设置}"
echo "HTTPS_PROXY: ${HTTPS_PROXY:-未设置}"
echo "NO_PROXY: ${NO_PROXY:-未设置}"

# 防火墙检测
echo "🛡️ 防火墙状态:"
if command -v ufw >/dev/null; then
    sudo ufw status
elif command -v firewall-cmd >/dev/null; then
    sudo firewall-cmd --state
else
    echo "未检测到常见防火墙"
fi

EOF

chmod +x ccs-network-test.sh
./ccs-network-test.sh
```

### 3. 配置文件分析

**配置文件健康检查：**
```bash
# 创建配置分析脚本
cat > ccs-config-analyzer.sh << 'EOF'
#!/bin/bash

CONFIG_FILE="$HOME/.ccs_config.toml"

echo "🔍 CCS 配置文件分析"
echo "=================="

# 文件基本信息
echo "📁 文件信息:"
ls -la "$CONFIG_FILE"
echo "文件大小: $(du -h "$CONFIG_FILE" | cut -f1)"
echo "最后修改: $(stat -c %y "$CONFIG_FILE")"

# TOML语法检查
echo "📝 语法检查:"
if command -v toml-test >/dev/null; then
    toml-test "$CONFIG_FILE" && echo "✅ TOML语法正确" || echo "❌ TOML语法错误"
else
    python3 -c "import toml; toml.load('$CONFIG_FILE')" 2>/dev/null && echo "✅ TOML语法正确" || echo "❌ TOML语法错误"
fi

# 配置统计
echo "📊 配置统计:"
echo "配置数量: $(grep -c '\[.*\]' "$CONFIG_FILE" | grep -v default_config)"
echo "总行数: $(wc -l < "$CONFIG_FILE")"
echo "空行数: $(grep -c '^$' "$CONFIG_FILE")"
echo "注释行数: $(grep -c '^#' "$CONFIG_FILE")"

# 字段完整性检查
echo "🔍 字段完整性:"
grep -A 10 '\[.*\]' "$CONFIG_FILE" | grep -E '(base_url|auth_token)' | wc -l

# 敏感信息检查
echo "🔐 敏感信息检查:"
if grep -q 'auth_token.*sk-' "$CONFIG_FILE"; then
    echo "⚠️  发现明文API密钥"
else
    echo "✅ 未发现明文API密钥"
fi

EOF

chmod +x ccs-config-analyzer.sh
./ccs-config-analyzer.sh
```

### 4. 系统资源监控

**资源使用监控：**
```bash
# 创建资源监控脚本
cat > ccs-resource-monitor.sh << 'EOF'
#!/bin/bash

echo "📊 CCS 资源使用监控"
echo "=================="

# CPU使用率
echo "💻 CPU使用率:"
top -b -n1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1

# 内存使用
echo "🧠 内存使用:"
free -h

# 磁盘使用
echo "💾 磁盘使用:"
df -h ~

# CCS进程信息
echo "🔍 CCS进程:"
ps aux | grep -E "(ccs|bash.*ccs)" | grep -v grep

# 网络连接
echo "🌐 网络连接:"
netstat -an | grep -E "(443|80)" | head -5

# 文件句柄
echo "📁 文件句柄:"
lsof | grep ccs | wc -l

EOF

chmod +x ccs-resource-monitor.sh
./ccs-resource-monitor.sh
```

## 🆘 获取帮助

### 1. 内置帮助

**使用内置帮助系统：**
```bash
# 显示主帮助
ccs --help
ccs -h

# 显示特定命令帮助
ccs switch --help
ccs create --help
ccs validate --help

# 显示版本信息
ccs --version
ccs -v

# 显示配置信息
ccs info
ccs about
```

### 2. 生成诊断报告

**创建完整诊断报告：**
```bash
# 生成诊断报告
ccs diagnose --full --output ~/ccs-diagnostic-report.txt

# 或手动创建
cat > ~/ccs-diagnostic-report.txt << EOF
CCS 诊断报告
生成时间: $(date)
系统信息: $(uname -a)
CCS版本: $(ccs --version)

=== 系统诊断 ===
$(ccs diagnose)

=== 配置验证 ===
$(ccs validate --all)

=== 环境变量 ===
$(env | grep -E "(CCS|OPENAI|ANTHROPIC|GOOGLE)_")

=== 网络测试 ===
$(ping -c 3 api.openai.com)

=== 文件权限 ===
$(ls -la ~/.ccs_config.toml ~/.ccs/)

=== 错误日志 ===
$(tail -50 ~/.ccs/logs/error.log 2>/dev/null || echo "无错误日志")
EOF

echo "📋 诊断报告已生成: ~/ccs-diagnostic-report.txt"
```

### 3. 社区支持

**获取社区帮助：**
```bash
# 查看项目文档
echo "📚 项目文档: https://github.com/user/ccs/wiki"

# 搜索已知问题
echo "🔍 已知问题: https://github.com/user/ccs/issues"

# 提交问题报告
echo "🐛 问题报告: https://github.com/user/ccs/issues/new"

# 社区讨论
echo "💬 社区讨论: https://github.com/user/ccs/discussions"

# 联系方式
echo "📧 邮件支持: support@ccs-project.org"
```

**问题报告模板：**
```markdown
## 问题描述
简要描述遇到的问题

## 重现步骤
1. 执行命令: `ccs switch openai-gpt4`
2. 观察到的错误信息
3. 预期的行为

## 环境信息
- 操作系统: Linux Ubuntu 22.04
- Shell: bash 5.1.16
- CCS版本: 1.2.3
- Python版本: 3.10.6

## 错误信息
```
粘贴完整的错误信息
```

## 诊断信息
```
粘贴 `ccs diagnose` 的输出
```

## 已尝试的解决方案
- 尝试了重新安装
- 检查了配置文件格式
- 验证了网络连接
```

### 4. 自助修复工具

**创建自动修复脚本：**
```bash
#!/bin/bash
# ccs-auto-fix.sh

echo "🔧 CCS 自动修复工具"
echo "=================="

# 检查并修复常见问题
fix_permissions() {
    echo "🔐 修复文件权限..."
    chmod 644 ~/.ccs_config.toml 2>/dev/null
    chmod 755 ~/.ccs/ 2>/dev/null
    echo "✅ 权限修复完成"
}

fix_config_format() {
    echo "📝 检查配置格式..."
    if ! ccs validate --format >/dev/null 2>&1; then
        echo "⚠️  配置格式有误,尝试修复..."
        cp ~/.ccs_config.toml ~/.ccs_config.toml.backup
        # 简单的格式修复
        sed -i 's/\([^"]*\)=\([^"]*[^"\s]\)$/\1="\2"/' ~/.ccs_config.toml
        echo "✅ 配置格式修复完成"
    else
        echo "✅ 配置格式正确"
    fi
}

fix_environment() {
    echo "🌍 修复环境变量..."
    if ! env | grep -q CCS_CURRENT_CONFIG; then
        source ~/.ccs/scripts/shell/ccs.sh
        echo "✅ 环境变量已重新加载"
    else
        echo "✅ 环境变量正常"
    fi
}

fix_network() {
    echo "🌐 检查网络连接..."
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo "❌ 网络连接异常,请检查网络设置"
        return 1
    else
        echo "✅ 网络连接正常"
    fi
}

# 执行修复
fix_permissions
fix_config_format
fix_environment
fix_network

echo "🎉 自动修复完成！"
echo "💡 如果问题仍然存在,请运行: ccs diagnose --full"
```

---

**相关文档**：
- [快速开始](quick-start.md) - 快速上手指南
- [安装指南](installation.md) - 详细安装说明
- [配置管理](configuration.md) - 配置文件详解
- [命令行使用](cli-usage.md) - 命令行工具使用
- [Web界面](web-interface.md) - Web界面使用