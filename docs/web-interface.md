# Web界面使用指南

本文档详细介绍 CCS (Claude Code Configuration Switcher) Web界面的功能、操作方法和最佳实践。

## 📋 目录

- [界面概览](#界面概览)
- [功能特性](#功能特性)
- [基本操作](#基本操作)
- [配置管理](#配置管理)
- [高级功能](#高级功能)
- [界面定制](#界面定制)
- [故障排除](#故障排除)
- [最佳实践](#最佳实践)

## 🖥️ 界面概览

### 1. 启动Web界面

```bash
# 方法1: 直接打开HTML文件
open ~/.ccs/index.html

# 方法2: 使用浏览器打开
firefox ~/.ccs/index.html
chrome ~/.ccs/index.html

# 方法3: 使用本地服务器（推荐）
cd ~/.ccs
python3 -m http.server 8080
# 然后在浏览器中访问 http://localhost:8080
```

### 2. 界面布局

```
┌─────────────────────────────────────────────────────────────┐
│                    CCS Web 管理界面                          │
├─────────────────────────────────────────────────────────────┤
│ 🏠 首页  📋 配置列表  ➕ 新建配置  ⚙️ 设置  ❓ 帮助        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  当前配置: [OpenAI-GPT4] ✅                                  │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   配置列表      │  │   配置详情      │  │   操作面板   │ │
│  │                 │  │                 │  │              │ │
│  │ • OpenAI-GPT4   │  │ 名称: OpenAI... │  │ [切换配置]   │ │
│  │ • Claude-3      │  │ URL: https://.. │  │ [编辑配置]   │ │
│  │ • Gemini-Pro    │  │ 模型: gpt-4     │  │ [删除配置]   │ │
│  │ • 本地模型      │  │ 状态: ✅ 正常   │  │ [测试连接]   │ │
│  │                 │  │                 │  │              │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│ 状态栏: 最后更新 2024-01-15 14:30:25 | 配置文件: 正常      │
└─────────────────────────────────────────────────────────────┘
```

### 3. 主要组件说明

| 组件 | 功能 | 描述 |
|------|------|------|
| 🏠 首页 | 概览面板 | 显示当前配置状态和快速操作 |
| 📋 配置列表 | 配置管理 | 显示所有可用配置及其状态 |
| ➕ 新建配置 | 配置创建 | 创建新的API配置 |
| ⚙️ 设置 | 系统设置 | 界面偏好和系统配置 |
| ❓ 帮助 | 帮助文档 | 使用说明和故障排除 |

## ✨ 功能特性

### 1. 实时配置监控

```javascript
// 配置状态实时监控
const ConfigMonitor = {
    // 监控间隔（毫秒）
    interval: 5000,
    
    // 启动监控
    start() {
        this.timer = setInterval(() => {
            this.checkConfigStatus();
        }, this.interval);
        
        console.log('配置监控已启动');
    },
    
    // 检查配置状态
    async checkConfigStatus() {
        try {
            const currentConfig = await this.getCurrentConfig();
            const configStatus = await this.testConfigConnection(currentConfig);
            
            this.updateStatusIndicator(configStatus);
            this.updateLastCheckTime();
            
        } catch (error) {
            console.error('配置状态检查失败:', error);
            this.showErrorIndicator(error.message);
        }
    },
    
    // 更新状态指示器
    updateStatusIndicator(status) {
        const indicator = document.getElementById('status-indicator');
        const statusText = document.getElementById('status-text');
        
        if (status.connected) {
            indicator.className = 'status-indicator online';
            indicator.textContent = '✅';
            statusText.textContent = '连接正常';
        } else {
            indicator.className = 'status-indicator offline';
            indicator.textContent = '❌';
            statusText.textContent = `连接失败: ${status.error}`;
        }
    }
};
```

### 2. 配置验证系统

```javascript
// 配置验证器
const ConfigValidator = {
    // 验证规则
    rules: {
        base_url: {
            required: true,
            pattern: /^https?:\/\/[^\s]+$/,
            message: 'URL格式无效,必须以http://或https://开头'
        },
        auth_token: {
            required: true,
            minLength: 10,
            message: 'API密钥长度至少10个字符'
        },
        model: {
            required: false,
            pattern: /^[a-zA-Z0-9._-]+$/,
            message: '模型名称只能包含字母、数字、点、下划线和连字符'
        }
    },
    
    // 验证单个字段
    validateField(fieldName, value) {
        const rule = this.rules[fieldName];
        if (!rule) return { valid: true };
        
        // 必需字段检查
        if (rule.required && (!value || value.trim() === '')) {
            return {
                valid: false,
                message: `${fieldName} 是必需字段`
            };
        }
        
        // 最小长度检查
        if (rule.minLength && value.length < rule.minLength) {
            return {
                valid: false,
                message: `${fieldName} 长度至少 ${rule.minLength} 个字符`
            };
        }
        
        // 格式检查
        if (rule.pattern && !rule.pattern.test(value)) {
            return {
                valid: false,
                message: rule.message
            };
        }
        
        return { valid: true };
    },
    
    // 验证完整配置
    validateConfig(config) {
        const errors = [];
        
        for (const [fieldName, value] of Object.entries(config)) {
            const result = this.validateField(fieldName, value);
            if (!result.valid) {
                errors.push({
                    field: fieldName,
                    message: result.message
                });
            }
        }
        
        return {
            valid: errors.length === 0,
            errors: errors
        };
    }
};
```

### 3. 智能配置建议

```javascript
// 配置建议系统
const ConfigSuggestions = {
    // 预定义的服务模板
    templates: {
        'openai': {
            name: 'OpenAI',
            base_url: 'https://api.openai.com/v1',
            model: 'gpt-4',
            small_fast_model: 'gpt-3.5-turbo',
            description: 'OpenAI官方API服务'
        },
        'claude': {
            name: 'Claude',
            base_url: 'https://api.anthropic.com',
            model: 'claude-3-opus-20240229',
            small_fast_model: 'claude-3-haiku-20240307',
            description: 'Anthropic Claude API服务'
        },
        'gemini': {
            name: 'Gemini',
            base_url: 'https://generativelanguage.googleapis.com/v1beta',
            model: 'gemini-pro',
            small_fast_model: 'gemini-pro',
            description: 'Google Gemini API服务'
        }
    },
    
    // 根据URL自动建议配置
    suggestByUrl(url) {
        if (url.includes('openai.com')) {
            return this.templates.openai;
        } else if (url.includes('anthropic.com')) {
            return this.templates.claude;
        } else if (url.includes('googleapis.com')) {
            return this.templates.gemini;
        }
        
        return null;
    },
    
    // 显示配置建议
    showSuggestions(inputElement) {
        const url = inputElement.value;
        const suggestion = this.suggestByUrl(url);
        
        if (suggestion) {
            this.displaySuggestionCard(suggestion, inputElement);
        }
    },
    
    // 显示建议卡片
    displaySuggestionCard(suggestion, targetElement) {
        const card = document.createElement('div');
        card.className = 'suggestion-card';
        card.innerHTML = `
            <div class="suggestion-header">
                <h4>💡 检测到 ${suggestion.name} 服务</h4>
                <button class="close-btn" onclick="this.parentElement.parentElement.remove()">×</button>
            </div>
            <div class="suggestion-body">
                <p>${suggestion.description}</p>
                <div class="suggestion-fields">
                    <div><strong>推荐模型:</strong> ${suggestion.model}</div>
                    <div><strong>快速模型:</strong> ${suggestion.small_fast_model}</div>
                </div>
                <button class="apply-suggestion-btn" onclick="ConfigSuggestions.applySuggestion('${JSON.stringify(suggestion).replace(/'/g, "\\'")}')">应用建议</button>
            </div>
        `;
        
        // 插入到目标元素后面
        targetElement.parentNode.insertBefore(card, targetElement.nextSibling);
    },
    
    // 应用建议配置
    applySuggestion(suggestionJson) {
        const suggestion = JSON.parse(suggestionJson);
        
        // 填充表单字段
        document.getElementById('model').value = suggestion.model || '';
        document.getElementById('small_fast_model').value = suggestion.small_fast_model || '';
        document.getElementById('description').value = suggestion.description || '';
        
        // 移除建议卡片
        document.querySelector('.suggestion-card').remove();
        
        // 显示成功消息
        this.showMessage('✅ 已应用配置建议', 'success');
    }
};
```

## 🔧 基本操作

### 1. 查看配置列表

**操作步骤：**
1. 点击顶部导航栏的 "📋 配置列表"
2. 查看所有可用配置及其状态
3. 当前激活的配置会有 ✅ 标记

**配置状态说明：**
- ✅ **正常** - 配置有效且连接正常
- ⚠️ **警告** - 配置有效但连接异常
- ❌ **错误** - 配置无效或格式错误
- 🔄 **检测中** - 正在测试连接状态

### 2. 切换配置

**方法1: 通过配置列表**
1. 在配置列表中找到目标配置
2. 点击配置名称或 "切换" 按钮
3. 确认切换操作
4. 等待切换完成提示

**方法2: 通过快速切换**
1. 点击顶部的当前配置名称
2. 在下拉菜单中选择目标配置
3. 配置会立即切换

**切换确认：**
```javascript
// 配置切换确认对话框
function confirmConfigSwitch(configName) {
    const dialog = document.createElement('div');
    dialog.className = 'confirm-dialog';
    dialog.innerHTML = `
        <div class="dialog-content">
            <h3>🔄 确认切换配置</h3>
            <p>您确定要切换到配置 "<strong>${configName}</strong>" 吗？</p>
            <p class="warning">⚠️ 这将影响所有使用CCS的应用程序</p>
            <div class="dialog-buttons">
                <button class="btn-cancel" onclick="closeDialog()">取消</button>
                <button class="btn-confirm" onclick="executeConfigSwitch('${configName}')">确认切换</button>
            </div>
        </div>
    `;
    
    document.body.appendChild(dialog);
}
```

### 3. 测试配置连接

**操作步骤：**
1. 选择要测试的配置
2. 点击 "🔗 测试连接" 按钮
3. 等待测试结果

**测试结果解读：**
- ✅ **连接成功** - API可正常访问
- ❌ **连接失败** - 网络或URL问题
- 🔐 **认证失败** - API密钥无效
- ⏱️ **超时** - 请求超时,可能是网络问题
- 🚫 **服务不可用** - API服务暂时不可用

## ⚙️ 配置管理

### 1. 创建新配置

**操作步骤：**
1. 点击 "➕ 新建配置" 按钮
2. 填写配置信息：
   - **配置名称** - 唯一标识符（必需）
   - **描述** - 配置说明（可选）
   - **API地址** - 服务端点URL（必需）
   - **API密钥** - 认证令牌（必需）
   - **默认模型** - 主要使用的模型（可选）
   - **快速模型** - 轻量级模型（可选）
3. 点击 "💾 保存配置"
4. 可选择立即切换到新配置

**配置表单示例：**
```html
<form id="config-form" class="config-form">
    <div class="form-group">
        <label for="config-name">配置名称 *</label>
        <input type="text" id="config-name" name="name" required 
               placeholder="例如: OpenAI-GPT4" 
               pattern="[a-zA-Z0-9_-]+" 
               title="只能包含字母、数字、下划线和连字符">
        <div class="field-hint">用于标识此配置的唯一名称</div>
    </div>
    
    <div class="form-group">
        <label for="description">描述</label>
        <input type="text" id="description" name="description" 
               placeholder="例如: OpenAI官方API,用于生产环境">
        <div class="field-hint">可选的配置说明</div>
    </div>
    
    <div class="form-group">
        <label for="base-url">API地址 *</label>
        <input type="url" id="base-url" name="base_url" required 
               placeholder="https://api.openai.com/v1"
               onchange="ConfigSuggestions.showSuggestions(this)">
        <div class="field-hint">API服务的基础URL</div>
    </div>
    
    <div class="form-group">
        <label for="auth-token">API密钥 *</label>
        <input type="password" id="auth-token" name="auth_token" required 
               placeholder="sk-..." 
               minlength="10">
        <div class="field-hint">用于API认证的密钥</div>
        <button type="button" class="toggle-password" onclick="togglePasswordVisibility('auth-token')">👁️</button>
    </div>
    
    <div class="form-group">
        <label for="model">默认模型</label>
        <input type="text" id="model" name="model" 
               placeholder="gpt-4">
        <div class="field-hint">主要使用的AI模型</div>
    </div>
    
    <div class="form-group">
        <label for="small-fast-model">快速模型</label>
        <input type="text" id="small-fast-model" name="small_fast_model" 
               placeholder="gpt-3.5-turbo">
        <div class="field-hint">用于快速响应的轻量级模型</div>
    </div>
    
    <div class="form-actions">
        <button type="button" class="btn-secondary" onclick="resetForm()">重置</button>
        <button type="button" class="btn-test" onclick="testConfigBeforeSave()">测试连接</button>
        <button type="submit" class="btn-primary">💾 保存配置</button>
    </div>
</form>
```

### 2. 编辑现有配置

**操作步骤：**
1. 在配置列表中找到要编辑的配置
2. 点击 "✏️ 编辑" 按钮
3. 修改需要更改的字段
4. 点击 "💾 保存更改"
5. 确认保存操作

**编辑安全提示：**
- 🔒 编辑当前激活的配置时会显示警告
- 💾 修改会自动创建备份
- 🔄 可以随时恢复到之前的版本

### 3. 删除配置

**操作步骤：**
1. 选择要删除的配置
2. 点击 "🗑️ 删除" 按钮
3. 在确认对话框中输入配置名称
4. 点击 "确认删除"

**删除限制：**
- ❌ 无法删除当前激活的配置
- ❌ 无法删除默认配置（如果设置了的话）
- 💾 删除前会自动创建备份

### 4. 配置导入导出

**导出配置：**
```javascript
// 导出单个配置
function exportConfig(configName) {
    const config = getConfigData(configName);
    const exportData = {
        version: '1.0',
        exported_at: new Date().toISOString(),
        config: config
    };
    
    const blob = new Blob([JSON.stringify(exportData, null, 2)], 
                         { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    
    const a = document.createElement('a');
    a.href = url;
    a.download = `ccs-config-${configName}.json`;
    a.click();
    
    URL.revokeObjectURL(url);
}

// 导出所有配置
function exportAllConfigs() {
    const allConfigs = getAllConfigData();
    const exportData = {
        version: '1.0',
        exported_at: new Date().toISOString(),
        configs: allConfigs
    };
    
    const blob = new Blob([JSON.stringify(exportData, null, 2)], 
                         { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    
    const a = document.createElement('a');
    a.href = url;
    a.download = `ccs-configs-backup-${new Date().toISOString().split('T')[0]}.json`;
    a.click();
    
    URL.revokeObjectURL(url);
}
```

**导入配置：**
```javascript
// 导入配置文件
function importConfig(file) {
    const reader = new FileReader();
    
    reader.onload = function(e) {
        try {
            const importData = JSON.parse(e.target.result);
            
            // 验证导入数据格式
            if (!validateImportData(importData)) {
                throw new Error('导入文件格式无效');
            }
            
            // 处理单个配置导入
            if (importData.config) {
                importSingleConfig(importData.config);
            }
            
            // 处理批量配置导入
            if (importData.configs) {
                importMultipleConfigs(importData.configs);
            }
            
            showMessage('✅ 配置导入成功', 'success');
            refreshConfigList();
            
        } catch (error) {
            showMessage(`❌ 导入失败: ${error.message}`, 'error');
        }
    };
    
    reader.readAsText(file);
}
```

## 🚀 高级功能

### 1. 批量操作

**批量测试连接：**
```javascript
// 批量测试所有配置的连接状态
async function batchTestConnections() {
    const configs = getAllConfigs();
    const results = [];
    
    // 显示进度条
    const progressBar = showProgressBar('测试配置连接', configs.length);
    
    for (let i = 0; i < configs.length; i++) {
        const config = configs[i];
        
        try {
            const result = await testConfigConnection(config.name);
            results.push({
                name: config.name,
                status: result.connected ? 'success' : 'failed',
                message: result.message,
                responseTime: result.responseTime
            });
        } catch (error) {
            results.push({
                name: config.name,
                status: 'error',
                message: error.message,
                responseTime: null
            });
        }
        
        // 更新进度
        updateProgress(progressBar, i + 1);
    }
    
    // 隐藏进度条
    hideProgressBar(progressBar);
    
    // 显示测试结果
    showBatchTestResults(results);
}
```

**批量配置更新：**
```javascript
// 批量更新配置字段
function batchUpdateConfigs(updates) {
    const confirmDialog = document.createElement('div');
    confirmDialog.className = 'batch-update-dialog';
    confirmDialog.innerHTML = `
        <div class="dialog-content">
            <h3>🔄 批量更新配置</h3>
            <p>将要更新 ${updates.length} 个配置的以下字段：</p>
            <ul>
                ${Object.keys(updates[0].fields).map(field => 
                    `<li><strong>${field}</strong>: ${updates[0].fields[field]}</li>`
                ).join('')}
            </ul>
            <p class="warning">⚠️ 此操作将影响多个配置,请确认无误</p>
            <div class="dialog-buttons">
                <button class="btn-cancel" onclick="closeBatchDialog()">取消</button>
                <button class="btn-confirm" onclick="executeBatchUpdate()">确认更新</button>
            </div>
        </div>
    `;
    
    document.body.appendChild(confirmDialog);
}
```

### 2. 配置模板系统

**创建配置模板：**
```javascript
// 配置模板管理器
const TemplateManager = {
    // 预定义模板
    templates: {
        'openai-template': {
            name: 'OpenAI模板',
            description: 'OpenAI API配置模板',
            fields: {
                base_url: 'https://api.openai.com/v1',
                model: 'gpt-4',
                small_fast_model: 'gpt-3.5-turbo'
            },
            required_fields: ['auth_token'],
            instructions: '请填入您的OpenAI API密钥'
        },
        'claude-template': {
            name: 'Claude模板',
            description: 'Anthropic Claude API配置模板',
            fields: {
                base_url: 'https://api.anthropic.com',
                model: 'claude-3-opus-20240229',
                small_fast_model: 'claude-3-haiku-20240307'
            },
            required_fields: ['auth_token'],
            instructions: '请填入您的Anthropic API密钥'
        }
    },
    
    // 应用模板
    applyTemplate(templateId, configName) {
        const template = this.templates[templateId];
        if (!template) {
            throw new Error(`模板 ${templateId} 不存在`);
        }
        
        // 填充表单
        document.getElementById('config-name').value = configName;
        document.getElementById('description').value = template.description;
        
        // 填充模板字段
        for (const [field, value] of Object.entries(template.fields)) {
            const element = document.getElementById(field.replace('_', '-'));
            if (element) {
                element.value = value;
            }
        }
        
        // 显示说明
        if (template.instructions) {
            showTemplateInstructions(template.instructions);
        }
        
        // 高亮必需字段
        template.required_fields.forEach(field => {
            const element = document.getElementById(field.replace('_', '-'));
            if (element) {
                element.classList.add('required-field');
                element.focus();
            }
        });
    },
    
    // 保存为模板
    saveAsTemplate(configName, templateName) {
        const config = getConfigData(configName);
        const template = {
            name: templateName,
            description: `基于 ${configName} 创建的模板`,
            fields: { ...config },
            created_at: new Date().toISOString()
        };
        
        // 移除敏感信息
        delete template.fields.auth_token;
        
        // 保存到本地存储
        const customTemplates = JSON.parse(localStorage.getItem('ccs-custom-templates') || '{}');
        customTemplates[templateName] = template;
        localStorage.setItem('ccs-custom-templates', JSON.stringify(customTemplates));
        
        showMessage(`✅ 模板 "${templateName}" 已保存`, 'success');
    }
};
```

### 3. 配置历史和版本控制

**配置历史记录：**
```javascript
// 配置历史管理器
const ConfigHistory = {
    // 记录配置变更
    recordChange(configName, oldConfig, newConfig, action) {
        const historyEntry = {
            timestamp: new Date().toISOString(),
            config_name: configName,
            action: action, // 'create', 'update', 'delete', 'switch'
            old_config: oldConfig,
            new_config: newConfig,
            user: this.getCurrentUser(),
            id: this.generateId()
        };
        
        // 保存到历史记录
        const history = this.getHistory();
        history.unshift(historyEntry);
        
        // 限制历史记录数量
        if (history.length > 100) {
            history.splice(100);
        }
        
        localStorage.setItem('ccs-config-history', JSON.stringify(history));
    },
    
    // 获取配置历史
    getConfigHistory(configName) {
        const history = this.getHistory();
        return history.filter(entry => entry.config_name === configName);
    },
    
    // 回滚到指定版本
    rollbackToVersion(historyId) {
        const history = this.getHistory();
        const targetEntry = history.find(entry => entry.id === historyId);
        
        if (!targetEntry) {
            throw new Error('指定的历史版本不存在');
        }
        
        // 确认回滚操作
        const confirmed = confirm(`确定要回滚配置 "${targetEntry.config_name}" 到 ${targetEntry.timestamp} 的版本吗？`);
        if (!confirmed) return;
        
        // 执行回滚
        const currentConfig = getConfigData(targetEntry.config_name);
        updateConfigData(targetEntry.config_name, targetEntry.old_config);
        
        // 记录回滚操作
        this.recordChange(
            targetEntry.config_name,
            currentConfig,
            targetEntry.old_config,
            'rollback'
        );
        
        showMessage(`✅ 已回滚配置 "${targetEntry.config_name}"`, 'success');
        refreshConfigList();
    },
    
    // 显示历史记录界面
    showHistoryDialog(configName) {
        const history = this.getConfigHistory(configName);
        
        const dialog = document.createElement('div');
        dialog.className = 'history-dialog';
        dialog.innerHTML = `
            <div class="dialog-content">
                <div class="dialog-header">
                    <h3>📜 配置历史 - ${configName}</h3>
                    <button class="close-btn" onclick="closeHistoryDialog()">×</button>
                </div>
                <div class="history-list">
                    ${history.map(entry => `
                        <div class="history-entry">
                            <div class="history-time">${new Date(entry.timestamp).toLocaleString()}</div>
                            <div class="history-action">${this.getActionText(entry.action)}</div>
                            <div class="history-actions">
                                <button class="btn-view" onclick="viewHistoryDetails('${entry.id}')">查看</button>
                                <button class="btn-rollback" onclick="ConfigHistory.rollbackToVersion('${entry.id}')">回滚</button>
                            </div>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
        
        document.body.appendChild(dialog);
    }
};
```

## 🎨 界面定制

### 1. 主题设置

**切换主题：**
```css
/* 亮色主题 */
:root[data-theme="light"] {
    --bg-primary: #ffffff;
    --bg-secondary: #f8f9fa;
    --text-primary: #212529;
    --text-secondary: #6c757d;
    --border-color: #dee2e6;
    --accent-color: #007bff;
    --success-color: #28a745;
    --warning-color: #ffc107;
    --error-color: #dc3545;
}

/* 暗色主题 */
:root[data-theme="dark"] {
    --bg-primary: #1a1a1a;
    --bg-secondary: #2d2d2d;
    --text-primary: #ffffff;
    --text-secondary: #b0b0b0;
    --border-color: #404040;
    --accent-color: #0d6efd;
    --success-color: #198754;
    --warning-color: #fd7e14;
    --error-color: #dc3545;
}

/* 高对比度主题 */
:root[data-theme="high-contrast"] {
    --bg-primary: #000000;
    --bg-secondary: #1a1a1a;
    --text-primary: #ffffff;
    --text-secondary: #ffff00;
    --border-color: #ffffff;
    --accent-color: #00ff00;
    --success-color: #00ff00;
    --warning-color: #ffff00;
    --error-color: #ff0000;
}
```

**主题切换器：**
```javascript
// 主题管理器
const ThemeManager = {
    // 可用主题
    themes: {
        'light': '☀️ 亮色主题',
        'dark': '🌙 暗色主题',
        'high-contrast': '🔆 高对比度',
        'auto': '🔄 跟随系统'
    },
    
    // 当前主题
    currentTheme: localStorage.getItem('ccs-theme') || 'auto',
    
    // 初始化主题
    init() {
        this.applyTheme(this.currentTheme);
        this.setupThemeSelector();
        this.watchSystemTheme();
    },
    
    // 应用主题
    applyTheme(theme) {
        if (theme === 'auto') {
            // 跟随系统主题
            const systemTheme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
            document.documentElement.setAttribute('data-theme', systemTheme);
        } else {
            document.documentElement.setAttribute('data-theme', theme);
        }
        
        this.currentTheme = theme;
        localStorage.setItem('ccs-theme', theme);
    },
    
    // 设置主题选择器
    setupThemeSelector() {
        const selector = document.getElementById('theme-selector');
        if (!selector) return;
        
        // 清空现有选项
        selector.innerHTML = '';
        
        // 添加主题选项
        for (const [value, label] of Object.entries(this.themes)) {
            const option = document.createElement('option');
            option.value = value;
            option.textContent = label;
            option.selected = value === this.currentTheme;
            selector.appendChild(option);
        }
        
        // 监听变更
        selector.addEventListener('change', (e) => {
            this.applyTheme(e.target.value);
        });
    },
    
    // 监听系统主题变化
    watchSystemTheme() {
        const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
        mediaQuery.addEventListener('change', () => {
            if (this.currentTheme === 'auto') {
                this.applyTheme('auto');
            }
        });
    }
};
```

### 2. 布局自定义

**响应式布局：**
```css
/* 桌面布局 */
@media (min-width: 1024px) {
    .main-container {
        display: grid;
        grid-template-columns: 300px 1fr 250px;
        grid-template-areas: 
            "sidebar content panel";
        gap: 20px;
    }
    
    .config-list { grid-area: sidebar; }
    .config-details { grid-area: content; }
    .action-panel { grid-area: panel; }
}

/* 平板布局 */
@media (min-width: 768px) and (max-width: 1023px) {
    .main-container {
        display: grid;
        grid-template-columns: 1fr 1fr;
        grid-template-areas: 
            "sidebar content"
            "panel panel";
        gap: 15px;
    }
}

/* 手机布局 */
@media (max-width: 767px) {
    .main-container {
        display: flex;
        flex-direction: column;
        gap: 10px;
    }
    
    .config-list,
    .config-details,
    .action-panel {
        width: 100%;
    }
    
    /* 隐藏不重要的信息 */
    .config-description,
    .last-updated {
        display: none;
    }
}
```

### 3. 个性化设置

**用户偏好设置：**
```javascript
// 用户偏好管理器
const UserPreferences = {
    // 默认偏好设置
    defaults: {
        theme: 'auto',
        language: 'zh-CN',
        autoRefresh: true,
        refreshInterval: 30000,
        showNotifications: true,
        compactMode: false,
        showAdvancedOptions: false,
        defaultView: 'list', // list, grid, table
        sortBy: 'name', // name, lastUsed, status
        sortOrder: 'asc' // asc, desc
    },
    
    // 当前设置
    current: {},
    
    // 初始化偏好设置
    init() {
        this.load();
        this.apply();
        this.setupSettingsPanel();
    },
    
    // 加载设置
    load() {
        const saved = localStorage.getItem('ccs-user-preferences');
        this.current = saved ? { ...this.defaults, ...JSON.parse(saved) } : { ...this.defaults };
    },
    
    // 保存设置
    save() {
        localStorage.setItem('ccs-user-preferences', JSON.stringify(this.current));
    },
    
    // 应用设置
    apply() {
        // 应用主题
        ThemeManager.applyTheme(this.current.theme);
        
        // 应用语言
        document.documentElement.lang = this.current.language;
        
        // 应用紧凑模式
        document.body.classList.toggle('compact-mode', this.current.compactMode);
        
        // 应用自动刷新
        if (this.current.autoRefresh) {
            this.startAutoRefresh();
        }
        
        // 应用默认视图
        this.setDefaultView(this.current.defaultView);
    },
    
    // 更新设置
    update(key, value) {
        this.current[key] = value;
        this.save();
        this.apply();
    },
    
    // 设置面板
    setupSettingsPanel() {
        const panel = document.getElementById('settings-panel');
        if (!panel) return;
        
        panel.innerHTML = `
            <div class="settings-section">
                <h3>🎨 外观设置</h3>
                <div class="setting-item">
                    <label for="theme-setting">主题</label>
                    <select id="theme-setting">
                        <option value="auto">🔄 跟随系统</option>
                        <option value="light">☀️ 亮色主题</option>
                        <option value="dark">🌙 暗色主题</option>
                        <option value="high-contrast">🔆 高对比度</option>
                    </select>
                </div>
                
                <div class="setting-item">
                    <label for="compact-mode">紧凑模式</label>
                    <input type="checkbox" id="compact-mode" ${this.current.compactMode ? 'checked' : ''}>
                </div>
                
                <div class="setting-item">
                    <label for="default-view">默认视图</label>
                    <select id="default-view">
                        <option value="list">📋 列表视图</option>
                        <option value="grid">⊞ 网格视图</option>
                        <option value="table">📊 表格视图</option>
                    </select>
                </div>
            </div>
            
            <div class="settings-section">
                <h3>🔄 行为设置</h3>
                <div class="setting-item">
                    <label for="auto-refresh">自动刷新</label>
                    <input type="checkbox" id="auto-refresh" ${this.current.autoRefresh ? 'checked' : ''}>
                </div>
                
                <div class="setting-item">
                    <label for="refresh-interval">刷新间隔（秒）</label>
                    <input type="number" id="refresh-interval" min="10" max="300" value="${this.current.refreshInterval / 1000}">
                </div>
                
                <div class="setting-item">
                    <label for="show-notifications">显示通知</label>
                    <input type="checkbox" id="show-notifications" ${this.current.showNotifications ? 'checked' : ''}>
                </div>
            </div>
        `;
        
        // 绑定事件监听器
        this.bindSettingsEvents();
    }
};
```

## 🔧 故障排除

### 1. 常见问题

**问题1: 配置列表为空**
- **原因**: 配置文件不存在或格式错误
- **解决方案**:
  1. 检查 `~/.ccs_config.toml` 文件是否存在
  2. 验证TOML格式是否正确
  3. 运行 `ccs --init` 创建默认配置

**问题2: 配置切换失败**
- **原因**: 权限不足或文件锁定
- **解决方案**:
  1. 检查配置文件权限
  2. 确保没有其他程序占用文件
  3. 重启浏览器重新尝试

**问题3: API连接测试失败**
- **原因**: 网络问题、API密钥错误或服务不可用
- **解决方案**:
  1. 检查网络连接
  2. 验证API密钥是否正确
  3. 确认API服务状态
  4. 检查防火墙设置

### 2. 调试工具

**浏览器控制台调试：**
```javascript
// 启用调试模式
window.CCS_DEBUG = true;

// 调试信息收集器
const DebugCollector = {
    logs: [],
    
    // 记录调试信息
    log(level, message, data = null) {
        const entry = {
            timestamp: new Date().toISOString(),
            level: level,
            message: message,
            data: data,
            stack: new Error().stack
        };
        
        this.logs.push(entry);
        
        // 输出到控制台
        console[level](`[CCS] ${message}`, data);
        
        // 限制日志数量
        if (this.logs.length > 1000) {
            this.logs.splice(0, 500);
        }
    },
    
    // 导出调试日志
    exportLogs() {
        const debugData = {
            timestamp: new Date().toISOString(),
            userAgent: navigator.userAgent,
            url: window.location.href,
            logs: this.logs,
            config: this.getSystemInfo()
        };
        
        const blob = new Blob([JSON.stringify(debugData, null, 2)], 
                             { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        
        const a = document.createElement('a');
        a.href = url;
        a.download = `ccs-debug-${Date.now()}.json`;
        a.click();
        
        URL.revokeObjectURL(url);
    },
    
    // 获取系统信息
    getSystemInfo() {
        return {
            browser: this.getBrowserInfo(),
            screen: {
                width: screen.width,
                height: screen.height,
                colorDepth: screen.colorDepth
            },
            viewport: {
                width: window.innerWidth,
                height: window.innerHeight
            },
            localStorage: this.getLocalStorageInfo(),
            preferences: UserPreferences.current
        };
    }
};
```

**网络请求监控：**
```javascript
// API请求监控器
const APIMonitor = {
    requests: [],
    
    // 监控fetch请求
    init() {
        const originalFetch = window.fetch;
        
        window.fetch = async function(...args) {
            const startTime = Date.now();
            const request = {
                url: args[0],
                options: args[1],
                startTime: startTime
            };
            
            try {
                const response = await originalFetch.apply(this, args);
                
                request.endTime = Date.now();
                request.duration = request.endTime - request.startTime;
                request.status = response.status;
                request.success = response.ok;
                
                APIMonitor.requests.push(request);
                
                if (window.CCS_DEBUG) {
                    console.log(`[API] ${request.url} - ${request.status} (${request.duration}ms)`);
                }
                
                return response;
            } catch (error) {
                request.endTime = Date.now();
                request.duration = request.endTime - request.startTime;
                request.error = error.message;
                request.success = false;
                
                APIMonitor.requests.push(request);
                
                if (window.CCS_DEBUG) {
                    console.error(`[API] ${request.url} - Error: ${error.message} (${request.duration}ms)`);
                }
                
                throw error;
            }
        };
    },
    
    // 获取请求统计
    getStats() {
        const total = this.requests.length;
        const successful = this.requests.filter(r => r.success).length;
        const failed = total - successful;
        const avgDuration = this.requests.reduce((sum, r) => sum + r.duration, 0) / total;
        
        return {
            total: total,
            successful: successful,
            failed: failed,
            successRate: (successful / total * 100).toFixed(2) + '%',
            averageDuration: Math.round(avgDuration) + 'ms'
        };
    }
};
```

## 💡 最佳实践

### 1. 安全建议

**API密钥管理：**
- 🔐 定期轮换API密钥
- 🚫 不要在截图中暴露密钥
- 💾 定期备份配置（排除敏感信息）
- 🔒 使用浏览器的密码管理器

**访问控制：**
- 🏠 仅在可信设备上使用Web界面
- 🔒 使用HTTPS访问（如果通过网络）
- 👥 不要共享配置文件
- 🚪 使用后及时关闭浏览器标签

### 2. 性能优化

**减少资源消耗：**
```javascript
// 配置缓存管理
const ConfigCache = {
    cache: new Map(),
    ttl: 5 * 60 * 1000, // 5分钟
    
    // 获取缓存的配置
    get(key) {
        const item = this.cache.get(key);
        if (!item) return null;
        
        if (Date.now() - item.timestamp > this.ttl) {
            this.cache.delete(key);
            return null;
        }
        
        return item.data;
    },
    
    // 设置缓存
    set(key, data) {
        this.cache.set(key, {
            data: data,
            timestamp: Date.now()
        });
    },
    
    // 清除过期缓存
    cleanup() {
        const now = Date.now();
        for (const [key, item] of this.cache.entries()) {
            if (now - item.timestamp > this.ttl) {
                this.cache.delete(key);
            }
        }
    }
};

// 定期清理缓存
setInterval(() => ConfigCache.cleanup(), 60000);
```

**懒加载实现：**
```javascript
// 懒加载配置详情
const LazyLoader = {
    // 观察器
    observer: null,
    
    // 初始化懒加载
    init() {
        this.observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    this.loadConfigDetails(entry.target);
                    this.observer.unobserve(entry.target);
                }
            });
        }, {
            rootMargin: '50px'
        });
    },
    
    // 观察配置项
    observe(element) {
        if (this.observer) {
            this.observer.observe(element);
        }
    },
    
    // 加载配置详情
    async loadConfigDetails(element) {
        const configName = element.dataset.configName;
        if (!configName) return;
        
        try {
            // 显示加载状态
            element.classList.add('loading');
            
            // 加载配置详情
            const details = await getConfigDetails(configName);
            
            // 更新界面
            this.renderConfigDetails(element, details);
            
            // 移除加载状态
            element.classList.remove('loading');
            
        } catch (error) {
            console.error('加载配置详情失败:', error);
            element.classList.add('error');
        }
    }
};
```

### 3. 用户体验优化

**快捷键支持：**
```javascript
// 快捷键管理器
const KeyboardShortcuts = {
    shortcuts: {
        'Ctrl+N': () => showNewConfigDialog(),
        'Ctrl+S': () => saveCurrentConfig(),
        'Ctrl+R': () => refreshConfigList(),
        'Ctrl+F': () => focusSearchBox(),
        'Escape': () => closeCurrentDialog(),
        'F5': () => location.reload(),
        'Ctrl+1': () => switchToConfig(1),
        'Ctrl+2': () => switchToConfig(2),
        'Ctrl+3': () => switchToConfig(3)
    },
    
    // 初始化快捷键
    init() {
        document.addEventListener('keydown', (e) => {
            const key = this.getKeyString(e);
            const handler = this.shortcuts[key];
            
            if (handler) {
                e.preventDefault();
                handler();
            }
        });
    },
    
    // 获取按键字符串
    getKeyString(event) {
        const parts = [];
        
        if (event.ctrlKey) parts.push('Ctrl');
        if (event.altKey) parts.push('Alt');
        if (event.shiftKey) parts.push('Shift');
        
        if (event.key !== 'Control' && event.key !== 'Alt' && event.key !== 'Shift') {
            parts.push(event.key);
        }
        
        return parts.join('+');
    }
};
```

**无障碍访问：**
```html
<!-- 无障碍访问增强 -->
<div class="config-item" 
     role="button" 
     tabindex="0" 
     aria-label="OpenAI GPT-4 配置,当前激活" 
     aria-describedby="config-description-1">
    
    <div class="config-header">
        <h3 id="config-title-1">OpenAI GPT-4</h3>
        <span class="status-badge" aria-label="状态：正常">✅</span>
    </div>
    
    <div id="config-description-1" class="config-description">
        OpenAI官方API服务,用于生产环境
    </div>
    
    <div class="config-actions" role="group" aria-label="配置操作">
        <button type="button" 
                aria-label="切换到此配置" 
                onclick="switchConfig('openai-gpt4')">
            切换
        </button>
        <button type="button" 
                aria-label="编辑此配置" 
                onclick="editConfig('openai-gpt4')">
            编辑
        </button>
        <button type="button" 
                aria-label="测试此配置的连接" 
                onclick="testConfig('openai-gpt4')">
            测试
        </button>
    </div>
</div>
```

---

**相关文档**：
- [快速开始](quick-start.md) - 快速上手指南
- [配置管理](configuration.md) - 配置文件详解
- [故障排除](troubleshooting.md) - 问题解决方案
- [API参考](api-reference.md) - 接口文档