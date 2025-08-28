# CLAUDE.md

[Root Directory](../../CLAUDE.md) > [scripts](../) > **windows**

## Windows 脚本模块

### 模块职责

Windows 脚本模块负责 Windows 环境下的核心功能实现，包括：
- Windows CMD 和 PowerShell 环境支持
- 配置文件解析和环境变量管理
- Windows 特定的安装和配置
- 系统注册表和 PATH 环境变量管理
- 与 Linux/macOS 版本功能对等

### 入口和启动

#### 主要入口点
- **ccs.ps1**: PowerShell 主脚本，包含 `ccs()` 主函数
- **ccs.bat**: 批处理脚本，兼容 Windows 7+

#### 启动流程
1. 用户运行 `ccs` 命令
2. 根据环境选择合适的脚本（PowerShell 或 CMD）
3. 解析配置文件并设置环境变量
4. 根据参数调用相应的处理函数

### 外部接口

#### 公共命令接口
```cmd
ccs [配置名称]        # 切换到指定配置
ccs list              # 列出所有配置
ccs current           # 显示当前配置
ccs uninstall         # 卸载工具
ccs help              # 显示帮助信息
```

#### PowerShell 特有功能
- 彩色输出支持
- 错误处理和异常管理
- 系统环境变量持久化

#### CMD 特有功能
- 兼容 Windows 7+
- 纯批处理实现
- 注册表操作

### 关键依赖和配置

#### 系统要求
- **Windows**: 7+ (ccs.bat), 支持 PowerShell 5.1+
- **PowerShell**: 5.1+ (推荐)
- **CMD**: 内置命令支持

#### 配置文件
- **位置**: `%USERPROFILE%\.ccs_config.toml`
- **格式**: TOML
- **编码**: UTF-8

#### Windows 特定依赖
- **PowerShell**: 用于高级功能和错误处理
- **注册表**: 用于环境变量持久化
- **文件系统**: Windows 路径和权限管理

#### 依赖关系
```
ccs.ps1/ccs.bat
├── %USERPROFILE%\.ccs_config.toml (读取)
└── %USERPROFILE%\.ccs\ (安装目录)
    ├── ccs.ps1 (PowerShell 脚本)
    ├── ccs.bat (批处理脚本)
    └── web\index.html (Web 界面)
```

### 数据模型

#### 配置数据结构
```toml
# 全局配置
default_config = "config_name"

# 配置节
[config_name]
description = "配置描述"
base_url = "https://api.example.com"
auth_token = "sk-api-key"
model = "model-name"  # 可选
small_fast_model = "fast-model-name"  # 可选
```

#### 环境变量持久化
- **用户环境变量**: 使用 `[Environment]::SetEnvironmentVariable()`
- **系统环境变量**: 需要管理员权限
- **当前会话**: 直接设置 `$env:` 变量

### 测试和质量

#### 测试策略
- **功能测试**: 验证所有命令功能正常
- **兼容性测试**: 确保在不同 Windows 版本下工作
- **权限测试**: 验证管理员和普通用户权限
- **环境测试**: 验证环境变量持久化

#### 质量工具
- **PowerShell Script Analyzer**: 静态代码分析
- **错误处理**: 结构化异常处理
- **日志记录**: 分级输出和信息显示
- **配置验证**: 自动配置文件验证

#### 测试方法
```powershell
# 测试 PowerShell 脚本
.\scripts\windows\ccs.ps1 list
.\scripts\windows\ccs.ps1 current
.\scripts\windows\ccs.ps1 [config_name]

# 测试批处理脚本
.\scripts\windows\ccs.bat list
.\scripts\windows\ccs.bat current
```

### 关键函数说明

#### ccs.ps1 核心函数
- `Parse-Toml(configName)`: 解析指定配置
- `List-Configs()`: 列出所有可用配置
- `Show-Current()`: 显示当前环境变量设置
- `Uninstall-CCS()`: 卸载工具
- `Show-Help()`: 显示帮助信息
- `ccs(command)`: 主函数，命令分发

#### ccs.bat 核心函数
- `:parse_toml`: 解析指定配置
- `:list_configs`: 列出所有可用配置
- `:show_current`: 显示当前环境变量设置
- `:ccs_uninstall`: 卸载工具
- `:ccs_help`: 显示帮助信息
- `:validate_config_file`: 配置文件验证

#### Windows 特有功能
- **注册表操作**: 修改用户环境变量
- **PATH 管理**: 添加/移除目录到 PATH
- **文件权限**: Windows 文件系统权限处理
- **服务管理**: Windows 服务相关操作

### 常见问题

#### PowerShell 执行策略
- **问题**: 脚本执行被阻止
- **解决**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

#### 环境变量持久化
- **问题**: 环境变量在重启后丢失
- **解决**: 使用 `[Environment]::SetEnvironmentVariable()` 设置用户环境变量

#### 权限问题
- **问题**: 无法修改系统环境变量
- **解决**: 需要管理员权限，或只修改用户环境变量

#### 配置文件编码
- **问题**: 配置文件包含中文字符
- **解决**: 确保文件使用 UTF-8 编码保存

#### 路径问题
- **问题**: Windows 路径分隔符问题
- **解决**: 使用反斜杠 `\` 或双反斜杠 `\\`

### 相关文件列表

#### 核心文件
- `scripts/windows/ccs.ps1` - PowerShell 主脚本
- `scripts/windows/ccs.bat` - 批处理脚本

#### 相关文件
- `config/.ccs_config.toml.example` - 配置文件示例
- `scripts/install/install.bat` - Windows 安装脚本
- `web/index.html` - Web 管理界面

### 与 Linux/macOS 版本的区别

#### 功能差异
- **Web 界面**: Windows 版本不支持 `ccs web` 命令
- **安装方式**: 使用 Windows 特定的安装脚本
- **环境变量**: 使用 Windows 环境变量管理机制

#### 实现差异
- **脚本语言**: PowerShell vs Bash
- **配置文件路径**: Windows 用户目录 vs Linux/macOS 主目录
- **权限管理**: Windows ACL vs Unix 权限

### Change Log (Changelog)

#### 2025-08-28 23:46:58
- ✨ 创建 Windows 脚本模块文档
- 📝 完善函数说明和接口描述
- 🔧 添加 Windows 特有功能说明
- 📋 补充常见问题和解决方案
- 🔄 添加与 Linux/macOS 版本对比