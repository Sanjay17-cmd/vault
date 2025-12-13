class Note
{
  final String title;
  final String content;
  bool isLocked;
  bool isSelected;

  Note({
    required this.title,
    required this.content,
    this.isLocked = false,
    this.isSelected = false,
  });
}
