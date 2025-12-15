import '../model/note_model.dart';

List<Note> notes = [
  Note(
    id: '1',
    title: 'Welcome',
    content: 'This is your first note',
    notebookId: 'default',
    isLocked: false,
    isSelected: false,
    lastEdited: DateTime.now(),
  ),
  Note(
    id: '2',
    title: 'Vault idea',
    content: 'Build a secure notes app',
    notebookId: 'default',
    isLocked: false,
    isSelected: false,
    lastEdited: DateTime.now(),
  ),
  Note(
    id: '3',
    title: 'Locked note',
    content: 'This note is locked',
    notebookId: 'default',
    isLocked: true,
    isSelected: false,
    lastEdited: DateTime.now(),
  ),
];
