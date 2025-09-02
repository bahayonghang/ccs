# Claude Code Configuration Switcher (CCS) - Justfile
# 集中管理项目的所有开发、构建和测试命令
#
# 📋 使用前请先安装 just:
#   Ubuntu/Debian: sudo snap install just
#   macOS: brew install just
#   其他系统: https://github.com/casey/just#installation
#
# 🚀 快速开始:
#   just --list          # 显示所有命令
#   just quickstart       # 快速安装和配置
#   just help            # 显示CCS帮助

# 设置默认配置
set shell := ["bash", "-c"]
set dotenv-load := true

# 显示所有可用命令
default:
    @echo "📋 CCS Justfile - 可用命令列表"
    @echo "================================"
    @just --list

# 🚀 安装和配置
# ================

# 安装CCS到系统 (Linux/macOS)
install:
    @echo "📦 安装CCS到系统..."
    cd scripts/install && bash install.sh
    @echo "✅ 安装完成！请重新打开终端使用"

# 安装CCS到系统 (Windows)
install-windows:
    @echo "📦 安装CCS到Windows系统..."
    cd scripts/install && cmd.exe /c install.bat
    @echo "✅ 安装完成！请重新打开终端使用"

# 快速安装 (一键安装脚本)
quick-install:
    @echo "🚀 执行快速安装..."
    curl -L https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.sh | bash

# 卸载CCS
uninstall:
    @echo "🗑️ 卸载CCS..."
    cd scripts/install && bash install.sh --uninstall
    @echo "✅ 卸载完成"

# 🧪 测试和验证
# ================

# 运行基本测试
test:
    @echo "🧪 运行基本功能测试..."
    bash scripts/shell/ccs.sh list
    @echo "✅ 测试完成"

# 测试所有Shell脚本
test-all:
    @echo "🧪 测试所有Shell脚本..."
    @echo "测试Bash脚本:"
    bash scripts/shell/ccs.sh help
    @echo "测试Fish脚本:"
    fish scripts/shell/ccs.fish help || echo "Fish未安装，跳过测试"
    @echo "✅ 所有测试完成"

# 验证配置文件格式
validate-config:
    @echo "📋 验证配置文件格式..."
    @if [ -f "config/.ccs_config.toml.example" ]; then \
        echo "✅ 示例配置文件存在"; \
    else \
        echo "❌ 示例配置文件不存在"; \
        exit 1; \
    fi
    @if [ -f "~/.ccs_config.toml" ]; then \
        echo "✅ 用户配置文件存在"; \
    else \
        echo "⚠️ 用户配置文件不存在，请先安装"; \
    fi

# 🌐 Web界面管理
# ================

# 启动Web管理界面
web:
    @echo "🌐 启动Web管理界面..."
    @echo "请在浏览器中访问显示的地址"
    bash scripts/shell/ccs.sh web

# 启动本地HTTP服务器 (用于开发Web界面)
web-dev:
    @echo "🌐 启动开发Web服务器..."
    @echo "访问 http://localhost:8000"
    cd web && python3 -m http.server 8000 || python -m SimpleHTTPServer 8000

# 🔧 开发和维护
# ================

# 检查项目结构
check-structure:
    @echo "📁 检查项目结构..."
    @echo "核心脚本文件:"
    @ls -la scripts/shell/ || echo "❌ Shell脚本目录不存在"
    @echo "\n安装脚本:"
    @ls -la scripts/install/ || echo "❌ 安装脚本目录不存在"
    @echo "\nWeb界面:"
    @ls -la web/ || echo "❌ Web目录不存在"
    @echo "\n配置文件:"
    @ls -la config/ || echo "❌ 配置目录不存在"
    @echo "\n文档:"
    @ls -la docs/ || echo "❌ 文档目录不存在"

# 检查脚本语法
check-syntax:
    @echo "🔍 检查脚本语法..."
    @echo "检查Bash脚本:"
    bash -n scripts/shell/ccs.sh && echo "✅ ccs.sh 语法正确" || echo "❌ ccs.sh 语法错误"
    bash -n scripts/shell/ccs-common.sh && echo "✅ ccs-common.sh 语法正确" || echo "❌ ccs-common.sh 语法错误"
    bash -n scripts/install/install.sh && echo "✅ install.sh 语法正确" || echo "❌ install.sh 语法错误"
    @echo "检查Fish脚本:"
    fish -n scripts/shell/ccs.fish && echo "✅ ccs.fish 语法正确" || echo "⚠️ Fish未安装或语法错误"

# 格式化代码
format:
    @echo "🎨 格式化代码..."
    @echo "格式化Shell脚本..."
    @command -v shfmt >/dev/null 2>&1 && shfmt -w scripts/shell/*.sh || echo "⚠️ shfmt未安装，跳过格式化"
    @echo "✅ 格式化完成"

# 🔄 配置管理
# ================

# 列出所有配置
list-configs:
    @echo "📋 列出所有配置..."
    bash scripts/shell/ccs.sh list

# 显示当前配置
current-config:
    @echo "📍 显示当前配置..."
    bash scripts/shell/ccs.sh current

# 切换到指定配置
switch-config CONFIG:
    @echo "🔄 切换到配置: {{CONFIG}}"
    bash scripts/shell/ccs.sh {{CONFIG}}

# 编辑配置文件
edit-config:
    @echo "📝 编辑配置文件..."
    ${EDITOR:-nano} ~/.ccs_config.toml

# 备份配置文件
backup-config:
    @echo "💾 备份配置文件..."
    cp ~/.ccs_config.toml ~/.ccs_config.toml.backup.$(date +%Y%m%d_%H%M%S)
    @echo "✅ 配置文件已备份"

# 恢复配置文件
restore-config BACKUP_FILE:
    @echo "🔄 恢复配置文件..."
    cp {{BACKUP_FILE}} ~/.ccs_config.toml
    @echo "✅ 配置文件已恢复"

# 📦 构建和发布
# ================

# 创建发布包
build:
    @echo "📦 创建发布包..."
    @mkdir -p dist
    @echo "复制核心文件..."
    cp -r scripts dist/
    cp -r config dist/
    cp -r web dist/
    cp -r docs dist/
    cp README.md dist/
    cp package.json dist/
    @echo "✅ 发布包已创建在 dist/ 目录"

# 清理构建文件
clean:
    @echo "🧹 清理构建文件..."
    rm -rf dist/
    @echo "✅ 清理完成"

# 检查发布准备
check-release:
    @echo "🔍 检查发布准备..."
    @echo "检查版本信息..."
    @grep -E '^\s*"version"' package.json || echo "❌ 版本信息不存在"
    @echo "检查README文件..."
    @[ -f "README.md" ] && echo "✅ README.md 存在" || echo "❌ README.md 不存在"
    @echo "检查许可证..."
    @grep -i "MIT" README.md && echo "✅ 许可证信息存在" || echo "❌ 许可证信息不存在"
    @echo "检查核心脚本..."
    @[ -f "scripts/shell/ccs.sh" ] && echo "✅ 核心脚本存在" || echo "❌ 核心脚本不存在"

# 📚 文档和帮助
# ================

# 显示CCS帮助
help:
    @echo "📚 显示CCS帮助信息..."
    bash scripts/shell/ccs.sh help

# 生成文档
docs:
    @echo "📚 生成文档..."
    @echo "当前文档结构:"
    @ls -la docs/
    @echo "\n主要文档文件:"
    @echo "- README.md: 主要说明文档"
    @echo "- docs/: 详细文档目录"
    @echo "- config/.ccs_config.toml.example: 配置示例"

# 检查文档链接
check-docs:
    @echo "🔍 检查文档链接..."
    @echo "检查README中的图片链接..."
    @grep -o 'assets/imgs/[^)]*' README.md | while read img; do \
        if [ -f "$$img" ]; then \
            echo "✅ $$img 存在"; \
        else \
            echo "❌ $$img 不存在"; \
        fi; \
    done

# 🛠️ 故障排除
# ================

# 诊断系统环境
diagnose:
    @echo "🔍 诊断系统环境..."
    @echo "操作系统信息:"
    @uname -a
    @echo "\nShell环境:"
    @echo "当前Shell: $SHELL"
    @echo "Bash版本: $(bash --version | head -1)"
    @command -v fish >/dev/null 2>&1 && echo "Fish版本: $(fish --version)" || echo "Fish: 未安装"
    @echo "\n环境变量:"
    @env | grep -E '^(ANTHROPIC|CCS)' || echo "未找到相关环境变量"
    @echo "\n配置文件状态:"
    @[ -f "~/.ccs_config.toml" ] && echo "✅ 用户配置存在" || echo "❌ 用户配置不存在"
    @[ -d "~/.ccs" ] && echo "✅ CCS目录存在" || echo "❌ CCS目录不存在"

# 修复权限问题
fix-permissions:
    @echo "🔧 修复文件权限..."
    chmod +x scripts/shell/*.sh
    chmod +x scripts/shell/*.fish
    chmod +x scripts/install/*.sh
    @echo "✅ 权限修复完成"

# 重新安装 (修复损坏的安装)
reinstall:
    @echo "🔄 重新安装CCS..."
    @echo "1. 卸载现有安装..."
    just uninstall || echo "卸载失败，继续安装"
    @echo "2. 重新安装..."
    just install
    @echo "✅ 重新安装完成"

# 🧹 维护任务
# ================

# 更新脚本到用户目录
update-scripts:
    @echo "🔄 更新用户目录中的脚本..."
    @if [ -d "~/.ccs" ]; then \
        cp scripts/shell/ccs.sh ~/.ccs/ && echo "✅ ccs.sh 已更新"; \
        cp scripts/shell/ccs.fish ~/.ccs/ && echo "✅ ccs.fish 已更新"; \
        cp scripts/shell/ccs-common.sh ~/.ccs/ && echo "✅ ccs-common.sh 已更新"; \
    else \
        echo "❌ ~/.ccs 目录不存在，请先安装"; \
    fi

# 检查更新
check-updates:
    @echo "🔍 检查更新..."
    @echo "当前版本: $(grep '"version"' package.json | cut -d'"' -f4)"
    @echo "检查远程仓库更新..."
    @git fetch origin main 2>/dev/null || echo "无法连接到远程仓库"
    @git log HEAD..origin/main --oneline 2>/dev/null || echo "已是最新版本或无法检查更新"

# 全面检查项目健康状态
health-check:
    @echo "🏥 项目健康检查..."
    just check-structure
    just check-syntax
    just validate-config
    just diagnose
    @echo "\n✅ 健康检查完成"

# 🎯 快捷命令
# ================

# 快速开始 (安装并配置)
quickstart:
    @echo "🚀 快速开始..."
    just install
    @echo "\n📝 请编辑配置文件: ~/.ccs_config.toml"
    @echo "📚 使用 'just help' 查看更多命令"

# 开发者设置 (安装开发依赖)
dev-setup:
    @echo "👨‍💻 开发者环境设置..."
    @command -v shfmt >/dev/null 2>&1 || echo "建议安装 shfmt: go install mvdan.cc/sh/v3/cmd/shfmt@latest"
    @command -v shellcheck >/dev/null 2>&1 || echo "建议安装 shellcheck: apt install shellcheck 或 brew install shellcheck"
    just fix-permissions
    @echo "✅ 开发环境设置完成"

# 完整测试套件
full-test:
    @echo "🧪 运行完整测试套件..."
    just check-syntax
    just test-all
    just validate-config
    just check-docs
    @echo "✅ 完整测试完成"