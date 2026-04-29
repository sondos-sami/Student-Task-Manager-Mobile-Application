import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController dateController;

  late String priority;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    descController = TextEditingController(text: widget.task.description);
    dateController = TextEditingController(text: widget.task.dueDate);
    priority = widget.task.priority;
  }

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
      appBar: AppBar(title: const Text("Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(controller: descController),
              TextFormField(
                controller: dateController,
                readOnly: true,
                onTap: pickDate,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
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
                    final provider =
                        Provider.of<TaskProvider>(context, listen: false);

                    widget.task.title = titleController.text;
                    widget.task.description = descController.text;
                    widget.task.dueDate = dateController.text;
                    widget.task.priority = priority;

                    await provider.updateTask(widget.task);
                    Navigator.pop(context, true);
                  }
                },
                child: const Text("Update Task"),
              )
            ],
          ),
        ),
      ),
    );
  }
}