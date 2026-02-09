import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';

import '../dao/history_dao.dart';
import '../dao/word_collect_dao.dart';
import '../models/history.dart';
import '../models/word.dart';

// 定义应用运行所需的数据
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];
  GlobalKey<AnimatedListState>? historyListKey; // 可为空的全局键变量
  bool isHistoryLoading = true; // 历史记录加载状态
  final HistoryDao _historyDao = HistoryDao();
  final WordCollectDao _wordCollectDao = WordCollectDao();

  Future<void> getNext() async {
    history.insert(0, current);
    final his = History(
      id: -1,
      first: current.first,
      second: current.second,
      createTime: DateTime.now(),
    );
    await _historyDao.addHistory(his);
    // AnimatedList 带动画的列表；通过提前绑定的全局key，获取AnimatedList的状态管理对象
    // historyListKey绑定在页面的AnimatedList组件上，拿到状态后才能调用列表的动画增删方法
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    // 调用AnimatedList的动画插入方法：在列表【第0个位置(列表顶部)】插入一条数据，并且自带系统默认的插入动画
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners(); // (ChangeNotifier) 的一个方法）;watch 该对象会收到通知
  }

  // 存储在内存中
  // var favorites = <WordPair>[];
  var favorites = <WordPair>[];

  // 从数据库加载收藏的单词
  Future<void> loadFavorites() async {
    try {
      final words = await _wordCollectDao.selectCollects();
      favorites = words.map((word) => word.convertWordPair()).toList();
      notifyListeners();
    } catch (e) {
      // 处理加载失败的情况
      print('Failed to load favorites: $e');
      favorites = [];
    }
  }

  // 加载历史记录
  Future<void> loadHistorys() async {
    try {
      final historys = await _historyDao.selectHistory();
      history = historys.map((his) => his.convertWordPair()).toList();
    } catch (e) {
      // 处理加载失败的情况
      print('Failed to load historys: $e');
      history = [];
    } finally {
      isHistoryLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite([WordPair? pair]) async {
    pair = pair ?? current; // pair 不为 null 取 pair,pair 为 null,取 current
    try {
      if (favorites.contains(pair)) {
        // 取消收藏
        favorites.remove(pair);
        await _wordCollectDao.deleteWord(pair.first);
      } else {
        // 添加收藏
        favorites.add(pair);
        final word = Word(
          id: -1,
          first: pair.first,
          second: pair.second,
          addTime: DateTime.now(),
        );
        await _wordCollectDao.insertCollect(word);
      }
      notifyListeners();
    } catch (e) {
      // 处理操作失败的情况
      print('Failed to toggle favorite: $e');
      // 如果操作失败，恢复状态
      if (favorites.contains(pair)) {
        favorites.remove(pair);
      } else {
        favorites.add(pair);
      }
    }
  }

  Future<void> removeFavorite(WordPair pair) async {
    try {
      if (favorites.contains(pair)) {
        favorites.remove(pair);
        await _wordCollectDao.deleteWord(pair.first);
        notifyListeners();
      }
    } catch (e) {
      // 处理操作失败的情况
      print('Failed to remove favorite: $e');
      // 如果操作失败，恢复状态
      if (!favorites.contains(pair)) {
        favorites.add(pair);
      }
    }
  }
}
