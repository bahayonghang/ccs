# 📚 CCS API 参考文档

> CCS (Claude Code Switcher) API 接口完整参考手册

## 📋 目录

- [命令行 API](#命令行-api)
- [Shell 函数 API](#shell-函数-api)
- [配置文件 API](#配置文件-api)
- [环境变量 API](#环境变量-api)
- [Web API](#web-api)
- [插件 API](#插件-api)
- [错误代码](#错误代码)
- [示例代码](#示例代码)

## 🖥️ 命令行 API

### 基本语法

```bash
ccs [GLOBAL_OPTIONS] <COMMAND> [COMMAND_OPTIONS] [ARGUMENTS]
```

### 全局选项

| 选项 | 简写 | 描述 | 默认值 |
|------|------|------|--------|
| `--config` | `-c` | 指定配置文件路径 | `$HOME/.ccs_config.toml` |
| `--verbose` | `-v` | 启用详细输出 | `false` |
| `--quiet` | `-q` | 静默模式 | `false` |
| `--debug` | `-d` | 启用调试模式 | `false` |
| `--help` | `-h` | 显示帮助信息 | - |
| `--version` | `-V` | 显示版本信息 | - |
| `--no-color` | | 禁用彩色输出 | `false` |
| `--format` | `-f` | 输出格式 (json/yaml/table) | `table` |

### 核心命令

#### 1. 配置管理

**`ccs list`** - 列出所有配置

```bash
ccs list [OPTIONS]
```

**选项：**
- `--names-only` - 仅显示配置名称
- `--active-only` - 仅显示活跃配置
- `--format FORMAT` - 输出格式 (table/json/yaml)
- `--filter PATTERN` - 过滤配置名称

**返回值：**
- `0` - 成功
- `1` - 配置文件不存在
- `2` - 配置文件格式错误

**示例：**
```bash
# 列出所有配置
ccs list

# 仅显示配置名称
ccs list --names-only

# JSON格式输出
ccs list --format json

# 过滤包含"openai"的配置
ccs list --filter "*openai*"
```

**`ccs switch`** - 切换配置

```bash
ccs switch <CONFIG_NAME> [OPTIONS]
```

**参数：**
- `CONFIG_NAME` - 要切换到的配置名称

**选项：**
- `--no-verify` - 跳过配置验证
- `--force` - 强制切换（即使验证失败）
- `--backup` - 切换前备份当前配置
- `--dry-run` - 模拟切换（不实际执行）

**返回值：**
- `0` - 切换成功
- `1` - 配置不存在
- `2` - 配置验证失败
- `3` - 权限不足

**示例：**
```bash
# 切换到openai配置
ccs switch openai

# 跳过验证切换
ccs switch claude --no-verify

# 强制切换
ccs switch test-config --force
```

**`ccs current`** - 显示当前配置

```bash
ccs current [OPTIONS]
```

**选项：**
- `--name-only` - 仅显示配置名称
- `--details` - 显示详细信息
- `--verify` - 验证当前配置

**返回值：**
- `0` - 成功
- `1` - 无当前配置
- `2` - 当前配置无效

**`ccs create`** - 创建新配置

```bash
ccs create <CONFIG_NAME> [OPTIONS]
```

**参数：**
- `CONFIG_NAME` - 新配置名称

**选项：**
- `--template TEMPLATE` - 使用模板 (openai/claude/google/custom)
- `--base-url URL` - API基础URL
- `--auth-token TOKEN` - 认证令牌
- `--model MODEL` - 默认模型
- `--description DESC` - 配置描述
- `--interactive` - 交互式创建
- `--from-file FILE` - 从文件导入

**返回值：**
- `0` - 创建成功
- `1` - 配置已存在
- `2` - 参数无效
- `3` - 创建失败

**示例：**
```bash
# 使用OpenAI模板创建配置
ccs create my-openai --template openai

# 交互式创建
ccs create my-config --interactive

# 从文件导入
ccs create imported --from-file config.toml
```

**`ccs edit`** - 编辑配置

```bash
ccs edit <CONFIG_NAME> [OPTIONS]
```

**参数：**
- `CONFIG_NAME` - 要编辑的配置名称

**选项：**
- `--field FIELD` - 指定要编辑的字段
- `--value VALUE` - 设置字段值
- `--editor EDITOR` - 指定编辑器
- `--interactive` - 交互式编辑

**返回值：**
- `0` - 编辑成功
- `1` - 配置不存在
- `2` - 字段无效
- `3` - 值无效

**`ccs delete`** - 删除配置

```bash
ccs delete <CONFIG_NAME> [OPTIONS]
```

**参数：**
- `CONFIG_NAME` - 要删除的配置名称

**选项：**
- `--force` - 强制删除（不确认）
- `--backup` - 删除前备份

**返回值：**
- `0` - 删除成功
- `1` - 配置不存在
- `2` - 用户取消
- `3` - 删除失败

#### 2. 配置验证

**`ccs validate`** - 验证配置

```bash
ccs validate [CONFIG_NAME] [OPTIONS]
```

**参数：**
- `CONFIG_NAME` - 要验证的配置名称（可选,默认验证当前配置）

**选项：**
- `--all` - 验证所有配置
- `--fix` - 自动修复可修复的问题
- `--strict` - 严格验证模式
- `--timeout SECONDS` - 网络验证超时时间

**返回值：**
- `0` - 验证通过
- `1` - 验证失败
- `2` - 网络错误
- `3` - 配置不存在

#### 3. 备份和恢复

**`ccs backup`** - 备份配置

```bash
ccs backup [OPTIONS]
```

**选项：**
- `--output FILE` - 指定输出文件
- `--compress` - 压缩备份文件
- `--encrypt` - 加密备份文件
- `--include-logs` - 包含日志文件

**`ccs restore`** - 恢复配置

```bash
ccs restore <BACKUP_FILE> [OPTIONS]
```

**参数：**
- `BACKUP_FILE` - 备份文件路径

**选项：**
- `--force` - 强制恢复（覆盖现有配置）
- `--merge` - 合并模式
- `--decrypt` - 解密备份文件

#### 4. 实用工具

**`ccs status`** - 显示系统状态

```bash
ccs status [OPTIONS]
```

**选项：**
- `--health` - 健康检查
- `--performance` - 性能统计
- `--environment` - 环境信息

**`ccs init`** - 初始化CCS

```bash
ccs init [OPTIONS]
```

**选项：**
- `--force` - 强制重新初始化
- `--template TEMPLATE` - 使用初始模板
- `--shell SHELL` - 指定Shell类型

**`ccs web`** - 启动Web界面

```bash
ccs web [OPTIONS]
```

**选项：**
- `--port PORT` - 指定端口 (默认: 8080)
- `--host HOST` - 指定主机 (默认: localhost)
- `--no-browser` - 不自动打开浏览器
- `--auth` - 启用认证

## 🔧 Shell 函数 API

### 核心函数

#### 配置管理函数

**`load_ccs_config()`** - 加载CCS配置

```bash
load_ccs_config [config_file]
```

**参数：**
- `config_file` - 配置文件路径（可选）

**返回值：**
- `0` - 加载成功
- `1` - 文件不存在
- `2` - 格式错误

**环境变量设置：**
- `CCS_CONFIG_LOADED` - 配置加载状态
- `CCS_CURRENT_CONFIG` - 当前配置名称
- `CCS_CONFIG_*` - 各配置项值

**`switch_ccs_config()`** - 切换配置

```bash
switch_ccs_config <config_name> [options]
```

**参数：**
- `config_name` - 配置名称
- `options` - 选项字符串

**返回值：**
- `0` - 切换成功
- `1` - 配置不存在
- `2` - 验证失败

**`get_ccs_config_value()`** - 获取配置值

```bash
get_ccs_config_value <config_name> <field_name>
```

**参数：**
- `config_name` - 配置名称
- `field_name` - 字段名称

**返回值：**
- `0` - 获取成功
- `1` - 配置或字段不存在

**输出：** 字段值（通过stdout）

#### 验证函数

**`validate_ccs_config()`** - 验证配置

```bash
validate_ccs_config <config_name> [strict]
```

**参数：**
- `config_name` - 配置名称
- `strict` - 严格模式（可选）

**返回值：**
- `0` - 验证通过
- `1` - 验证失败

**`test_api_connection()`** - 测试API连接

```bash
test_api_connection <base_url> <auth_token> [timeout]
```

**参数：**
- `base_url` - API基础URL
- `auth_token` - 认证令牌
- `timeout` - 超时时间（秒,可选）

**返回值：**
- `0` - 连接成功
- `1` - 连接失败
- `2` - 超时

#### 实用函数

**`ccs_log()`** - 记录日志

```bash
ccs_log <level> <message> [category]
```

**参数：**
- `level` - 日志级别 (DEBUG/INFO/WARN/ERROR)
- `message` - 日志消息
- `category` - 日志分类（可选）

**`ccs_error()`** - 错误处理

```bash
ccs_error <error_code> <error_message> [exit_on_error]
```

**参数：**
- `error_code` - 错误代码
- `error_message` - 错误消息
- `exit_on_error` - 是否退出（可选,默认false）

**`ccs_debug()`** - 调试输出

```bash
ccs_debug <message> [context]
```

**参数：**
- `message` - 调试消息
- `context` - 上下文信息（可选）

### Hook函数

**`ccs_pre_switch_hook()`** - 切换前钩子

```bash
ccs_pre_switch_hook <from_config> <to_config>
```

**`ccs_post_switch_hook()`** - 切换后钩子

```bash
ccs_post_switch_hook <from_config> <to_config> <result>
```

**`ccs_config_changed_hook()`** - 配置变更钩子

```bash
ccs_config_changed_hook <config_name> <field_name> <old_value> <new_value>
```

## 📄 配置文件 API

### TOML 配置结构

```toml
# CCS配置文件格式
[default_config]
name = "default-config-name"

[current_config]
name = "current-config-name"

[config-name]
description = "配置描述"
base_url = "https://api.example.com/v1"
auth_token = "your-auth-token"
model = "default-model"
small_fast_model = "fast-model"

# 可选字段
max_tokens = 4096
temperature = 0.7
top_p = 1.0
frequency_penalty = 0.0
presence_penalty = 0.0
timeout = 30
retry_count = 3
retry_delay = 1

# 自定义字段
[config-name.custom]
organization = "your-org"
project = "your-project"
tags = ["tag1", "tag2"]
```

### 字段规范

#### 必需字段

| 字段 | 类型 | 描述 | 示例 |
|------|------|------|------|
| `description` | String | 配置描述 | `"OpenAI GPT-4 配置"` |
| `base_url` | String | API基础URL | `"https://api.openai.com/v1"` |
| `auth_token` | String | 认证令牌 | `"sk-..."` |
| `model` | String | 默认模型 | `"gpt-4"` |

#### 可选字段

| 字段 | 类型 | 默认值 | 描述 |
|------|------|--------|------|
| `small_fast_model` | String | `model` | 快速模型 |
| `max_tokens` | Integer | `4096` | 最大令牌数 |
| `temperature` | Float | `0.7` | 温度参数 |
| `top_p` | Float | `1.0` | Top-p参数 |
| `frequency_penalty` | Float | `0.0` | 频率惩罚 |
| `presence_penalty` | Float | `0.0` | 存在惩罚 |
| `timeout` | Integer | `30` | 超时时间（秒） |
| `retry_count` | Integer | `3` | 重试次数 |
| `retry_delay` | Integer | `1` | 重试延迟（秒） |

#### 自定义字段

可以在 `[config-name.custom]` 段落中添加自定义字段：

```toml
[my-config.custom]
organization = "my-org"
project = "my-project"
environment = "production"
tags = ["ai", "gpt", "production"]
metadata = { version = "1.0", author = "user" }
```

### 配置验证规则

#### URL验证

```bash
# base_url 必须是有效的HTTP/HTTPS URL
base_url = "https://api.example.com/v1"  # ✅ 有效
base_url = "http://localhost:8080"       # ✅ 有效
base_url = "ftp://example.com"           # ❌ 无效协议
base_url = "not-a-url"                   # ❌ 无效格式
```

#### 令牌验证

```bash
# auth_token 格式验证
auth_token = "sk-..."                    # ✅ OpenAI格式
auth_token = "Bearer token"              # ✅ Bearer格式
auth_token = ""                          # ❌ 空值
```

#### 数值范围验证

```bash
# 参数范围验证
max_tokens = 1                          # ✅ 最小值
max_tokens = 32768                       # ✅ 最大值
max_tokens = 0                           # ❌ 无效值

temperature = 0.0                        # ✅ 最小值
temperature = 2.0                        # ✅ 最大值
temperature = -1.0                       # ❌ 无效值
```

## 🌍 环境变量 API

### CCS 系统环境变量

| 变量名 | 类型 | 描述 | 默认值 |
|--------|------|------|--------|
| `CCS_CONFIG_FILE` | String | 配置文件路径 | `$HOME/.ccs_config.toml` |
| `CCS_HOME` | String | CCS主目录 | `$HOME/.ccs` |
| `CCS_DEBUG` | Boolean | 调试模式 | `false` |
| `CCS_DEBUG_LEVEL` | Integer | 调试级别 (0-4) | `0` |
| `CCS_LOG_FILE` | String | 日志文件路径 | `$CCS_HOME/logs/ccs.log` |
| `CCS_CACHE_DIR` | String | 缓存目录 | `$CCS_HOME/cache` |
| `CCS_BACKUP_DIR` | String | 备份目录 | `$CCS_HOME/backups` |
| `CCS_PLUGIN_DIR` | String | 插件目录 | `$CCS_HOME/plugins` |

### 配置相关环境变量

| 变量名 | 类型 | 描述 |
|--------|------|------|
| `CCS_CURRENT_CONFIG` | String | 当前配置名称 |
| `CCS_CONFIG_LOADED` | Boolean | 配置加载状态 |
| `CCS_CONFIG_DESCRIPTION` | String | 当前配置描述 |
| `CCS_CONFIG_BASE_URL` | String | 当前API基础URL |
| `CCS_CONFIG_MODEL` | String | 当前默认模型 |
| `CCS_CONFIG_SMALL_FAST_MODEL` | String | 当前快速模型 |

### API 环境变量

根据当前配置,CCS会设置以下环境变量：

#### OpenAI 配置

```bash
export OPENAI_API_KEY="$auth_token"
export OPENAI_BASE_URL="$base_url"
export OPENAI_MODEL="$model"
export OPENAI_MAX_TOKENS="$max_tokens"
export OPENAI_TEMPERATURE="$temperature"
```

#### Anthropic 配置

```bash
export ANTHROPIC_API_KEY="$auth_token"
export ANTHROPIC_BASE_URL="$base_url"
export ANTHROPIC_MODEL="$model"
```

#### Google 配置

```bash
export GOOGLE_API_KEY="$auth_token"
export GOOGLE_BASE_URL="$base_url"
export GOOGLE_MODEL="$model"
```

### 性能和行为控制

| 变量名 | 类型 | 描述 | 默认值 |
|--------|------|------|--------|
| `CCS_CACHE_TTL` | Integer | 缓存生存时间（秒） | `300` |
| `CCS_VALIDATION_TIMEOUT` | Integer | 验证超时时间（秒） | `10` |
| `CCS_MAX_PARALLEL_JOBS` | Integer | 最大并行任务数 | `4` |
| `CCS_MEMORY_OPTIMIZE` | Boolean | 内存优化模式 | `false` |
| `CCS_AUTO_BACKUP` | Boolean | 自动备份 | `true` |
| `CCS_BACKUP_RETENTION` | Integer | 备份保留天数 | `30` |

### 功能开关

| 变量名 | 类型 | 描述 | 默认值 |
|--------|------|------|--------|
| `CCS_DISABLE_AUTOCOMPLETE` | Boolean | 禁用自动补全 | `false` |
| `CCS_DISABLE_HISTORY` | Boolean | 禁用历史记录 | `false` |
| `CCS_DISABLE_COLORS` | Boolean | 禁用彩色输出 | `false` |
| `CCS_DISABLE_NOTIFICATIONS` | Boolean | 禁用通知 | `false` |
| `CCS_ENABLE_TELEMETRY` | Boolean | 启用遥测 | `false` |

## 🌐 Web API

### REST API 端点

#### 配置管理

**GET `/api/v1/configs`** - 获取配置列表

```http
GET /api/v1/configs?filter=openai&format=json
```

**响应：**
```json
{
  "status": "success",
  "data": [
    {
      "name": "openai-gpt4",
      "description": "OpenAI GPT-4 配置",
      "active": true,
      "valid": true,
      "last_used": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 1
}
```

**GET `/api/v1/configs/{name}`** - 获取特定配置

```http
GET /api/v1/configs/openai-gpt4
```

**响应：**
```json
{
  "status": "success",
  "data": {
    "name": "openai-gpt4",
    "description": "OpenAI GPT-4 配置",
    "base_url": "https://api.openai.com/v1",
    "model": "gpt-4",
    "small_fast_model": "gpt-3.5-turbo",
    "max_tokens": 4096,
    "temperature": 0.7,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

**POST `/api/v1/configs`** - 创建新配置

```http
POST /api/v1/configs
Content-Type: application/json

{
  "name": "new-config",
  "description": "新配置",
  "base_url": "https://api.example.com/v1",
  "auth_token": "token",
  "model": "model-name"
}
```

**PUT `/api/v1/configs/{name}`** - 更新配置

```http
PUT /api/v1/configs/openai-gpt4
Content-Type: application/json

{
  "description": "更新的描述",
  "temperature": 0.8
}
```

**DELETE `/api/v1/configs/{name}`** - 删除配置

```http
DELETE /api/v1/configs/old-config
```

#### 配置切换

**POST `/api/v1/switch`** - 切换配置

```http
POST /api/v1/switch
Content-Type: application/json

{
  "config_name": "openai-gpt4",
  "verify": true,
  "backup": false
}
```

**GET `/api/v1/current`** - 获取当前配置

```http
GET /api/v1/current
```

#### 配置验证

**POST `/api/v1/validate`** - 验证配置

```http
POST /api/v1/validate
Content-Type: application/json

{
  "config_name": "openai-gpt4",
  "strict": true
}
```

**响应：**
```json
{
  "status": "success",
  "data": {
    "valid": true,
    "errors": [],
    "warnings": [],
    "connection_test": {
      "success": true,
      "response_time": 150,
      "status_code": 200
    }
  }
}
```

#### 系统状态

**GET `/api/v1/status`** - 获取系统状态

```http
GET /api/v1/status
```

**响应：**
```json
{
  "status": "success",
  "data": {
    "version": "1.3.0",
    "uptime": 3600,
    "config_count": 5,
    "current_config": "openai-gpt4",
    "memory_usage": "15.2MB",
    "cache_size": "2.1MB",
    "last_backup": "2024-01-15T09:00:00Z"
  }
}
```

### WebSocket API

#### 实时配置监控

```javascript
// 连接WebSocket
const ws = new WebSocket('ws://localhost:8080/ws/config-monitor');

// 监听配置变更
ws.onmessage = function(event) {
  const data = JSON.parse(event.data);
  console.log('配置变更:', data);
};

// 消息格式
{
  "type": "config_changed",
  "data": {
    "config_name": "openai-gpt4",
    "field": "temperature",
    "old_value": 0.7,
    "new_value": 0.8,
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

## 🔌 插件 API

### 插件结构

```bash
# 插件目录结构
$CCS_HOME/plugins/
├── my-plugin/
│   ├── plugin.toml          # 插件配置
│   ├── hooks.sh             # 钩子函数
│   ├── commands.sh          # 自定义命令
│   └── README.md            # 插件文档
```

### 插件配置文件

```toml
# plugin.toml
[plugin]
name = "my-plugin"
version = "1.0.0"
description = "我的CCS插件"
author = "作者名"
license = "MIT"

[dependencies]
ccs_version = ">= 1.3.0"
shell = ["bash", "zsh"]

[hooks]
pre_switch = "pre_switch_handler"
post_switch = "post_switch_handler"
config_changed = "config_changed_handler"

[commands]
my_command = "my_command_handler"
```

### 钩子函数

```bash
#!/bin/bash
# hooks.sh

# 切换前钩子
function pre_switch_handler() {
    local from_config="$1"
    local to_config="$2"
    
    echo "准备从 $from_config 切换到 $to_config"
    
    # 执行预处理逻辑
    # 返回0表示允许切换,非0表示阻止切换
    return 0
}

# 切换后钩子
function post_switch_handler() {
    local from_config="$1"
    local to_config="$2"
    local result="$3"
    
    if [[ $result -eq 0 ]]; then
        echo "成功切换到 $to_config"
        # 执行后处理逻辑
    else
        echo "切换失败"
    fi
}

# 配置变更钩子
function config_changed_handler() {
    local config_name="$1"
    local field_name="$2"
    local old_value="$3"
    local new_value="$4"
    
    echo "配置 $config_name 的 $field_name 从 $old_value 变更为 $new_value"
}
```

### 自定义命令

```bash
#!/bin/bash
# commands.sh

# 自定义命令处理器
function my_command_handler() {
    local args=("$@")
    
    case "${args[0]}" in
        "--help")
            echo "用法: ccs my-command [选项]"
            echo "选项:"
            echo "  --help    显示帮助"
            echo "  --version 显示版本"
            ;;
        "--version")
            echo "my-command 1.0.0"
            ;;
        *)
            echo "执行自定义命令: ${args[*]}"
            # 实现命令逻辑
            ;;
    esac
}
```

### 插件管理命令

```bash
# 安装插件
ccs plugin install /path/to/plugin
ccs plugin install https://github.com/user/ccs-plugin.git

# 列出插件
ccs plugin list

# 启用/禁用插件
ccs plugin enable my-plugin
ccs plugin disable my-plugin

# 卸载插件
ccs plugin uninstall my-plugin

# 更新插件
ccs plugin update my-plugin
ccs plugin update --all
```

## ❌ 错误代码

### 系统错误 (1-99)

| 代码 | 名称 | 描述 |
|------|------|------|
| `1` | `GENERAL_ERROR` | 一般错误 |
| `2` | `FILE_NOT_FOUND` | 文件不存在 |
| `3` | `PERMISSION_DENIED` | 权限不足 |
| `4` | `INVALID_ARGUMENT` | 无效参数 |
| `5` | `COMMAND_NOT_FOUND` | 命令不存在 |
| `10` | `CONFIG_FILE_ERROR` | 配置文件错误 |
| `11` | `CONFIG_PARSE_ERROR` | 配置解析错误 |
| `12` | `CONFIG_VALIDATION_ERROR` | 配置验证错误 |
| `20` | `NETWORK_ERROR` | 网络错误 |
| `21` | `CONNECTION_TIMEOUT` | 连接超时 |
| `22` | `API_ERROR` | API错误 |

### 配置错误 (100-199)

| 代码 | 名称 | 描述 |
|------|------|------|
| `100` | `CONFIG_NOT_FOUND` | 配置不存在 |
| `101` | `CONFIG_ALREADY_EXISTS` | 配置已存在 |
| `102` | `INVALID_CONFIG_NAME` | 无效配置名称 |
| `103` | `INVALID_CONFIG_FORMAT` | 无效配置格式 |
| `110` | `INVALID_BASE_URL` | 无效基础URL |
| `111` | `INVALID_AUTH_TOKEN` | 无效认证令牌 |
| `112` | `INVALID_MODEL_NAME` | 无效模型名称 |
| `120` | `SWITCH_FAILED` | 切换失败 |
| `121` | `VALIDATION_FAILED` | 验证失败 |

### 插件错误 (200-299)

| 代码 | 名称 | 描述 |
|------|------|------|
| `200` | `PLUGIN_NOT_FOUND` | 插件不存在 |
| `201` | `PLUGIN_LOAD_ERROR` | 插件加载错误 |
| `202` | `PLUGIN_DEPENDENCY_ERROR` | 插件依赖错误 |
| `203` | `PLUGIN_HOOK_ERROR` | 插件钩子错误 |

### Web API错误 (300-399)

| 代码 | 名称 | 描述 |
|------|------|------|
| `300` | `WEB_SERVER_ERROR` | Web服务器错误 |
| `301` | `INVALID_REQUEST` | 无效请求 |
| `302` | `AUTHENTICATION_FAILED` | 认证失败 |
| `303` | `AUTHORIZATION_FAILED` | 授权失败 |

## 💡 示例代码

### Shell脚本集成

```bash
#!/bin/bash
# 项目构建脚本示例

# 加载CCS
source "$HOME/.ccs/scripts/ccs.sh"

# 根据环境切换配置
case "${BUILD_ENV:-development}" in
    "production")
        ccs switch prod-openai
        ;;
    "staging")
        ccs switch staging-claude
        ;;
    *)
        ccs switch dev-local
        ;;
esac

# 验证配置
if ! ccs validate; then
    echo "错误: 配置验证失败"
    exit 1
fi

# 执行构建
echo "使用配置: $(ccs current --name-only)"
echo "API端点: $CCS_CONFIG_BASE_URL"
echo "模型: $CCS_CONFIG_MODEL"

# 运行构建命令
npm run build
```

### Python集成

```python
#!/usr/bin/env python3
# Python项目中使用CCS配置

import os
import subprocess
import json

class CCSConfig:
    """CCS配置管理器"""
    
    def __init__(self):
        self.config_file = os.path.expanduser('~/.ccs_config.toml')
    
    def get_current_config(self):
        """获取当前配置"""
        try:
            result = subprocess.run(
                ['ccs', 'current', '--format', 'json'],
                capture_output=True,
                text=True,
                check=True
            )
            return json.loads(result.stdout)
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"获取配置失败: {e}")
    
    def switch_config(self, config_name, verify=True):
        """切换配置"""
        cmd = ['ccs', 'switch', config_name]
        if not verify:
            cmd.append('--no-verify')
        
        try:
            subprocess.run(cmd, check=True)
            return True
        except subprocess.CalledProcessError:
            return False
    
    def get_api_config(self):
        """获取API配置"""
        config = self.get_current_config()
        return {
            'base_url': config.get('base_url'),
            'api_key': os.getenv('OPENAI_API_KEY') or os.getenv('ANTHROPIC_API_KEY'),
            'model': config.get('model'),
            'max_tokens': config.get('max_tokens', 4096),
            'temperature': config.get('temperature', 0.7)
        }

# 使用示例
if __name__ == '__main__':
    ccs = CCSConfig()
    
    # 切换到生产配置
    if ccs.switch_config('prod-openai'):
        print("成功切换到生产配置")
        
        # 获取API配置
        api_config = ccs.get_api_config()
        print(f"API端点: {api_config['base_url']}")
        print(f"模型: {api_config['model']}")
    else:
        print("配置切换失败")
```

### Node.js集成

```javascript
// Node.js项目中使用CCS配置
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

class CCSManager {
  constructor() {
    this.configFile = path.join(process.env.HOME, '.ccs_config.toml');
  }

  // 获取当前配置
  getCurrentConfig() {
    try {
      const result = execSync('ccs current --format json', { encoding: 'utf8' });
      return JSON.parse(result);
    } catch (error) {
      throw new Error(`获取配置失败: ${error.message}`);
    }
  }

  // 切换配置
  switchConfig(configName, options = {}) {
    const { verify = true, backup = false } = options;
    
    let cmd = `ccs switch ${configName}`;
    if (!verify) cmd += ' --no-verify';
    if (backup) cmd += ' --backup';
    
    try {
      execSync(cmd);
      return true;
    } catch (error) {
      console.error(`配置切换失败: ${error.message}`);
      return false;
    }
  }

  // 获取环境变量配置
  getEnvConfig() {
    return {
      baseUrl: process.env.CCS_CONFIG_BASE_URL,
      apiKey: process.env.OPENAI_API_KEY || process.env.ANTHROPIC_API_KEY,
      model: process.env.CCS_CONFIG_MODEL,
      maxTokens: parseInt(process.env.CCS_CONFIG_MAX_TOKENS) || 4096,
      temperature: parseFloat(process.env.CCS_CONFIG_TEMPERATURE) || 0.7
    };
  }

  // 监听配置变更
  watchConfig(callback) {
    if (!fs.existsSync(this.configFile)) {
      throw new Error('配置文件不存在');
    }

    fs.watchFile(this.configFile, (curr, prev) => {
      if (curr.mtime !== prev.mtime) {
        callback(this.getCurrentConfig());
      }
    });
  }
}

// 使用示例
const ccs = new CCSManager();

// 根据环境切换配置
const env = process.env.NODE_ENV || 'development';
const configMap = {
  production: 'prod-openai',
  staging: 'staging-claude',
  development: 'dev-local'
};

if (ccs.switchConfig(configMap[env])) {
  console.log(`成功切换到 ${env} 环境配置`);
  
  // 获取配置
  const config = ccs.getEnvConfig();
  console.log('API配置:', config);
  
  // 监听配置变更
  ccs.watchConfig((newConfig) => {
    console.log('配置已更新:', newConfig);
  });
} else {
  console.error('配置切换失败');
  process.exit(1);
}

module.exports = CCSManager;
```

### Docker集成

```dockerfile
# Dockerfile示例
FROM node:18-alpine

# 安装CCS
RUN wget -O- https://raw.githubusercontent.com/user/ccs/main/install.sh | sh

# 复制配置文件
COPY .ccs_config.toml /root/.ccs_config.toml

# 设置默认配置
RUN ccs switch production

# 复制应用代码
COPY . /app
WORKDIR /app

# 安装依赖
RUN npm install

# 启动脚本
CMD ["sh", "-c", "source ~/.ccs/scripts/ccs.sh && npm start"]
```

```yaml
# docker-compose.yml示例
version: '3.8'

services:
  app:
    build: .
    environment:
      - CCS_CONFIG_FILE=/app/.ccs_config.toml
      - NODE_ENV=production
    volumes:
      - ./.ccs_config.toml:/app/.ccs_config.toml:ro
    command: >
      sh -c "
        source ~/.ccs/scripts/ccs.sh &&
        ccs switch $$NODE_ENV &&
        npm start
      "
```

### CI/CD集成

```yaml
# GitHub Actions示例
name: Build and Deploy

on:
  push:
    branches: [main, develop]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install CCS
      run: |
        wget -O- https://raw.githubusercontent.com/user/ccs/main/install.sh | sh
        echo "$HOME/.ccs/bin" >> $GITHUB_PATH
    
    - name: Setup CCS Config
      run: |
        echo '${{ secrets.CCS_CONFIG }}' > ~/.ccs_config.toml
    
    - name: Switch to appropriate config
      run: |
        if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
          ccs switch production
        else
          ccs switch staging
        fi
    
    - name: Verify config
      run: |
        ccs validate
        ccs status
    
    - name: Build application
      run: |
        source ~/.ccs/scripts/ccs.sh
        echo "Using config: $(ccs current --name-only)"
        echo "API endpoint: $CCS_CONFIG_BASE_URL"
        npm run build
    
    - name: Deploy
      if: github.ref == 'refs/heads/main'
      run: |
        npm run deploy
```

---

**相关文档**：
- [快速开始](quick-start.md) - 5分钟上手指南
- [配置说明](configuration.md) - 配置文件详解
- [命令行使用](cli-usage.md) - CLI完整指南
- [Web界面](web-interface.md) - Web界面使用
- [故障排除](troubleshooting.md) - 常见问题解决
- [开发指南](development.md) - 开发和贡献指南