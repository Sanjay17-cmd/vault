import 'package:hive_flutter/hive_flutter.dart';
import '../../features/notes/model/note_model.dart';
import '../../features/notes/model/notebook_model.dart';
import '../../features/tasks/model/task_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(NoteAdapter());
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(NotebookAdapter());
    }

    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TaskModelAdapter());
    }

    await Hive.openBox<Note>('notesBox');
    await Hive.openBox<Notebook>('notebooksBox');
    await Hive.openBox<TaskModel>('tasksBox');
  }

  static Box<Note> notesBox() => Hive.box<Note>('notesBox');
  static Box<Notebook> notebooksBox() => Hive.box<Notebook>('notebooksBox');
  static Box<TaskModel> tasksBox() => Hive.box<TaskModel>('tasksBox');
}
