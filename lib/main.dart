import 'package:flutter/material.dart';
import 'package:namer_app/page/home_page.dart';
import 'package:namer_app/providers/note_provider.dart';
import 'package:provider/provider.dart';

import 'config/my_app_state.dart';
import 'config/shared_preference_provider.dart';
import 'dao/database.dart';

void main() async{
  // 1. 初始化组件绑定
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 初始化偏好存储组件
  await Prefs().initPrefs();

  // 初始化 sqlite 数据库
  await DBHelper().initDB();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifier 管理应用状态
    return MultiProvider (
      providers: [
        ChangeNotifierProvider(create: (_) => Prefs(),),
        ChangeNotifierProvider(create: (context) => MyAppState(),),
        // 创建后立即触发加载数据库
        ChangeNotifierProvider(create: (context) => NotesProvider()..loadNotes(),),
      ],
      child: Consumer<Prefs>(  // Consumer 从上面的 MultiProvider 注册的状态列表中，获取 Prefs 并监听
          builder: (context, prefsNotifier, child) {
            return MaterialApp(
              title: 'Namer App',
              themeMode: prefsNotifier.themeMode,
              // TODO 扩展使用 FlexThemeData
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                    seedColor: prefsNotifier.themeColor), //  应用主题
              ),
              darkTheme: ThemeData(
                primarySwatch: Colors.blue,
                brightness: Brightness.dark,
              ),
              home: MyHomePage(),
            );
          }
      ),

    );
  }
}

