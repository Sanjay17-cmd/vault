import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 3)
class TaskModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String text;

  @HiveField(2)
  String priority;

  @HiveField(3)
  String category;

  @HiveField(4)
  bool done;

  TaskModel({
    required this.id,
    required this.text,
    required this.priority,
    required this.category,
    required this.done,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      text: json['text'] as String,
      priority: json['priority'] as String,
      category: json['category'] as String? ?? '',
      done: json['done'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'priority': priority,
      'category': category,
      'done': done,
    };
  }
}
