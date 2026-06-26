import 'package:hive/hive.dart';

part 'notebook_model.g.dart';

@HiveType(typeId: 2)
class Notebook {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool isLocked;

  Notebook({
    required this.id,
    required this.name,
    required this.isLocked,
  });
}
