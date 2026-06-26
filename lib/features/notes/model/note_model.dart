import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 1)
class Note {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  String notebookId;

  @HiveField(4)
  bool isLocked;

  @HiveField(5)
  DateTime lastEdited;

  @HiveField(6)
  bool isSelected;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.notebookId,
    required this.isLocked,
    required this.lastEdited,
    this.isSelected = false,
  });
}
