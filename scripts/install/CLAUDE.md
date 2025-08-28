# CLAUDE.md

[Root Directory](../../CLAUDE.md) > [scripts](../) > **install**

## 安装系统模块

### 模块职责

安装系统模块负责 CCS 工具的跨平台安装、配置和卸载，包括：
- 自动检测用户环境和 Shell 类型
- 创建和配置用户目录结构
- 设置 Shell 配置文件集成
- 处理文件权限和路径配置
- 提供一键安装和卸载功能

### 入口和启动

#### 主要入口点
- **install.sh**: Linux/macOS 安装脚本
- **install.bat**: Windows 安装脚本
- **quick_install/quick_install.sh**: Linux/macOS 一键安装
- **quick_install/quick_install.bat**: Windows 一键安装

#### 启动流程
1. 用户运行安装脚本
2. 检测系统环境和依赖
3. 创建必要的目录结构
4. 复制和配置脚本文件
5. 更新 Shell 配置文件
6. 验证安装结果

### 外部接口

#### 安装命令接口
```bash
# Linux/macOS
./scripts/install/install.sh                    # 标准安装
./scripts/install/install.sh --uninstall        # 卸载
./scripts/install/quick_install/quick_install.sh # 一键安装

# Windows
.\scripts\install\install.bat                    # 标准安装
.\scripts\install\quick_install\quick_install.bat # 一键安装
```

#### 配置接口
- **Shell 检测**: 自动检测当前 Shell 类型
- **路径配置**: 设置脚本安装路径
- **环境变量**: 配置 PATH 环境变量（Windows）
- **权限设置**: 设置脚本文件执行权限

#### 用户交互接口
- **确认提示**: 询问用户是否继续安装
- **进度显示**: 显示安装进度和状态
- **错误处理**: 提供详细的错误信息和解决方案

### 关键依赖和配置

#### 系统要求
- **Linux**: 任意主流发行版
- **macOS**: 10.12+
- **Windows**: 7+ (PowerShell 5.1+)
- **Shell**: Bash 4.0+, Zsh, Fish 3.0+, PowerShell 5.1+

#### 外部工具依赖
- **curl/wget**: 用于下载文件
- **Python**: 用于 Web 界面 HTTP 服务器
- **PowerShell**: Windows 环境支持
- **Git**: 用于版本控制（可选）

#### 配置文件
- **用户配置**: `~/.ccs_config.toml` 或 `%USERPROFILE%\.ccs_config.toml`
- **Shell 配置**: `.bashrc`, `.zshrc`, Fish 配置文件
- **PowerShell 配置**: PowerShell profile 文件

#### 目录结构
```
~/.ccs/ (或 %USERPROFILE%\.ccs\)
├── ccs.sh/ccs.fish/ccs.ps1/ccs.bat  # 平台特定脚本
├── ccs-common.sh                    # 通用工具库
├── web/
│   └── index.html                   # Web 界面
└── backups/                         # 配置文件备份
```

### 数据模型

#### 安装配置数据
```toml
# 安装过程中创建的配置
default_config = "anyrouter"
current_config = "anyrouter"

# Shell 配置文件内容
# Linux/macOS: ~/.bashrc, ~/.zshrc, ~/.config/fish/config.fish
# Windows: PowerShell profile
```

#### 安装状态跟踪
- **文件存在性检查**: 验证文件是否正确安装
- **权限验证**: 确保脚本文件有执行权限
- **路径配置**: 验证 PATH 环境变量设置
- **Shell 集成**: 验证 Shell 配置文件更新

### 测试和质量

#### 测试策略
- **安装测试**: 验证完整安装流程
- **卸载测试**: 验证完整卸载流程
- **跨平台测试**: 确保在不同操作系统下正常工作
- **Shell 兼容性**: 测试不同 Shell 类型的集成

#### 质量保证
- **错误处理**: 详细的错误信息和解决方案
- **回滚机制**: 安装失败时的清理操作
- **备份功能**: 自动备份现有配置文件
- **验证步骤**: 安装后的功能验证

#### 测试方法
```bash
# 测试 Linux/macOS 安装
./scripts/install/install.sh
source ~/.bashrc  # 或相应的 Shell 配置
ccs list
ccs current

# 测试卸载
./scripts/install/install.sh --uninstall

# 测试一键安装
./scripts/install/quick_install/quick_install.sh
```

### 关键函数说明

#### install.sh 核心函数
- `detect_shell()`: 检测当前 Shell 类型
- `shell_config_exists()`: 检查 Shell 配置文件是否存在
- `configure_shell_for_type()`: 配置特定 Shell 环境
- `copy_script()`: 复制脚本文件到用户目录
- `create_config_file()`: 创建初始配置文件
- `setup_shell_integration()`: 设置 Shell 集成

#### install.bat 核心功能
- **PowerShell 检查**: 验证 PowerShell 可用性
- **目录创建**: 创建 `.ccs` 目录结构
- **文件复制**: 复制脚本文件
- **PATH 设置**: 添加到 Windows PATH
- **注册表操作**: 修改环境变量

#### quick_install 脚本
- **网络下载**: 从 GitHub 下载安装脚本
- **自动执行**: 直接运行下载的安装脚本
- **错误处理**: 网络错误和权限错误处理

### 常见问题

#### 权限问题
- **问题**: 无法创建目录或写入文件
- **解决**: 检查用户权限，必要时使用 sudo（不推荐）

#### Shell 配置问题
- **问题**: Shell 配置文件无法更新
- **解决**: 检查文件权限和用户主目录

#### PATH 环境变量
- **问题**: 命令未找到
- **解决**: 重新启动终端或手动加载配置文件

#### 网络问题
- **问题**: 无法下载文件
- **解决**: 检查网络连接和代理设置

#### Windows 特定问题
- **问题**: PowerShell 执行策略阻止脚本运行
- **解决**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### 相关文件列表

#### 核心文件
- `scripts/install/install.sh` - Linux/macOS 安装脚本
- `scripts/install/install.bat` - Windows 安装脚本
- `scripts/install/quick_install/quick_install.sh` - Linux/macOS 一键安装
- `scripts/install/quick_install/quick_install.bat` - Windows 一键安装

#### 相关文件
- `scripts/shell/ccs.sh` - Bash 主脚本
- `scripts/shell/ccs.fish` - Fish 脚本
- `scripts/shell/ccs-common.sh` - 通用工具库
- `scripts/windows/ccs.ps1` - PowerShell 脚本
- `scripts/windows/ccs.bat` - 批处理脚本
- `config/.ccs_config.toml.example` - 配置文件示例

### 安装流程详解

#### Linux/macOS 安装流程
1. 检测系统环境（操作系统、Shell 类型）
2. 创建 `~/.ccs/` 目录结构
3. 复制脚本文件到 `~/.ccs/`
4. 设置文件权限（755）
5. 创建配置文件 `~/.ccs_config.toml`
6. 更新 Shell 配置文件（`.bashrc`, `.zshrc`, Fish 配置）
7. 验证安装结果

#### Windows 安装流程
1. 检查 PowerShell 可用性
2. 创建 `%USERPROFILE%\.ccs\` 目录结构
3. 复制脚本文件到 `.ccs\`
4. 配置 PowerShell profile
5. 设置 PATH 环境变量
6. 创建配置文件 `%USERPROFILE%\.ccs_config.toml`
7. 验证安装结果

### 卸载流程详解

#### Linux/macOS 卸载流程
1. 备份现有配置文件
2. 删除 `~/.ccs/` 目录中的脚本文件
3. 从 Shell 配置文件中移除 CCS 配置
4. 询问是否删除配置文件
5. 清理临时文件

#### Windows 卸载流程
1. 备份现有配置文件
2. 删除 `%USERPROFILE%\.ccs\` 目录中的脚本文件
3. 从 PATH 环境变量中移除 CCS 目录
4. 从 PowerShell profile 中移除 CCS 配置
5. 询问是否删除配置文件
6. 清理注册表项

### Change Log (Changelog)

#### 2025-08-28 23:46:58
- ✨ 创建安装系统模块文档
- 📝 完善安装流程和函数说明
- 🔧 添加跨平台支持说明
- 📋 补充常见问题和解决方案
- 🔄 添加详细的安装卸载流程