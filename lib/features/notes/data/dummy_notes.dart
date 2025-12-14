import '../model/note_model.dart';

List<Note> notes = [
  Note(
    id: 'n1',
    notebookId: 'nb_personal',
    title: 'Shopping List',
    content: 'Milk, Bread, Eggs',
    lastEdited: DateTime.now(),
  ),
  Note(
    id: 'n2',
    notebookId: 'nb_work',
    title: 'Meeting Notes',
    content: 'Discuss project timeline',
    lastEdited: DateTime.now(),
  ),
  Note(
    id: 'n3',
    notebookId: 'nb_personal',
    title: 'Workout Plan',
    content: 'Monday: Chest\nTuesday: Back',
    lastEdited: DateTime.now(),
  ),
];
