// These are task values

class Task {
  final String id;
  final String title;
  final DateTime dueDate;
  final DateTime timeCreated;
  final String category;
  final String tag;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.timeCreated,
    required this.category,
    required this.tag,
    required this.isCompleted,
  });
}