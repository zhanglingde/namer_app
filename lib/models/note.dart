import 'dart:convert';

enum NoteType {
  markdown,
  richText,
}

class Note {
  final String id;
  final String title;
  final String content; // Markdown text or Quill Delta JSON
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final bool isPinned;
  final bool isArchived;
  final NoteType noteType; // 笔记类型

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.isPinned = false,
    this.isArchived = false,
    this.noteType = NoteType.markdown, // 默认为 Markdown
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
      noteType: NoteType.values[map['noteType'] as int? ?? 0], // as int? 预期可能为整数，但也可能为 null; ?? 0 为 null 时给默认值 0
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
      'noteType': noteType.index,
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
    NoteType? noteType,
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
      noteType: noteType ?? this.noteType,
    );
  }

  // 获取纯文本内容（用于搜索和预览）
  String getPlainText() {
    try {
      if (noteType == NoteType.markdown) {
        // Markdown 笔记直接返回内容
        return content;
      } else {
        // 富文本笔记需要从 Quill Delta JSON 中提取文本
        final List<dynamic> delta = jsonDecode(content);
        final StringBuffer buffer = StringBuffer();
        for (var op in delta) {
          if (op is Map && op.containsKey('insert')) {
            buffer.write(op['insert'].toString());
          }
        }
        return buffer.toString();
      }
    } catch (e) {
      return content;
    }
  }

  // 获取预览文本（限制长度）
  String getPreview({int maxLength = 100}) {
    final text = getPlainText();
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
