
import 'package:flutter/material.dart';
import 'package:namer_app/page/note_page.dart';
import 'package:namer_app/page/search_page.dart';
import 'package:namer_app/page/settings_page.dart';
import 'package:provider/provider.dart';

import '../config/my_app_state.dart';
import 'favorite_page.dart';
import 'generator_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// 下划线该类设置为私有类
class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // 应用启动时加载收藏数据
    final appState = Provider.of<MyAppState>(context, listen: false);
    appState.loadFavorites();
    appState.loadHistorys();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();  // Placeholder 交叉图形占位符
        break;
      case 2:
        page = SearchPage();   // 搜索
        break;
      case 3:
        page = Placeholder();   // 下载
        break;  //
      case 4:
        page = SettingsPage();   // 设置
        break;  //
      case 5:
        page = NotePage();   // 笔记
        break;  //
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // The container for the current page, with its background color
    // and subtle switching animation.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          // 手机版：导航在底部
          return Column(
            children: [
              Expanded(child: mainArea),
              SafeArea(
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  items: [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
                    BottomNavigationBarItem(icon: Icon(Icons.search), label: '搜索'),
                    BottomNavigationBarItem(icon: Icon(Icons.download), label: '下载'),
                    BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
                  ],
                  currentIndex: selectedIndex,
                  onTap: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              )
            ],
          );
        } else {
          return Row(
            children: [
              SafeArea(
                // 确保其子项不会被硬件凹口或状态栏遮挡
                child: NavigationRail(
                  // 防止导航按钮被遮挡
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home'),),
                    NavigationRailDestination(icon: Icon(Icons.favorite), label: Text('Favorites'),),
                    NavigationRailDestination(icon: Icon(Icons.search), label: Text('搜索'),),
                    NavigationRailDestination(icon: Icon(Icons.download), label: Text('下载'),),
                    NavigationRailDestination(icon: Icon(Icons.settings), label: Text('设置'),),
                    NavigationRailDestination(icon: Icon(Icons.book), label: Text('笔记'),),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    // 选择索引时触发事件

                    setState(() {
                      selectedIndex = value;
                    });
                    // print('selected: $value');
                  },
                ),
              ),
              Expanded(
                // 子项仅占用所需要的空间 NavigationRail，其他 widget 尽可能占用剩余空间
                child: Container(
                  // 指定了颜色
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}