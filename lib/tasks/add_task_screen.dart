import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  final int userId;

  const AddTaskScreen({super.key, required this.userId});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final dateController = TextEditingController();

  String priority = 'Low';

  Future<void> saveTask() async {
    if (titleController.text.isEmpty || dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Date are required")),
      );
      return;
    }

    Task task = Task(
      userId: widget.userId,
      title: titleController.text,
      description: descController.text,
      dueDate: dateController.text,
      priority: priority,
    );

    await DatabaseHelper.insertTask(task);

    Navigator.pop(context, true); // يرجع للـ list ويعمل refresh
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
      appBar: AppBar(title: const Text("Add Task")),
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
              onPressed: saveTask,
              child: const Text("Save Task"),
            )
          ],
        ),
      ),
    );
  }
}
