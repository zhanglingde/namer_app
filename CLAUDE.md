# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此代码库中工作时提供指导。

## 项目概述

这是一个名为 "namer_app" 的 Flutter 应用程序 - 一个多功能应用，包含以下模块：
1. **单词生成和收藏**：使用 `english_words` 包生成随机英文单词对，用户可以收藏单词、查看历史记录并搜索收藏
2. **笔记管理**：支持 Markdown 和富文本两种格式的笔记编辑，提供标签管理、搜索、置顶等功能

该应用支持移动端和桌面端平台（Windows/Linux/macOS）。

## 开发命令

### 运行应用
```bash
# 在默认设备上运行
flutter run

# 在指定设备上运行
flutter run -d windows
flutter run -d chrome
flutter run -d <device-id>

# 列出可用设备
flutter devices
```

### 构建
```bash
# 构建 Windows 版本
flutter build windows

# 构建 Android APK
flutter build apk

# 构建 Web 版本
flutter build web
```

### 测试和代码检查
```bash
# 运行测试
flutter test

# 分析代码
flutter analyze

# 格式化代码
dart format .
```

### 依赖管理
```bash
# 获取依赖
flutter pub get

# 更新依赖
flutter pub upgrade

# 检查过时的包
flutter pub outdated
```

## 架构概述

### 状态管理
应用使用 **Provider** 模式进行状态管理，包含三个主要的 Provider：

1. **MyAppState** (`lib/config/my_app_state.dart`) - 单词模块状态
   - 管理当前单词生成、收藏列表和历史记录
   - 处理单词收藏操作（添加/删除收藏）
   - 应用启动时从 SQLite 加载数据
   - 使用 `ChangeNotifier` 通知 UI 状态变化

2. **NotesProvider** (`lib/providers/note_provider.dart`) - 笔记模块状态
   - 管理笔记列表、选中的笔记、标签列表
   - 处理笔记的 CRUD 操作（创建、读取、更新、删除）
   - 支持搜索和标签过滤
   - 应用启动时自动加载笔记数据
   - 使用 `ChangeNotifier` 通知 UI 状态变化

3. **Prefs** (`lib/config/shared_preference_provider.dart`) - 用户偏好设置
   - 管理主题颜色、主题模式（亮色/暗色/系统）和语言
   - 使用 `SharedPreferences` 持久化设置
   - 单例模式配合 `ChangeNotifier`

### 数据持久化

**SQLite 数据库** (`lib/dao/database.dart`)：
- 数据库名称：`namer_app.db`
- 当前版本：3
- 使用 `sqflite_common_ffi` 实现跨平台支持（桌面端 + 移动端）
- 在 `main()` 中应用启动前初始化
- 三个主要数据表：
  - `tb_word_collect`：存储收藏的单词对
  - `tb_history`：存储单词生成历史记录（限制为最近 10 条）
  - `notes`：存储笔记数据（包含标题、内容、标签、置顶状态、笔记类型等）

**DAO 层**：
- `lib/dao/word_collect.dart`：单词收藏的 CRUD 操作
- `lib/dao/history.dart`：历史记录的操作
- `lib/dao/note_dao.dart`：笔记的 CRUD 操作，支持搜索和标签过滤
- 所有数据库操作都是异步的，返回 Future

### UI 结构

**导航** (`lib/page/home_page.dart`)：
- 自适应布局：移动端（<450px）使用 BottomNavigationBar，桌面端使用 NavigationRail
- 五个主要页面，索引 0-4：
  - 0: Generator（单词生成主页）
  - 1: Favorites（单词收藏）
  - 2: Notes（笔记管理）
  - 3: Search（搜索）
  - 4: Settings（设置）

**单词模块页面**：
- `generator_page.dart`：单词生成界面
- `favorite_page.dart`：显示收藏的单词
- `search_page.dart`：搜索功能

**笔记模块页面**：
- `notes_layout_page.dart`：笔记模块布局容器（左右分栏）
- `note_page.dart`：笔记列表页面，显示所有笔记，支持搜索和新建
- `note_detail_page.dart`：笔记详情和编辑页面，根据笔记类型显示不同编辑器
- `rich_text_editor.dart`：富文本编辑器组件（基于 flutter_quill）

**通用页面**：
- `settings_page.dart`：主题和应用设置

### 模型

**单词模块**：
- `lib/models/Word.dart`：表示收藏的单词对
- `lib/models/History.dart`：表示历史记录条目
- 两个模型都有 `toMap()` 方法用于数据库序列化，以及 `convertWordPair()` 方法将其转换为 `english_words` 包的 `WordPair` 类型

**笔记模块**：
- `lib/models/note.dart`：表示笔记数据
  - 包含字段：id, title, content, createdAt, updatedAt, tags, isPinned, isArchived, noteType
  - `NoteType` 枚举：`markdown` 和 `richText` 两种类型
  - `toMap()` 方法用于数据库序列化
  - `fromMap()` 工厂方法从数据库加载
  - `getPlainText()` 方法提取纯文本（支持 Markdown 和 Quill Delta JSON）
  - `getPreview()` 方法生成预览文本

## 关键技术细节

### 初始化序列 (main.dart)
1. `WidgetsFlutterBinding.ensureInitialized()` - 初始化 Flutter 绑定
2. `Prefs().initPrefs()` - 加载 SharedPreferences
3. `DBHelper().initDB()` - 初始化 SQLite 数据库
4. `runApp(MyApp())` - 启动应用

### 数据库平台处理
应用会检测平台并初始化相应的 SQLite 实现：
- 桌面端（Windows/Linux）：使用 `sqfliteFfiInit()` 和 `databaseFactoryFfi`
- 移动端（iOS/Android）：使用标准的 `sqflite`

### 主题系统
- 主题颜色和模式存储在 SharedPreferences 中
- MaterialApp 中的 `Consumer<Prefs>` 在主题变化时重建 UI
- 支持 Material 3 设计，使用 `useMaterial3: true`
- 从种子颜色动态生成配色方案

### 历史记录的 AnimatedList
历史记录使用 `AnimatedList` 配合 `GlobalKey` 实现动画插入：
- Key 存储在 `MyAppState.historyListKey` 中
- 新项目在索引 0（顶部）插入并带有动画效果
- 数据库中限制为最近 10 条记录

## 重要模式

### 数据库操作
始终使用单例模式访问数据库：
```dart
final db = await DBHelper().database;
```

### 状态更新
在 Provider 中修改状态后，始终调用：
```dart
notifyListeners();
```

### 状态中的错误处理
状态操作（收藏、历史记录）包含 try-catch 块，在失败时恢复之前的状态。

## 笔记模块详细说明

### 笔记类型

应用支持两种笔记类型：

1. **Markdown 笔记** (`NoteType.markdown`)
   - 使用纯文本存储 Markdown 格式内容
   - 提供编辑/预览模式切换
   - 编辑模式：带 Markdown 工具栏的文本编辑器
   - 预览模式：使用 `flutter_markdown` 渲染 Markdown 内容
   - 工具栏支持：加粗、斜体、标题、列表、链接、代码、引用等

2. **富文本笔记** (`NoteType.richText`)
   - 使用 Quill Delta JSON 格式存储内容
   - 所见即所得的编辑体验
   - 基于 `flutter_quill` 插件实现
   - 工具栏支持：撤销/重做、文本样式、标题、列表、缩进、链接等

### 笔记功能

- **创建笔记**：点击 "+" 按钮，选择笔记类型（Markdown 或富文本）
- **编辑笔记**：点击笔记卡片进入详情页编辑
- **标签管理**：为笔记添加/删除标签，支持按标签过滤
- **置顶功能**：重要笔记可以置顶显示在列表顶部
- **搜索功能**：支持按标题和内容搜索笔记
- **自动保存**：编辑后点击保存按钮保存更改

### 数据库结构

**notes 表**：
```sql
CREATE TABLE notes (
  id TEXT PRIMARY KEY,              -- UUID
  title TEXT NOT NULL,              -- 笔记标题
  content TEXT NOT NULL,            -- 内容（Markdown 文本或 Quill Delta JSON）
  createdAt TEXT NOT NULL,          -- 创建时间（ISO 8601）
  updatedAt TEXT NOT NULL,          -- 更新时间（ISO 8601）
  tags TEXT,                        -- 标签（逗号分隔）
  isPinned INTEGER NOT NULL DEFAULT 0,     -- 是否置顶（0/1）
  isArchived INTEGER NOT NULL DEFAULT 0,   -- 是否归档（0/1）
  noteType INTEGER NOT NULL DEFAULT 0      -- 笔记类型（0=Markdown, 1=富文本）
)
```

### 关键实现细节

1. **笔记类型选择对话框** (`note_page.dart:_showCreateNoteDialog`)
   - 用户点击新建按钮时弹出
   - 提供两个选项：Markdown 笔记和富文本笔记
   - 选择后调用 `NotesProvider.createNote(noteType: ...)` 创建笔记

2. **富文本编辑器** (`rich_text_editor.dart`)
   - 使用 `QuillController` 管理编辑器状态
   - 初始化时从 JSON 加载 Quill Delta 文档
   - 监听内容变化，将 Delta 转换为 JSON 字符串回调
   - 自定义工具栏，提供常用格式化按钮

3. **笔记详情页** (`note_detail_page.dart`)
   - 根据 `note.noteType` 显示不同的编辑器
   - Markdown 笔记：显示 Markdown 编辑器和预览切换
   - 富文本笔记：显示富文本编辑器
   - 工具栏显示笔记类型标签（蓝色/橙色）

4. **本地化支持** (`main.dart`)
   - 添加 `FlutterQuillLocalizations.delegate` 到 MaterialApp
   - 支持中文和英文界面

## 依赖说明

**核心依赖**：
- `english_words: ^4.0.0` - 单词对生成
- `provider: ^6.0.0` - 状态管理（Flutter 官方推荐）
- `sqflite_common_ffi: 2.3.0` - 桌面端 SQLite 支持
- `sqflite: ^2.3.2` - 移动端 SQLite 支持
- `shared_preferences: ^2.2.2` - 轻量级持久化存储
- `window_manager: 0.3.6` - Windows 桌面窗口管理
- `uuid: ^4.2.1` - UUID 生成（用于笔记 ID）
- `intl: ^0.20.2` - 日期格式化

**笔记模块依赖**：
- `flutter_markdown: ^0.7.4+1` - Markdown 渲染
- `flutter_quill: ^11.5.0` - 富文本编辑器
- `flutter_localizations` - Flutter 本地化支持（flutter_quill 需要）

## Claude Code 使用说明

- 在回答问题和解释代码时，请使用中文（简体）。