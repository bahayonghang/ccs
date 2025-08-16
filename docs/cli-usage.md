# 命令行使用指南

本文档详细介绍 CCS (Claude Code Configuration Switcher) 命令行工具的使用方法、参数说明和高级功能。

## 📋 目录

- [基本语法](#基本语法)
- [核心命令](#核心命令)
- [配置管理](#配置管理)
- [环境变量](#环境变量)
- [高级功能](#高级功能)
- [脚本集成](#脚本集成)
- [故障排除](#故障排除)
- [最佳实践](#最佳实践)

## 🔧 基本语法

### 1. 命令格式

```bash
# 基本格式
ccs [选项] [命令] [参数]

# 显示帮助
ccs --help
ccs -h

# 显示版本信息
ccs --version
ccs -v

# 显示详细输出
ccs --verbose [命令]
ccs -V [命令]
```

### 2. 全局选项

| 选项 | 简写 | 描述 | 示例 |
|------|------|------|------|
| `--help` | `-h` | 显示帮助信息 | `ccs -h` |
| `--version` | `-v` | 显示版本信息 | `ccs -v` |
| `--verbose` | `-V` | 详细输出模式 | `ccs -V list` |
| `--quiet` | `-q` | 静默模式 | `ccs -q switch openai` |
| `--config` | `-c` | 指定配置文件路径 | `ccs -c /path/to/config.toml list` |
| `--dry-run` | `-n` | 预览模式（不执行实际操作） | `ccs -n switch claude` |

### 3. 返回码说明

```bash
# 返回码含义
0   # 成功
1   # 一般错误
2   # 配置文件错误
3   # 网络连接错误
4   # 权限错误
5   # 参数错误
```

## 🎯 核心命令

### 1. 配置切换 (switch)

**基本用法：**
```bash
# 切换到指定配置
ccs switch <配置名称>

# 示例
ccs switch openai-gpt4
ccs switch claude-3
ccs switch local-model
```

**高级选项：**
```bash
# 强制切换（跳过确认）
ccs switch --force openai-gpt4
ccs switch -f openai-gpt4

# 临时切换（不保存为默认）
ccs switch --temporary claude-3
ccs switch -t claude-3

# 切换并验证连接
ccs switch --verify openai-gpt4
ccs switch -V openai-gpt4

# 切换前备份当前配置
ccs switch --backup openai-gpt4
ccs switch -b openai-gpt4
```

**实际使用示例：**
```bash
# 场景1: 开发环境切换到测试API
$ ccs switch test-api
✅ 已切换到配置: test-api
🔗 API地址: https://api-test.example.com
🤖 默认模型: gpt-3.5-turbo
⚡ 快速模型: gpt-3.5-turbo

# 场景2: 生产环境切换（带验证）
$ ccs switch --verify production-api
🔄 正在切换到配置: production-api...
🔗 验证API连接...
✅ API连接正常 (响应时间: 245ms)
✅ 已切换到配置: production-api

# 场景3: 临时切换用于测试
$ ccs switch --temporary --verify claude-3
⚠️  临时切换模式 - 重启Shell后将恢复原配置
🔄 正在切换到配置: claude-3...
🔗 验证API连接...
✅ API连接正常 (响应时间: 189ms)
✅ 临时切换到配置: claude-3
```

### 2. 配置列表 (list)

**基本用法：**
```bash
# 显示所有配置
ccs list
ccs ls  # 简写

# 显示详细信息
ccs list --detailed
ccs list -d

# 只显示配置名称
ccs list --names-only
ccs list -n
```

**输出格式：**
```bash
$ ccs list
📋 CCS 配置列表:

✅ openai-gpt4        [当前] OpenAI GPT-4 官方API
   claude-3           Anthropic Claude-3 API  
   gemini-pro         Google Gemini Pro API
   local-llama        本地 Llama 模型
⚠️  test-api          测试环境API (连接异常)

📊 统计信息:
   总配置数: 5
   正常配置: 4
   异常配置: 1
   当前配置: openai-gpt4
```

**详细模式输出：**
```bash
$ ccs list --detailed
📋 CCS 配置详情:

✅ openai-gpt4 [当前配置]
   📝 描述: OpenAI GPT-4 官方API
   🔗 地址: https://api.openai.com/v1
   🤖 模型: gpt-4
   ⚡ 快速: gpt-3.5-turbo
   📅 更新: 2024-01-15 14:30:25
   🔗 状态: ✅ 连接正常 (245ms)

   claude-3
   📝 描述: Anthropic Claude-3 API
   🔗 地址: https://api.anthropic.com
   🤖 模型: claude-3-opus-20240229
   ⚡ 快速: claude-3-haiku-20240307
   📅 更新: 2024-01-14 09:15:42
   🔗 状态: ✅ 连接正常 (189ms)
```

### 3. 当前状态 (status)

**基本用法：**
```bash
# 显示当前配置状态
ccs status
ccs st  # 简写

# 包含环境变量信息
ccs status --env
ccs status -e

# 测试当前配置连接
ccs status --test
ccs status -t
```

**输出示例：**
```bash
$ ccs status
📊 CCS 当前状态:

🎯 当前配置: openai-gpt4
📝 描述: OpenAI GPT-4 官方API
🔗 API地址: https://api.openai.com/v1
🤖 默认模型: gpt-4
⚡ 快速模型: gpt-3.5-turbo
📅 最后切换: 2024-01-15 14:30:25
🔗 连接状态: ✅ 正常

💾 配置文件: ~/.ccs_config.toml
📁 安装目录: ~/.ccs/
🐚 Shell环境: bash 5.1.16
```

**包含环境变量：**
```bash
$ ccs status --env
📊 CCS 当前状态:

🎯 当前配置: openai-gpt4
📝 描述: OpenAI GPT-4 官方API

🌍 环境变量:
   ANTHROPIC_API_KEY=sk-ant-***
   ANTHROPIC_BASE_URL=https://api.openai.com/v1
   OPENAI_API_KEY=sk-***
   OPENAI_BASE_URL=https://api.openai.com/v1
   CCS_CURRENT_CONFIG=openai-gpt4
   CCS_DEFAULT_MODEL=gpt-4
   CCS_SMALL_FAST_MODEL=gpt-3.5-turbo
```

### 4. 配置验证 (validate)

**基本用法：**
```bash
# 验证所有配置
ccs validate
ccs check  # 简写

# 验证指定配置
ccs validate <配置名称>
ccs validate openai-gpt4

# 验证配置文件格式
ccs validate --format
ccs validate -f

# 详细验证报告
ccs validate --detailed
ccs validate -d
```

**验证输出：**
```bash
$ ccs validate
🔍 验证 CCS 配置...

✅ openai-gpt4
   ✅ 配置格式正确
   ✅ 必需字段完整
   ✅ API连接正常 (245ms)
   ✅ 模型配置有效

✅ claude-3
   ✅ 配置格式正确
   ✅ 必需字段完整
   ✅ API连接正常 (189ms)
   ✅ 模型配置有效

⚠️  test-api
   ✅ 配置格式正确
   ✅ 必需字段完整
   ❌ API连接失败: 连接超时
   ⚠️  模型配置未验证

📊 验证结果:
   总配置: 3
   通过验证: 2
   存在问题: 1
```

## ⚙️ 配置管理

### 1. 创建配置 (create)

**交互式创建：**
```bash
# 交互式创建新配置
ccs create
ccs new  # 简写

# 指定配置名称
ccs create <配置名称>
ccs create my-openai-config
```

**非交互式创建：**
```bash
# 使用参数创建
ccs create my-config \
  --description "我的API配置" \
  --base-url "https://api.example.com/v1" \
  --auth-token "your-api-key" \
  --model "gpt-4" \
  --small-fast-model "gpt-3.5-turbo"

# 从模板创建
ccs create --template openai my-openai-config
ccs create --template claude my-claude-config

# 从现有配置复制
ccs create --copy-from openai-gpt4 my-backup-config
```

**交互式创建示例：**
```bash
$ ccs create
🆕 创建新的 CCS 配置

📝 配置名称: my-openai-config
📝 描述 (可选): 我的OpenAI配置
🔗 API地址: https://api.openai.com/v1
🔑 API密钥: [输入密钥]
🤖 默认模型 (可选): gpt-4
⚡ 快速模型 (可选): gpt-3.5-turbo

🔍 验证配置...
✅ API连接正常
✅ 模型配置有效

💾 保存配置? [Y/n]: y
✅ 配置 'my-openai-config' 已创建

🔄 是否切换到此配置? [Y/n]: y
✅ 已切换到配置: my-openai-config
```

### 2. 编辑配置 (edit)

**基本用法：**
```bash
# 编辑指定配置
ccs edit <配置名称>
ccs edit openai-gpt4

# 使用指定编辑器
ccs edit --editor vim openai-gpt4
ccs edit -e nano openai-gpt4

# 编辑特定字段
ccs edit openai-gpt4 --field model
ccs edit openai-gpt4 --field auth_token
```

**字段编辑示例：**
```bash
$ ccs edit openai-gpt4 --field model
📝 编辑配置字段: model
当前值: gpt-4
新值: gpt-4-turbo

✅ 字段已更新
🔍 验证配置...
✅ 配置验证通过

💾 保存更改? [Y/n]: y
✅ 配置已保存
```

### 3. 删除配置 (delete)

**基本用法：**
```bash
# 删除指定配置
ccs delete <配置名称>
ccs remove <配置名称>  # 别名
ccs rm <配置名称>      # 简写

# 强制删除（跳过确认）
ccs delete --force <配置名称>
ccs delete -f <配置名称>

# 删除前备份
ccs delete --backup <配置名称>
ccs delete -b <配置名称>
```

**删除示例：**
```bash
$ ccs delete test-config
⚠️  确认删除配置 'test-config'?
📝 描述: 测试环境API配置
🔗 地址: https://api-test.example.com

⚠️  此操作不可撤销!

确认删除? [y/N]: y
💾 创建备份: ~/.ccs/backups/test-config-20240115-143025.toml
✅ 配置 'test-config' 已删除
```

### 4. 配置备份和恢复

**备份操作：**
```bash
# 备份所有配置
ccs backup
ccs backup --all

# 备份指定配置
ccs backup <配置名称>
ccs backup openai-gpt4

# 指定备份位置
ccs backup --output /path/to/backup.toml
ccs backup -o ~/my-ccs-backup.toml

# 压缩备份
ccs backup --compress
ccs backup -z
```

**恢复操作：**
```bash
# 从备份恢复
ccs restore <备份文件>
ccs restore ~/.ccs/backups/backup-20240115.toml

# 恢复指定配置
ccs restore --config <配置名称> <备份文件>
ccs restore -c openai-gpt4 backup.toml

# 预览恢复内容
ccs restore --preview backup.toml
ccs restore -p backup.toml
```

## 🌍 环境变量

### 1. 环境变量管理

**查看环境变量：**
```bash
# 显示CCS相关环境变量
ccs env
ccs env list

# 显示所有环境变量
ccs env --all
ccs env -a

# 导出环境变量到文件
ccs env --export > ccs-env.sh
ccs env -e > ccs-env.sh
```

**设置环境变量：**
```bash
# 手动设置环境变量
ccs env set OPENAI_API_KEY "your-api-key"
ccs env set ANTHROPIC_BASE_URL "https://api.anthropic.com"

# 从配置文件加载
ccs env load
ccs env reload

# 清除CCS环境变量
ccs env clear
ccs env unset
```

### 2. 环境变量映射

**CCS自动设置的环境变量：**
```bash
# 通用环境变量
CCS_CURRENT_CONFIG          # 当前配置名称
CCS_CONFIG_FILE             # 配置文件路径
CCS_INSTALL_DIR             # CCS安装目录
CCS_DEFAULT_MODEL           # 默认模型
CCS_SMALL_FAST_MODEL        # 快速模型

# API服务环境变量
OPENAI_API_KEY              # OpenAI API密钥
OPENAI_BASE_URL             # OpenAI API地址
ANTHROPIC_API_KEY           # Anthropic API密钥
ANTHROPIC_BASE_URL          # Anthropic API地址
GOOGLE_API_KEY              # Google API密钥
GOOGLE_BASE_URL             # Google API地址

# 自定义环境变量
CUSTOM_API_KEY              # 自定义API密钥
CUSTOM_BASE_URL             # 自定义API地址
```

**环境变量优先级：**
```bash
# 优先级从高到低
1. 手动设置的环境变量
2. CCS当前配置的环境变量
3. CCS默认配置的环境变量
4. 系统默认环境变量
```

## 🚀 高级功能

### 1. 配置模板系统

**使用预定义模板：**
```bash
# 列出可用模板
ccs template list
ccs template ls

# 查看模板详情
ccs template show openai
ccs template show claude

# 从模板创建配置
ccs template apply openai my-openai-config
ccs template apply claude my-claude-config
```

**创建自定义模板：**
```bash
# 从现有配置创建模板
ccs template create --from-config openai-gpt4 my-openai-template

# 编辑模板
ccs template edit my-openai-template

# 删除模板
ccs template delete my-openai-template
```

**模板文件示例：**
```toml
# ~/.ccs/templates/my-openai-template.toml
[template]
name = "My OpenAI Template"
description = "自定义OpenAI配置模板"
version = "1.0"

[config]
base_url = "https://api.openai.com/v1"
model = "gpt-4"
small_fast_model = "gpt-3.5-turbo"

[variables]
api_key = { required = true, description = "OpenAI API密钥" }
organization = { required = false, description = "组织ID" }
```

### 2. 批量操作

**批量配置管理：**
```bash
# 批量验证配置
ccs batch validate
ccs batch check

# 批量测试连接
ccs batch test
ccs batch ping

# 批量更新字段
ccs batch update --field base_url --value "https://new-api.example.com"

# 批量备份
ccs batch backup --output ~/ccs-batch-backup/
```

**批量操作脚本：**
```bash
#!/bin/bash
# batch-update-models.sh

# 批量更新所有OpenAI配置的模型
for config in $(ccs list --names-only | grep openai); do
    echo "更新配置: $config"
    ccs edit "$config" --field model --value "gpt-4-turbo"
    ccs validate "$config"
done

echo "批量更新完成"
```

### 3. 配置同步

**远程同步：**
```bash
# 推送配置到远程
ccs sync push --remote origin
ccs sync push --url https://git.example.com/my-ccs-configs.git

# 从远程拉取配置
ccs sync pull --remote origin
ccs sync pull --url https://git.example.com/my-ccs-configs.git

# 同步状态检查
ccs sync status
ccs sync diff
```

**本地同步：**
```bash
# 同步到另一个目录
ccs sync local --target /path/to/backup/

# 从另一个CCS安装同步
ccs sync import --source /path/to/other/ccs/

# 双向同步
ccs sync bidirectional --target /path/to/sync/
```

### 4. 插件系统

**插件管理：**
```bash
# 列出可用插件
ccs plugin list
ccs plugin ls

# 安装插件
ccs plugin install <插件名称>
ccs plugin install auto-switch
ccs plugin install config-validator

# 启用/禁用插件
ccs plugin enable auto-switch
ccs plugin disable auto-switch

# 插件配置
ccs plugin config auto-switch
```

**常用插件：**
```bash
# auto-switch: 自动配置切换
ccs plugin install auto-switch
ccs plugin config auto-switch --rule "project:openai -> openai-gpt4"

# config-validator: 增强配置验证
ccs plugin install config-validator
ccs plugin config config-validator --strict-mode

# usage-tracker: 使用统计
ccs plugin install usage-tracker
ccs plugin config usage-tracker --enable-analytics
```

## 🔗 脚本集成

### 1. Shell集成

**Bash集成：**
```bash
# ~/.bashrc
# CCS自动加载
if [ -f ~/.ccs/scripts/shell/ccs.sh ]; then
    source ~/.ccs/scripts/shell/ccs.sh
fi

# 自定义函数
ccs_quick_switch() {
    local config="$1"
    if [ -z "$config" ]; then
        echo "用法: ccs_quick_switch <配置名称>"
        return 1
    fi
    
    ccs switch "$config" && echo "✅ 已切换到: $config"
}

# 别名定义
alias ccs-status='ccs status'
alias ccs-list='ccs list'
alias ccs-openai='ccs switch openai-gpt4'
alias ccs-claude='ccs switch claude-3'
```

**Fish Shell集成：**
```fish
# ~/.config/fish/config.fish
# CCS自动加载
if test -f ~/.ccs/scripts/shell/ccs.fish
    source ~/.ccs/scripts/shell/ccs.fish
end

# 自定义函数
function ccs_quick_switch
    set config $argv[1]
    if test -z "$config"
        echo "用法: ccs_quick_switch <配置名称>"
        return 1
    end
    
    ccs switch "$config"; and echo "✅ 已切换到: $config"
end

# 别名定义
alias ccs-status 'ccs status'
alias ccs-list 'ccs list'
alias ccs-openai 'ccs switch openai-gpt4'
alias ccs-claude 'ccs switch claude-3'
```

### 2. 项目集成

**项目级配置：**
```bash
# 项目根目录创建 .ccsrc
# .ccsrc
CCS_PROJECT_CONFIG="project-specific-config"
CCS_AUTO_SWITCH=true
CCS_BACKUP_ON_SWITCH=true

# 项目启动脚本
#!/bin/bash
# start-project.sh

# 加载项目CCS配置
if [ -f .ccsrc ]; then
    source .ccsrc
    
    if [ "$CCS_AUTO_SWITCH" = "true" ] && [ -n "$CCS_PROJECT_CONFIG" ]; then
        echo "🔄 切换到项目配置: $CCS_PROJECT_CONFIG"
        ccs switch "$CCS_PROJECT_CONFIG"
    fi
fi

# 启动项目
npm start
```

**Git钩子集成：**
```bash
#!/bin/bash
# .git/hooks/post-checkout

# 根据分支自动切换配置
branch=$(git branch --show-current)

case "$branch" in
    "main"|"master")
        ccs switch production-config
        ;;
    "develop")
        ccs switch development-config
        ;;
    "feature/*")
        ccs switch feature-config
        ;;
    *)
        ccs switch default-config
        ;;
esac

echo "✅ 已根据分支 '$branch' 切换CCS配置"
```

### 3. CI/CD集成

**GitHub Actions：**
```yaml
# .github/workflows/test.yml
name: Test with CCS

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install CCS
      run: |
        curl -sSL https://raw.githubusercontent.com/user/ccs/main/scripts/install/quick_install.sh | bash
        
    - name: Setup CCS Configuration
      run: |
        ccs create ci-config \
          --base-url "${{ secrets.API_BASE_URL }}" \
          --auth-token "${{ secrets.API_TOKEN }}" \
          --model "gpt-3.5-turbo"
        ccs switch ci-config
        
    - name: Validate Configuration
      run: ccs validate ci-config
      
    - name: Run Tests
      run: npm test
```

**Docker集成：**
```dockerfile
# Dockerfile
FROM node:18-alpine

# 安装CCS
RUN curl -sSL https://raw.githubusercontent.com/user/ccs/main/scripts/install/quick_install.sh | sh

# 复制配置文件
COPY ccs-config.toml /root/.ccs_config.toml

# 设置默认配置
RUN ccs switch docker-config

# 应用代码
COPY . /app
WORKDIR /app

# 启动应用
CMD ["npm", "start"]
```

## 🔧 故障排除

### 1. 常见错误

**配置文件错误：**
```bash
# 错误: 配置文件格式无效
$ ccs list
❌ 错误: 配置文件格式无效
📁 文件: ~/.ccs_config.toml
📍 行号: 15
💡 建议: 检查TOML语法,特别是引号和括号

# 解决方案
$ ccs validate --format
🔍 验证配置文件格式...
❌ 第15行: 缺少闭合引号
💡 修复建议: 在 'description = "My config' 后添加闭合引号
```

**权限错误：**
```bash
# 错误: 权限不足
$ ccs switch openai-gpt4
❌ 错误: 无法写入配置文件
📁 文件: ~/.ccs_config.toml
💡 建议: 检查文件权限

# 解决方案
$ ls -la ~/.ccs_config.toml
-r--r--r-- 1 user user 1234 Jan 15 14:30 ~/.ccs_config.toml

$ chmod 644 ~/.ccs_config.toml
$ ccs switch openai-gpt4
✅ 已切换到配置: openai-gpt4
```

**网络连接错误：**
```bash
# 错误: API连接失败
$ ccs validate openai-gpt4
❌ openai-gpt4: API连接失败
🔗 地址: https://api.openai.com/v1
💡 错误: 连接超时

# 诊断步骤
$ ccs diagnose network
🔍 网络诊断...
✅ DNS解析正常
✅ 网络连接正常
❌ API端点响应超时
💡 建议: 检查防火墙设置或使用代理
```

### 2. 调试模式

**启用调试输出：**
```bash
# 详细输出模式
ccs --verbose switch openai-gpt4
ccs -V switch openai-gpt4

# 调试模式
export CCS_DEBUG=1
ccs switch openai-gpt4

# 跟踪模式
export CCS_TRACE=1
ccs switch openai-gpt4
```

**调试输出示例：**
```bash
$ CCS_DEBUG=1 ccs switch openai-gpt4
[DEBUG] 加载配置文件: ~/.ccs_config.toml
[DEBUG] 解析配置: openai-gpt4
[DEBUG] 验证配置字段...
[DEBUG] 设置环境变量: OPENAI_API_KEY
[DEBUG] 设置环境变量: OPENAI_BASE_URL
[DEBUG] 更新当前配置: openai-gpt4
[DEBUG] 保存配置文件
✅ 已切换到配置: openai-gpt4
```

### 3. 诊断工具

**系统诊断：**
```bash
# 完整系统诊断
ccs diagnose
ccs diagnose --full

# 特定组件诊断
ccs diagnose config      # 配置文件诊断
ccs diagnose network     # 网络连接诊断
ccs diagnose env         # 环境变量诊断
ccs diagnose permissions # 权限诊断
```

**诊断报告：**
```bash
$ ccs diagnose
🔍 CCS 系统诊断报告

📊 系统信息:
   操作系统: Linux 5.15.0
   Shell: bash 5.1.16
   CCS版本: 1.2.3
   安装路径: ~/.ccs/

📁 配置文件:
   ✅ 配置文件存在: ~/.ccs_config.toml
   ✅ 格式正确
   ✅ 权限正常 (644)
   📊 配置数量: 5

🌍 环境变量:
   ✅ CCS_CURRENT_CONFIG=openai-gpt4
   ✅ OPENAI_API_KEY=sk-***
   ✅ OPENAI_BASE_URL=https://api.openai.com/v1

🔗 网络连接:
   ✅ DNS解析正常
   ✅ 互联网连接正常
   ✅ API端点可达

📊 诊断结果: 系统正常
```

## 💡 最佳实践

### 1. 配置命名规范

**推荐命名模式：**
```bash
# 服务商-模型-环境
openai-gpt4-prod
openai-gpt4-dev
claude-3-opus-prod
claude-3-haiku-dev

# 项目-服务商-用途
myproject-openai-main
myproject-claude-backup
webapp-gemini-fast

# 环境-服务商
prod-openai
dev-claude
test-local
```

### 2. 安全最佳实践

**API密钥管理：**
```bash
# 使用环境变量存储敏感信息
export OPENAI_API_KEY="your-secret-key"
ccs create openai-config --auth-token "$OPENAI_API_KEY"

# 定期轮换API密钥
ccs edit openai-config --field auth_token

# 备份时排除敏感信息
ccs backup --exclude-secrets
```

**权限控制：**
```bash
# 设置适当的文件权限
chmod 600 ~/.ccs_config.toml  # 仅所有者可读写
chmod 700 ~/.ccs/             # 仅所有者可访问

# 避免在共享环境中使用
if [ "$USER" != "$(whoami)" ]; then
    echo "⚠️  警告: 检测到共享环境,请谨慎使用CCS"
fi
```

### 3. 自动化工作流

**项目启动自动化：**
```bash
#!/bin/bash
# project-start.sh

# 检查项目配置
if [ -f .ccs-project ]; then
    PROJECT_CONFIG=$(cat .ccs-project)
    echo "🔄 切换到项目配置: $PROJECT_CONFIG"
    ccs switch "$PROJECT_CONFIG"
else
    echo "⚠️  未找到项目配置文件 .ccs-project"
    echo "💡 创建项目配置:"
    echo "   echo 'your-project-config' > .ccs-project"
fi

# 验证配置
ccs validate

# 启动开发服务器
npm run dev
```

**定期维护脚本：**
```bash
#!/bin/bash
# ccs-maintenance.sh

# 备份配置
echo "📦 备份CCS配置..."
ccs backup --output "~/backups/ccs-$(date +%Y%m%d).toml"

# 验证所有配置
echo "🔍 验证配置..."
ccs validate --detailed

# 清理旧备份
echo "🧹 清理旧备份..."
find ~/backups/ -name "ccs-*.toml" -mtime +30 -delete

# 更新统计
echo "📊 配置统计:"
ccs list --stats

echo "✅ 维护完成"
```

### 4. 性能优化

**减少启动时间：**
```bash
# 使用配置缓存
export CCS_CACHE_CONFIG=1

# 延迟加载非关键配置
export CCS_LAZY_LOAD=1

# 跳过网络验证（仅在必要时）
export CCS_SKIP_NETWORK_CHECK=1
```

**批量操作优化：**
```bash
# 并行验证配置
ccs validate --parallel

# 批量操作时使用静默模式
ccs --quiet batch update --field model --value gpt-4-turbo

# 使用预览模式避免不必要的操作
ccs --dry-run batch delete --pattern "test-*"
```

---

**相关文档**：
- [快速开始](quick-start.md) - 快速上手指南
- [配置管理](configuration.md) - 配置文件详解
- [Web界面](web-interface.md) - Web界面使用
- [故障排除](troubleshooting.md) - 问题解决方案