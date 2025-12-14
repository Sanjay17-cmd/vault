class Note
{
  final String id;
  final String notebookId;
  String title;
  String content;
  DateTime lastEdited;
  bool isLocked;
  bool isSelected;

  Note({
    required this.id,
    required this.notebookId,
    required this.title,
    required this.content,
    required this.lastEdited,
    this.isLocked = false,
    this.isSelected = false,
  });
}
