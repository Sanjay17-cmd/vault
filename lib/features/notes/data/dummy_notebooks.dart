import '../model/notebook_model.dart';

List<Notebook> notebooks = [
  Notebook(
    id: 'nb_all',
    name: 'All Notes',
  ),
  Notebook(
    id: 'nb_personal',
    name: 'Personal',
  ),
  Notebook(
    id: 'all',
    name: 'All notes',
    isLocked: false,
  ),
  Notebook(
    id: 'nb_work',
    name: 'Work',
  ),
  Notebook(
    id: 'nb_locked',
    name: 'Locked',
    isLocked: true,
  ),
];
