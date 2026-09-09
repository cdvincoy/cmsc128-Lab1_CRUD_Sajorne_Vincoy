import 'package:flutter/material.dart';
import 'package:todo_list/pages/add_task.dart';
import 'package:todo_list/pages/edit_task.dart';
import 'package:todo_list/models/task.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final List<Task> tasks = [];

  Future<void> openAddTaskPage() async {
    final Task? newTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskPage(),
      ),
    );

    if (newTask != null) {
      setState(() {
        tasks.add(newTask);
      });
    }
  }

  Future<void> editTask(int index) async {
    final Task? updatedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskPage(
          task: tasks[index],
        ),
      ),
    );

    if (updatedTask != null) {
      setState(() {
        tasks[index] = updatedTask;
      });
    }
  }

  Future<void> deleteTask(int index) async {
    final Task deletedTask = tasks[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text(
            'Are you sure you want to delete this task?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tasks.removeAt(index);
                });
                Navigator.pop(context);

                // remove the task from the list first, then show the snackbar
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: const Text('Task deleted'),
                    duration: const Duration(seconds: 5),
                    persist: false,
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        setState(() {
                          tasks.insert(index, deletedTask);
                        });
                      },
                    ),
                  ),
                );
              },
              child: const Text(
                'DELETE',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F9),
        elevation: 0,

        title: const Text(
          'Todo',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              // More options
            },
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 20),

            const Text(
              'My Tasks',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Today / Scheduled toggle
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,

                    decoration: BoxDecoration(
                      color: const Color(0xFF002366),
                      borderRadius: BorderRadius.circular(25),
                    ),

                    child: const Center(
                      child: Text(
                        'Today',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Container(
                    height: 45,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),

                    child: const Center(
                      child: Text(
                        'Scheduled',
                        style: TextStyle(
                          color: Color(0xFF555555),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Task list
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks yet.\nAdd a task to get started!',
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF777777),
                          height: 1.5,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,

                      itemBuilder: (context, index) {
                        final Task task = tasks[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),

                          child: Row(
                            children: [
                              // Completion checkbox
                              Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) {
                                  // completion
                                },
                              ),

                              const SizedBox(width: 8),

                              // Task information
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      '${task.category} • ${task.priority}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF777777),
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      'Due: ${task.dueDate.month}/'
                                      '${task.dueDate.day}/'
                                      '${task.dueDate.year} '
                                      '${TimeOfDay.fromDateTime(task.dueDate).format(context)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF999999),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Edit button
                              IconButton(
                                onPressed: () => editTask(index),
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFF002366),
                                ),
                                tooltip: 'Edit task',
                              ),

                              // Delete button
                              IconButton(
                                onPressed: () => deleteTask(index),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                tooltip: 'Delete task',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // + button
      floatingActionButton: FloatingActionButton(
        onPressed: openAddTaskPage,

        backgroundColor: const Color(0xFF002366),

        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
