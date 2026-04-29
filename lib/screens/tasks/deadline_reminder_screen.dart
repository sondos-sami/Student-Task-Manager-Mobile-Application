import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';

class DeadlineScreen extends StatelessWidget {
  final Task task;

  const DeadlineScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    DateTime dueDate = DateTime.parse(task.dueDate);
    DateTime today = DateTime.now();

    Duration diff = dueDate.difference(today);
    int daysLeft = diff.inDays;

    return Scaffold(
      appBar: AppBar(title: const Text("Deadline Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Task: ${task.title}"),
            const SizedBox(height: 10),
            Text("Due Date: ${DateFormat('yyyy-MM-dd').format(dueDate)}"),
            Text("Today: ${DateFormat('yyyy-MM-dd').format(today)}"),
            const SizedBox(height: 20),
            Text(
              "Remaining: $daysLeft days",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}