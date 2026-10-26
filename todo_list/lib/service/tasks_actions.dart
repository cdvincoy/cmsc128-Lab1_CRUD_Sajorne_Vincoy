
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_list/models/task.dart';

class TasksActions {
  final CollectionReference<Map<String, dynamic>>
      tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  // Get the current authenticated user's UID.
  String get _currentUid {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('A signed-in user is required.');
    }

    return user.uid;
  }

  // Check that an existing task belongs to
  // the currently authenticated user.
  Future<DocumentReference<Map<String, dynamic>>>
      _ownedTaskRef(String taskId) async {
    final uid = _currentUid;
    final taskRef = tasksCollection.doc(taskId);
    final snapshot = await taskRef.get();

    if (!snapshot.exists) {
      throw StateError('Task does not exist.');
    }

    if (snapshot.data()?['ownerUid'] != uid) {
      throw StateError('You do not own this task.');
    }

    return taskRef;
  }

  // Only create tasks owned by the current user.
  Future<void> createTask(Task task) async {
    final uid = _currentUid;

    if (task.ownerUid != uid) {
      throw StateError(
        'Task owner does not match the current user.',
      );
    }

    await tasksCollection.add(task.toMap());
  }

  // Verify existing ownership before updating.
  Future<void> updateTask(Task task) async {
    final uid = _currentUid;

    if (task.ownerUid != uid) {
      throw StateError(
        'Task owner does not match the current user.',
      );
    }

    final taskRef = await _ownedTaskRef(task.id);

    await taskRef.update(task.toMap());
  }

  // Verify ownership before deleting.
  Future<void> deleteTask(String taskId) async {
    final taskRef = await _ownedTaskRef(taskId);
    await taskRef.delete();
  }

  // Prevent restoring a task over an
  // existing document owned by someone else.
  Future<void> undoDelete(Task task) async {
    final uid = _currentUid;

    if (task.ownerUid != uid) {
      throw StateError(
        'Task owner does not match the current user.',
      );
    }

    final taskRef = tasksCollection.doc(task.id);
    final existing = await taskRef.get();

    if (existing.exists) {
      throw StateError(
        'Task already exists and cannot be restored.',
      );
    }

    await taskRef.set(task.toMap());
  }

  // Verify ownership before completing a task.
  Future<void> completeTask(
    String taskId,
    bool isCompleted,
  ) async {
    final taskRef = await _ownedTaskRef(taskId);

    await taskRef.update({
      'isCompleted': isCompleted,
    });
  }

  // Read only the current user's tasks.
  Stream<List<Task>> readTasks() {
    final uid = _currentUid;

    return tasksCollection
        .where('ownerUid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
}
