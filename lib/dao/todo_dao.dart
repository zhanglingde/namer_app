import '../models/todo.dart';
import 'database.dart';

class TodoDao {
  // 创建待办
  Future<Todo> createTodo(Todo todo) async {
    final db = await DBHelper().database;
    await db.insert('todos', todo.toMap());
    return todo;
  }

  // 读取单个待办
  Future<Todo?> readTodo(String id) async {
    final db = await DBHelper().database;
    final maps = await db.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Todo.fromMap(maps.first);
    }
    return null;
  }

  // 读取所有待办
  Future<List<Todo>> readAllTodos() async {
    final db = await DBHelper().database;
    final result = await db.query(
      'todos',
      orderBy: 'createdAt DESC',
    );

    return result.map((map) => Todo.fromMap(map)).toList();
  }

  // 更新待办
  Future<int> updateTodo(Todo todo) async {
    final db = await DBHelper().database;
    return db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // 删除待办
  Future<int> deleteTodo(String id) async {
    final db = await DBHelper().database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 根据分组获取待办
  Future<List<Todo>> getTodosByGroup(String? groupId) async {
    final db = await DBHelper().database;
    final result = await db.query(
      'todos',
      where: groupId != null ? 'groupId = ?' : 'groupId IS NULL',
      whereArgs: groupId != null ? [groupId] : null,
      orderBy: 'createdAt DESC',
    );

    return result.map((map) => Todo.fromMap(map)).toList();
  }

  // 获取所有标签
  Future<List<String>> getAllTags() async {
    final todos = await readAllTodos();
    final tagsSet = <String>{};

    for (var todo in todos) {
      tagsSet.addAll(todo.tags);
    }

    return tagsSet.toList()..sort();
  }

  // 创建分组
  Future<TodoGroup> createGroup(TodoGroup group) async {
    final db = await DBHelper().database;
    await db.insert('todo_groups', group.toMap());
    return group;
  }

  // 读取所有分组
  Future<List<TodoGroup>> readAllGroups() async {
    final db = await DBHelper().database;
    final result = await db.query('todo_groups');
    return result.map((map) => TodoGroup.fromMap(map)).toList();
  }

  // 删除分组
  Future<int> deleteGroup(String id) async {
    final db = await DBHelper().database;
    return await db.delete(
      'todo_groups',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
