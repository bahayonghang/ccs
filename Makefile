# Claude Code Configuration Switcher (CCS) - Makefile
# 备选方案：如果不想安装just，可以使用make命令
# 使用方法: make <target>

.PHONY: help install install-windows uninstall test web check-structure diagnose

# 默认目标：显示帮助
help:
	@echo "📋 CCS Makefile - 可用命令"
	@echo "==========================="
	@echo "🚀 安装和配置:"
	@echo "  make install          - 安装CCS到系统 (Linux/macOS)"
	@echo "  make install-windows  - 安装CCS到Windows系统"
	@echo "  make quick-install    - 快速安装 (一键安装脚本)"
	@echo "  make uninstall        - 卸载CCS"
	@echo ""
	@echo "🧪 测试和验证:"
	@echo "  make test             - 运行基本测试"
	@echo "  make test-all         - 测试所有Shell脚本"
	@echo "  make check-syntax     - 检查脚本语法"
	@echo ""
	@echo "🌐 Web界面:"
	@echo "  make web              - 启动Web管理界面"
	@echo "  make web-dev          - 启动开发Web服务器"
	@echo ""
	@echo "🔧 开发和维护:"
	@echo "  make check-structure  - 检查项目结构"
	@echo "  make diagnose         - 诊断系统环境"
	@echo "  make health-check     - 全面健康检查"
	@echo ""
	@echo "💡 推荐安装just获得完整功能: sudo snap install just"

# 🚀 安装和配置
install:
	@echo "📦 安装CCS到系统..."
	cd scripts/install && bash install.sh
	@echo "✅ 安装完成！请重新打开终端使用"

install-windows:
	@echo "📦 安装CCS到Windows系统..."
	cd scripts/install && cmd.exe /c install.bat
	@echo "✅ 安装完成！请重新打开终端使用"

quick-install:
	@echo "🚀 执行快速安装..."
	curl -L https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.sh | bash

uninstall:
	@echo "🗑️ 卸载CCS..."
	cd scripts/install && bash install.sh --uninstall
	@echo "✅ 卸载完成"

# 🧪 测试和验证
test:
	@echo "🧪 运行基本功能测试..."
	bash scripts/shell/ccs.sh list
	@echo "✅ 测试完成"

test-all:
	@echo "🧪 测试所有Shell脚本..."
	@echo "测试Bash脚本:"
	bash scripts/shell/ccs.sh help
	@echo "测试Fish脚本:"
	fish scripts/shell/ccs.fish help || echo "Fish未安装，跳过测试"
	@echo "✅ 所有测试完成"

check-syntax:
	@echo "🔍 检查脚本语法..."
	@echo "检查Bash脚本:"
	bash -n scripts/shell/ccs.sh && echo "✅ ccs.sh 语法正确" || echo "❌ ccs.sh 语法错误"
	bash -n scripts/shell/ccs-common.sh && echo "✅ ccs-common.sh 语法正确" || echo "❌ ccs-common.sh 语法错误"
	bash -n scripts/install/install.sh && echo "✅ install.sh 语法正确" || echo "❌ install.sh 语法错误"
	@echo "检查Fish脚本:"
	fish -n scripts/shell/ccs.fish && echo "✅ ccs.fish 语法正确" || echo "⚠️ Fish未安装或语法错误"

# 🌐 Web界面管理
web:
	@echo "🌐 启动Web管理界面..."
	@echo "请在浏览器中访问显示的地址"
	bash scripts/shell/ccs.sh web

web-dev:
	@echo "🌐 启动开发Web服务器..."
	@echo "访问 http://localhost:8000"
	cd web && python3 -m http.server 8000 || python -m SimpleHTTPServer 8000

# 🔧 开发和维护
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

# 🔄 配置管理
list-configs:
	@echo "📋 列出所有配置..."
	bash scripts/shell/ccs.sh list

current-config:
	@echo "📍 显示当前配置..."
	bash scripts/shell/ccs.sh current

edit-config:
	@echo "📝 编辑配置文件..."
	$${EDITOR:-nano} ~/.ccs_config.toml

# 🛠️ 故障排除
diagnose:
	@echo "🔍 诊断系统环境..."
	@echo "操作系统信息:"
	@uname -a
	@echo "\nShell环境:"
	@echo "当前Shell: $$SHELL"
	@echo "Bash版本: $$(bash --version | head -1)"
	@command -v fish >/dev/null 2>&1 && echo "Fish版本: $$(fish --version)" || echo "Fish: 未安装"
	@echo "\n环境变量:"
	@env | grep -E '^(ANTHROPIC|CCS)' || echo "未找到相关环境变量"
	@echo "\n配置文件状态:"
	@[ -f "~/.ccs_config.toml" ] && echo "✅ 用户配置存在" || echo "❌ 用户配置不存在"
	@[ -d "~/.ccs" ] && echo "✅ CCS目录存在" || echo "❌ CCS目录不存在"

fix-permissions:
	@echo "🔧 修复文件权限..."
	chmod +x scripts/shell/*.sh
	chmod +x scripts/shell/*.fish
	chmod +x scripts/install/*.sh
	@echo "✅ 权限修复完成"

# 🧹 维护任务
health-check:
	@echo "🏥 项目健康检查..."
	@$(MAKE) check-structure
	@$(MAKE) check-syntax
	@$(MAKE) diagnose
	@echo "\n✅ 健康检查完成"

# 🎯 快捷命令
quickstart:
	@echo "🚀 快速开始..."
	@$(MAKE) install
	@echo "\n📝 请编辑配置文件: ~/.ccs_config.toml"
	@echo "📚 使用 'make help' 查看更多命令"

# 显示CCS帮助
ccs-help:
	@echo "📚 显示CCS帮助信息..."
	bash scripts/shell/ccs.sh help