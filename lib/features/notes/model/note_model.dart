class Note
{
  final String title;
  final String content;
  final bool isLocked;

  Note({
    required this.title,
    required this.content,
    this.isLocked = false,
  });
}
