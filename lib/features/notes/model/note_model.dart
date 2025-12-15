class Note
{
  final String id;
  String title;
  String content;
  String notebookId;
  bool isLocked;
  bool isSelected;
  DateTime lastEdited;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.notebookId,
    required this.isLocked,
    required this.isSelected,
    required this.lastEdited,
  });
}
