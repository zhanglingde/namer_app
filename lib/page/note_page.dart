import 'package:flutter/material.dart';
import 'package:namer_app/providers/note_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';

enum CreateNoteType {
  markdown,
  richText,
}

class NotePage extends StatefulWidget {
  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          Row(  // Row 在水平上无限延伸，需要使用 Expanded 包裹占据剩余空间
            children: [
              Expanded(
                child: _buildSearchBar(),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 24),
                onPressed: () => _showCreateNoteDialog(context),
                tooltip: '新建笔记',
              ),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: _buildNotesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索内容、标签、文件',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: () {
              _searchController.clear();
              context.read<NotesProvider>().setSearchQuery('');
            },
          )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        onChanged: (value) {
          context.read<NotesProvider>().setSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildNotesList(){
    return Consumer<NotesProvider>(
      builder: (context, provider, child) {
        final notes = provider.notes;

        if (notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_add, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  provider.searchQuery.isNotEmpty ? '未找到相关笔记' : '暂无笔记',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                if (provider.searchQuery.isEmpty)
                  TextButton.icon(
                    onPressed: () => _showCreateNoteDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('创建第一篇笔记'),
                  ),
              ],
            ),
          );
        }

        return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final isSelected = provider.selectedNote?.id == note.id;

              return _buildNoteCard(context, note, isSelected);
            });
      },
    );
  }


  Widget _buildNoteCard(BuildContext context, Note note, bool isSelected) {
    final dateFormat = DateFormat('MM/dd HH:mm');

    return Material(
      color: isSelected ? Colors.blue[50] : Colors.white,
      child: InkWell(
        onTap: () {
          context.read<NotesProvider>().selectNote(note);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和时间
              Row(
                children: [
                  if (note.isPinned)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.push_pin,
                        size: 14,
                        color: Colors.orange[700],
                      ),
                    ),
                  Expanded(
                    child: Text(
                      note.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.blue[900] : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    icon: Icon(
                      Icons.more_horiz,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              note.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(note.isPinned ? '取消置顶' : '置顶'),
                          ],
                        ),
                        onTap: () {
                          context.read<NotesProvider>().togglePin(note.id);
                        },
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('删除', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        onTap: () {
                          _confirmDelete(context, note);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 内容预览
              Text(
                note.getPreview(maxLength: 80),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // 标签和时间
              Row(
                children: [
                  if (note.tags.isNotEmpty) ...[
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: note.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[700],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  Text(
                    dateFormat.format(note.updatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Note note) {
    Future.delayed(Duration.zero, () {
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
                context.read<NotesProvider>().deleteNote(note.id);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        ),
      );
    });
  }

  void _showCreateNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择笔记类型'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields, color: Colors.blue),
              title: const Text('Markdown 笔记'),
              subtitle: const Text('支持 Markdown 语法的文本编辑'),
              onTap: () {
                Navigator.pop(context);
                context.read<NotesProvider>().createNote(noteType: NoteType.markdown);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.format_paint, color: Colors.orange),
              title: const Text('富文本笔记'),
              subtitle: const Text('所见即所得的富文本编辑器'),
              onTap: () {
                Navigator.pop(context);
                context.read<NotesProvider>().createNote(noteType: NoteType.richText);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}
