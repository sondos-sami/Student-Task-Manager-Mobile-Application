import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';

class DeadlineReminderScreen extends StatelessWidget {
  const DeadlineReminderScreen({super.key});

  Map<String, dynamic> _calculateTimeRemaining(String dueDate) {
    try {
      DateTime deadline = DateTime.parse(dueDate);
      DateTime today = DateTime.now();

      DateTime deadlineAtMidnight =
          DateTime(deadline.year, deadline.month, deadline.day);
      DateTime todayAtMidnight =
          DateTime(today.year, today.month, today.day);

      int daysRemaining =
          deadlineAtMidnight.difference(todayAtMidnight).inDays;

      if (daysRemaining < 0) {
        return {
          'status': 'overdue',
          'display': '${daysRemaining.abs()} days overdue',
        };
      } else if (daysRemaining == 0) {
        int hoursRemaining = 24 - today.hour;
        return {
          'status': 'today',
          'display': '$hoursRemaining hours remaining',
        };
      } else {
        return {
          'status': 'upcoming',
          'display': '$daysRemaining days remaining',
        };
      }
    } catch (e) {
      return {'status': 'invalid', 'display': 'Invalid date'};
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'overdue':
        return Colors.red;
      case 'today':
        return Colors.orange;
      case 'upcoming':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    // نجيب التاسكات من Provider مش SQLite
    List<Task> tasks = provider.tasks
        .where((t) => t.isCompleted == 0)
        .toList();

    tasks.sort((a, b) =>
        DateTime.parse(a.dueDate).compareTo(DateTime.parse(b.dueDate)));

    return Scaffold(
      appBar: AppBar(title: const Text('Deadline Reminders')),
      body: tasks.isEmpty
          ? const Center(child: Text("No pending deadlines"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final timeInfo =
                    _calculateTimeRemaining(task.dueDate);
                final statusColor =
                    _getStatusColor(timeInfo['status']);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(task.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "${task.dueDate} | ${task.priority}\n${timeInfo['display']}"),
                    trailing: Icon(Icons.circle,
                        color: statusColor, size: 14),
                  ),
                );
              },
            ),
    );
  }
}