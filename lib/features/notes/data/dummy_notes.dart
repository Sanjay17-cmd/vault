import '../model/note_model.dart';

final List<Note> notes =
[
  Note(
    title: 'Welcome to Vault',
    content: 'This is your first secure note.',
  ),
  Note(
    title: 'Private Note',
    content: 'This note will be locked later.',
    isLocked: true,
  ),
];
