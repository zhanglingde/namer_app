import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import 'todo_page.dart';

class TodoLayoutPage extends StatelessWidget {
  const TodoLayoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 左侧导航栏
          _buildSidebar(context),
          // 右侧主内容区
          Expanded(
            child: TodoPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          right: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              const SizedBox(height: 16),
              // 全部分组
              _buildSidebarItem(
                context,
                icon: Icons.inbox,
                title: '任务箱',
                isSelected: provider.selectedGroupId == null,
                onTap: () => provider.selectGroup(null),
              ),
              const Divider(),
              // 分组列表
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '分组',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () => _showCreateGroupDialog(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              ...provider.groups.map((group) => _buildSidebarItem(
                    context,
                    icon: Icons.folder,
                    title: group.name,
                    color: Color(group.color),
                    isSelected: provider.selectedGroupId == group.id,
                    onTap: () => provider.selectGroup(group.id),
                  )),
              const Divider(),
              // 标签管理
              _buildSidebarItem(
                context,
                icon: Icons.label,
                title: '标签管理',
                onTap: () => _showTagsDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? color,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? Colors.blue[50] : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color ?? (isSelected ? Colors.blue[700] : Colors.grey[600]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.blue[900] : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    int selectedColor = Colors.blue.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建分组'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '分组名称',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                context.read<TodoProvider>().createGroup(
                      nameController.text.trim(),
                      selectedColor,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showTagsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('标签管理'),
        content: Consumer<TodoProvider>(
          builder: (context, provider, child) {
            if (provider.tags.isEmpty) {
              return const Text('暂无标签');
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.tags.map((tag) {
                return Chip(
                  label: Text('#$tag'),
                  backgroundColor: Colors.blue[50],
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
