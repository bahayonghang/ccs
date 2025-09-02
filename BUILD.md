# CCS 构建和开发指南

本文档介绍如何使用项目提供的构建工具来管理 Claude Code Configuration Switcher (CCS) 的开发、测试和部署。

## 🛠️ 可用的构建工具

项目提供了两种构建工具供选择：

### 1. Justfile (推荐)
- **文件**: `justfile`
- **命令**: `just <target>`
- **特点**: 功能最完整，语法简洁，支持参数传递
- **安装**: `sudo snap install just` (Ubuntu) 或 `brew install just` (macOS)

### 2. Makefile (备选)
- **文件**: `Makefile`
- **命令**: `make <target>`
- **特点**: 系统自带，无需额外安装，功能相对简化
- **优势**: 在大多数Linux/Unix系统上都可直接使用

## 🚀 快速开始

### 使用 Just (推荐)
```bash
# 安装 just
sudo snap install just  # Ubuntu/Debian
brew install just       # macOS

# 查看所有可用命令
just --list

# 快速安装和配置
just quickstart

# 运行测试
just test
```

### 使用 Make (备选)
```bash
# 查看所有可用命令
make help

# 快速安装和配置
make quickstart

# 运行测试
make test
```

## 📋 主要命令分类

### 🚀 安装和配置
| 命令 | Just | Make | 描述 |
|------|------|------|------|
| 安装到系统 | `just install` | `make install` | Linux/macOS安装 |
| Windows安装 | `just install-windows` | `make install-windows` | Windows系统安装 |
| 快速安装 | `just quick-install` | `make quick-install` | 一键安装脚本 |
| 卸载 | `just uninstall` | `make uninstall` | 卸载CCS |
| 快速开始 | `just quickstart` | `make quickstart` | 安装并配置 |

### 🧪 测试和验证
| 命令 | Just | Make | 描述 |
|------|------|------|------|
| 基本测试 | `just test` | `make test` | 运行基本功能测试 |
| 全面测试 | `just test-all` | `make test-all` | 测试所有Shell脚本 |
| 语法检查 | `just check-syntax` | `make check-syntax` | 检查脚本语法 |
| 完整测试 | `just full-test` | `make health-check` | 运行完整测试套件 |
| 配置验证 | `just validate-config` | - | 验证配置文件格式 |

### 🌐 Web界面管理
| 命令 | Just | Make | 描述 |
|------|------|------|------|
| 启动Web界面 | `just web` | `make web` | 启动Web管理界面 |
| 开发服务器 | `just web-dev` | `make web-dev` | 启动开发Web服务器 |

### 🔄 配置管理
| 命令 | Just | Make | 描述 |
|------|------|------|------|
| 列出配置 | `just list-configs` | `make list-configs` | 列出所有配置 |
| 当前配置 | `just current-config` | `make current-config` | 显示当前配置 |
| 切换配置 | `just switch-config <name>` | - | 切换到指定配置 |
| 编辑配置 | `just edit-config` | `make edit-config` | 编辑配置文件 |
| 备份配置 | `just backup-config` | - | 备份配置文件 |
| 恢复配置 | `just restore-config <file>` | - | 恢复配置文件 |

### 🔧 开发和维护
| 命令 | Just | Make | 描述 |
|------|------|------|------|
| 检查结构 | `just check-structure` | `make check-structure` | 检查项目结构 |
| 系统诊断 | `just diagnose` | `make diagnose` | 诊断系统环境 |
| 健康检查 | `just health-check` | `make health-check` | 全面健康检查 |
| 修复权限 | `just fix-permissions` | `make fix-permissions` | 修复文件权限 |
| 格式化代码 | `just format` | - | 格式化Shell脚本 |
| 更新脚本 | `just update-scripts` | - | 更新用户目录脚本 |

### 📦 构建和发布
| 命令 | Just | Make | 描述 |
|------|------|------|------|
| 创建发布包 | `just build` | - | 创建发布包 |
| 清理构建 | `just clean` | - | 清理构建文件 |
| 检查发布 | `just check-release` | - | 检查发布准备 |
| 检查更新 | `just check-updates` | - | 检查远程更新 |

### 📚 文档和帮助
| 命令 | Just | Make | 描述 |
|------|------|------|------|
| CCS帮助 | `just help` | `make ccs-help` | 显示CCS帮助 |
| 生成文档 | `just docs` | - | 生成文档 |
| 检查文档 | `just check-docs` | - | 检查文档链接 |

## 🎯 常用工作流程

### 开发者首次设置
```bash
# 使用 Just
just dev-setup      # 设置开发环境
just install         # 安装到系统
just test-all        # 运行所有测试

# 使用 Make
make quickstart      # 快速开始
make check-syntax    # 检查语法
make health-check    # 健康检查
```

### 日常开发流程
```bash
# 使用 Just
just check-syntax    # 检查语法
just format          # 格式化代码
just test            # 运行测试
just update-scripts  # 更新脚本

# 使用 Make
make check-syntax    # 检查语法
make test            # 运行测试
make diagnose        # 系统诊断
```

### 发布前检查
```bash
# 使用 Just
just full-test       # 完整测试
just check-release   # 检查发布准备
just build           # 创建发布包

# 使用 Make
make health-check    # 健康检查
make test-all        # 测试所有功能
```

### 故障排除
```bash
# 使用 Just
just diagnose        # 系统诊断
just fix-permissions # 修复权限
just reinstall       # 重新安装

# 使用 Make
make diagnose        # 系统诊断
make fix-permissions # 修复权限
make quickstart      # 重新开始
```

## 🔧 高级功能 (仅Just支持)

### 参数化命令
```bash
# 切换到指定配置
just switch-config anthropic

# 恢复指定的备份文件
just restore-config ~/.ccs_config.toml.backup.20240902_215300
```

### 环境变量支持
```bash
# 使用自定义编辑器
EDITOR=vim just edit-config

# 设置调试模式
DEBUG=1 just test
```

## 📝 自定义和扩展

### 添加新命令

**在 Justfile 中添加:**
```just
# 自定义命令示例
my-custom-task:
    @echo "执行自定义任务..."
    # 你的命令
```

**在 Makefile 中添加:**
```makefile
# 自定义命令示例
my-custom-task:
	@echo "执行自定义任务..."
	# 你的命令
```

### 修改现有命令

1. 编辑对应的构建文件 (`justfile` 或 `Makefile`)
2. 修改相应的命令定义
3. 测试修改后的命令

## 🛠️ 故障排除

### Just 相关问题

**问题**: `just: command not found`
**解决**: 安装 just
```bash
# Ubuntu/Debian
sudo snap install just

# macOS
brew install just

# 其他系统
# 参考: https://github.com/casey/just#installation
```

**问题**: 权限错误
**解决**: 修复文件权限
```bash
just fix-permissions
```

### Make 相关问题

**问题**: `make: *** No rule to make target`
**解决**: 检查命令名称是否正确
```bash
make help  # 查看所有可用命令
```

**问题**: 脚本执行权限问题
**解决**: 修复权限
```bash
make fix-permissions
```

### 通用问题

**问题**: 脚本语法错误
**解决**: 检查语法
```bash
# Just
just check-syntax

# Make
make check-syntax
```

**问题**: 配置文件问题
**解决**: 验证配置
```bash
# Just
just validate-config

# Make
make diagnose
```

## 📚 更多资源

- [Just 官方文档](https://github.com/casey/just)
- [Make 官方文档](https://www.gnu.org/software/make/manual/)
- [CCS 主要文档](README.md)
- [CCS 故障排除](docs/troubleshooting.md)

## 🤝 贡献

如果你想为构建系统添加新功能或改进现有功能：

1. Fork 项目
2. 创建功能分支
3. 修改 `justfile` 和/或 `Makefile`
4. 测试你的更改
5. 提交 Pull Request

请确保新添加的命令在两个构建系统中都有对应的实现（如果可能的话）。