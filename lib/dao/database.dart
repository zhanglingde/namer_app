import 'dart:async';
import 'dart:io';

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
const CREATE_NOTE_SQL = '''
CREATE TABLE notes (
  id TEXT PRIMARY KEY ,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL,
  tags TEXT,
  isPinned INTEGER NOT NULL DEFAULT 0,
  isArchived INTEGER NOT NULL DEFAULT 0,
  noteType INTEGER NOT NULL DEFAULT 0
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
    if (Platform.isWindows || Platform.isLinux) {
      // 桌面端：初始化 FFI; 安卓和 ios 原生支持 sqlite,不需要 ffi
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // 获取数据库存储路径，全平台兼容，无需path_provider
    String dbDir = await getDatabasesPath();
    String dbPath = join(dbDir, dbName);
    print('dbPath' + dbPath);
    return await databaseFactory.openDatabase(dbPath,
        options: OpenDatabaseOptions(
          version: 3,  // 更新数据库时手动修改版本
          onCreate: (db, version) async {
            // 数据库首次创建时，执行建表
            await db.execute(CREATE_LIKE_SQL);
            await db.execute(CREATE_HISTORY_SQL);
            await db.execute(CREATE_NOTE_SQL);
            print("✅ 收藏单词表创建成功！");
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            // 后续版本更新、表结构修改在这里写（比如新增字段）
            if (oldVersion < 2) {
              await db.execute(CREATE_NOTE_SQL);
              print("✅ 数据库升级成功，新增笔记表！");
            }
            if (oldVersion < 3) {
              await db.execute('ALTER TABLE notes ADD COLUMN noteType INTEGER NOT NULL DEFAULT 0');
              print("✅ 数据库升级成功，新增笔记类型字段！");
            }
          },
        ));
  }

  // 更新数据库
  Future<void> onUpgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    switch(oldVersion) {
      case 2:
        await db.execute(CREATE_NOTE_SQL);
    }
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
