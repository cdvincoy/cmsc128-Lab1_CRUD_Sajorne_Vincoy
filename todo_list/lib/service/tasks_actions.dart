import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_list/models/task.dart';

class TasksActions {
  final CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> createTask(Task task) async {
    await tasksCollection.add(task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await tasksCollection.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await tasksCollection.doc(taskId).delete();
  }

  Future<void> undoDelete (Task task) async {
    await tasksCollection.doc(task.id).set(task.toMap());
  }

  Future<void> completeTask(
    String taskId,
    bool isCompleted,
  ) async {
    await tasksCollection.doc(taskId).update({
      'isCompleted': isCompleted,
    });
  }

  Stream<List<Task>> readTasks() {
    return tasksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}