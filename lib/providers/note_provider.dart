import 'package:flutter/material.dart';
import 'package:namer_app/dao/note_dao.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';

class NotesProvider extends ChangeNotifier {
  final NoteDao _noteDao = NoteDao();
  List<Note> _notes = [];
  List<String> _tags = [];
  Note? _selectedNote;
  String _searchQuery = '';
  String? _selectedTag;

  List<Note> get notes => _filteredNotes();
  List<String> get tags => _tags;
  Note? get selectedNote => _selectedNote;
  String get searchQuery => _searchQuery;
  String? get selectedTag => _selectedTag;

  // 初始化加载数据
  Future<void> loadNotes() async {
    _notes = await _noteDao.readAllNotes();
    _tags = await _noteDao.getAllTags();
    notifyListeners();
  }

  // 过滤笔记
  List<Note> _filteredNotes() {
    var filtered = _notes;

    // 按标签过滤
    if (_selectedTag != null && _selectedTag!.isNotEmpty) {
      filtered = filtered.where((note) => note.tags.contains(_selectedTag)).toList();
    }

    // 按搜索关键词过滤
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((note) {
        return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            note.getPlainText().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  // 创建新笔记
  Future<Note> createNote({String title = '无标题', NoteType noteType = NoteType.markdown}) async {
    final note = Note(
      id: const Uuid().v4(),
      title: title,
      content: noteType == NoteType.richText ? '[{"insert":"\\n"}]' : '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      noteType: noteType,
    );

    await _noteDao.createNote(note);
    _notes.insert(0, note);
    _selectedNote = note;
    notifyListeners();
    return note;
  }

  // 更新笔记
  Future<void> updateNote(Note note) async {
    final updatedNote = note.copyWith(updatedAt: DateTime.now());
    await _noteDao.updateNote(updatedNote);

    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      if (_selectedNote?.id == note.id) {
        _selectedNote = updatedNote;
      }
      notifyListeners();
    }
  }

  // 删除笔记
  Future<void> deleteNote(String id) async {
    await _noteDao.deleteNote(id);
    _notes.removeWhere((note) => note.id == id);

    if (_selectedNote?.id == id) {
      _selectedNote = _notes.isNotEmpty ? _notes.first : null;
    }

    notifyListeners();
  }

  // 切换置顶状态
  Future<void> togglePin(String id) async {
    final note = _notes.firstWhere((n) => n.id == id);
    final updated = note.copyWith(isPinned: !note.isPinned);
    await updateNote(updated);
  }

  // 选择笔记
  void selectNote(Note? note) {
    _selectedNote = note;
    notifyListeners();
  }

  // 设置搜索关键词
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // 选择标签过滤
  void selectTag(String? tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  // 添加标签到笔记
  Future<void> addTagToNote(String noteId, String tag) async {
    final note = _notes.firstWhere((n) => n.id == noteId);
    if (!note.tags.contains(tag)) {
      final updatedTags = [...note.tags, tag];
      final updated = note.copyWith(tags: updatedTags);
      await updateNote(updated);

      // 更新全局标签列表
      if (!_tags.contains(tag)) {
        _tags.add(tag);
        _tags.sort();
      }
    }
  }

  // 从笔记移除标签
  Future<void> removeTagFromNote(String noteId, String tag) async {
    final note = _notes.firstWhere((n) => n.id == noteId);
    final updatedTags = note.tags.where((t) => t != tag).toList();
    final updated = note.copyWith(tags: updatedTags);
    await updateNote(updated);

    // 更新全局标签列表
    _tags = await _noteDao.getAllTags();
  }

  // 获取统计信息
  int get totalNotes => _notes.length;
  int get totalTags => _tags.length;
  int get totalWords {
    return _notes.fold(0, (sum, note) => sum + note.getPlainText().split(' ').length);
  }
}
