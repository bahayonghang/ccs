# CCS (Claude Code Switcher)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Rust](https://img.shields.io/badge/rust-%23000000.svg?style=flat&logo=rust&logoColor=white)](https://www.rust-lang.org/)

🚀 **跨平台 AI API 配置管理工具**

快速切换多个 AI API 服务配置的命令行工具。支持 Claude、GPT、GLM 等主流 AI 服务，让 API 配置管理变得简单高效。

[English](README.md) | 中文

![实际效果](assets/imgs/screenshot1.png)

## 🚀 快速开始

### 安装

**Linux/macOS:**
```bash
curl -L https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.ps1 | iex
```

### 设置

安装后配置：
1. 重新打开终端（或运行 `source ~/.bashrc`）
2. 编辑配置文件：`~/.ccs_config.toml`
3. 填入API密钥并开始使用：`ccs list` → `ccs [配置名]`

## ✨ 功能特性

- 🔄 **一键切换** - 快速切换 API 提供商
- 🌐 **Web 界面** - 可视化配置管理
- 🔧 **跨平台** - 支持 Linux、macOS、Windows
- 🐚 **多 Shell** - 支持 Bash、Zsh、Fish、PowerShell
- 🔗 **全局持久化** - 配置在所有终端间同步
- 📝 **简单配置** - 人类可读的 TOML 格式

## 📝 配置

编辑 `~/.ccs_config.toml`：

```toml
default_config = "anthropic"

[anthropic]
description = "Anthropic 官方 API"
base_url = "https://api.anthropic.com"
auth_token = "sk-ant-your-api-key-here"

[openai]
description = "OpenAI API"
base_url = "https://api.openai.com/v1"
auth_token = "sk-your-openai-api-key-here"
model = "gpt-4"

[custom]
description = "自定义 API 提供商"
base_url = "https://your-api-provider.com"
auth_token = "your-api-key-here"
```

**关键字段：**
- `base_url`: API 端点
- `auth_token`: 您的 API 密钥
- `model`: 模型名称（Claude API 可选）

## 📖 使用方法

```bash
# 基本用法
ccs [配置名]                # 切换到指定配置
ccs list                    # 列出所有配置
ccs current                 # 显示当前配置状态

# 管理命令
ccs web                     # 启动Web配置界面
ccs update                  # 自动更新CCS到最新版本
ccs backup                  # 备份当前配置文件
ccs verify                  # 验证配置文件完整性
ccs clear-cache             # 清理配置缓存
ccs uninstall               # 卸载CCS工具

# 信息命令
ccs version                 # 显示版本信息
ccs help                    # 显示帮助信息

# 调试命令
ccs --debug [命令]          # 启用调试模式运行命令
```

### 🔗 全局配置持久化

CCS支持全局配置持久化,解决了传统环境变量作用域限制：

```bash
# 终端1
ccs glm              # 切换到GLM配置

# 终端2（新打开）
echo $ANTHROPIC_MODEL # 自动显示: glm-4
```

- ✅ 在任意终端切换配置,其他新终端自动继承
- ✅ 重启电脑后配置保持不变
- ✅ 支持Bash、Zsh、Fish等多种Shell

## 🔄 自动更新

CCS 提供便捷的自动更新功能，无需手动执行复杂的安装命令：

```bash
ccs update                  # 自动更新到最新版本
```

### 更新功能特性

- ✅ **智能路径检测** - 自动搜索安装脚本位置
- ✅ **配置保护** - 自动备份现有配置文件
- ✅ **完整更新** - 更新所有脚本文件和Web界面
- ✅ **环境刷新** - 自动刷新Shell环境配置
- ✅ **错误处理** - 详细的错误信息和解决建议

### 更新过程

1. **搜索安装脚本** - 在多个可能位置查找 `install.sh`
2. **备份配置** - 自动备份当前配置到 `~/.ccs/backups/`
3. **执行更新** - 运行安装脚本更新所有组件
4. **验证完成** - 确认更新成功并提供后续操作指导

### 注意事项

⚠️ **更新后操作**：
- 重新启动终端，或运行 `source ~/.bashrc`（Bash）/ `source ~/.config/fish/config.fish`（Fish）
- 运行 `ccs version` 确认版本更新成功

⚠️ **故障排除**：
- 确保在CCS项目目录中运行，或确保默认安装路径存在
- 检查网络连接和磁盘空间
- 如更新失败，可手动运行：`cd /path/to/ccs && ./scripts/install/install.sh`

## 🌐 Web 界面

启动 Web 界面进行可视化配置管理：

```bash
ccs web                     # 启动Web界面（自动检测端口）
```

访问显示的URL来：
- 可视化编辑配置
- 一键切换配置
- 实时查看配置状态

## 🗑️ 卸载

```bash
ccs uninstall  # 推荐方式
```

或使用安装脚本：
```bash
./scripts/install/install.sh --uninstall
```

## 🔧 环境变量

ccs会自动设置以下环境变量：
- `ANTHROPIC_BASE_URL`: API端点地址
- `ANTHROPIC_AUTH_TOKEN`: API认证令牌
- `ANTHROPIC_MODEL`: 模型名称（可选,留空使用默认模型）
- `ANTHROPIC_SMALL_FAST_MODEL`: 快速模型名称（可选）

### 💡 模型设置逻辑

- **有值时**: 设置对应的环境变量
- **空值时**: 不设置环境变量,由Claude Code工具使用默认模型
- **建议**: Claude API服务留空model字段,非Claude服务明确指定model

## 🛠️ 故障排除

### Windows PowerShell 语法错误

**问题**: 在Windows中运行PowerShell时出现语法错误：
```
Missing closing ')' in expression.
Unexpected token 'PATH", $newPath, "User")' in expression or statement.
```

**解决方案**: 此问题已在最新版本中修复。如果仍遇到问题：

1. **重新安装**：
   ```powershell
   ccs uninstall
   # 然后重新运行安装脚本
   ```

2. **检查PowerShell版本**：
   ```powershell
   $PSVersionTable.PSVersion
   ```

3. **设置执行策略**（如需要）：
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

### 配置文件更新验证失败

**问题**: 切换配置时显示"❌ 配置文件更新验证失败"但功能正常。

**原因**: 早期版本的配置验证逻辑在某些情况下可能误报失败。

**解决方案**: 此问题已在最新版本中修复,使用了更健壮的验证方法。如果仍遇到问题：

1. **更新脚本**：
   ```bash
   cp scripts/shell/ccs.sh ~/.ccs/
   ```

2. **重新测试配置切换**：
   ```bash
   ccs list
   ccs [配置名称]
   ```

### 其他常见问题

- **配置文件不存在**: 运行安装脚本重新创建配置文件
- **命令未找到**: 重新打开终端或检查PATH环境变量
- **API连接失败**: 检查网络连接和API密钥是否正确

## 🔧 开发

```bash
# 克隆并构建
git clone https://github.com/your-username/ccs.git
cd ccs
cargo build --release

# 运行测试
cargo test

# 本地安装
cargo install --path .
```

## 📄 许可证

MIT License