
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/config/my_app_state.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sp_util/sp_util.dart';

import '../config/shared_preference_provider.dart';
import '../window_config/window_buttons.dart';
import '../window_config/windows_adapter.dart';

class SettingsPage extends StatefulWidget{
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>{

  late String _storagePath;

  bool _isDarkMode = Prefs().isDarkMode();

  @override
  void initState() {
    super.initState();
    _loadStoragePath();
  }

  Future<void> _loadStoragePath() async {
    _storagePath = SpUtil.getString(SpKey.storagePath) ?? '';
    if (_storagePath.isEmpty) {
      _storagePath = (await getDownloadsDirectory())!.path;
      SpUtil.putString(SpKey.storagePath, _storagePath);
    }
    setState(() {});
  }

  Future<void> _pickStoragePath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        _storagePath = selectedDirectory;
        SpUtil.putString(SpKey.storagePath, _storagePath);
      });
    }
  }

  Future<void> _openCurrentDirectory() async {
    if (Directory(_storagePath).existsSync()) {
      if (Platform.isWindows) {
        await Process.run('explorer', [_storagePath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [_storagePath]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    var prefs = context.watch<Prefs>();

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: DragToMoveArea(
            child: AppBar(
              actions: const [WindowButtons()],
            ),
          )),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text("更改存储目录"),
            subtitle: Text(_storagePath),
            onTap: _pickStoragePath,
          ),
          ListTile(
            title: const Text("预览存储目录"),
            onTap: _openCurrentDirectory,    // onTap 处理回调事件
          ),
          ListTile(
            title: const Text("切换主题"),
            subtitle: Text(_isDarkMode ? "深色模式" : "浅色模式"),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                  prefs.saveThemeModeToPrefs(_isDarkMode ? "dark" : "light");
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}