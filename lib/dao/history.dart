import '../models/History.dart';
import 'database.dart';

// 新增历史记录
Future<int> addHistory(History history) async {
  if(history.id != -1) {
    return history.id;
  }
  final db = await DBHelper().database;
  // conflictAlgorithm: 唯一键冲突时执行更新，完美解决「重复收藏」问题
  return await db.insert('tb_history', history.toMap());
}

// 查询历史记录
Future<List<History>> selectHistory() async{
  final db = await DBHelper().database;
  final List<Map<String,dynamic>> maps =
      await db.query('tb_history',limit: 10);

  return List.generate(maps.length,(i){
    return History(
        id: maps[i]['id'],
        first: maps[i]['first'],
        second: maps[i]['second'],
        createTime: DateTime.parse(maps[i]['create_time'])
    );
  });
}