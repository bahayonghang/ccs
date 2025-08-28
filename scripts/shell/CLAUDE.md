# CLAUDE.md

[Root Directory](../../CLAUDE.md) > [scripts](../) > **shell**

## Shell 脚本模块

### 模块职责

Shell 脚本模块负责 Linux/macOS 环境下的核心功能实现，包括：
- 配置文件解析和环境变量管理
- 多 Shell 环境支持（Bash、Zsh、Fish）
- 命令行接口和用户交互
- 配置切换和持久化
- Web 界面启动支持

### 入口和启动

#### 主要入口点
- **ccs.sh**: Bash 主脚本，包含 `ccs()` 主函数
- **ccs.fish**: Fish shell 实现，包含 `ccs()` 主函数
- **ccs-common.sh**: 通用工具库，被其他脚本 source

#### 启动流程
1. 用户运行 `ccs` 命令
2. Shell 配置文件中的 sourcing 机制加载对应脚本
3. 自动调用 `load_current_config()` 加载当前配置
4. 根据参数调用相应的处理函数

### 外部接口

#### 公共命令接口
```bash
ccs [配置名称]        # 切换到指定配置
ccs list              # 列出所有配置
ccs current           # 显示当前配置
ccs web               # 启动 Web 管理界面
ccs version           # 显示版本信息
ccs uninstall         # 卸载工具
ccs help              # 显示帮助信息
```

#### Fish 自动补全
- **函数**: `__ccs_complete`
- **功能**: 为 Fish shell 提供配置名称自动补全

#### 环境变量接口
- `ANTHROPIC_BASE_URL`
- `ANTHROPIC_AUTH_TOKEN`
- `ANTHROPIC_MODEL`
- `ANTHROPIC_SMALL_FAST_MODEL`

### 关键依赖和配置

#### 外部依赖
- **Bash**: >= 4.0 (用于 ccs.sh)
- **Fish**: >= 3.0 (用于 ccs.fish)
- **Core Utils**: grep, sed, awk, find 等
- **网络工具**: curl, wget (用于下载和安装)
- **Python**: python3 或 python (用于 Web 界面 HTTP 服务器)

#### 配置文件
- **位置**: `~/.ccs_config.toml`
- **格式**: TOML
- **必需字段**: `default_config`, `base_url`, `auth_token`
- **可选字段**: `model`, `small_fast_model`, `description`

#### 依赖关系
```
ccs.sh/ccs.fish
├── ccs-common.sh (source)
├── ~/.ccs_config.toml (读取)
└── ~/.ccs/ (安装目录)
    ├── ccs.sh/ccs.fish (脚本文件)
    ├── ccs-common.sh (工具库)
    └── web/index.html (Web 界面)
```

### 数据模型

#### 配置数据结构
```toml
# 全局配置
default_config = "config_name"
current_config = "config_name"  # 自动管理

# 配置节
[config_name]
description = "配置描述"
base_url = "https://api.example.com"
auth_token = "sk-api-key"
model = "model-name"  # 可选
small_fast_model = "fast-model-name"  # 可选
```

#### 环境变量映射
- 配置节中的字段直接映射到对应的环境变量
- 空值或缺失的字段不会设置对应的环境变量
- 敏感信息（auth_token）在显示时会被部分隐藏

### 测试和质量

#### 测试策略
- **功能测试**: 验证所有命令功能正常
- **兼容性测试**: 确保在不同 Bash/Zsh/Fish 版本下正常工作
- **配置测试**: 验证各种配置格式的解析
- **错误处理测试**: 验证各种错误情况的处理

#### 质量工具
- **ShellCheck**: 静态代码分析
- **日志系统**: 分级日志记录 (DEBUG, INFO, WARN, ERROR)
- **错误码**: 统一的错误码定义
- **配置验证**: 自动配置文件验证

#### 测试方法
```bash
# 测试 Bash 脚本
source ./scripts/shell/ccs.sh
ccs list
ccs current
ccs [config_name]

# 测试 Fish 脚本
source ./scripts/shell/ccs.fish
ccs list
ccs current

# 测试工具库
source ./scripts/shell/ccs-common.sh
validate_config_file ~/.ccs_config.toml
```

### 关键函数说明

#### ccs.sh 核心函数
- `parse_toml(config_name, silent_mode)`: 解析指定配置
- `list_configs()`: 列出所有可用配置
- `show_current()`: 显示当前环境变量设置
- `update_current_config(config_name)`: 更新配置文件中的当前配置
- `load_current_config()`: 自动加载当前配置
- `ccs_uninstall()`: 卸载工具
- `open_web()`: 启动 Web 管理界面

#### ccs.fish 核心函数
- `set_config_env(profile_name, silent_mode)`: 设置配置环境变量
- `update_current_config(config_name)`: 更新当前配置
- `load_current_config()`: 自动加载当前配置
- `show_version()`: 显示版本信息

#### ccs-common.sh 工具函数
- `handle_error(error_code, error_message, show_help)`: 统一错误处理
- `validate_config_file(config_file)`: 配置文件验证
- `validate_toml_syntax(config_file)`: TOML 语法验证
- `backup_file(source, backup_dir)`: 文件备份
- `get_system_info()`: 获取系统信息
- `get_shell_type()`: 获取 Shell 类型

### 常见问题

#### 配置文件问题
- **配置文件不存在**: 运行安装脚本重新创建
- **配置格式错误**: 检查 TOML 语法和必需字段
- **权限问题**: 确保配置文件可读可写

#### 环境变量问题
- **环境变量未设置**: 检查配置是否正确加载
- **变量值不正确**: 验证配置文件中的值
- **变量作用域**: 确保在正确的 Shell 会话中

#### Shell 兼容性
- **Bash 版本**: 需要 Bash 4.0+
- **Fish 版本**: 需要 Fish 3.0+
- **配置文件**: 确保 Shell 配置文件正确 sourcing 脚本

### 相关文件列表

#### 核心文件
- `scripts/shell/ccs.sh` - Bash 主脚本
- `scripts/shell/ccs.fish` - Fish 脚本
- `scripts/shell/ccs-common.sh` - 通用工具库

#### 相关文件
- `config/.ccs_config.toml.example` - 配置文件示例
- `scripts/install/install.sh` - 安装脚本
- `web/index.html` - Web 管理界面
- `package.json` - 项目元数据

### Change Log (Changelog)

#### 2025-08-28 23:46:58
- ✨ 创建 Shell 脚本模块文档
- 📝 完善函数说明和接口描述
- 🔧 添加测试方法和质量工具说明
- 📋 补充常见问题和解决方案