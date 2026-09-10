import 'package:cloud_firestore/cloud_firestore.dart';

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

   Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dueDate': dueDate,
      'timeCreated': timeCreated,
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      timeCreated: (map['timeCreated'] as Timestamp).toDate(),
      category: map['category'] ?? '',
      priority: map['priority'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}