import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';

class FavoriteTasksScreen extends StatefulWidget {
  final int userId;

  const FavoriteTasksScreen({super.key, required this.userId});

  @override
  State<FavoriteTasksScreen> createState() => _FavoriteTasksScreenState();
}

class _FavoriteTasksScreenState extends State<FavoriteTasksScreen> {
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
        final favorites = provider.favorites;

        return Scaffold(
          appBar: AppBar(title: const Text("Favorite Tasks")),

          body: favorites.isEmpty
              ? const Center(child: Text("No favorites yet"))
              : ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final task = favorites[index];

                    return ListTile(
                      title: Text(task.title),
                      subtitle: Text("${task.dueDate} | ${task.priority}"),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () {
                              provider.toggleFavorite(task);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
