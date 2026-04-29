import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final int userId;
  const AddTaskScreen({super.key, required this.userId});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final dateController = TextEditingController();

  String priority = 'Low';

  Future<void> pickDate() async {
      final today = DateTime.now();
      final nextYear = DateTime.now().add(const Duration(days: 365));
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: nextYear,
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextFormField(
                controller: dateController,
                readOnly: true,
                onTap: pickDate,
                decoration: const InputDecoration(labelText: "Due Date"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: priority,
                items: ['Low', 'Medium', 'High']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => priority = v!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final provider = Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    );

                    final task = Task(
                      userId: widget.userId,
                      title: titleController.text,
                      description: descController.text,
                      dueDate: dateController.text,
                      priority: priority,
                    );

                    await provider.addTask(task);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Save Task"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
