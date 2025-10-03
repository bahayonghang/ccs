export default {
  title: 'CCS 技术文档',
  description: 'Claude Code Configuration Switcher 技术架构文档',
  
  // 基础配置
  base: '/',
  lang: 'zh-CN',
  
  // 主题配置
  themeConfig: {
    // 网站标题
    siteTitle: 'CCS 技术文档',
    
    // 导航栏
    nav: [
      { text: '首页', link: '/' },
      { text: '架构概览', link: '/architecture/' },
      { text: 'Shell脚本', link: '/shell/' },
      { text: '安装部署', link: '/installation/' },
      { text: 'API参考', link: '/api/' },
      { 
        text: '源码',
        link: 'https://github.com/bahayonghang/ccs'
      }
    ],
    
    // 侧边栏
    sidebar: {
      '/architecture/': [
        {
          text: '系统架构',
          items: [
            { text: '整体架构', link: '/architecture/' },
            { text: '核心组件', link: '/architecture/components' },
            { text: '数据流程', link: '/architecture/data-flow' },
            { text: '跨平台设计', link: '/architecture/cross-platform' }
          ]
        }
      ],
      '/shell/': [
        {
          text: 'Shell脚本系统',
          items: [
            { text: '脚本概览', link: '/shell/' },
            { text: '主脚本 (ccs.sh)', link: '/shell/ccs-main' },
            { text: '通用工具库 (ccs-common.sh)', link: '/shell/ccs-common' },
            { text: '横幅显示 (banner.sh)', link: '/shell/banner' },
            { text: 'Fish Shell支持', link: '/shell/fish' }
          ]
        },
        {
          text: '核心功能',
          items: [
            { text: '配置管理', link: '/shell/config-management' },
            { text: '缓存系统', link: '/shell/caching' },
            { text: '错误处理', link: '/shell/error-handling' },
            { text: '性能监控', link: '/shell/performance' },
            { text: '日志系统', link: '/shell/logging' }
          ]
        }
      ],
      '/installation/': [
        {
          text: '安装部署',
          items: [
            { text: '安装概览', link: '/installation/' },
            { text: '快速安装', link: '/installation/quick-install' },
            { text: '完整安装', link: '/installation/full-install' },
            { text: '跨平台支持', link: '/installation/cross-platform' },
            { text: '故障排除', link: '/installation/troubleshooting' }
          ]
        }
      ],
      '/api/': [
        {
          text: 'API参考',
          items: [
            { text: 'API概览', link: '/api/' },
            { text: '命令行接口', link: '/api/cli' },
            { text: '配置文件格式', link: '/api/config-format' },
            { text: '环境变量', link: '/api/environment' },
            { text: '错误码', link: '/api/error-codes' }
          ]
        }
      ]
    },
    
    // 社交链接
    socialLinks: [
      { icon: 'github', link: 'https://github.com/bahayonghang/ccs' }
    ],
    
    // 页脚
    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2024 CCS Development Team'
    },
    
    // 搜索
    search: {
      provider: 'local'
    },
    
    // 编辑链接
    editLink: {
      pattern: 'https://github.com/bahayonghang/ccs/edit/main/docs_ai/:path',
      text: '在 GitHub 上编辑此页'
    },
    
    // 最后更新时间
    lastUpdated: {
      text: '最后更新于',
      formatOptions: {
        dateStyle: 'short',
        timeStyle: 'medium'
      }
    }
  },
  
  // Markdown配置
  markdown: {
    lineNumbers: true,
    theme: {
      light: 'github-light',
      dark: 'github-dark'
    }
  },
  
  // 构建配置
  vite: {
    build: {
      chunkSizeWarningLimit: 1600
    }
  }
}