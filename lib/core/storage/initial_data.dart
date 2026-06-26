import 'hive_service.dart';
import '../../features/notes/data/dummy_notes.dart';
import '../../features/notes/data/dummy_notebooks.dart';

class InitialData {
  static Future<void> loadIfEmpty() async {
    final notesBox = HiveService.notesBox();
    final notebooksBox = HiveService.notebooksBox();

    if (notebooksBox.isEmpty) {
      for (var notebook in notebooks) {
        notebooksBox.put(notebook.id, notebook);
      }
    }

    if (notesBox.isEmpty) {
      for (var note in notes) {
        notesBox.put(note.id, note);
      }
    }
  }
}
