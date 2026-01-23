import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 用户偏好设置存储
class Prefs extends ChangeNotifier {
  /**
   * SharedPreferences 是用于在Flutter应用中存储简单键值对数据的一种持久化存储方式。
   * 它主要用于存储用户的偏好设置、配置信息等轻量级数据
   */
  late SharedPreferences prefs;
  static final Prefs _instance = Prefs._internal();

  factory Prefs() {
    return _instance;
  }

  Prefs._internal() {
    initPrefs();
  }

  // SharedPreferences 存储简单键值对的一种持久化方式（主要用于存储用户的偏好设置、配置信息等轻量级数据）
  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    saveBeginDate();
    notifyListeners();
  }

  void saveBeginDate() {
    String? beginDate = prefs.getString('beginDate');
    if (beginDate == null) {
      prefs.setString('beginDate', DateTime.now().toIso8601String());
    }
  }

  // 默认主题 Colors.deepOrange.value
  Color get themeColor {
    int colorValue = prefs.getInt('themeColor') ?? Colors.deepOrange.value;
    return Color(colorValue);
  }

  Future<void> saveThemeToPrefs(int colorValue) async {
    await prefs.setInt('themeColor', colorValue);
    notifyListeners();
  }

  Locale? get locale {
    String? localeCode = prefs.getString('locale');
    if (localeCode == null || localeCode == '') return null;
    return Locale(localeCode);
  }

  Future<void> saveLocaleToPrefs(String localeCode) async {
    await prefs.setString('locale', localeCode);
    notifyListeners();
  }

  // 获取存储的主题模式
  ThemeMode get themeMode {
    String themeMode = prefs.getString('themeMode') ?? 'system';
    switch (themeMode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> saveThemeModeToPrefs(String themeMode) async {
    await prefs.setString('themeMode', themeMode);
    notifyListeners();
  }


  // 存储路径
  String get storagePath {
    String storagePath = prefs.getString("storagePath") ?? "storage_path";
    return storagePath;
  }

  Future<void> saveStoragePath(String path) async {
    await prefs.setString('storagePath', path);
    notifyListeners();
  }
}

class SpKey{
  SpKey._();


  static String storagePath = "storage_path";
}
