import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../notes/model/note_model.dart';
import '../../core/storage/hive_service.dart';

class NoteEditorPage extends StatefulWidget {
  final Note note;

  const NoteEditorPage({
    super.key,
    required this.note,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleController;
  late QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);

    Document doc;
    try {
      if (widget.note.content.isNotEmpty) {
        final jsonDelta = jsonDecode(widget.note.content);
        doc = Document.fromJson(jsonDelta);
      } else {
        doc = Document();
      }
    } catch (e) {
      doc = Document()..insert(0, widget.note.content);
    }
    _quillController = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  void _saveNote() {
    widget.note.title = _titleController.text.trim();
    final deltaJson = jsonEncode(_quillController.document.toDelta().toJson());
    widget.note.content = deltaJson;
    widget.note.lastEdited = DateTime.now();
    HiveService.notesBox().put(widget.note.id, widget.note);
  }

  @override
  void dispose() {
    _saveNote();
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _saveNote();
            Navigator.pop(context);
          },
        ),
        title: const Text('Edit Note'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          QuillSimpleToolbar(
            controller: _quillController,
            config: const QuillSimpleToolbarConfig(),
          ),
          const Divider(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: QuillEditor(
                controller: _quillController,
                focusNode: _editorFocusNode,
                scrollController: _scrollController,
                config: const QuillEditorConfig(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

