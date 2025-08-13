# Claude Code Configuration Switcher (CCS)

一个用于快速切换不同Claude Code API配置的工具，支持多种Shell环境和Windows环境。

![实际效果](assets/imgs/screenshot1.png)

## 🚀 快速安装

### Linux/macOS
```bash
curl -L https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.sh | bash
```

### Windows
下载并运行：https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.bat

### 安装后配置
1. 重新打开终端
2. 编辑配置文件：`~/.ccs_config.toml`
3. 填入API密钥并开始使用

## ✨ 功能特性

- 🔄 快速切换Claude Code API配置
- 🌐 Web界面管理
- 🔧 支持多平台和多Shell环境
- 📝 TOML配置格式

## 📝 配置文件

配置文件位于 `~/.ccs_config.toml`，示例配置文件在 `config/ccs_config.toml.example`：

```toml
default_config = "anthropic"

[anthropic]
description = "Anthropic官方API"
base_url = "https://api.anthropic.com"
auth_token = "sk-ant-your-api-key-here"
model = "claude-3-sonnet-20240229"
small_fast_model = "claude-3-5-haiku-20241022"

[openai]
description = "OpenAI API配置"
base_url = "https://api.openai.com/v1"
auth_token = "sk-your-api-key-here"
model = "gpt-4"
```

## 📖 使用方法

```bash
ccs list              # 列出所有配置
ccs [配置名称]        # 切换到指定配置
ccs current          # 显示当前配置
ccs web              # 启动Web管理界面
ccs uninstall        # 卸载工具
ccs help             # 显示帮助
ccs                  # 使用默认配置
```

## 🌐 Web界面管理

![Web界面预览](assets/imgs/screenshot2.png)

```bash
ccs web  # 启动Web管理界面
```

通过浏览器访问显示的地址（如 `http://localhost:8888`），可以：
- 可视化管理所有配置
- 在线编辑配置参数
- 实时保存修改

## 🏗️ 项目架构图

```mermaid
graph TD
    A[CCS - Claude Code Configuration Switcher] --> B[用户接口层]
    A --> C[核心脚本层]
    A --> D[配置管理层]
    A --> E[安装部署层]
    A --> F[文档资源层]
    
    B --> B1[命令行接口]
    B --> B2[Web界面]
    B1 --> B11[ccs command]
    B1 --> B12[参数解析]
    B2 --> B21[HTML界面]
    B2 --> B22[配置编辑器]
    
    C --> C1[Shell脚本]
    C --> C2[Windows脚本]
    C1 --> C11[ccs.sh - Bash]
    C1 --> C12[ccs.fish - Fish]
    C2 --> C21[ccs.bat - CMD]
    C2 --> C22[ccs.ps1 - PowerShell]
    
    D --> D1[TOML配置文件]
    D --> D2[环境变量管理]
    D1 --> D11[~/.ccs_config.toml]
    D2 --> D21[ANTHROPIC_BASE_URL]
    D2 --> D22[ANTHROPIC_AUTH_TOKEN]
    D2 --> D23[ANTHROPIC_MODEL]
    D2 --> D24[ANTHROPIC_SMALL_FAST_MODEL]
    
    E --> E1[安装脚本]
    E --> E2[一键安装]
    E1 --> E11[install.sh - Linux/macOS]
    E1 --> E12[install.bat - Windows]
    E2 --> E21[quick_install.sh]
    E2 --> E22[quick_install.bat]
    
    F --> F1[文档]
    F --> F2[资源文件]
    F1 --> F11[README.md]
    F1 --> F12[CLAUDE.md]
    F2 --> F21[截图]
    F2 --> F22[图标]
    
    style A fill:#4A90E2,stroke:#2E5C8A,stroke-width:2px
    style B fill:#7ED321,stroke:#5BA517,stroke-width:1px
    style C fill:#F5A623,stroke:#C17E11,stroke-width:1px
    style D fill:#BD10E0,stroke:#8B0AA6,stroke-width:1px
    style E fill:#50E3C2,stroke:#2FA785,stroke-width:1px
    style F fill:#E85D75,stroke:#B23A4F,stroke-width:1px
```

## 🗂️ 项目结构

```
ccs/
├── scripts/                    # 脚本文件目录
│   ├── shell/                 # Shell脚本
│   │   ├── ccs.sh            # Bash脚本
│   │   └── ccs.fish          # Fish脚本
│   ├── windows/              # Windows脚本
│   │   ├── ccs.bat           # 批处理脚本
│   │   └── ccs.ps1           # PowerShell脚本
│   └── install/              # 安装脚本
│       ├── install.sh        # Linux/macOS安装
│       ├── install.bat       # Windows安装
│       └── quick_install/    # 一键安装
│           ├── quick_install.sh
│           └── quick_install.bat
├── config/                    # 配置文件目录
│   └── ccs_config.toml.example  # 示例配置文件
├── web/                       # Web界面
│   └── index.html
├── docs/                      # 文档目录
│   └── CLAUDE.md
├── assets/                    # 资源文件目录
│   └── imgs/
│       ├── screenshot1.png
│       └── screenshot2.png
├── README.md                  # 项目说明文档
└── package.json              # 项目元数据
```

## 📁 安装后文件结构

```
~/.ccs/                    # 配置目录
├── ccs.sh/.fish/.bat/.ps1 # 各平台脚本
└── web/index.html         # Web界面

~/.ccs_config.toml         # 配置文件
```

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
- `ANTHROPIC_BASE_URL`
- `ANTHROPIC_AUTH_TOKEN` 
- `ANTHROPIC_MODEL`
- `ANTHROPIC_SMALL_FAST_MODEL`（可选）

## 📄 许可证

MIT License