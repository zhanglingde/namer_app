enum TodoPriority {
  low,
  medium,
  high,
}

class Todo {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;
  final TodoPriority priority;
  final List<String> tags;
  final String? groupId; // 所属分组

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.priority = TodoPriority.medium,
    this.tags = const [],
    this.groupId,
  });

  // 从数据库加载
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      priority: TodoPriority.values[map['priority'] as int? ?? 1],
      tags: (map['tags'] as String? ?? '').split(',').where((t) => t.isNotEmpty).toList(),
      groupId: map['groupId'] as String?,
    );
  }

  // 转换为数据库格式
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.index,
      'tags': tags.join(','),
      'groupId': groupId,
    };
  }

  // 复制并修改
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    TodoPriority? priority,
    List<String>? tags,
    String? groupId,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      groupId: groupId ?? this.groupId,
    );
  }
}

// 待办分组
class TodoGroup {
  final String id;
  final String name;
  final int color; // 颜色值

  TodoGroup({
    required this.id,
    required this.name,
    required this.color,
  });

  factory TodoGroup.fromMap(Map<String, dynamic> map) {
    return TodoGroup(
      id: map['id'] as String,
      name: map['name'] as String,
      color: map['color'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }
}
