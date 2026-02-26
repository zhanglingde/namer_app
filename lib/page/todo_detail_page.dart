import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class TodoDetailPage extends StatefulWidget {
  const TodoDetailPage({Key? key}) : super(key: key);

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Todo? _currentTodo;
  DateTime? _selectedDate;
  TodoPriority _selectedPriority = TodoPriority.medium;
  String? _selectedGroupId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadTodo(Todo todo) {
    if (_currentTodo?.id != todo.id) {
      _currentTodo = todo;
      _titleController.text = todo.title;
      _descriptionController.text = todo.description ?? '';
      _selectedDate = todo.dueDate;
      _selectedPriority = todo.priority;
      _selectedGroupId = todo.groupId;
    }
  }

  Future<void> _saveTodo() async {
    if (_currentTodo == null) return;

    final provider = context.read<TodoProvider>();
    final updatedTodo = _currentTodo!.copyWith(
      title: _titleController.text.trim().isEmpty ? '无标题' : _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      dueDate: _selectedDate,
      priority: _selectedPriority,
      groupId: _selectedGroupId,
    );

    await provider.updateTodo(updatedTodo);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('保存成功'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        final todo = provider.selectedTodo;

        if (todo == null) {
          return const SizedBox.shrink();
        }

        _loadTodo(todo);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(provider),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: 24),
                      _buildDescriptionField(),
                      const SizedBox(height: 24),
                      _buildDatePicker(),
                      const SizedBox(height: 24),
                      _buildPrioritySelector(),
                      const SizedBox(height: 24),
                      _buildGroupSelector(provider),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(TodoProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            '待办详情',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _saveTodo,
            icon: const Icon(Icons.save, size: 18),
            label: const Text('保存'),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => provider.selectTodo(null),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '标题',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: '输入待办标题',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '描述',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: '输入待办描述（可选）',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '截止日期',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                      : '选择日期',
                  style: TextStyle(
                    color: _selectedDate != null ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '优先级',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<TodoPriority>(
          segments: const [
            ButtonSegment(
              value: TodoPriority.low,
              label: Text('低'),
              icon: Icon(Icons.flag, color: Colors.green),
            ),
            ButtonSegment(
              value: TodoPriority.medium,
              label: Text('中'),
              icon: Icon(Icons.flag, color: Colors.orange),
            ),
            ButtonSegment(
              value: TodoPriority.high,
              label: Text('高'),
              icon: Icon(Icons.flag, color: Colors.red),
            ),
          ],
          selected: {_selectedPriority},
          onSelectionChanged: (Set<TodoPriority> newSelection) {
            setState(() {
              _selectedPriority = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildGroupSelector(TodoProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '分组',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          value: _selectedGroupId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('无分组'),
            ),
            ...provider.groups.map((group) {
              return DropdownMenuItem(
                value: group.id,
                child: Row(
                  children: [
                    Icon(Icons.folder, size: 16, color: Color(group.color)),
                    const SizedBox(width: 8),
                    Text(group.name),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedGroupId = value;
            });
          },
        ),
      ],
    );
  }
}
