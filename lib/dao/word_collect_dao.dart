import '../models/word.dart';
import 'database.dart';


// ===================== 表字段说明 =====================
// id          : 主键，自增ID（唯一标识，不用手动传）
// word        : 英文单词，非空+唯一（防止同一个单词重复收藏）
// translation : 单词翻译，非空（必填项）
// pos         : 单词词性，如：n.名词 v.动词 adj.形容词，默认为空
// is_collect  : 是否收藏 1=收藏 0=取消收藏，默认1
// add_time    : 添加时间，时间戳（秒），默认当前时间，自动生成无需手动传

class WordCollectDao{
  // ===================== 核心CRUD增删改查方法 =====================
  /// 1. 添加/收藏单词 (有则更新，无则新增)
  Future<int> insertCollect(Word word) async {
    if(word.id != -1) {
      return word.id;
    }
    final db = await DBHelper().database;
    // conflictAlgorithm: 唯一键冲突时执行更新，完美解决「重复收藏」问题
    return await db.insert('tb_word_collect', word.toMap());
  }


  // 查询所有收藏
  Future<List<Word>> selectCollects() async{
    final db = await DBHelper().database;
    final List<Map<String, dynamic>> maps =
    await db.query('tb_word_collect', orderBy: 'add_time DESC');
    return List.generate(maps.length, (i) {
      return Word(
        id: maps[i]['id'],
        first: maps[i]['first'],
        second: maps[i]['second'],
        addTime: DateTime.parse(maps[i]['add_time']),
      );
    });
  }

  /// 2. 根据【单词】查询单条数据 (最常用，精准查询单词是否收藏)
  Future<Map<String, dynamic>?> getWordByWordName(String word) async {
    final db = await DBHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tb_word_collect',
      where: 'first = ?',
      whereArgs: [word], // 防SQL注入，必须用占位符
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  /// 3. 查询所有收藏的单词 (可排序：按添加时间倒序，最新收藏的在前面)
  Future<List<Map<String, dynamic>>> getAllCollectWord() async {
    final db = await DBHelper().database;
    return await db.query(
      'tb_word_collect',
      where: 'is_collect = ?',
      whereArgs: [1],
      orderBy: 'add_time DESC',
    );
  }

  /// 4. 更新单词翻译/词性 (比如修改单词的翻译内容)
  Future<int> updateWord(String word, Map<String, dynamic> updateMap) async {
    final db = await DBHelper().database;
    return await db.update(
      'tb_word_collect',
      updateMap,
      where: 'word = ?',
      whereArgs: [word],
    );
  }

  /// 5. 取消收藏/删除单词 (两种方式可选，推荐方式1：软删除)
  // 方式1：软删除 - 只修改状态，保留数据（推荐，可恢复收藏）
  Future<int> cancelCollectWord(String word) async {
    final db = await DBHelper().database;
    return await db.update(
      'tb_word_collect',
      {'is_collect': 0},
      where: 'word = ?',
      whereArgs: [word],
    );
  }

  // 方式2：硬删除 - 从数据库彻底删除该单词数据（不可恢复）
  Future<int> deleteWord(String first) async {
    final db = await DBHelper().database;
    return await db.delete(
      'tb_word_collect',
      where: 'first = ?',
      whereArgs: [first],
    );
  }

  /// 6. 清空所有收藏单词
  Future<int> deleteAllWord() async {
    final db = await DBHelper().database;
    return await db.delete('tb_word_collect');
  }
}


