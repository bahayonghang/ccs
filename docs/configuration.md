# 配置文件详解

CCS使用TOML格式的配置文件来管理多个API服务配置。本文档详细说明配置文件的结构、选项和最佳实践。

## 📁 配置文件位置

```bash
# Linux/macOS
~/.ccs_config.toml

# Windows
%USERPROFILE%\.ccs_config.toml
```

## 📋 配置文件结构

### 基本结构
```toml
# 全局设置
default_config = "配置名称"
current_config = "当前配置"  # 自动管理,请勿手动修改

# API服务配置节
[配置名称]
description = "服务描述"
base_url = "API端点地址"
auth_token = "API密钥"
model = "模型名称"  # 可选
small_fast_model = "快速模型"  # 可选
```

### 完整示例
```toml
# ==================== 全局配置 ====================
# 默认配置（首次启动时使用）
default_config = "anyrouter"

# 当前激活配置（由CCS自动管理,请勿手动修改）
current_config = "anyrouter"

# ==================== Claude API服务 ====================
# 推荐：Claude API服务建议留空model字段,使用默认模型

[anyrouter]
description = "AnyRouter API服务 - 稳定的Claude代理"
base_url = "https://anyrouter.top"
auth_token = "sk-your-anyrouter-api-key-here"
# model = ""  # 留空使用Claude Code默认模型选择
# small_fast_model = ""  # 留空使用默认快速模型

[anthropic]
description = "Anthropic官方API - Claude原生服务"
base_url = "https://api.anthropic.com"
auth_token = "sk-ant-your-anthropic-api-key-here"
# model = ""  # 留空使用默认模型
# small_fast_model = ""  # 留空使用默认快速模型

[aicodemirror]
description = "AICodeMirror API服务"
base_url = "https://aicodemirror.com/api"
auth_token = "your-aicodemirror-api-key-here"
# model = ""  # 留空使用默认Claude模型

[wenwen]
description = "文文AI API服务"
base_url = "https://api.wenwen.ai"
auth_token = "your-wenwen-api-key-here"
# model = ""  # 留空使用默认Claude模型

# ==================== 非Claude API服务 ====================
# 建议：非Claude服务明确指定model字段确保兼容性

[openai]
description = "OpenAI API配置"
base_url = "https://api.openai.com/v1"
auth_token = "sk-your-openai-api-key-here"
model = "gpt-4"  # 明确指定模型

[glm]
description = "智谱GLM API服务"
base_url = "https://open.bigmodel.cn/api/paas/v4"
auth_token = "your-glm-api-key-here"
model = "glm-4"  # 明确指定模型

[moonshot]
description = "月之暗面API服务"
base_url = "https://api.moonshot.cn/v1"
auth_token = "sk-your-moonshot-api-key-here"
model = "moonshot-v1-8k"  # 明确指定模型

[siliconflow]
description = "SiliconFlow API服务"
base_url = "https://api.siliconflow.cn/v1"
auth_token = "sk-your-siliconflow-api-key-here"
model = "anthropic/claude-3-5-sonnet-20241022"  # 明确指定模型

# ==================== 自定义配置示例 ====================

[dev]
description = "开发环境 - 使用免费服务"
base_url = "https://api.free-service.com/v1"
auth_token = "free-api-key"
model = "free-model"

[prod]
description = "生产环境 - 使用高质量服务"
base_url = "https://api.premium-service.com/v1"
auth_token = "premium-api-key"
model = "premium-model"
```

## 🔧 配置字段详解

### 全局字段

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `default_config` | String | ✅ | 默认配置名称,首次启动时使用 |
| `current_config` | String | ✅ | 当前激活配置,由CCS自动管理 |

### 配置节字段

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `description` | String | ✅ | 配置描述,用于显示和识别 |
| `base_url` | String | ✅ | API端点地址 |
| `auth_token` | String | ✅ | API认证令牌/密钥 |
| `model` | String | ❌ | 模型名称（可选） |
| `small_fast_model` | String | ❌ | 快速模型名称（可选） |

### 字段详细说明

#### `description`
- **用途**：配置的人类可读描述
- **显示**：在 `ccs list` 和 `ccs current` 中显示
- **建议**：使用清晰、简洁的描述

```toml
# ✅ 好的描述
description = "AnyRouter API服务 - 稳定的Claude代理"

# ❌ 不好的描述
description = "api"
```

#### `base_url`
- **用途**：API服务的基础URL
- **格式**：完整的HTTP/HTTPS URL
- **注意**：不要包含尾随斜杠

```toml
# ✅ 正确格式
base_url = "https://api.openai.com/v1"

# ❌ 错误格式
base_url = "https://api.openai.com/v1/"  # 多余的斜杠
base_url = "api.openai.com"  # 缺少协议
```

#### `auth_token`
- **用途**：API认证令牌
- **格式**：根据服务商要求
- **安全**：确保密钥安全,不要泄露

```toml
# OpenAI格式
auth_token = "sk-proj-..."

# Anthropic格式
auth_token = "sk-ant-..."

# 其他服务格式
auth_token = "your-api-key-here"
```

#### `model`（可选）
- **用途**：指定使用的模型
- **Claude服务**：建议留空,使用默认模型
- **非Claude服务**：建议明确指定

```toml
# Claude服务 - 留空使用默认
[anyrouter]
auth_token = "sk-..."
# model = ""  # 留空或注释掉

# 非Claude服务 - 明确指定
[openai]
auth_token = "sk-..."
model = "gpt-4"  # 明确指定
```

#### `small_fast_model`（可选）
- **用途**：指定快速模型（用于简单任务）
- **使用场景**：代码补全、简单问答等
- **建议**：Claude服务留空,其他服务可指定

## 🎯 模型配置策略

### Claude API服务配置
```toml
# 推荐配置：留空model字段
[anyrouter]
description = "AnyRouter API服务"
base_url = "https://anyrouter.top"
auth_token = "sk-your-api-key"
# model = ""  # 留空,让Claude Code选择最佳模型
# small_fast_model = ""  # 留空,使用默认快速模型
```

**优势**：
- ✅ 自动使用最新的Claude模型
- ✅ 无需手动更新模型名称
- ✅ 享受Claude Code的智能模型选择

### 非Claude服务配置
```toml
# 推荐配置：明确指定model字段
[openai]
description = "OpenAI API配置"
base_url = "https://api.openai.com/v1"
auth_token = "sk-your-api-key"
model = "gpt-4"  # 明确指定,确保兼容性

[glm]
description = "智谱GLM API服务"
base_url = "https://open.bigmodel.cn/api/paas/v4"
auth_token = "your-api-key"
model = "glm-4"  # 明确指定,确保正确调用
```

**优势**：
- ✅ 确保API调用正确
- ✅ 避免模型不兼容问题
- ✅ 明确知道使用的模型

## 🔐 安全最佳实践

### 1. API密钥安全
```bash
# 设置配置文件权限（仅用户可读写）
chmod 600 ~/.ccs_config.toml

# 检查权限
ls -la ~/.ccs_config.toml
# 应显示：-rw------- 1 user user ...
```

### 2. 密钥格式验证
```toml
# ✅ 正确的密钥格式
auth_token = "sk-proj-abc123..."  # OpenAI
auth_token = "sk-ant-api03-..."   # Anthropic
auth_token = "glm-4-..."          # GLM

# ❌ 错误的密钥格式
auth_token = "your-api-key-here"  # 占位符未替换
auth_token = ""                   # 空密钥
auth_token = "invalid-key"        # 无效格式
```

### 3. 配置文件备份
```bash
# 创建备份
cp ~/.ccs_config.toml ~/.ccs_config.toml.backup

# 定期备份（添加到crontab）
0 2 * * * cp ~/.ccs_config.toml ~/.ccs_config.toml.$(date +\%Y\%m\%d)
```

## 🔍 配置验证

### 自动验证
CCS会在启动时自动验证配置文件：

```bash
# 检查配置文件语法
ccs list

# 如果配置有问题,会显示错误信息
```

### 手动验证
```bash
# 检查TOML语法
python3 -c "import toml; toml.load('~/.ccs_config.toml')"

# 或使用在线TOML验证器
# https://www.toml-lint.com/
```

### 常见配置错误

#### 1. TOML语法错误
```toml
# ❌ 错误：缺少引号
auth_token = sk-api-key

# ✅ 正确：使用引号
auth_token = "sk-api-key"
```

#### 2. 重复配置节
```toml
# ❌ 错误：重复的配置节
[openai]
description = "OpenAI 1"

[openai]  # 重复！
description = "OpenAI 2"

# ✅ 正确：使用不同名称
[openai]
description = "OpenAI官方"

[openai_backup]
description = "OpenAI备用"
```

#### 3. 无效的URL格式
```toml
# ❌ 错误：无效URL
base_url = "not-a-url"

# ✅ 正确：完整URL
base_url = "https://api.example.com/v1"
```

## 🛠️ 高级配置技巧

### 1. 环境特定配置
```toml
# 开发环境
[dev-claude]
description = "开发环境 - Claude"
base_url = "https://dev-api.example.com"
auth_token = "dev-key"

# 测试环境
[test-claude]
description = "测试环境 - Claude"
base_url = "https://test-api.example.com"
auth_token = "test-key"

# 生产环境
[prod-claude]
description = "生产环境 - Claude"
base_url = "https://api.example.com"
auth_token = "prod-key"
```

### 2. 成本优化配置
```toml
# 免费/便宜的服务
[cheap]
description = "成本优化 - 免费服务"
base_url = "https://free-api.example.com"
auth_token = "free-key"
model = "free-model"

# 高质量服务
[premium]
description = "高质量 - 付费服务"
base_url = "https://premium-api.example.com"
auth_token = "premium-key"
model = "premium-model"
```

### 3. 地区特定配置
```toml
# 国内服务
[china]
description = "国内服务 - 智谱GLM"
base_url = "https://open.bigmodel.cn/api/paas/v4"
auth_token = "glm-key"
model = "glm-4"

# 国外服务
[global]
description = "国外服务 - OpenAI"
base_url = "https://api.openai.com/v1"
auth_token = "openai-key"
model = "gpt-4"
```

## 📊 配置管理工具

### 1. 配置导出
```bash
# 导出当前配置
ccs current > current-config.txt

# 导出所有配置
ccs list > all-configs.txt
```

### 2. 配置模板
```bash
# 创建配置模板
cat > config-template.toml << 'EOF'
default_config = "CHANGE_ME"
current_config = "CHANGE_ME"

[CHANGE_ME]
description = "CHANGE_ME"
base_url = "CHANGE_ME"
auth_token = "CHANGE_ME"
model = "CHANGE_ME"
EOF
```

### 3. 批量配置更新
```bash
#!/bin/bash
# update-configs.sh - 批量更新配置

# 备份当前配置
cp ~/.ccs_config.toml ~/.ccs_config.toml.backup

# 更新特定字段
sed -i 's/old-api-key/new-api-key/g' ~/.ccs_config.toml

# 验证更新
ccs list
```

## 🔄 配置迁移

### 从旧版本迁移
```bash
# 1. 备份旧配置
cp ~/.ccs_config.toml ~/.ccs_config.toml.old

# 2. 更新配置格式
# 手动编辑或使用脚本更新

# 3. 验证新配置
ccs list
```

### 跨设备同步
```bash
# 导出配置（移除敏感信息）
sed 's/auth_token = "[^"]*"/auth_token = "YOUR_API_KEY_HERE"/g' ~/.ccs_config.toml > ccs-config-template.toml

# 在新设备上使用模板
cp ccs-config-template.toml ~/.ccs_config.toml
# 然后编辑填入真实API密钥
```

---

**相关文档**：
- [快速入门指南](quick-start.md) - 基础配置和使用
- [命令行使用](cli-usage.md) - 配置管理命令
- [故障排除](troubleshooting.md) - 配置问题解决