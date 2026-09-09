class Task {
  final String id;
  final String title;
  final DateTime dueDate;
  final DateTime timeCreated;
  final String category;
  final String priority;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.timeCreated,
    required this.category,
    required this.priority,
    required this.isCompleted,
  });
}