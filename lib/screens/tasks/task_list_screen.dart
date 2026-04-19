import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  final int userId;

  const TaskListScreen({super.key, required this.userId});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];

  String filter = "All";
  String priorityFilter = "All";

  final TaskService taskService = TaskService();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    List<Task> allTasks =
        await taskService.getTasks(widget.userId);

    if (filter == "Completed") {
      allTasks = allTasks.where((t) => t.isCompleted == 1).toList();
    } else if (filter == "Pending") {
      allTasks = allTasks.where((t) => t.isCompleted == 0).toList();
    }

    if (priorityFilter != "All") {
      allTasks =
          allTasks.where((t) => t.priority == priorityFilter).toList();
    }

    setState(() {
      tasks = allTasks;
    });
  }

  Future<void> deleteTask(int id) async {
    await taskService.deleteTask(id);
    loadTasks();
  }

  Future<void> toggleComplete(Task task) async {
    task.isCompleted = task.isCompleted == 1 ? 0 : 1;
    await taskService.updateTask(task);
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          DropdownButton<String>(
            value: filter,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: "All", child: Text("All")),
              DropdownMenuItem(value: "Completed", child: Text("Completed")),
              DropdownMenuItem(value: "Pending", child: Text("Pending")),
            ],
            onChanged: (value) {
              setState(() {
                filter = value!;
                loadTasks();
              });
            },
          ),

          const SizedBox(width: 10),

          DropdownButton<String>(
            value: priorityFilter,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: "All", child: Text("Priority")),
              DropdownMenuItem(value: "Low", child: Text("Low")),
              DropdownMenuItem(value: "Medium", child: Text("Medium")),
              DropdownMenuItem(value: "High", child: Text("High")),
            ],
            onChanged: (value) {
              setState(() {
                priorityFilter = value!;
                loadTasks();
              });
            },
          ),
        ],
      ),

      body: tasks.isEmpty
          ? const Center(child: Text('No tasks yet'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return Card(
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted == 1
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      'Due: ${task.dueDate} | Priority: ${task.priority}',
                    ),
                    leading: Checkbox(
                      value: task.isCompleted == 1,
                      onChanged: (_) => toggleComplete(task),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditTaskScreen(task: task),
                              ),
                            );

                            if (result == true) loadTasks();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteTask(task.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(userId: widget.userId),
            ),
          );

          if (result == true) loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}