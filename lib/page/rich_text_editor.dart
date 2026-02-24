import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class RichTextEditor extends StatefulWidget {
  final String initialContent;
  final Function(String) onContentChanged;

  const RichTextEditor({
    Key? key,
    required this.initialContent,
    required this.onContentChanged,
  }) : super(key: key);

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    try {
      if (widget.initialContent.isEmpty || widget.initialContent == '[{"insert":"\\n"}]') {
        _controller = QuillController.basic();
      } else {
        final doc = Document.fromJson(jsonDecode(widget.initialContent));
        _controller = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      }

      _controller.addListener(() {
        final json = jsonEncode(_controller.document.toDelta().toJson());
        widget.onContentChanged(json);
      });
    } catch (e) {
      print('Error initializing controller: $e');
      _controller = QuillController.basic();
    }
  }

  @override
  void didUpdateWidget(RichTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialContent != widget.initialContent) {
      _controller.removeListener(() {});
      _controller.dispose();
      _initializeController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 工具栏
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildToolbar(),
        ),
        const SizedBox(height: 16),
        // 编辑器
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: QuillEditor.basic(
              controller: _controller,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          QuillToolbarHistoryButton(
            controller: _controller,
            isUndo: true,
          ),
          QuillToolbarHistoryButton(
            controller: _controller,
            isUndo: false,
          ),
          const SizedBox(width: 8),
          QuillToolbarToggleStyleButton(
            controller: _controller,
            attribute: Attribute.bold,
          ),
          QuillToolbarToggleStyleButton(
            controller: _controller,
            attribute: Attribute.italic,
          ),
          QuillToolbarToggleStyleButton(
            controller: _controller,
            attribute: Attribute.underline,
          ),
          QuillToolbarToggleStyleButton(
            controller: _controller,
            attribute: Attribute.strikeThrough,
          ),
          const SizedBox(width: 8),
          QuillToolbarSelectHeaderStyleDropdownButton(
            controller: _controller,
          ),
          const SizedBox(width: 8),
          QuillToolbarToggleStyleButton(
            controller: _controller,
            attribute: Attribute.ol,
          ),
          QuillToolbarToggleStyleButton(
            controller: _controller,
            attribute: Attribute.ul,
          ),
          QuillToolbarToggleStyleButton(
            controller: _controller,
            attribute: Attribute.blockQuote,
          ),
          const SizedBox(width: 8),
          QuillToolbarIndentButton(
            controller: _controller,
            isIncrease: true,
          ),
          QuillToolbarIndentButton(
            controller: _controller,
            isIncrease: false,
          ),
          const SizedBox(width: 8),
          QuillToolbarLinkStyleButton(controller: _controller),
          QuillToolbarClearFormatButton(controller: _controller),
        ],
      ),
    );
  }
}
