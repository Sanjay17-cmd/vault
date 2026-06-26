import '../model/note_model.dart';

final List<Note> notes = [
  Note(
    id: '1',
    title: 'Welcome to Vault',
    content: 'This is your first secure note.',
    notebookId: 'personal',
    isLocked: false,
    lastEdited: DateTime.now(),
  ),
  Note(
    id: '2',
    title: 'Work Tasks',
    content: 'Finish Flutter vault app',
    notebookId: 'work',
    isLocked: false,
    lastEdited: DateTime.now(),
  ),
  Note(
    id: '3',
    title: 'Locked Example',
    content: 'This note is locked',
    notebookId: 'personal',
    isLocked: true,
    lastEdited: DateTime.now(),
  ),
];
