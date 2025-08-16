# 安装指南

CCS (Claude Code Configuration Switcher) 支持多种安装方式,适用于不同的操作系统和使用场景。

## 🚀 一键安装（推荐）

### Linux/macOS

```bash
# 一键安装脚本
curl -L https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.sh | bash
```

### Windows

1. 下载安装脚本：
   ```
   https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.bat
   ```

2. 右键以管理员身份运行下载的 `.bat` 文件

## 📦 手动安装

### 1. 克隆项目

```bash
git clone https://github.com/bahayonghang/ccs.git
cd ccs
```

### 2. 运行安装脚本

#### Linux/macOS
```bash
cd scripts/install
bash install.sh
```

#### Windows (CMD)
```cmd
cd scripts\install
install.bat
```

#### Windows (PowerShell)
```powershell
cd scripts\install
.\install.bat
```

## 🔧 安装过程详解

### 安装脚本执行的操作

1. **创建目录结构**
   ```
   ~/.ccs/                 # 主目录
   ├── ccs.sh             # Bash脚本
   ├── ccs.fish           # Fish脚本
   ├── ccs-common.sh      # 通用工具库
   └── web/               # Web界面文件
       └── index.html
   ```

2. **复制脚本文件**
   - 将核心脚本复制到 `~/.ccs/` 目录
   - 设置正确的文件权限（755）
   - 复制Web界面文件

3. **创建配置文件**
   ```bash
   ~/.ccs_config.toml     # 主配置文件
   ```

4. **配置Shell环境**
   - 自动检测当前Shell类型
   - 添加PATH环境变量
   - 配置Shell启动脚本

### Shell配置详情

#### Bash/Zsh配置
安装脚本会在 `~/.bashrc` 或 `~/.zshrc` 中添加：
```bash
# CCS (Claude Code Configuration Switcher)
if [ -f "$HOME/.ccs/ccs.sh" ]; then
    alias ccs="$HOME/.ccs/ccs.sh"
    # 自动加载当前配置
    source "$HOME/.ccs/ccs.sh" load_current_config 2>/dev/null || true
fi
```

#### Fish Shell配置
在 `~/.config/fish/config.fish` 中添加：
```fish
# CCS (Claude Code Configuration Switcher)
if test -f "$HOME/.ccs/ccs.fish"
    alias ccs="$HOME/.ccs/ccs.fish"
    # 自动加载当前配置
    source "$HOME/.ccs/ccs.fish"
    load_current_config
end
```

#### Windows PowerShell配置
在PowerShell配置文件中添加：
```powershell
# CCS (Claude Code Configuration Switcher)
$ccsPath = "$env:USERPROFILE\.ccs\ccs.ps1"
if (Test-Path $ccsPath) {
    Set-Alias ccs $ccsPath
    # 自动加载当前配置
    & $ccsPath load_current_config
}
```

## ✅ 安装验证

### 1. 重启终端
安装完成后,请重新打开终端或运行以下命令：

```bash
# Bash/Zsh
source ~/.bashrc
# 或
source ~/.zshrc

# Fish
source ~/.config/fish/config.fish
```

### 2. 验证安装
```bash
# 检查命令是否可用
ccs help

# 查看版本信息
ccs list

# 检查配置文件
ls -la ~/.ccs_config.toml
```

### 3. 预期输出
```
Claude Code Configuration Switcher (CCS)

用法:
  ccs [配置名称]    - 切换到指定配置
  ccs list          - 列出所有可用配置
  ccs current       - 显示当前配置
  ccs web           - 启动Web管理界面
  ccs help          - 显示帮助信息
```

## 🔄 重新安装/更新

如果CCS已经安装,再次运行安装脚本将执行更新操作：

```bash
# 更新所有脚本文件
bash install.sh
```

更新过程：
- ✅ 强制更新所有shell脚本文件
- ✅ 保留现有配置文件不变
- ✅ 不重复添加shell配置
- ✅ 更新Web界面文件

## 🗑️ 卸载

### 使用CCS命令卸载（推荐）
```bash
ccs uninstall
```

### 使用安装脚本卸载
```bash
cd scripts/install
bash install.sh --uninstall
```

### 手动卸载
如果自动卸载失败,可以手动删除：

```bash
# 删除CCS目录
rm -rf ~/.ccs

# 删除配置文件
rm -f ~/.ccs_config.toml

# 手动编辑Shell配置文件,删除CCS相关行
# ~/.bashrc, ~/.zshrc, ~/.config/fish/config.fish
```

## 🚨 常见安装问题

### 权限问题
```bash
# 如果遇到权限错误,确保有写入权限
chmod +w ~/.bashrc ~/.zshrc

# 或者使用sudo（不推荐）
sudo bash install.sh
```

### Shell配置未生效
```bash
# 手动重新加载配置
source ~/.bashrc
# 或重启终端
```

### 配置文件格式错误
```bash
# 重新生成配置文件
rm ~/.ccs_config.toml
bash install.sh
```

### Windows路径问题
- 确保使用反斜杠 `\` 作为路径分隔符
- 避免路径中包含空格和特殊字符
- 以管理员身份运行安装脚本

## 📋 系统要求

### Linux/macOS
- **Bash**: >= 4.0
- **Fish**: >= 3.0 (可选)
- **工具**: curl, sed, grep, mktemp

### Windows
- **PowerShell**: >= 5.1
- **CMD**: 支持批处理脚本
- **权限**: 管理员权限（推荐）

## 🔧 高级安装选项

### 自定义安装路径
```bash
# 设置自定义安装目录
export CCS_INSTALL_DIR="/opt/ccs"
bash install.sh
```

### 静默安装
```bash
# 无交互安装
bash install.sh --silent
```

### 仅安装特定Shell支持
```bash
# 仅安装Bash支持
bash install.sh --shell=bash

# 仅安装Fish支持
bash install.sh --shell=fish
```

---

**下一步**: 查看 [快速入门指南](quick-start.md) 开始使用CCS