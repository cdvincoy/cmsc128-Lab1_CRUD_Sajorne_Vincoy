import 'package:flutter/material.dart';
import 'package:todo_list/pages/add_task.dart';
import 'package:todo_list/pages/edit_task.dart';
import 'package:todo_list/service/tasks_actions.dart';
import 'package:todo_list/service/category_actions.dart';
import 'package:todo_list/models/task.dart';
import 'package:table_calendar/table_calendar.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TasksActions tasksActions = TasksActions();
  final CategoryActions categoryActions = CategoryActions();

  bool showCalendar = false;

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  Future<void> openAddTaskPage() async {
    final Task? newTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskPage(),
      ),
    );

    if (newTask != null) {
      await tasksActions.createTask(newTask);
    }
  }

  Future<void> editTask(Task task) async {
    final Task? updatedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskPage(
          task: task,
        ),
      ),
    );

    if (updatedTask != null) {
      await tasksActions.updateTask(updatedTask);
    }
  }

  Future<void> deleteTask(Task task) async {
    final Task deletedTask = task;
    final confirmDelete = await showDialog<bool>(
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
                Navigator.pop(context, false);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
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
    if (confirmDelete != true) {
      return;
    }
    await tasksActions.deleteTask(deletedTask.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        duration: const Duration(seconds: 5),
        persist: false,
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () async {
            await tasksActions.undoDelete(deletedTask);
          },
        ),
      ),
    );
  }

  // method for initializing defaualt categories
  @override
  void initState() {
    super.initState();
    categoryActions.createCategories();
  }

  Future<void> completedTask(Task task, bool isCompleted) async {
    await tasksActions.completeTask(task.id, isCompleted);
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

            // Scheduled / Calendar toggle
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        showCalendar = false;
                      });
                    },
                  
                  child: Container(
                    height: 45,

                    decoration: BoxDecoration(
                      color: !showCalendar ?
                       const Color(0xFF002366)
                       : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),

                    child: Center(
                      child: Text(
                        'Scheduled',
                        style: TextStyle(
                          color: !showCalendar ?
                           Colors.white
                           : const Color(0xFF555555),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
                
                const SizedBox(width: 10),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showCalendar = true;
                      });
                    },
                  
                  child: Container(
                    height: 45,

                    decoration: BoxDecoration(
                      color: showCalendar
                      ? const Color(0xFF002366)
                      : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),

                    child: Center(
                      child: Text(
                        'Calendar',
                        style: TextStyle(
                          color: showCalendar
                          ? Colors.white
                          : const Color(0xFF555555),
                          fontWeight: FontWeight.bold,
                        ),
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
              child: StreamBuilder<List<Task>>(
                stream: tasksActions.readTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Text('Loading your tasks...'),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error loading tasks'),
                    );
                  }

                  final tasks = snapshot.data ?? [];

                  final activeTasks = tasks
                      .where((task) => !task.isCompleted)
                      .toList();

                  final completedTasks = tasks
                      .where((task) => task.isCompleted)
                      .toList();

                  if (showCalendar) {
                    return ListView (
                      padding: const EdgeInsets.only(bottom: 100),
                      children: [
                        TableCalendar(
                          firstDay: DateTime.utc(2020,1,1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: focusedDay,
                          rowHeight: 35,
                          
                          selectedDayPredicate: (day) {
                            return isSameDay(selectedDay, day);
                          },

                          onDaySelected: (selected, focused) {
                            setState(() {
                              selectedDay = selected;
                              focusedDay = focused;
                            }
                            );
                          },

                          eventLoader: (day) {
                            return tasks.where((task) {
                              return isSameDay(task.dueDate, day);
                            }).toList();
                          },
                        ),

                        const SizedBox(height: 16),

                        // Expanded(
                        //   child: ListView(
                        //     children: [
                              Text(
                                'Tasks for ${selectedDay.month}/${selectedDay.day}/${selectedDay.year}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              ...tasks.where((task) {
                                return isSameDay(task.dueDate, selectedDay);
                              }).map(
                                (task){
                                  return ListTile(
                                    title: Text(task.title),
                                    subtitle: Text(
                                      '${task.category} • ${task.priority}\n'
                                      '${TimeOfDay.fromDateTime(task.dueDate).format(context)}'
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () => editTask(task),
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            color: Color(0xFF002366),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed:() => deleteTask(task),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          // ),

                      //     ),
                      // ],
                    );
                  }

                  if (tasks.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tasks yet.\nAdd a task to get started!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF777777),
                          height: 1.5,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    children: [
                      ...activeTasks.map(
                        (task) {
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
                                    completedTask(task, value ?? false);
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
                                  onPressed: () => editTask(task),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Color(0xFF002366),
                                  ),
                                  tooltip: 'Edit task',
                                ),

                                // Delete button
                                IconButton(
                                  onPressed: () => deleteTask(task),
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

                      if (completedTasks.isNotEmpty) ...[
                        const SizedBox(height: 20),

                        const Text(
                          'Tasks Done',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        ...completedTasks.map(
                          (task) {
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
                                      completedTask(task, value ?? false);
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
                                    onPressed: () => editTask(task),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Color(0xFF002366),
                                    ),
                                    tooltip: 'Edit task',
                                  ),

                                  // Delete button
                                  IconButton(
                                    onPressed: () => deleteTask(task),
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
                      ],
                    ],
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