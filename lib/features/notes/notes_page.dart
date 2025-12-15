import 'package:flutter/material.dart';
import 'data/dummy_notes.dart';
import 'data/dummy_notebooks.dart';
import 'model/notebook_model.dart';
import 'model/note_model.dart';
import 'widgets/note_card.dart';
import 'widgets/notebook_chip.dart';
import '../vault/locked_notes_page.dart';
import '../editor/note_editor_page.dart';

class NotesPage extends StatefulWidget
{
  const NotesPage({super.key});

  @override
  State<NotesPage> createState()
  {
    return _NotesPageState();
  }
}

class _NotesPageState extends State<NotesPage>
{
  late Notebook _activeNotebook;

  bool _selectionMode = false;
  bool _showFabMenu = false;

  @override
  void initState()
  {
    super.initState();
    _activeNotebook = notebooks.first;
  }

  List<Note> get _filteredNotes
  {
    if (_activeNotebook.id == 'all')
    {
      return notes.where((n) => !n.isLocked).toList();
    }

    if (_activeNotebook.isLocked)
    {
      return notes.where((n) => n.isLocked).toList();
    }

    return notes.where((n) =>
    n.notebookId == _activeNotebook.id &&
        !n.isLocked).toList();
  }

  void _deleteNotebookWithUndo()
  {
    if (_activeNotebook.id == 'all') return;

    final deletedNotebook = _activeNotebook;
    final deletedIndex =
    notebooks.indexWhere((n) => n.id == deletedNotebook.id);

    final removedNotes =
    notes.where((n) => n.notebookId == deletedNotebook.id).toList();

    setState(() {
      notebooks.removeAt(deletedIndex);
      notes.removeWhere(
              (n) => n.notebookId == deletedNotebook.id);

      _activeNotebook = notebooks.first;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: const Text('Notebook deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: ()
          {
            setState(() {
              notebooks.insert(deletedIndex, deletedNotebook);
              notes.addAll(removedNotes);
              _activeNotebook = deletedNotebook;
            });
          },
        ),
      ),
    );
  }

  void _renameSelectedNote()
  {
    final selectedNotes =
    _filteredNotes.where((n) => n.isSelected).toList();

    if (selectedNotes.length != 1) return;

    final note = selectedNotes.first;
    final controller = TextEditingController(text: note.title);

    showDialog(
      context: context,
      builder: (context)
      {
        return AlertDialog(
          title: const Text('Rename note'),
          content: TextField(
            controller: controller,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: ()
              {
                setState(() {
                  note.title = controller.text.trim();
                  note.isSelected = false;
                  _selectionMode = false;
                });
                Navigator.pop(context);
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _selectNotebook(Notebook notebook)
  {
    setState(() {
      _activeNotebook = notebook;
      _clearSelection();
    });
  }

  void _onNoteLongPress(Note note)
  {
    setState(() {
      _selectionMode = true;
      note.isSelected = true;
    });
  }

  void _onNoteTap(Note note)
  {
    if (_selectionMode)
    {
      setState(() {
        note.isSelected = !note.isSelected;

        if (!_filteredNotes.any((n) => n.isSelected))
        {
          _selectionMode = false;
        }
      });
    }
    else
    {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NoteEditorPage(note: note),
        ),
      ).then((_) {
        setState(() {});
      });
    }
  }


  void _clearSelection()
  {
    for (var note in notes)
    {
      note.isSelected = false;
    }
    _selectionMode = false;
  }

  void _toggleFabMenu()
  {
    setState(() {
      _showFabMenu = !_showFabMenu;
    });
  }

  // ---------------- ADD NOTE ----------------

  void _createNewNote()
  {
    final targetNotebookId =
    _activeNotebook.id == 'all'
        ? notebooks.firstWhere((n) => n.id != 'all').id
        : _activeNotebook.id;

    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      content: '',
      notebookId: targetNotebookId,
      isLocked: false,
      isSelected: false,
      lastEdited: DateTime.now(),
    );

    setState(() {
      notes.insert(0, newNote);
      _showFabMenu = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorPage(note: newNote),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  // ---------------- ADD NOTEBOOK ----------------

  void _createNotebook()
  {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context)
      {
        return AlertDialog(
          title: const Text('New notebook'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration:
            const InputDecoration(hintText: 'Name'),
          ),
          actions: [
            TextButton(
              onPressed: ()
              {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: ()
              {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                final notebook = Notebook(
                  id: DateTime.now()
                      .millisecondsSinceEpoch
                      .toString(),
                  name: name,
                  isLocked: false,
                );

                setState(() {
                  notebooks.add(notebook);
                  _activeNotebook = notebook;
                  _showFabMenu = false;
                });

                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  // ---------------- MENU ACTIONS ----------------

  void _deleteSelectedNotes()
  {
    setState(() {
      for (var note in notes)
      {
        if (note.isSelected)
        {
          note.isLocked = true; // soft delete
          note.isSelected = false;
        }
      }
      _selectionMode = false;
    });
  }

  void _renameNotebook()
  {
    final controller =
    TextEditingController(text: _activeNotebook.name);

    showDialog(
      context: context,
      builder: (context)
      {
        return AlertDialog(
          title: const Text('Rename notebook'),
          content: TextField(
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: ()
              {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: ()
              {
                setState(() {
                  _activeNotebook.name =
                      controller.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _openLockedNotes()
  {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LockedNotesPage(),
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context)
  {
    final selectedCount =
        _filteredNotes.where((n) => n.isSelected).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectionMode
              ? '$selectedCount selected'
              : _activeNotebook.name,
        ),
        leading: _selectionMode
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: _clearSelection,
        )
            : null,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value)
            {
              if (value == 'rename_notebook')
              {
                _renameNotebook();
              }
              else if (value == 'delete_notebook')
              {
                _deleteNotebookWithUndo();
              }
              else if (value == 'rename_note')
              {
                _renameSelectedNote();
              }
              else if (value == 'delete')
              {
                _deleteSelectedNotes();
              }
              else if (value == 'locked')
              {
                _openLockedNotes();
              }
            },
            itemBuilder: (context)
            {
              return [
                if (!_selectionMode && _activeNotebook.id != 'all')
                  const PopupMenuItem(
                    value: 'rename_notebook',
                    child: Text('Rename notebook'),
                  ),
                if (!_selectionMode && _activeNotebook.id != 'all')
                  const PopupMenuItem(
                    value: 'delete_notebook',
                    child: Text('Delete notebook'),
                  ),
                if (_selectionMode)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete notes'),
                  ),
                if (_selectionMode && selectedCount == 1)
                  const PopupMenuItem(
                    value: 'rename_note',
                    child: Text('Rename note'),
                  ),
                if (!_selectionMode)
                  const PopupMenuItem(
                    value: 'locked',
                    child: Text('Locked notes'),
                  ),
              ];
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 56,
                child: ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: notebooks.length,
                  itemBuilder: (context, index)
                  {
                    final notebook = notebooks[index];
                    return NotebookChip(
                      notebook: notebook,
                      isActive:
                      notebook.id == _activeNotebook.id,
                      onTap: ()
                      {
                        _selectNotebook(notebook);
                      },
                      onMenuTap: () {},
                    );
                  },
                ),
              ),
              const Divider(),
              Expanded(
                child: _filteredNotes.isEmpty
                    ? const Center(child: Text('No notes'))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredNotes.length,
                  itemBuilder: (context, index)
                  {
                    final note = _filteredNotes[index];
                    return NoteCard(
                      note: note,
                      onTap: ()
                      {
                        _onNoteTap(note);
                      },
                      onLongPress: ()
                      {
                        _onNoteLongPress(note);
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          if (_showFabMenu)
            GestureDetector(
              onTap: _toggleFabMenu,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),

          if (_showFabMenu)
            Positioned(
              bottom: 100,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'note',
                    onPressed: _createNewNote,
                    icon: const Icon(Icons.note_add),
                    label: const Text('New note'),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton.extended(
                    heroTag: 'notebook',
                    onPressed: _createNotebook,
                    icon: const Icon(Icons.folder),
                    label: const Text('New notebook'),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleFabMenu,
        child:
        Icon(_showFabMenu ? Icons.close : Icons.add),
      ),
    );
  }
}
