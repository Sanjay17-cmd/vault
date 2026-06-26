import 'package:flutter/material.dart';
import '../notes/model/note_model.dart';
import '../notes/model/notebook_model.dart';
import '../notes/widgets/note_card.dart';
import '../../core/storage/hive_service.dart';
import '../editor/note_editor_page.dart';
class LockedNotesPage extends StatefulWidget
{
  const LockedNotesPage({super.key});

  @override
  State<LockedNotesPage> createState()
  {
    return _LockedNotesPageState();
  }
}

class _LockedNotesPageState extends State<LockedNotesPage>
{
  Notebook? _activeNotebook;
  late List<Notebook> _notebooks;
  late List<Note> _notes;

  @override
  void initState()
  {
    super.initState();
    _notebooks = HiveService.notebooksBox().values.toList();
    _notes = HiveService.notesBox().values.toList();

    final lockedNotebooks = _notebooks.where((n) => n.isLocked).toList();
    if (lockedNotebooks.isNotEmpty) {
      _activeNotebook = lockedNotebooks.first;
    }
  }

  List<Note> get _lockedNotes
  {
    if (_activeNotebook == null) return [];
    return _notes.where((note) {
      return note.isLocked &&
          note.notebookId == _activeNotebook!.id;
    }).toList();
  }

  void _selectNotebook(Notebook notebook)
  {
    setState(() {
      _activeNotebook = notebook;
    });
  }

  @override
  Widget build(BuildContext context)
  {
    final lockedNotebooks =
    _notebooks.where((n) => n.isLocked).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locked Notes'),
      ),
      body: Column(
        children: [
          if (lockedNotebooks.isNotEmpty)
            SizedBox(
              height: 56,
              child: ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: lockedNotebooks.length,
                itemBuilder: (context, index)
                {
                  final notebook = lockedNotebooks[index];
                  final bool isActive =
                      _activeNotebook != null && notebook.id == _activeNotebook!.id;

                  return GestureDetector(
                    onTap: ()
                    {
                      _selectNotebook(notebook);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.blue
                            : Colors.grey.shade200,
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          notebook.name,
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const Divider(),
          Expanded(
            child: _lockedNotes.isEmpty
                ? const Center(
              child: Text('No locked notes'),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _lockedNotes.length,
              itemBuilder: (context, index)
              {
                final note = _lockedNotes[index];
                return NoteCard(
                  note: note,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteEditorPage(note: note),
                      ),
                    ).then((_) {
                      setState(() {});
                    });
                  },
                  onLongPress: () {
                    // Selection mode can be implemented here later
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
