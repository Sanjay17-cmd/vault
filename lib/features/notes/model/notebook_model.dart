class Notebook
{
  final String id;
  final String name;
  final bool isLocked;

  Notebook({
    required this.id,
    required this.name,
    this.isLocked = false,
  });
}
