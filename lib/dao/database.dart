import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const CREATE_BOOK_SQL = '''
CREATE TABLE tb_books (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  cover_path TEXT,
  file_path TEXT,
  last_read_position TEXT,
  reading_percentage REAL,
  author TEXT,
  is_deleted INTEGER,
  description TEXT,
  create_time TEXT,
  update_time TEXT
)
''';


const String dbName = "namer_app.db"; // 数据库文件名
const CREATE_LIKE_SQL = '''
CREATE TABLE tb_word_collect (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  first TEXT NOT NULL UNIQUE,
  second TEXT NOT NULL UNIQUE,
  add_time INTEGER DEFAULT (strftime('%s', 'now'))
)
''';
const CREATE_HISTORY_SQL = '''
CREATE TABLE tb_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  first TEXT NOT NULL UNIQUE,
  second TEXT NOT NULL UNIQUE,
  create_time INTEGER DEFAULT (strftime('%s', 'now'))
)
''';

class DBHelper {

  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();

  // 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  // 初始化数据库 + 执行建表语句
  Future<Database> initDB() async {

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // 获取数据库存储路径，全平台兼容，无需path_provider
    String dbDir = await getDatabasesPath();
    String dbPath = join(dbDir, dbName);
    return await databaseFactory.openDatabase(dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // 数据库首次创建时，执行建表
          await db.execute(CREATE_LIKE_SQL);
          await db.execute(CREATE_HISTORY_SQL);
          print("✅ 收藏单词表创建成功！");
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          // 后续版本更新、表结构修改在这里写（比如新增字段）
          // await db.execute("ALTER TABLE $tableWord ADD COLUMN remark TEXT DEFAULT ''");
          // print("✅ 数据库升级成功，新增历史表！");
        },
      )
    );
  }

  // 关闭数据库
  Future<void> closeDb() async {
    final db = await database;
    if (db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}



