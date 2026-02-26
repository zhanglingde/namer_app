import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 顶部导航
          _buildTopNavigation(),
          const Divider(height: 1),
          // 输入框区域
          _buildInputArea(),
          const Divider(height: 1),
          // 任务列表
          Expanded(
            child: _buildTaskList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildFilterChip('全部', TodoFilter.all, provider),
              const SizedBox(width: 8),
              _buildFilterChip('日', TodoFilter.today, provider),
              const SizedBox(width: 8),
              _buildFilterChip('三日', TodoFilter.threeDays, provider),
              const SizedBox(width: 8),
              _buildFilterChip('周', TodoFilter.week, provider),
              const SizedBox(width: 8),
              _buildFilterChip('月', TodoFilter.month, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, TodoFilter filter, TodoProvider provider) {
    final isSelected = provider.currentFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          provider.setFilter(filter);
        }
      },
      selectedColor: Colors.blue[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue[900] : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _inputController,
                decoration: const InputDecoration(
                  hintText: '添加新任务...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _addTodo(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _addTodo,
            color: Colors.blue[700],
          ),
        ],
      ),
    );
  }

  void _addTodo() {
    if (_inputController.text.trim().isEmpty) return;

    context.read<TodoProvider>().createTodo(
          title: _inputController.text.trim(),
        );
    _inputController.clear();
  }

  Widget _buildTaskList() {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        final todos = provider.todos;
        final incompleteTodos = todos.where((t) => !t.isCompleted).toList();
        final completedTodos = todos.where((t) => t.isCompleted).toList();

        if (todos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  '暂无任务',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 未完成列表
            ...incompleteTodos.map((todo) => _buildTodoItem(todo)),

            // 已完成折叠层
            if (completedTodos.isNotEmpty) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: Text(
                  '已完成 (${completedTodos.length})',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                initiallyExpanded: false,
                children: completedTodos.map((todo) => _buildTodoItem(todo)).toList(),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTodoItem(Todo todo) {
    return ListTile(
      leading: Checkbox(
        value: todo.isCompleted,
        onChanged: (value) {
          context.read<TodoProvider>().toggleComplete(todo.id);
        },
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          color: todo.isCompleted ? Colors.grey[500] : Colors.black87,
        ),
      ),
      subtitle: todo.dueDate != null
          ? Text(
              _formatDate(todo.dueDate!),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 优先级指示器
          _buildPriorityIndicator(todo.priority),
          const SizedBox(width: 8),
          // 删除按钮
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => _confirmDelete(todo),
            color: Colors.grey[600],
          ),
        ],
      ),
      onTap: () {
        context.read<TodoProvider>().selectTodo(todo);
      },
    );
  }

  Widget _buildPriorityIndicator(TodoPriority priority) {
    Color color;
    switch (priority) {
      case TodoPriority.high:
        color = Colors.red;
        break;
      case TodoPriority.medium:
        color = Colors.orange;
        break;
      case TodoPriority.low:
        color = Colors.green;
        break;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todoDate = DateTime(date.year, date.month, date.day);

    if (todoDate == today) {
      return '今天';
    } else if (todoDate == today.add(const Duration(days: 1))) {
      return '明天';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  void _confirmDelete(Todo todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除任务"${todo.title}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<TodoProvider>().deleteTodo(todo.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
