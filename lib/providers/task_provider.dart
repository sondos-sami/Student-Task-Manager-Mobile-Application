import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  List<Task> _favorites = [];

  int? _userId;

  // ===== Filters =====
  String _statusFilter = "All";
  String _priorityFilter = "All";

  List<Task> get tasks => _tasks;
  List<Task> get favorites => _favorites;

  String get statusFilter => _statusFilter;
  String get priorityFilter => _priorityFilter;

  void setUser(int id) {
    _userId = id;
  }

  // ================= LOAD =================
  Future<void> loadTasks() async {
    if (_userId == null) return;

    _tasks = await _taskService.getTasks(_userId!);
    _favorites = _tasks.where((t) => t.isFavorite == 1).toList();

    notifyListeners();
  }

  // ================= CRUD =================
  Future<void> addTask(Task task) async {
    await _taskService.addTask(task);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _taskService.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await _taskService.deleteTask(id);
    await loadTasks();
  }

  Future<void> toggleComplete(Task task) async {
    task.isCompleted = task.isCompleted == 1 ? 0 : 1;
    await _taskService.updateTask(task);
    await loadTasks();
  }

  Future<void> toggleFavorite(Task task) async {
    await _taskService.toggleFavorite(task);
    await loadTasks();
  }

  // ================= FILTERS =================
  void setStatusFilter(String value) {
    _statusFilter = value;
    notifyListeners();
  }

  void setPriorityFilter(String value) {
    _priorityFilter = value;
    notifyListeners();
  }

  // ================= FILTERED LIST =================
  List<Task> get filteredTasks {
    List<Task> list = [..._tasks];

    // Status
    if (_statusFilter == "Completed") {
      list = list.where((t) => t.isCompleted == 1).toList();
    } else if (_statusFilter == "Pending") {
      list = list.where((t) => t.isCompleted == 0).toList();
    }

    // Priority
    if (_priorityFilter != "All") {
      list = list.where((t) => t.priority == _priorityFilter).toList();
    }

    return list;
  }
}