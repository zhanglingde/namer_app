import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';

class NoteDetailPage extends StatefulWidget {
  const NoteDetailPage({Key? key}) : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  Note? _currentNote;
  bool _isModified = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _loadNote(Note note) {
    if (_currentNote?.id != note.id) {
      _currentNote = note;
      _titleController.text = note.title;
      _contentController.text = note.content;
      _isModified = false;
    }
  }

  Future<void> _saveNote() async {
    if (_currentNote == null || !_isModified) return;

    final provider = context.read<NotesProvider>();
    final updatedNote = _currentNote!.copyWith(
      title: _titleController.text.trim().isEmpty ? '无标题' : _titleController.text.trim(),
      content: _contentController.text,
    );

    await provider.updateNote(updatedNote);
    setState(() {
      _isModified = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('保存成功'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _onTextChanged() {
    if (!_isModified) {
      setState(() {
        _isModified = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, provider, child) {
        final note = provider.selectedNote;

        if (note == null) {
          return _buildEmptyState();
        }

        _loadNote(note);

        return _buildDetailView(note, provider);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '选择一篇笔记开始编辑',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView(Note note, NotesProvider provider) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 顶部工具栏
          _buildToolbar(note, provider),
          const Divider(height: 1),

          // 编辑区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题输入
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: '笔记标题',
                      border: InputBorder.none,
                    ),
                    onChanged: (_) => _onTextChanged(),
                  ),
                  const SizedBox(height: 8),

                  // 时间信息
                  _buildTimeInfo(note),
                  const SizedBox(height: 16),

                  // 标签
                  _buildTags(note, provider),
                  const SizedBox(height: 24),

                  // 内容输入
                  TextField(
                    controller: _contentController,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                    decoration: const InputDecoration(
                      hintText: '开始写点什么...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    onChanged: (_) => _onTextChanged(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(Note note, NotesProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 保存按钮
          ElevatedButton.icon(
            onPressed: _isModified ? _saveNote : null,
            icon: const Icon(Icons.save, size: 18),
            label: Text(_isModified ? '保存' : '已保存'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isModified ? Colors.blue : Colors.grey[300],
              foregroundColor: _isModified ? Colors.white : Colors.grey[600],
            ),
          ),
          const Spacer(),

          // 置顶按钮
          IconButton(
            icon: Icon(
              note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: note.isPinned ? Colors.orange[700] : Colors.grey[600],
            ),
            onPressed: () {
              provider.togglePin(note.id);
            },
            tooltip: note.isPinned ? '取消置顶' : '置顶',
          ),

          // 删除按钮
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.grey[600]),
            onPressed: () => _confirmDelete(note, provider),
            tooltip: '删除',
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(Note note) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          '创建于 ${_formatDateTime(note.createdAt)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(width: 16),
        Text(
          '更新于 ${_formatDateTime(note.updatedAt)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTags(Note note, NotesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.label_outline, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              '标签',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...note.tags.map((tag) => _buildTagChip(tag, note, provider)),
            _buildAddTagButton(note, provider),
          ],
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag, Note note, NotesProvider provider) {
    return Chip(
      label: Text('#$tag'),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () {
        provider.removeTagFromNote(note.id, tag);
      },
      backgroundColor: Colors.blue[50],
      labelStyle: TextStyle(color: Colors.blue[700], fontSize: 13),
    );
  }

  Widget _buildAddTagButton(Note note, NotesProvider provider) {
    return ActionChip(
      label: const Text('+ 添加标签'),
      onPressed: () => _showAddTagDialog(note, provider),
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(color: Colors.grey[700], fontSize: 13),
    );
  }

  void _showAddTagDialog(Note note, NotesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加标签'),
        content: TextField(
          controller: _tagController,
          decoration: const InputDecoration(
            hintText: '输入标签名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              provider.addTagToNote(note.id, value.trim());
              _tagController.clear();
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _tagController.clear();
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_tagController.text.trim().isNotEmpty) {
                provider.addTagToNote(note.id, _tagController.text.trim());
                _tagController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Note note, NotesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除笔记"${note.title}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteNote(note.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
