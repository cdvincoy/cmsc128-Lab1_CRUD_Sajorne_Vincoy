import 'package:flutter/material.dart';
import 'package:todo_list/models/task.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  const EditTaskPage({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController titleController;

  String? selectedCategory;
  String? selectedPriority;
  DateTime? selectedDueDate;
  TimeOfDay? selectedDueTime;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.task.title,
    );

    selectedCategory = widget.task.category;
    selectedPriority = widget.task.priority;
    selectedDueDate = widget.task.dueDate;
    selectedDueTime = TimeOfDay.fromDateTime(widget.task.dueDate);
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> selectDueDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDueDate = pickedDate;
      });
    }
  }

  Future<void> selectDueTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedDueTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedDueTime = pickedTime;
      });
    }
  }

  void saveChanges() {
    if (titleController.text.trim().isEmpty ||
        selectedCategory == null ||
        selectedPriority == null ||
        selectedDueDate == null ||
        selectedDueTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields.'),
        ),
      );

      return;
    }

    final DateTime finalDueDate = DateTime(
      selectedDueDate!.year,
      selectedDueDate!.month,
      selectedDueDate!.day,
      selectedDueTime!.hour,
      selectedDueTime!.minute,
    );

    final Task updatedTask = Task(
      id: widget.task.id,
      title: titleController.text.trim(),
      dueDate: finalDueDate,
      timeCreated: widget.task.timeCreated,
      category: selectedCategory!,
      priority: selectedPriority!,
      isCompleted: widget.task.isCompleted,
    );

    Navigator.pop(context, updatedTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F9),
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),

        title: const Text(
          'Edit Task',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Task',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Enter task',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),

              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,

                  items: const [
                    DropdownMenuItem(
                      value: 'School',
                      child: Text('School'),
                    ),
                    DropdownMenuItem(
                      value: 'Personal',
                      child: Text('Personal'),
                    ),
                    DropdownMenuItem(
                      value: 'Work',
                      child: Text('Work'),
                    ),
                  ],

                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Priority',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                _priorityButton('High'),
                const SizedBox(width: 8),
                _priorityButton('Medium'),
                const SizedBox(width: 8),
                _priorityButton('Low'),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Due Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: selectDueDate,

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      selectedDueDate == null
                          ? 'Select a date'
                          : '${selectedDueDate!.month}/'
                            '${selectedDueDate!.day}/'
                            '${selectedDueDate!.year}',
                    ),

                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Due Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: selectDueTime,

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      selectedDueTime == null
                          ? 'Select a time'
                          : selectedDueTime!.format(context),
                    ),

                    const Icon(
                      Icons.access_time,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: saveChanges,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002366),
                  foregroundColor: Colors.white,
                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),

                child: const Text(
                  'SAVE CHANGES',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityButton(String text) {
    final bool isSelected = selectedPriority == text;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPriority = text;
          });
        },

        child: Container(
          height: 45,

          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF002366)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),

          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}