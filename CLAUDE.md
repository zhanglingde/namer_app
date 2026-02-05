# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此代码库中工作时提供指导。

## 项目概述

这是一个名为 "namer_app" 的 Flutter 应用程序 - 一个单词生成和收藏应用，使用 `english_words` 包生成随机英文单词对。用户可以收藏单词、查看历史记录并搜索他们的收藏。该应用支持移动端和桌面端平台（Windows/Linux/macOS）。

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
应用使用 **Provider** 模式进行状态管理，包含两个主要的 Provider：

1. **MyAppState** (`lib/config/my_app_state.dart`) - 核心应用状态
   - 管理当前单词生成、收藏列表和历史记录
   - 处理单词收藏操作（添加/删除收藏）
   - 应用启动时从 SQLite 加载数据
   - 使用 `ChangeNotifier` 通知 UI 状态变化

2. **Prefs** (`lib/config/shared_preference_provider.dart`) - 用户偏好设置
   - 管理主题颜色、主题模式（亮色/暗色/系统）和语言
   - 使用 `SharedPreferences` 持久化设置
   - 单例模式配合 `ChangeNotifier`

### 数据持久化

**SQLite 数据库** (`lib/dao/database.dart`)：
- 数据库名称：`namer_app.db`
- 使用 `sqflite_common_ffi` 实现跨平台支持（桌面端 + 移动端）
- 在 `main()` 中应用启动前初始化
- 两个主要数据表：
  - `tb_word_collect`：存储收藏的单词对
  - `tb_history`：存储单词生成历史记录（限制为最近 10 条）

**DAO 层**：
- `lib/dao/word_collect.dart`：收藏的 CRUD 操作
- `lib/dao/history.dart`：历史记录的操作
- 所有数据库操作都是异步的，返回 Future

### UI 结构

**导航** (`lib/page/home_page.dart`)：
- 自适应布局：移动端（<450px）使用 BottomNavigationBar，桌面端使用 NavigationRail
- 五个主要页面，索引 0-4：
  - 0: Generator（主页）
  - 1: Favorites（收藏）
  - 2: Search（搜索）
  - 3: Download（下载，占位符）
  - 4: Settings（设置）

**页面**：
- `generator_page.dart`：主要的单词生成界面
- `favorite_page.dart`：显示收藏的单词
- `search_page.dart`：搜索功能
- `settings_page.dart`：主题和应用设置

### 模型
- `lib/models/Word.dart`：表示收藏的单词对
- `lib/models/History.dart`：表示历史记录条目
- 两个模型都有 `toMap()` 方法用于数据库序列化，以及 `convertWordPair()` 方法将其转换为 `english_words` 包的 `WordPair` 类型

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

## 依赖说明

- `english_words: ^4.0.0` - 单词对生成
- `provider: ^6.0.0` - 状态管理（Flutter 官方推荐）
- `sqflite_common_ffi: 2.3.0` - 桌面端 SQLite 支持
- `sqflite: ^2.3.2` - 移动端 SQLite 支持
- `shared_preferences: ^2.2.2` - 轻量级持久化存储
- `window_manager: 0.3.6` - Windows 桌面窗口管理
- `get: ^4.6.6` - 工具包（来自 bilibili 项目）

## Claude Code 使用说明

- 在回答问题和解释代码时，请使用中文（简体）。