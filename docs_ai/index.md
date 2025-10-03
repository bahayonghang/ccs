---
layout: home

hero:
  name: "CCS 技术文档"
  text: "Claude Code Configuration Switcher"
  tagline: "跨平台API配置切换工具的完整技术架构文档"
  actions:
    - theme: brand
      text: 快速开始
      link: /architecture/
    - theme: alt
      text: Shell脚本详解
      link: /shell/

features:
  - icon: 🚀
    title: 高性能架构
    details: 基于缓存系统和智能重试机制，实现毫秒级配置切换，支持300秒TTL缓存优化
  - icon: 🔧
    title: 跨平台支持
    details: 完整支持Linux、macOS、Windows三大平台，包含Bash、Zsh、Fish、PowerShell多种Shell环境
  - icon: 🛡️
    title: 企业级可靠性
    details: 13种错误码分类处理、自动备份机制、完整的日志系统和性能监控
  - icon: 📊
    title: 智能诊断
    details: 内置系统诊断、依赖检查、配置验证和性能分析，提供详细的故障排除指导
  - icon: 🌐
    title: Web管理界面
    details: 提供可视化配置管理界面，支持实时配置验证和在线编辑功能
  - icon: 🔄
    title: 自动化部署
    details: 一键安装脚本、自动环境配置、智能Shell检测和无缝升级机制
---

<div class="vp-doc">

## 📚 文档结构

本技术文档全面覆盖了CCS (Claude Code Configuration Switcher) 的技术架构、实现细节和最佳实践。

<div class="doc-grid">

### 🏗️ [系统架构](/architecture/)
深入了解CCS的核心设计理念和技术实现
- **整体架构设计** - 模块化设计理念和组件关系
- **核心组件分析** - 主要功能模块的技术实现
- **数据流程图** - 配置切换的完整数据流
- **跨平台设计** - 多平台兼容性的技术方案

### 🐚 [Shell脚本系统](/shell/)
探索强大的Shell脚本生态系统
- **主脚本 (ccs.sh)** - 核心业务逻辑和命令路由
- **通用工具库 (ccs-common.sh)** - 共享函数和工具集
- **横幅显示 (banner.sh)** - 用户界面和视觉体验
- **配置管理** - TOML解析和配置缓存机制
- **错误处理** - 统一错误处理和安全退出机制

### 🚀 [安装部署](/installation/)
快速上手和部署指南
- **快速安装** - 一键安装脚本的技术实现
- **完整安装** - 详细安装过程和配置选项
- **跨平台支持** - 不同操作系统的适配策略
- **故障排除** - 常见问题和解决方案

### 📖 [API参考](/api/)
完整的接口和配置参考
- **命令行接口** - 完整的CLI命令参考
- **配置文件格式** - TOML配置文件规范
- **环境变量** - 系统环境变量说明
- **错误码** - 详细的错误码分类和处理

</div>

## 🎯 核心技术特性

<div class="feature-grid">

<div class="feature-card">

### ⚡ 性能优化
- **智能缓存系统** - 300秒TTL缓存，5倍性能提升
- **并发处理** - 支持多任务并行执行
- **资源管理** - 自动清理临时文件和缓存

</div>

<div class="feature-card">

### 🔒 安全增强
- **权限验证** - 文件权限和执行权限检查
- **安全退出** - 在Shell环境中的安全退出机制
- **配置保护** - 自动备份和完整性验证

</div>

<div class="feature-card">

### 🎨 用户体验
- **智能诊断** - 自动检测系统环境和依赖
- **详细日志** - 多级别日志系统 (DEBUG/INFO/WARN/ERROR)
- **友好提示** - 彩色输出和进度指示

</div>

</div>

## 🔗 相关链接

<div class="link-grid">

- 📦 [GitHub 仓库](https://github.com/bahayonghang/ccs)
- 🐛 [问题反馈](https://github.com/bahayonghang/ccs/issues)
- 🤝 [贡献指南](https://github.com/bahayonghang/ccs/blob/main/CONTRIBUTING.md)

</div>

---

<div class="footer-note">
<em>本文档基于 CCS v2.0.0 版本编写，持续更新中...</em>
</div>

</div>

<style>
.vp-doc {
  max-width: 1200px;
  margin: 0 auto;
}

.doc-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  margin: 2rem 0;
}

.doc-grid > div {
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  padding: 1.5rem;
  border: 1px solid var(--vp-c-divider);
  transition: all 0.3s ease;
}

.doc-grid > div:hover {
  border-color: var(--vp-c-brand);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.feature-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.feature-card {
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  padding: 1.5rem;
  border: 1px solid var(--vp-c-divider);
  transition: all 0.3s ease;
}

.feature-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
  border-color: var(--vp-c-brand);
}

.feature-card h3 {
  margin-top: 0;
  color: var(--vp-c-brand);
  font-size: 1.2rem;
  margin-bottom: 1rem;
}

.feature-card ul {
  margin: 0;
  padding-left: 0;
  list-style: none;
}

.feature-card li {
  margin: 0.5rem 0;
  padding-left: 1rem;
  position: relative;
}

.feature-card li::before {
  content: "▸";
  position: absolute;
  left: 0;
  color: var(--vp-c-brand);
  font-weight: bold;
}

.link-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  justify-content: center;
  margin: 2rem 0;
}

.link-grid a {
  display: inline-flex;
  align-items: center;
  padding: 0.75rem 1.5rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  text-decoration: none;
  color: var(--vp-c-text-1);
  transition: all 0.3s ease;
  font-weight: 500;
}

.link-grid a:hover {
  background: var(--vp-c-brand);
  color: white;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.footer-note {
  text-align: center;
  margin: 3rem 0 1rem;
  padding: 1rem;
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  border: 1px solid var(--vp-c-divider);
}

@media (max-width: 768px) {
  .doc-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .feature-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .link-grid {
    flex-direction: column;
    align-items: center;
  }
  
  .link-grid a {
    width: 100%;
    max-width: 300px;
    justify-content: center;
  }
}
</style>