import 'package:flutter/material.dart';
import 'package:namer_app/page/note_detail_page.dart';
import 'package:namer_app/page/note_page.dart';

class NotesLayoutPage extends StatelessWidget {
  const NotesLayoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 笔记列表 - 占 1 份
        Expanded(
          flex: 1,
          child: NotePage(),
        ),
        // 笔记详情 - 占 2 份
        Expanded(
          flex: 2,
          child: NoteDetailPage(),
        ),
      ],
    );
  }
}
