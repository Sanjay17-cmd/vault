import 'package:flutter/material.dart';
import 'data/dummy_notes.dart';
import 'data/dummy_notebooks.dart';
import 'model/notebook_model.dart';
import 'model/note_model.dart';
import 'widgets/note_card.dart';
import 'widgets/notebook_chip.dart';
import '../vault/locked_notes_page.dart';

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

  @override
  void initState()
  {
    super.initState();
    _activeNotebook = notebooks.first;
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
              if (value == 'delete')
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
                if (_selectionMode)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete notes'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: ()
        {
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
