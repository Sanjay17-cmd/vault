import 'package:flutter/material.dart';
import 'data/dummy_notes.dart';
import 'data/dummy_notebooks.dart';
import 'model/notebook_model.dart';
import 'model/note_model.dart';
import 'widgets/note_card.dart';
import 'widgets/notebook_chip.dart';
import '../vault/locked_notes_page.dart';
import '../../editor/note_editor_page.dart';


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
  int _activeNotebookIndex = 0;
  bool _selectionMode = false;

  @override
  void initState()
  {
    super.initState();
    _activeNotebookIndex = 0;
    _activeNotebook = notebooks[_activeNotebookIndex];
  }

  List<Note> get _filteredNotes
  {
    return notes.where((note) {
      if (_activeNotebook.isLocked)
      {
        return note.isLocked;
      }
      return note.notebookId == _activeNotebook.id && !note.isLocked;
    }).toList();
  }

  void _selectNotebook(Notebook notebook)
  {
    setState(() {
      _activeNotebookIndex =
          notebooks.indexWhere((n) => n.id == notebook.id);
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
        _selectionMode =
            _filteredNotes.any((n) => n.isSelected);
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

  void _deleteSelectedNotes()
  {
    setState(() {
      notes.removeWhere((note) => note.isSelected);
      _selectionMode = false;
    });
  }

  void _moveSelectedNotes(String targetNotebookId)
  {
    setState(() {
      for (var note in notes)
      {
        if (note.isSelected)
        {
          note.notebookId = targetNotebookId;
          note.isSelected = false;
        }
      }
      _selectionMode = false;
    });
  }

  void _showMoveDialog()
  {
    showDialog(
      context: context,
      builder: (context)
      {
        return SimpleDialog(
          title: const Text('Move to notebook'),
          children: notebooks
              .where((n) => n.id != _activeNotebook.id)
              .map(
                (notebook) => SimpleDialogOption(
              child: Text(notebook.name),
              onPressed: ()
              {
                Navigator.pop(context);
                _moveSelectedNotes(notebook.id);
              },
            ),
          )
              .toList(),
        );
      },
    );
  }

  void _moveToLocked()
  {
    setState(() {
      for (var note in notes)
      {
        if (note.isSelected)
        {
          note.isLocked = true;
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
            autofocus: true,
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
                  notebooks[_activeNotebookIndex] = Notebook(
                    id: _activeNotebook.id,
                    name: controller.text.trim(),
                    isLocked: _activeNotebook.isLocked,
                  );
                  _activeNotebook =
                  notebooks[_activeNotebookIndex];
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

  void _deleteNotebook()
  {
    final deletedNotebook = _activeNotebook;
    final deletedIndex = _activeNotebookIndex;

    showDialog(
      context: context,
      builder: (context)
      {
        return AlertDialog(
          title: const Text('Delete notebook?'),
          content:
          const Text('All notes inside will be removed.'),
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
                  notebooks.removeAt(deletedIndex);
                  notes.removeWhere(
                        (n) => n.notebookId == deletedNotebook.id,
                  );

                  _activeNotebookIndex = 0;
                  _activeNotebook = notebooks.first;
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 6),
                    content:
                    const Text('Notebook deleted'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: ()
                      {
                        setState(() {
                          notebooks.insert(
                              deletedIndex, deletedNotebook);
                        });
                      },
                    ),
                  ),
                );
              },
              child: const Text('Delete'),
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

  @override
  Widget build(BuildContext context)
  {
    final int selectedCount =
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
                _deleteNotebook();
              }
              else if (value == 'delete')
              {
                _deleteSelectedNotes();
              }
              else if (value == 'move')
              {
                _showMoveDialog();
              }
              else if (value == 'lock')
              {
                _moveToLocked();
              }
              else if (value == 'locked')
              {
                _openLockedNotes();
              }
            },
            itemBuilder: (context)
            {
              return [
                if (!_selectionMode)
                  const PopupMenuItem(
                    value: 'rename_notebook',
                    child: Text('Rename notebook'),
                  ),
                if (!_selectionMode)
                  const PopupMenuItem(
                    value: 'delete_notebook',
                    child: Text('Delete notebook'),
                  ),
                if (_selectionMode)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete notes'),
                  ),
                if (_selectionMode)
                  const PopupMenuItem(
                    value: 'move',
                    child: Text('Move to notebook'),
                  ),
                if (_selectionMode)
                  const PopupMenuItem(
                    value: 'lock',
                    child: Text('Move to locked'),
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
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: notebooks.length,
              itemBuilder: (context, index)
              {
                final notebook = notebooks[index];
                return NotebookChip(
                  notebook: notebook,
                  isActive: notebook.id == _activeNotebook.id,
                  onTap: ()
                  {
                    _selectNotebook(notebook);
                  },
                  onMenuTap: ()
                  {
                  },
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: _filteredNotes.isEmpty
                ? const Center(
              child: Text('No notes'),
            )
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
                    if (_selectionMode)
                    {
                      _onNoteTap(note);
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
      floatingActionButton: FloatingActionButton(
        onPressed: ()
        {
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
