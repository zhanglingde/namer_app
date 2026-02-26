import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../dao/todo_dao.dart';
import '../models/todo.dart';

enum TodoFilter {
  all,      // 全部
  today,    // 今天
  threeDays, // 三日
  week,     // 周
  month,    // 月
}

class TodoProvider extends ChangeNotifier {
  final TodoDao _todoDao = TodoDao();
  List<Todo> _todos = [];
  List<TodoGroup> _groups = [];
  List<String> _tags = [];
  Todo? _selectedTodo;
  TodoFilter _currentFilter = TodoFilter.all;
  String? _selectedGroupId;
  String? _selectedTag;

  List<Todo> get todos => _filteredTodos();
  List<TodoGroup> get groups => _groups;
  List<String> get tags => _tags;
  Todo? get selectedTodo => _selectedTodo;
  TodoFilter get currentFilter => _currentFilter;
  String? get selectedGroupId => _selectedGroupId;

  // 初始化加载数据
  Future<void> loadTodos() async {
    _todos = await _todoDao.readAllTodos();
    _groups = await _todoDao.readAllGroups();
    _tags = await _todoDao.getAllTags();
    notifyListeners();
  }

  // 过滤待办
  List<Todo> _filteredTodos() {
    var filtered = _todos;

    // 按分组过滤
    if (_selectedGroupId != null) {
      filtered = filtered.where((todo) => todo.groupId == _selectedGroupId).toList();
    }

    // 按标签过滤
    if (_selectedTag != null) {
      filtered = filtered.where((todo) => todo.tags.contains(_selectedTag)).toList();
    }

    // 按时间过滤
    final now = DateTime.now();
    switch (_currentFilter) {
      case TodoFilter.today:
        filtered = filtered.where((todo) {
          if (todo.dueDate == null) return false;
          return todo.dueDate!.year == now.year &&
              todo.dueDate!.month == now.month &&
              todo.dueDate!.day == now.day;
        }).toList();
        break;
      case TodoFilter.threeDays:
        final threeDaysLater = now.add(const Duration(days: 3));
        filtered = filtered.where((todo) {
          if (todo.dueDate == null) return false;
          return todo.dueDate!.isBefore(threeDaysLater);
        }).toList();
        break;
      case TodoFilter.week:
        final weekLater = now.add(const Duration(days: 7));
        filtered = filtered.where((todo) {
          if (todo.dueDate == null) return false;
          return todo.dueDate!.isBefore(weekLater);
        }).toList();
        break;
      case TodoFilter.month:
        final monthLater = now.add(const Duration(days: 30));
        filtered = filtered.where((todo) {
          if (todo.dueDate == null) return false;
          return todo.dueDate!.isBefore(monthLater);
        }).toList();
        break;
      case TodoFilter.all:
      default:
        break;
    }

    return filtered;
  }

  // 创建待办
  Future<Todo> createTodo({
    required String title,
    String? description,
    DateTime? dueDate,
    TodoPriority priority = TodoPriority.medium,
    String? groupId,
  }) async {
    final todo = Todo(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      priority: priority,
      groupId: groupId ?? _selectedGroupId,
    );

    await _todoDao.createTodo(todo);
    _todos.insert(0, todo);
    notifyListeners();
    return todo;
  }

  // 更新待办
  Future<void> updateTodo(Todo todo) async {
    await _todoDao.updateTodo(todo);

    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
      if (_selectedTodo?.id == todo.id) {
        _selectedTodo = todo;
      }
      notifyListeners();
    }
  }

  // 切换完成状态
  Future<void> toggleComplete(String id) async {
    final todo = _todos.firstWhere((t) => t.id == id);
    final updated = todo.copyWith(isCompleted: !todo.isCompleted);
    await updateTodo(updated);
  }

  // 删除待办
  Future<void> deleteTodo(String id) async {
    await _todoDao.deleteTodo(id);
    _todos.removeWhere((todo) => todo.id == id);

    if (_selectedTodo?.id == id) {
      _selectedTodo = null;
    }

    notifyListeners();
  }

  // 选择待办
  void selectTodo(Todo? todo) {
    _selectedTodo = todo;
    notifyListeners();
  }

  // 设置过滤器
  void setFilter(TodoFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // 选择分组
  void selectGroup(String? groupId) {
    _selectedGroupId = groupId;
    notifyListeners();
  }

  // 选择标签
  void selectTag(String? tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  // 创建分组
  Future<TodoGroup> createGroup(String name, int color) async {
    final group = TodoGroup(
      id: const Uuid().v4(),
      name: name,
      color: color,
    );

    await _todoDao.createGroup(group);
    _groups.add(group);
    notifyListeners();
    return group;
  }

  // 删除分组
  Future<void> deleteGroup(String id) async {
    await _todoDao.deleteGroup(id);
    _groups.removeWhere((group) => group.id == id);
    notifyListeners();
  }
}
