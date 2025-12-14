import 'package:flutter/material.dart';
import '../notes/model/note_model.dart';

class NoteEditorPage extends StatefulWidget
{
  final Note note;

  const NoteEditorPage({
    super.key,
    required this.note,
  });

  @override
  State<NoteEditorPage> createState()
  {
    return _NoteEditorPageState();
  }
}

class _NoteEditorPageState extends State<NoteEditorPage>
{
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState()
  {
    super.initState();
    _titleController =
        TextEditingController(text: widget.note.title);
    _contentController =
        TextEditingController(text: widget.note.content);
  }

  void _saveNote()
  {
    widget.note.title = _titleController.text;
    widget.note.content = _contentController.text;
    widget.note.lastEdited = DateTime.now();
  }

  @override
  void dispose()
  {
    _saveNote();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
        title: const Text('Edit note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
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
            const Divider(),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Start writing...',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
