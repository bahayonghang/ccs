# Claude Code Configuration Switcher (CCS) v2.0.0

一键切换不同的 Claude Code API 配置。跨平台支持 Linux、macOS 和 Windows，配备先进的缓存系统、性能优化和完善的错误处理机制。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-blue.svg)](#)

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

## 🍎 macOS 特殊处理策略

**Fish Shell 专用策略**：在 macOS 系统上，CCS 实施 fish-only 安装策略以确保最佳兼容性：

- **自动检测**：安装脚本自动检测 macOS 环境
- **Fish 专用配置**：仅配置 Fish shell，跳过 Bash 和 Zsh 集成
- **Bash 3.2 兼容性**：处理 macOS 默认 Bash 3.2 的限制（不支持关联数组）
- **清洁安装**：移除任何现有的 Bash 脚本以保持纯净的 fish-only 设置
- **零影响**：完全不触碰现有的 Bash/Zsh 配置

**为什么在 macOS 上只用 Fish？**
- macOS 自带过时的 Bash 3.2（缺乏现代功能）
- Fish 提供卓越的用户体验和现代 shell 特性
- 避免与旧版 shell 的兼容性问题
- 保持不同 shell 环境间的清洁分离

**macOS 上的安装行为：**
```bash
# 安装过程中，您会看到：
"🍎 检测到 macOS - 仅配置 Fish shell"
"⚠️  跳过 Bash/Zsh 配置（Fish 专用策略）"
"✅ Fish shell 配置成功"
```

**验证安装：**
```bash
# 检查安装结果
ls ~/.ccs/          # 应该只显示 ccs.fish（没有 ccs.sh）
grep ccs ~/.zshrc   # 应该返回 "No CCS configuration found"
fish -c "ccs version"  # 应该完美工作
```

## ✨ 功能特性

### 核心功能
- 🔄 **一键切换** - 瞬间切换 API 提供商（< 50ms）
- 🌐 **Web 界面** - 可视化配置管理，支持实时验证
- 🔧 **跨平台支持** - 兼容 Linux、macOS、Windows
- 🐚 **多 Shell 支持** - 支持 Bash 4.0+、Zsh、Fish 3.0+、PowerShell 5.1+
- 🔗 **全局持久化** - 配置在所有终端和会话间持久保存
- 📝 **简洁配置** - 人类可读的 TOML 格式

### 高级特性 (v2.0.0)
- ⚡ **智能缓存** - 配置缓存系统（300秒 TTL，5倍速度提升）
- 🔁 **自动重试** - 智能重试机制（最多3次尝试）
- 📊 **性能监控** - 内置性能追踪和指标统计
- 🛡️ **安全增强** - 全面的安全检查和文件权限验证
- 🔍 **高级诊断** - 详细的系统诊断和错误报告
- 📝 **结构化日志** - 多级日志系统（DEBUG/INFO/WARN/ERROR）
- 💾 **自动备份** - 自动配置备份（最多保留10个版本）
- 🎯 **错误处理** - 13种不同的错误码和详细解决方案

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

### 基本命令
```bash
# 配置管理
ccs [配置名]                # 切换到指定配置
ccs list                    # 列出所有可用配置
ccs current                 # 显示当前配置状态

# 管理命令
ccs web                     # 启动 Web 配置界面
ccs update                  # 自动更新 CCS 到最新版本
ccs backup                  # 备份当前配置文件
ccs verify                  # 验证配置文件完整性
ccs clear-cache             # 清除配置缓存

# 系统命令
ccs diagnose                # 运行全面的系统诊断
ccs uninstall               # 卸载 CCS 工具
ccs version                 # 显示版本信息
ccs help                    # 显示帮助信息
```

### 调试模式
```bash
# 启用调试模式进行详细故障排查
ccs --debug [命令]          # 以调试模式运行指定命令
export CCS_DEBUG=1          # 全局启用调试模式
export CCS_LOG_LEVEL=0      # 设置日志级别为 DEBUG（0=DEBUG, 1=INFO, 2=WARN, 3=ERROR）
```

### 环境变量
```bash
# 性能调优
export CCS_CACHE_TTL=300    # 缓存生存时间（秒），默认：300
export CCS_MAX_RETRIES=3    # 最大重试次数，默认：3
export CCS_TIMEOUT=30       # 操作超时时间（秒），默认：30

# 横幅控制
export CCS_DISABLE_BANNER=true  # 禁用横幅显示
export NO_BANNER=1              # 另一种禁用横幅的标志
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

## 🛠️ 高级特性

### 🏎️ 性能优化 (v2.0.0)

CCS v2.0.0 引入了全面的性能优化：

- **智能配置缓存**
  - 通过智能缓存将解析时间减少5倍
  - 可配置的 TTL（默认：300秒）
  - 基于文件修改时间的自动缓存失效
  - 内存高效，自动清理过期条目

- **快速 TOML 解析器**
  - 优化的基于 AWK 的解析器，O(n) 复杂度
  - 单次遍历解析算法
  - 最小内存占用（典型使用 <10MB）

- **懒加载**
  - 仅在需要时加载配置
  - 后台加载以提升响应速度
  - 启动时间 <50ms 完成配置切换

- **性能指标**
  ```bash
  ccs cache-stats       # 显示缓存性能统计
  ccs status           # 显示系统状态和性能概览
  ```

### 🔍 系统诊断

全面的诊断功能用于故障排查：

```bash
# 运行完整系统诊断
ccs diagnose

# 诊断检查包括：
# - 配置文件验证
# - TOML 语法验证
# - 环境变量状态
# - Shell 集成验证
# - 文件权限检查
# - 缓存系统状态
# - 网络连接（用于更新检查）
```

### 🛡️ 安全特性

v2.0.0 内置的安全增强功能：

- **文件权限验证**
  - 安装期间自动权限检查
  - 配置文件设置为 600（仅所有者可读写）
  - 检测过于宽松的权限（777）

- **PATH 安全检查**
  - 检测空 PATH 元素
  - 警告可疑的环境变量（LD_PRELOAD）

- **敏感数据脱敏**
  - API 令牌仅显示前10个字符
  - 日志和输出中自动脱敏
  - 安全的备份文件创建

- **输入验证**
  - 全面的 TOML 语法验证
  - 配置字段验证
  - 用户输入的净化处理

### 💾 备份和恢复

自动和手动备份功能：

```bash
ccs backup            # 创建手动备份
ccs restore [文件]    # 从备份文件恢复
```

**备份特性**：
- ✅ **自动备份**：配置更改前自动备份
- ✅ **版本控制**：带时间戳的多个备份版本（最多10个）
- ✅ **安全恢复**：安全回滚到以前的配置
- ✅ **跨平台**：备份文件可在不同操作系统间使用
- ✅ **备份位置**：`~/.ccs/backups/`（Windows 上为 `%USERPROFILE%\.ccs\backups\`）

### 🌐 Web 界面

```bash
ccs web               # 启动 Web 配置界面
```

**Web 界面特性**：
- **可视化配置**：点击式配置管理
- **实时验证**：即时配置验证和错误检查
- **导入/导出**：轻松配置备份和共享
- **无外部依赖**：纯 HTML/CSS/JavaScript 实现
- **自动端口选择**：自动查找可用端口启动 HTTP 服务器

## 📁 架构

### 项目结构

```
CCS/
├── scripts/
│   ├── shell/              # Linux/macOS 的 Shell 脚本
│   │   ├── ccs.sh         # Bash/Zsh 主脚本
│   │   ├── ccs.fish       # Fish shell 实现
│   │   ├── ccs-common.sh  # 工具库（v2.0 带缓存）
│   │   └── banner.sh      # ASCII 横幅显示
│   ├── install/           # 安装脚本
│   │   ├── install.sh     # 主安装器（Linux/macOS）
│   │   └── quick_install/ # 一键安装脚本
│   └── windows/           # Windows PowerShell/Batch 脚本
├── config/                # 配置模板
│   └── .ccs_config.toml.example
├── web/                   # Web 管理界面
│   └── index.html
└── docs/                  # 文档

安装结构：
~/.ccs/（Windows 上为 %USERPROFILE%\.ccs\）
├── ccs.sh / ccs.fish / ccs.ps1  # 平台特定脚本
├── ccs-common.sh                # 共享工具
├── banner.sh                    # 横幅显示
├── web/index.html               # Web 界面
├── backups/                     # 配置备份（最多10个）
└── logs/                        # 安装日志
```

### 系统要求

**最低要求**：
- **Linux**：任何主流发行版，配备 Bash 4.0+ 或 Fish 3.0+
- **macOS**：10.12+（推荐 Fish 3.0+，因 Bash 3.2 限制）
- **Windows**：Windows 7+ 配备 PowerShell 5.1+
- **磁盘空间**：~5MB（含缓存和备份）
- **内存**：<10MB 典型使用量

**可选依赖**：
- `curl` 或 `wget` - 用于下载和更新
- `python3` 或 `python` - 用于 Web 界面 HTTP 服务器
- `shellcheck` - 用于开发时的脚本验证

## 🎨 横幅显示

CCS 包含一个精美的 ASCII 艺术横幅，在运行命令时显示。横幅以现代、简洁的风格展示了 CCS 标志和项目信息。

```
██████╗ ██████╗ ███████╗
██╔════╝██╔════╝██╔════╝
██║     ██║     ███████╗
██║     ██║          ██║
╚██████╗╚██████╗███████║
 ╚═════╝ ╚═════╝╚══════╝

Claude Code Configuration Switcher
```

### 横幅命令

```bash
# 显示完整横幅
just banner

# 显示简化版横幅（紧凑版本）
just banner-mini

# 显示纯文本横幅（无颜色）
just banner-plain
```

### 横幅集成

横幅会在您运行 CCS 命令时自动出现：
```bash
ccs list                   # 显示横幅 + 列出配置
ccs current               # 显示横幅 + 当前状态
ccs anyrouter            # 显示横幅 + 切换配置
```

### 禁用横幅

如果您希望禁用横幅显示：
```bash
# 临时禁用
export CCS_DISABLE_BANNER=true
export NO_BANNER=1

# 或添加到shell配置文件中永久禁用
echo 'export CCS_DISABLE_BANNER=true' >> ~/.bashrc
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

## 🆘 故障排除

### 常见问题及解决方案

**1. 安装后找不到命令**
```bash
# 解决方案 1：重新加载 shell 配置
source ~/.bashrc          # Bash
source ~/.zshrc           # Zsh
source ~/.config/fish/config.fish  # Fish

# 解决方案 2：检查 PATH
echo $PATH | grep .ccs    # 应显示 PATH 中包含 ~/.ccs

# 解决方案 3：验证安装
ls -la ~/.ccs/            # 检查文件是否存在
cat ~/.bashrc | grep ccs  # 检查 shell 集成
```

**2. 配置不持久化**
```bash
# 运行诊断
ccs diagnose              # 全面系统检查
ccs status                # 检查当前状态

# 验证配置文件
cat ~/.ccs_config.toml | grep current_config

# 检查文件权限
ls -la ~/.ccs_config.toml # 应为 -rw------- (600)

# 手动修复权限
chmod 600 ~/.ccs_config.toml
```

**3. Web 界面无法工作**
```bash
# 检查 Python 可用性
python3 --version || python --version

# 安装 Python（macOS）
brew install python3

# 安装 Python（Linux）
sudo apt install python3    # Debian/Ubuntu
sudo dnf install python3    # Fedora/RHEL

# 检查防火墙设置
sudo ufw status             # Linux
```

**4. 权限被拒绝错误**
```bash
# 修复文件权限
chmod 600 ~/.ccs_config.toml
chmod 755 ~/.ccs/*.sh
chmod 755 ~/.ccs/*.fish

# 修复目录权限
chmod 755 ~/.ccs
chmod 755 ~/.ccs/backups
```

**5. 缓存问题**
```bash
# 清除缓存并重试
ccs clear-cache
ccs list

# 检查缓存统计
ccs cache-stats

# 调整缓存设置
export CCS_CACHE_TTL=0    # 临时禁用缓存
```

**6. 环境变量未设置**
```bash
# 检查当前环境
env | grep ANTHROPIC

# 验证配置已加载
ccs current

# 强制重新加载配置
ccs [配置名]

# 检查错误
ccs --debug current
```

### 错误码参考

CCS 使用 13 种不同的错误码进行精确故障排查：

| 代码 | 含义 | 常见解决方案 |
|------|------|-------------|
| 0 | 成功 | - |
| 1 | 配置文件缺失 | 运行 `ccs --install` 或安装脚本 |
| 2 | 配置无效 | 检查 TOML 语法，验证必需字段 |
| 3 | 下载失败 | 检查网络、代理、防火墙设置 |
| 4 | 权限被拒绝 | 使用 `chmod 600` 修复文件权限 |
| 5 | 文件未找到 | 重新安装 CCS 或检查文件路径 |
| 6 | 无效参数 | 使用 `ccs help` 检查命令语法 |
| 7 | 网络不可达 | 检查互联网连接 |
| 8 | 缺少依赖 | 安装所需工具（curl、python 等）|
| 9 | 配置损坏 | 从备份恢复或重新创建配置 |
| 10 | 资源忙 | 关闭冲突的进程 |
| 11 | 超时 | 增加 `CCS_TIMEOUT` 值 |
| 12 | 认证失败 | 验证 API 令牌有效性 |
| 99 | 未知错误 | 运行 `ccs diagnose` 获取详情 |

### 调试模式

启用全面的调试日志进行详细故障排查：

```bash
# 方法 1：单命令调试
ccs --debug list              # 对特定命令启用调试模式
ccs --debug current           # 显示详细环境信息

# 方法 2：全局调试模式
export CCS_DEBUG=1            # 启用调试输出
export CCS_LOG_LEVEL=0        # 设置为 DEBUG 级别

# 方法 3：记录到文件
export CCS_LOG_FILE=~/ccs_debug.log
ccs --debug [命令] 2>&1 | tee ~/ccs_debug.log

# 查看安装日志
ls ~/.ccs/logs/               # 安装日志目录
tail -f ~/.ccs/logs/install_*.log  # 监视最新的安装日志
```

**调试输出包括**：
- 配置解析详情
- 缓存命中/未命中统计
- 环境变量更改
- 函数调用跟踪
- TOML 解析器操作
- 文件 I/O 操作
- 错误堆栈跟踪

## 🔧 开发

### 从源码构建

```bash
git clone https://github.com/bahayonghang/ccs.git
cd ccs
make install  # 或者: just install
```

### 测试

```bash
make test          # 运行基本功能测试
make test-all      # 测试所有 shell 脚本
make check-syntax  # 检查脚本语法
```

### 开发命令

```bash
just --list        # 显示所有可用命令
just install       # 安装 CCS 到系统
just test          # 运行测试
just web           # 启动 Web 界面
```

## 📊 性能

CCS v2.0.0 针对性能进行了高度优化：

- **配置切换**：< 50ms 典型值（比 v1.x 快5倍）
- **内存使用**：< 10MB 典型值，高效清理
- **启动时间**：< 50ms shell 初始化
- **缓存命中率**：预热后 > 90%
- **TOML 解析**：O(n) 复杂度，单次遍历
- **磁盘使用**：~2MB 安装 + ~3MB 缓存/备份

**性能调优**：
```bash
export CCS_CACHE_TTL=600     # 增加缓存生存时间以提升性能
export CCS_MAX_RETRIES=5     # 为不可靠网络增加重试次数
export CCS_TIMEOUT=60        # 为慢速连接增加超时时间
```

## 🛡️ 安全

CCS v2.0.0 实施了全面的安全措施：

### 数据保护
- **敏感信息脱敏**：API 密钥仅显示前10个字符（例如：`sk-ant-abc***`）
- **安全文件权限**：配置文件设置为 `600`（仅所有者可读写）
- **无遥测**：零数据收集，所有操作在本地执行
- **本地处理**：所有操作仅在本地机器执行

### 安全验证
- **权限检查**：自动检测过于宽松的文件权限（777）
- **PATH 安全**：检测空 PATH 元素和安全风险
- **环境验证**：警告可疑变量（LD_PRELOAD）
- **输入净化**：所有用户输入都经过验证和净化
- **TOML 验证**：全面的语法和结构验证

### 安装安全
```bash
# 安装期间的安全检查
- 验证脚本权限
- 检查 PATH 安全性
- 验证文件完整性
- 创建安全的备份文件
- 自动设置严格权限
```

### 最佳实践
```bash
# 验证文件权限
ls -la ~/.ccs_config.toml        # 应显示：-rw------- (600)

# 检查安全问题
ccs diagnose                      # 包含安全验证

# 启用安全日志
export CCS_LOG_LEVEL=0           # 记录所有安全事件
```

## 🤝 贡献

我们欢迎贡献！请查看我们的[贡献指南](CONTRIBUTING.md)了解详情。

### 开发设置

```bash
git clone https://github.com/bahayonghang/ccs.git
cd ccs
# 设置开发环境
./scripts/dev/setup.sh
```

### 代码风格

- 遵循现有代码规范
- 为新功能添加测试
- 根据需要更新文档
- 确保跨平台兼容性

## 📋 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- **Claude Code** - 提供了出色的 AI 编码助手
- **开源社区** - 提供工具和灵感
- **贡献者** - 提供错误报告、功能请求和代码贡献

## 📞 支持

- **问题反馈**：[GitHub Issues](https://github.com/bahayonghang/ccs/issues)
- **讨论交流**：[GitHub Discussions](https://github.com/bahayonghang/ccs/discussions)
- **文档资料**：[Wiki](https://github.com/bahayonghang/ccs/wiki)
- **版本发布**：[Releases](https://github.com/bahayonghang/ccs/releases)

---

**⭐ 如果这个项目对您有帮助，请给它一个星标！**

**🔄 CCS - 让 Claude Code 配置管理变得简单高效**