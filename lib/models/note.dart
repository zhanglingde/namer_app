import 'dart:convert';

class Note {
  final String id;
  final String title;
  final String content; // Quill Delta JSON
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final bool isPinned;
  final bool isArchived;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.isPinned = false,
    this.isArchived = false,
  });

  // 从数据库加载
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      tags: (map['tags'] as String).split(',').where((t) => t.isNotEmpty).toList(),
      isPinned: map['isPinned'] == 1,
      isArchived: map['isArchived'] == 1,
    );
  }

  // 转换为数据库格式
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags.join(','),
      'isPinned': isPinned ? 1 : 0,
      'isArchived': isArchived ? 1 : 0,
    };
  }

  // 复制并修改
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    bool? isPinned,
    bool? isArchived,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  // 获取纯文本内容（用于搜索和预览）
  String getPlainText() {
    try {
      // final doc = Document.fromJson(jsonDecode(content));
      // return doc.toPlainText();
      return '';
    } catch (e) {
      return '';
    }
  }

  // 获取预览文本（限制长度）
  String getPreview({int maxLength = 100}) {
    final text = getPlainText();
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
