# SWidget - Sapphire 小组件系统

欢迎使用 Sapphire 小组件系统！这是一个强大的桌面小组件开发框架，支持使用 QML 和 HTML 技术创建自定义桌面小组件。

## 📖 简介

Sapphire 小组件系统允许开发者创建功能丰富的桌面小组件，支持：

- **QML 组件**：使用 Qt Quick/QML 开发，高性能、丰富的系统功能访问
- **HTML 组件**：使用 HTML/JavaScript/CSS 开发，Web 技术栈、快速开发
- **URL 组件**：直接嵌入网页，在线内容展示

所有组件都支持：

- 🎨 主题色自动适配
- 📁 文件拖放代理
- 🎵 系统媒体传输控制（SMTC）
- 💾 数据持久化
- 🔄 热重载开发
- 🎯 响应式布局

## 📁 目录结构

```text
swidget/
├── README.md              # 本文件
├── doc/                   # 📚 开发文档
│   ├── README.md         # 文档导航
│   ├── general.md        # 通用结构与系统概览（前置知识）
│   ├── QML.md            # QML组件开发指南
│   └── HTML.md           # HTML组件开发指南
├── common/                # 🔧 公共资源
│   ├── SWidget.qml       # QML组件基类
│   └── SWebWidget.qml    # HTML组件基类
├── qml_template/          # 📦 QML组件模板
├── html_template/        # 📦 HTML组件模板
└── [示例项目]/           # 💡 示例和演示
    ├── smtc_player/      # SMTC媒体控制示例
    ├── proxyfile_demo/   # 文件代理示例
    ├── hymnly_mp4_player/# 视频播放示例
    └── ...
```

## 🚀 快速开始

### 1. 阅读文档

**建议按以下顺序阅读：**

1. **[通用结构与系统概览](./doc/general.md)** - 了解系统基本概念、元数据结构、存储机制等前置知识
2. **选择组件类型**：
   - QML 组件 → 阅读 [QML组件开发文档](./doc/QML.md)
   - HTML 组件 → 阅读 [HTML组件开发文档](./doc/HTML.md)

### 2. 创建你的第一个小组件

1. 打开 Sapphire 小组件编辑器
2. 点击"创建新小组件"
3. 选择"从模板创建" → 选择 QML 或 HTML 模板
4. 输入组件名称和显示名称
5. 开始开发！

### 3. 参考示例

查看 `swidget/` 目录下的示例项目，了解实际开发案例：

- **`smtc_player/`** - SMTC 媒体控制组件示例
- **`proxyfile_demo/`** - 文件拖放代理示例
- **`hymnly_mp4_player/`** - 视频播放组件示例
- **`qml_template/`** - QML 组件基础模板
- **`html_template/`** - HTML 组件基础模板

## 📚 文档导航

### 核心文档

- **[📚 文档总览](./doc/README.md)** - 完整的文档导航和索引
- **[🔧 通用结构与系统概览](./doc/general.md)** - 系统架构、元数据、存储、编辑器等前置知识
- **[🎨 QML组件开发](./doc/QML.md)** - QML 组件的完整开发指南
- **[🌐 HTML组件开发](./doc/HTML.md)** - HTML 组件的完整开发指南

### 快速查找

| 主题 | 文档位置 |
|------|----------|
| 小组件类型选择 | [通用结构 - 小组件类型](./doc/general.md#小组件类型) |
| 元数据配置 | [通用结构 - 元数据结构](./doc/general.md#元数据结构) |
| QML 属性说明 | [QML开发 - 应用内属性](./doc/QML.md#应用内属性) |
| HTML Bridge 使用 | [HTML开发 - Bridge对象](./doc/HTML.md#bridge对象) |
| SMTC 功能 | [QML开发 - SMTC功能](./doc/QML.md#smtc功能系统媒体传输控制) / [HTML开发 - SMTC功能](./doc/HTML.md#smtc功能系统媒体传输控制) |
| 文件代理 | [QML开发 - ProxyFile](./doc/QML.md#proxyfile属性文件代理) / [HTML开发 - ProxyFile](./doc/HTML.md#proxyfile功能文件代理) |
| 数据持久化 | [通用结构 - 存储结构](./doc/general.md#存储结构) |
| 常见问题 | [QML开发 - 常见问题](./doc/QML.md#常见问题) / [HTML开发 - 常见问题](./doc/HTML.md#常见问题) |

## 🛠️ 开发工具

### 小组件编辑器

- **创建新组件**：从模板、文件或 URL 创建
- **编辑元数据**：配置组件基本信息、功能特性、尺寸布局
- **文件管理**：打开主文件、选择手册和预览图
- **导入导出**：导出为 `.sawidget` 安装包

### 开发调试

- **热重载**：开发时自动重载，实时查看效果
- **调试工具**：
  - QML：`console.log()` + `--log-console` 参数
  - HTML：浏览器开发者工具 + 在浏览器中打开
- **FPS 监控**：QML 组件支持性能监控

## 💡 示例项目

### QML 示例

- **`qml_template/`** - QML 组件基础模板
- **`smtc_player/`** - SMTC 媒体控制组件
- **`proxyfile_demo/`** - 文件代理演示（QML 版本）
- **`hymnly_mp4_player/`** - 视频播放组件

### HTML 示例

- **`html_template/`** - HTML 组件基础模板
- **`proxyfile_demo/`** - 文件代理演示（HTML 版本）
- **`example_webchannel/`** - WebChannel 通信示例
- **`Hymnly_clock/`** - 时钟组件示例

## 🎯 核心特性

### 统一接口

所有组件都继承自统一的基类：

- **QML 组件**：继承 `common/SWidget.qml`
- **HTML 组件**：通过 `common/SWebWidget.qml` 包装

### 丰富的功能支持

- **主题系统**：自动适配 Sapphire 主题色和样式
- **文件代理**：支持文件拖放，自动获取文件信息
- **SMTC 集成**：系统媒体传输控制，控制媒体播放
- **数据持久化**：单个实例属性和全局数据存储
- **响应式布局**：自动适应不同尺寸

### 开发体验

- **热重载**：修改代码后自动重载
- **完整文档**：详细的中文开发文档
- **丰富示例**：多个实际项目示例
- **调试支持**：完善的调试工具

## 📝 开发规范

### 文件命名

- 组件名称使用小写字母和下划线（如：`my_widget`）
- 主文件与组件名称一致（如：`my_widget.qml` 或 `my_widget.html`）

### 目录结构

每个小组件应包含：

- `metadata.json` - 元数据文件（必需）
- `组件名.qml` 或 `组件名.html` - 主文件（必需）
- `manual.md` - 使用手册（可选）
- `preview.png` - 预览图（可选）

### 代码规范

- **QML**：遵循 Qt QML 最佳实践
- **HTML**：使用现代 Web 标准
- **注释**：使用中文注释，关键功能添加详细说明

## ❓ 获取帮助

1. **查看文档**：阅读对应文档的"常见问题"章节
2. **参考示例**：查看 `swidget/` 目录下的示例项目
3. **调试工具**：使用调试工具排查问题
4. **查看源码**：参考 `common/` 目录下的基类实现

## 🔗 相关资源

- **开发文档**：[./doc/README.md](./doc/README.md)
- **QML 基类**：[./common/SWidget.qml](./common/SWidget.qml)
- **HTML 基类**：[./common/SWebWidget.qml](./common/SWebWidget.qml)

## 📄 许可证

请参考项目主 LICENSE 文件。

---

**开始你的小组件开发之旅吧！** 🎉

如有问题，请查阅文档或参考示例项目。
