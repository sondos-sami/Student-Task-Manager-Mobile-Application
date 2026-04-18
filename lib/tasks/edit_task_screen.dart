import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task_model.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController dateController;

  String priority = 'Low';

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.task.title);
    descController = TextEditingController(text: widget.task.description);
    dateController = TextEditingController(text: widget.task.dueDate);
    priority = widget.task.priority;
  }

  Future<void> updateTask() async {
    Task updatedTask = Task(
      id: widget.task.id,
      userId: widget.task.userId,
      title: titleController.text,
      description: descController.text,
      dueDate: dateController.text,
      priority: priority,
      isCompleted: widget.task.isCompleted,
    );

    await DatabaseHelper.updateTask(updatedTask);

    Navigator.pop(context, true);
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      dateController.text = picked.toString().split(" ")[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: dateController,
              readOnly: true,
              onTap: pickDate,
              decoration: const InputDecoration(labelText: "Due Date"),
            ),
            const SizedBox(height: 10),

            DropdownButton<String>(
              value: priority,
              items: ['Low', 'Medium', 'High']
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  priority = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: updateTask,
              child: const Text("Update Task"),
            )
          ],
        ),
      ),
    );
  }
}
