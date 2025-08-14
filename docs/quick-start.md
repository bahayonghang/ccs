# 快速入门指南

本指南将帮助您在5分钟内快速上手CCS，从安装到实际使用。

## 🎯 学习目标

完成本指南后，您将能够：
- ✅ 成功安装并配置CCS
- ✅ 理解配置文件的基本结构
- ✅ 切换不同的API配置
- ✅ 验证配置是否生效
- ✅ 使用Web界面管理配置

## 🚀 第一步：安装CCS

### Linux/macOS 一键安装
```bash
curl -L https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.sh | bash
```

### Windows 一键安装
1. 下载：https://github.com/bahayonghang/ccs/raw/main/scripts/install/quick_install/quick_install.bat
2. 右键以管理员身份运行

### 验证安装
```bash
# 重新打开终端，然后运行
ccs help
```

预期输出：
```
Claude Code Configuration Switcher (CCS)

用法:
  ccs [配置名称]    - 切换到指定配置
  ccs list          - 列出所有可用配置
  ccs current       - 显示当前配置
  ccs web           - 启动Web管理界面
  ccs help          - 显示帮助信息
```

## 📝 第二步：配置API密钥

### 查看配置文件位置
```bash
# 配置文件位于用户主目录
ls -la ~/.ccs_config.toml
```

### 编辑配置文件
```bash
# 使用您喜欢的编辑器
nano ~/.ccs_config.toml
# 或
vim ~/.ccs_config.toml
# 或
code ~/.ccs_config.toml
```

### 配置示例
```toml
# 默认配置
default_config = "anyrouter"

# 当前活跃配置（自动管理）
current_config = "anyrouter"

# AnyRouter配置（推荐用于Claude API）
[anyrouter]
description = "AnyRouter API服务"
base_url = "https://anyrouter.top"
auth_token = "sk-your-actual-api-key-here"  # 🔑 替换为您的真实API密钥
# model = ""  # 留空使用默认Claude模型

# OpenAI配置示例
[openai]
description = "OpenAI API配置"
base_url = "https://api.openai.com/v1"
auth_token = "sk-your-openai-api-key-here"  # 🔑 替换为您的OpenAI API密钥
model = "gpt-4"

# 智谱GLM配置示例
[glm]
description = "智谱GLM API服务"
base_url = "https://open.bigmodel.cn/api/paas/v4"
auth_token = "your-glm-api-key-here"  # 🔑 替换为您的GLM API密钥
model = "glm-4"
```

### 🔑 获取API密钥

| 服务商 | 获取地址 | 说明 |
|--------|----------|------|
| AnyRouter | https://anyrouter.top | 支持Claude API，推荐 |
| OpenAI | https://platform.openai.com/api-keys | 官方OpenAI服务 |
| 智谱GLM | https://open.bigmodel.cn | 国产大模型服务 |
| Anthropic | https://console.anthropic.com | Claude官方API |

## 🔄 第三步：切换配置

### 查看所有可用配置
```bash
ccs list
```

预期输出：
```
可用配置:
  anyrouter     - AnyRouter API服务 [当前]
  openai        - OpenAI API配置
  glm           - 智谱GLM API服务
```

### 切换到不同配置
```bash
# 切换到OpenAI配置
ccs openai
```

预期输出：
```
✅ 已切换到配置: openai
📝 描述: OpenAI API配置
🌐 API地址: https://api.openai.com/v1
🤖 模型: gpt-4
```

### 查看当前配置
```bash
ccs current
```

预期输出：
```
当前配置: openai
描述: OpenAI API配置
API地址: https://api.openai.com/v1
模型: gpt-4
```

## ✅ 第四步：验证配置生效

### 检查环境变量
```bash
# 查看设置的环境变量
echo "Base URL: $ANTHROPIC_BASE_URL"
echo "Auth Token: ${ANTHROPIC_AUTH_TOKEN:0:10}..."  # 只显示前10个字符
echo "Model: $ANTHROPIC_MODEL"
```

预期输出：
```
Base URL: https://api.openai.com/v1
Auth Token: sk-proj-ab...
Model: gpt-4
```

### 测试新终端继承配置
```bash
# 打开新终端窗口，然后运行
ccs current
```

应该显示相同的配置信息，证明全局配置持久化生效。

## 🌐 第五步：使用Web界面

### 启动Web管理界面
```bash
ccs web
```

预期输出：
```
🌐 启动Web配置界面...
📱 请在浏览器中访问: http://localhost:8888
🔧 配置文件: /home/user/.ccs_config.toml

按 Ctrl+C 停止服务
```

### Web界面功能
- 📊 **可视化配置管理**：查看所有配置的状态
- ✏️ **在线编辑**：直接修改配置参数
- 🔄 **实时切换**：点击切换不同配置
- 💾 **自动保存**：修改后自动保存到配置文件

## 🎯 实际使用场景

### 场景1：开发环境切换
```bash
# 开发时使用免费的GLM
ccs glm

# 生产环境使用Claude
ccs anyrouter

# 测试OpenAI兼容性
ccs openai
```

### 场景2：多项目配置
```bash
# 项目A使用Claude
ccs anyrouter

# 项目B使用OpenAI
ccs openai

# 每次切换项目时运行对应命令即可
```

### 场景3：成本控制
```bash
# 日常开发使用便宜的服务
ccs glm

# 重要任务使用高质量服务
ccs anthropic
```

## 🔧 高级技巧

### 1. 快速切换常用配置
```bash
# 创建别名简化操作
alias claude="ccs anyrouter"
alias gpt="ccs openai"
alias glm="ccs glm"

# 使用别名快速切换
claude  # 切换到Claude
gpt     # 切换到OpenAI
glm     # 切换到GLM
```

### 2. 批量配置管理
```bash
# 备份配置文件
cp ~/.ccs_config.toml ~/.ccs_config.toml.backup

# 恢复配置文件
cp ~/.ccs_config.toml.backup ~/.ccs_config.toml
```

### 3. 脚本自动化
```bash
#!/bin/bash
# auto-switch.sh - 根据时间自动切换配置

hour=$(date +%H)
if [ $hour -lt 9 ] || [ $hour -gt 18 ]; then
    # 非工作时间使用免费服务
    ccs glm
else
    # 工作时间使用高质量服务
    ccs anyrouter
fi
```

## 🚨 常见问题快速解决

### 问题1：命令未找到
```bash
# 解决方案：重新加载Shell配置
source ~/.bashrc
# 或重启终端
```

### 问题2：配置切换无效
```bash
# 检查配置文件语法
ccs list

# 如果报错，重新编辑配置文件
nano ~/.ccs_config.toml
```

### 问题3：API密钥无效
```bash
# 检查密钥格式
echo $ANTHROPIC_AUTH_TOKEN

# 重新设置正确的密钥
ccs [配置名称]
```

### 问题4：Web界面无法访问
```bash
# 检查端口是否被占用
netstat -an | grep 8888

# 使用不同端口
ccs web --port 9999
```

## 🎉 完成！

恭喜！您已经成功掌握了CCS的基本使用。现在您可以：

- ✅ 在不同AI服务之间快速切换
- ✅ 使用Web界面管理配置
- ✅ 享受全局配置持久化的便利
- ✅ 根据需要灵活调整API配置

## 📚 下一步学习

- 📖 [配置文件详解](configuration.md) - 深入了解配置选项
- 🏗️ [项目架构](architecture.md) - 理解CCS的工作原理
- 🔧 [命令行使用](cli-usage.md) - 掌握所有命令和选项
- 🌐 [Web界面使用](web-interface.md) - 深入使用Web管理功能

## 💡 小贴士

- 🔄 **定期备份**：定期备份您的配置文件
- 🔐 **安全第一**：不要在公共场所暴露API密钥
- 📊 **监控使用**：关注API使用量和费用
- 🆕 **保持更新**：定期更新CCS到最新版本

---

**需要帮助？** 查看 [故障排除指南](troubleshooting.md) 或 [提交Issue](https://github.com/bahayonghang/ccs/issues)