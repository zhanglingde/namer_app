import 'package:flutter/material.dart';
import 'package:namer_app/page/home_page.dart';
import 'package:provider/provider.dart';

import 'config/my_app_state.dart';
import 'dao/database.dart';

void main() async{
  // 1. 初始化组件绑定
  WidgetsFlutterBinding.ensureInitialized();

  await DBHelper().initDB();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifier 管理应用状态
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),   //  应用主题
        ),
        home: MyHomePage(),
      ),
    );
  }
}

