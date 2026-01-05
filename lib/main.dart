import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
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

// 定义应用运行所需的数据
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext(){
    current = WordPair.random();
    notifyListeners();   // (ChangeNotifier) 的一个方法）;watch 该对象会收到通知
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 使用 watch 方法跟踪对应用当前状态的更改
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    return Scaffold(
      body: Center( // 列居中
        child: Column(   // 子项放到一列中

          mainAxisAlignment: MainAxisAlignment.center,   // 在一列中：居中显示
          children: [
            // Text('A random AEShello idea:'),
            BigCard(pair: pair),   // 访问该类的 current 变量
            SizedBox(height: 10),
            // 添加一个按钮
            ElevatedButton(
              onPressed: () {
                appState.getNext();
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;



  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);   // 获取应用当前 Theme
    // displayMedium 展示文本大号样式
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,   // 设置成和应用相同 Theme
      child: Padding(
        padding: const EdgeInsets.all(20.0),   // 20 内边距
        child: Text(
            pair.asLowerCase,
            style: style,
            semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}