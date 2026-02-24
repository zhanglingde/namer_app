import '../models/note.dart';
import 'database.dart';


// ===================== 表字段说明 =====================
// id          : 主键，自增ID（唯一标识，不用手动传）
// word        : 英文单词，非空+唯一（防止同一个单词重复收藏）
// translation : 单词翻译，非空（必填项）
// pos         : 单词词性，如：n.名词 v.动词 adj.形容词，默认为空
// is_collect  : 是否收藏 1=收藏 0=取消收藏，默认1
// add_time    : 添加时间，时间戳（秒），默认当前时间，自动生成无需手动传

// ===================== 核心CRUD增删改查方法 =====================

class NoteDao {
  // 创建笔记
  Future<Note> createNote(Note note) async {
    final db = await DBHelper().database;
    await db.insert('notes', note.toMap());
    return note;
  }

  // 读取单个笔记
  Future<Note?> readNote(String id) async {
    final db = await DBHelper().database;
    final maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  // 读取所有笔记
  Future<List<Note>> readAllNotes() async {
    final db = await DBHelper().database;
    final result = await db.query(
      'notes',
      orderBy: 'isPinned DESC, updatedAt DESC',
    );

    return result.map((map) => Note.fromMap(map)).toList();
  }

  // 更新笔记
  Future<int> updateNote(Note note) async {
    final db = await DBHelper().database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // 删除笔记
  Future<int> deleteNote(String id) async {
    final db = await DBHelper().database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 搜索笔记
  Future<List<Note>> searchNotes(String query) async {
    final db = await DBHelper().database;
    final result = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'updatedAt DESC',
    );

    return result.map((map) => Note.fromMap(map)).toList();
  }

  // 根据标签筛选
  Future<List<Note>> getNotesByTag(String tag) async {
    final db = await DBHelper().database;
    final result = await db.query(
      'notes',
      where: 'tags LIKE ?',
      whereArgs: ['%$tag%'],
      orderBy: 'updatedAt DESC',
    );

    return result.map((map) => Note.fromMap(map)).toList();
  }

  // 获取所有标签
  Future<List<String>> getAllTags() async {
    final notes = await readAllNotes();
    final tagsSet = <String>{};

    for (var note in notes) {
      tagsSet.addAll(note.tags);
    }

    return tagsSet.toList()..sort();
  }

}
