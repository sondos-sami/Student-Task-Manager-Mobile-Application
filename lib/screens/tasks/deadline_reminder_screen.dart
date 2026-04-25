import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';

class DeadlineReminderScreen extends StatefulWidget {
  final int userId;

  const DeadlineReminderScreen({super.key, required this.userId});

  @override
  State<DeadlineReminderScreen> createState() => _DeadlineReminderScreenState();
}

class _DeadlineReminderScreenState extends State<DeadlineReminderScreen> {
  List<Task> tasks = [];
  final TaskService taskService = TaskService();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    List<Task> allTasks = await taskService.getTasks(widget.userId);
    // Filter out completed tasks and sort by due date
    allTasks = allTasks.where((t) => t.isCompleted == 0).toList();
    allTasks.sort((a, b) {
      try {
        DateTime dateA = DateTime.parse(a.dueDate);
        DateTime dateB = DateTime.parse(b.dueDate);
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });

    setState(() {
      tasks = allTasks;
    });
  }

  Map<String, dynamic> _calculateTimeRemaining(String dueDate) {
    try {
      DateTime deadline = DateTime.parse(dueDate);
      DateTime today = DateTime.now();

      // Create dates at midnight for accurate day calculation
      DateTime deadlineAtMidnight = DateTime(
        deadline.year,
        deadline.month,
        deadline.day,
      );
      DateTime todayAtMidnight = DateTime(today.year, today.month, today.day);

      int daysRemaining = deadlineAtMidnight.difference(todayAtMidnight).inDays;

      if (daysRemaining < 0) {
        return {
          'status': 'overdue',
          'display': '${daysRemaining.abs()} days overdue',
          'days': daysRemaining.abs(),
          'hours': 0,
        };
      } else if (daysRemaining == 0) {
        // Calculate hours remaining
        int hoursRemaining = 24 - today.hour;
        return {
          'status': 'today',
          'display': '$hoursRemaining hours remaining',
          'days': 0,
          'hours': hoursRemaining,
        };
      } else {
        return {
          'status': 'upcoming',
          'display': '$daysRemaining days remaining',
          'days': daysRemaining,
          'hours': 0,
        };
      }
    } catch (e) {
      return {
        'status': 'invalid',
        'display': 'Invalid date',
        'days': 0,
        'hours': 0,
      };
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
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
    return Scaffold(
      appBar: AppBar(title: const Text('Deadline Reminders'), elevation: 0),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'All tasks completed!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No pending deadlines',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final timeInfo = _calculateTimeRemaining(task.dueDate);
                final statusColor = _getStatusColor(timeInfo['status']);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        left: BorderSide(color: statusColor, width: 5),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(
                                  timeInfo['status'].toString().toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Task Deadline',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(task.dueDate),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: Colors.grey[300],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Today',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(
                                            DateTime.now().toString(),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: statusColor.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Time Remaining',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        timeInfo['display'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                      if (timeInfo['days'] > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            '(${timeInfo['days']} days)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Chip(
                                label: Text(
                                  'Priority: ${task.priority}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: _getPriorityColor(
                                  task.priority,
                                ).withOpacity(0.2),
                              ),
                              if (task.description != null &&
                                  task.description!.isNotEmpty)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      task.description!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
