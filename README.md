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

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String priority = 'Low';

  Future<void> pickDateTime() async {
    final today = DateTime.now();
    final nextYear = DateTime.now().add(const Duration(days: 365));

    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: nextYear,
      initialDate: today,
    );

    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    setState(() {
      selectedDate = pickedDate;
      selectedTime = pickedTime;
    });
  }

  String get formattedDateTime {
    if (selectedDate == null || selectedTime == null) return "";

    final dt = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    return dt.toIso8601String();
  }

  String get displayText {
    if (selectedDate == null || selectedTime == null) return "";

    return "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} "
        "${selectedTime!.hour.toString().padLeft(2, '0')}:"
        "${selectedTime!.minute.toString().padLeft(2, '0')}";
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

              const SizedBox(height: 10),

              GestureDetector(
                onTap: pickDateTime,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedDate == null
                        ? "Pick Date & Time"
                        : displayText,
                  ),
                ),
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
                  if (_formKey.currentState!.validate() &&
                      selectedDate != null &&
                      selectedTime != null) {
                    final provider = Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    );

                    final task = Task(
                      userId: widget.userId,
                      title: titleController.text,
                      description: descController.text,
                      dueDate: formattedDateTime,
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
