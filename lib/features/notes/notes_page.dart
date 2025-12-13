import 'package:flutter/material.dart';
import 'data/dummy_notes.dart';
import 'data/dummy_notebooks.dart';
import 'widgets/note_card.dart';
import 'widgets/notebook_chip.dart';
import '../vault/vault_page.dart';
import '../vault/locked_notes_page.dart';
import 'model/notebook_model.dart';
import 'model/note_model.dart';

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
  bool _selectionMode = false;

  void _onNoteLongPress(int index)
  {
    setState(() {
      _selectionMode = true;
      notes[index].isSelected = true;
    });
  }

  void _onNoteTap(int index)
  {
    if (_selectionMode)
    {
      setState(() {
        notes[index].isSelected = !notes[index].isSelected;
        _selectionMode =
            notes.any((note) => note.isSelected);
      });
    }
  }

  void _clearSelection()
  {
    setState(() {
      for (var note in notes)
      {
        note.isSelected = false;
      }
      _selectionMode = false;
    });
  }

  void _openNotebook(BuildContext context, bool isLocked)
  {
    if (isLocked)
    {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const VaultPage(),
        ),
      );
    }
  }

  // ====== Notebook Actions ======

  void _createNotebook()
  {
    String notebookName = '';
    showDialog(
      context: context,
      builder: (context)
      {
        return AlertDialog(
          title: const Text('Create Notebook'),
          content: TextField(
            onChanged: (value)
            {
              notebookName = value;
            },
            decoration: const InputDecoration(
              hintText: 'Notebook name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(context); },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: ()
              {
                if (notebookName.trim().isNotEmpty)
                {
                  setState(() {
                    notebooks.add(Notebook(name: notebookName));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _renameNotebook(int index)
  {
    String notebookName = notebooks[index].name;
    showDialog(
      context: context,
      builder: (context)
      {
        return AlertDialog(
          title: const Text('Rename Notebook'),
          content: TextField(
            onChanged: (value) { notebookName = value; },
            controller: TextEditingController(text: notebooks[index].name),
          ),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(context); },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: ()
              {
                if (notebookName.trim().isNotEmpty)
                {
                  setState(() {
                    notebooks[index] = Notebook(
                      name: notebookName,
                      isLocked: notebooks[index].isLocked,
                    );
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNotebook(int index)
  {
    showDialog(
      context: context,
      builder: (context)
      {
        return AlertDialog(
          title: const Text('Delete Notebook?'),
          content: Text('Are you sure you want to delete "${notebooks[index].name}"?'),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(context); },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: ()
              {
                setState(() {
                  notebooks.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _moveNotesToNotebook()
  {
    List<Note> selected = notes.where((note) => note.isSelected).toList();

    showDialog(
      context: context,
      builder: (context)
      {
        return AlertDialog(
          title: const Text('Move Notes To'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: notebooks.length,
              itemBuilder: (context, index)
              {
                return ListTile(
                  title: Text(notebooks[index].name),
                  onTap: ()
                  {
                    setState(() {
                      // For now, just clear selection
                      for (var note in selected)
                      {
                        note.isSelected = false;
                      }
                      _selectionMode = false;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _onMenuSelected(String value, [int? notebookIndex])
  {
    if (value == 'locked')
    {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LockedNotesPage(),
        ),
      );
    }
    else if (value == 'delete_notes')
    {
      setState(() {
        notes.removeWhere((note) => note.isSelected);
        _selectionMode = false;
      });
    }
    else if (value == 'move')
    {
      _moveNotesToNotebook();
    }
    else if (value == 'create')
    {
      _createNotebook();
    }
    else if (value == 'rename' && notebookIndex != null)
    {
      _renameNotebook(notebookIndex);
    }
    else if (value == 'delete_notebook' && notebookIndex != null)
    {
      _deleteNotebook(notebookIndex);
    }
  }

  @override
  Widget build(BuildContext context)
  {
    final int selectedCount =
        notes.where((note) => note.isSelected).length;

    return Scaffold(
      appBar: AppBar(
        leading: _selectionMode
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: _clearSelection,
        )
            : null,
        title: Text(
          _selectionMode
              ? '$selectedCount selected'
              : 'Notes',
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _onMenuSelected(value),
            itemBuilder: (context)
            {
              return [
                if (!_selectionMode)
                  const PopupMenuItem(
                    value: 'create',
                    child: Text('Create notebook'),
                  ),
                if (_selectionMode)
                  const PopupMenuItem(
                    value: 'delete_notes',
                    child: Text('Delete notes'),
                  ),
                if (_selectionMode)
                  const PopupMenuItem(
                    value: 'move',
                    child: Text('Move to notebook'),
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
                  onTap: ()
                  {
                    _openNotebook(context, notebook.isLocked);
                  },
                  onMenuTap: ()
                  {
                    showModalBottomSheet(
                      context: context,
                      builder: (context)
                      {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Rename'),
                              onTap: ()
                              {
                                Navigator.pop(context);
                                _onMenuSelected('rename', index);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete),
                              title: const Text('Delete'),
                              onTap: ()
                              {
                                Navigator.pop(context);
                                _onMenuSelected('delete_notebook', index);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index)
                {
                  return NoteCard(
                    note: notes[index],
                    onTap: ()
                    {
                      _onNoteTap(index);
                    },
                    onLongPress: ()
                    {
                      _onNoteLongPress(index);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
