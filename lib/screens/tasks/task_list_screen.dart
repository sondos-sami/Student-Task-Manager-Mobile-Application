import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../profile/profile_screen.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import 'favorite_tasks_screen.dart';
import 'deadline_reminder_screen.dart';
import '../../models/task_model.dart';

class TaskListScreen extends StatefulWidget {
  final int userId;

  const TaskListScreen({super.key, required this.userId});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final provider = Provider.of<TaskProvider>(context, listen: false);
      provider.setUser(widget.userId);
      provider.loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final tasks = provider.filteredTasks;

        return Scaffold(
          appBar: AppBar(
            title: const Text("My Tasks"),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                tooltip: 'Deadline Reminders',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DeadlineReminderScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FavoriteTasksScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),

          body: Column(
            children: [
              const SizedBox(height: 10),

              // ===== STATUS FILTER =====
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip(
                      "All",
                      provider.statusFilter == "All",
                      () => provider.setStatusFilter("All"),
                    ),
                    _chip(
                      "Completed",
                      provider.statusFilter == "Completed",
                      () => provider.setStatusFilter("Completed"),
                    ),
                    _chip(
                      "Pending",
                      provider.statusFilter == "Pending",
                      () => provider.setStatusFilter("Pending"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ===== PRIORITY FILTER =====
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip(
                      "All Priority",
                      provider.priorityFilter == "All",
                      () => provider.setPriorityFilter("All"),
                    ),
                    _chip(
                      "Low",
                      provider.priorityFilter == "Low",
                      () => provider.setPriorityFilter("Low"),
                    ),
                    _chip(
                      "Medium",
                      provider.priorityFilter == "Medium",
                      () => provider.setPriorityFilter("Medium"),
                    ),
                    _chip(
                      "High",
                      provider.priorityFilter == "High",
                      () => provider.setPriorityFilter("High"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ===== TASK LIST =====
              Expanded(
                child: tasks.isEmpty
                    ? const Center(child: Text("No tasks"))
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final Task task = tasks[index];

                          return Card(
                            child: ListTile(
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.isCompleted == 1
                                      ? TextDecoration.lineThrough
                                      : null,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "${task.dueDate} | ${task.priority}",
                                style: TextStyle(
                                  decoration: task.isCompleted == 1
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              leading: Checkbox(
                                value: task.isCompleted == 1,
                                onChanged: (_) => provider.toggleComplete(task),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EditTaskScreen(task: task),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      provider.deleteTask(task.id!);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      task.isFavorite == 1
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      provider.toggleFavorite(task);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTaskScreen(userId: widget.userId),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  // ===== CHIP WIDGET =====
  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.deepPurple : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
