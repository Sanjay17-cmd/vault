class Notebook
{
  final String id;
  String name;
  final bool isLocked;

  Notebook({
    required this.id,
    required this.name,
    this.isLocked = false,
  });
}
