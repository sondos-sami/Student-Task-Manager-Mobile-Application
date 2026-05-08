import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';

class TaskService {
  static const String baseUrl = "http://192.168.1.5:3000";
  final AuthService _authService = AuthService();

  // 🔹 GET TASKS
  Future<List<Task>> getTasks(int userId) async {
    try {
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 API status: ${response.statusCode}');
      print('📡 API body: ${response.body}');

     if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final List apiTasks = data['tasks'];
        print('✅ API: got ${apiTasks.length} tasks from MySQL');

        final db = await DatabaseHelper.database;
        for (var taskMap in apiTasks) {
          Task task = Task.fromApiMap(taskMap);
          await db.insert(
            'tasks',
            task.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        print('🔄 SYNC: SQLite updated');

        final result = await db.query('tasks',
            where: 'user_id = ?', whereArgs: [userId]);
        print('📱 SQLITE: returning ${result.length} tasks to UI');
        return result.map((e) => Task.fromMap(e)).toList();
      }

      throw Exception('API returned ${response.statusCode}: ${response.body}');

    } catch (e) {
      print('📱 SQLITE: falling back - $e');
      final db = await DatabaseHelper.database;
      final result = await db.query('tasks',
          where: 'user_id = ?', whereArgs: [userId]);
      return result.map((e) => Task.fromMap(e)).toList();
    }
  }

  // 🔹 ADD TASK
  Future<int> addTask(Task task) async {
    try {
      final token = await _authService.getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(task.toApiMap()),
      );

      print('📡 ADD TASK status: ${response.statusCode}');
      print('📡 ADD TASK body: ${response.body}');

     if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final db = await DatabaseHelper.database;
        print('✅ API: task added to MySQL with id ${data['task']['id']}');

        return await db.insert(
          'tasks',
          Task(
            id: data['task']['id'],
            userId: task.userId,
            title: task.title,
            description: task.description,
            dueDate: task.dueDate,
            priority: task.priority,
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      throw Exception('API returned ${response.statusCode}: ${response.body}');

    } catch (e) {
      print('📱 SQLITE: saving locally - $e');
      final db = await DatabaseHelper.database;
      return await db.insert('tasks', task.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // 🔹 UPDATE TASK
  Future<int> updateTask(Task task) async {
    try {
      final token = await _authService.getToken();

      final response = await http.put(
        Uri.parse('$baseUrl/tasks/${task.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(task.toApiMap()),
      );

      print('📡 UPDATE TASK status: ${response.statusCode}');
      print('📡 UPDATE TASK body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ API: task ${task.id} updated in MySQL');
        final db = await DatabaseHelper.database;
        return await db.update('tasks', task.toMap(),
            where: 'id = ?', whereArgs: [task.id]);
      }
      throw Exception('API returned ${response.statusCode}: ${response.body}');

    } catch (e) {
      print('📱 SQLITE: updating locally - $e');
      final db = await DatabaseHelper.database;
      return await db.update('tasks', task.toMap(),
          where: 'id = ?', whereArgs: [task.id]);
    }
  }

  // 🔹 DELETE TASK
  Future<int> deleteTask(int id) async {
    try {
      final token = await _authService.getToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 DELETE TASK status: ${response.statusCode}');
      print('📡 DELETE TASK body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ API: task $id deleted from MySQL');
        final db = await DatabaseHelper.database;
        return await db.delete('tasks',
            where: 'id = ?', whereArgs: [id]);
      }
      throw Exception('API returned ${response.statusCode}: ${response.body}');

    } catch (e) {
      print('📱 SQLITE: deleting locally - $e');
      final db = await DatabaseHelper.database;
      return await db.delete('tasks',
          where: 'id = ?', whereArgs: [id]);
    }
  }

  // 🔹 TOGGLE FAVORITE
  Future<void> toggleFavorite(Task task) async {
    try {
      final token = await _authService.getToken();
      final isFav = task.isFavorite == 1;

      http.Response response;
      if (isFav) {
        response = await http.delete(
          Uri.parse('$baseUrl/tasks/${task.id}/favourite'),
          headers: {'Authorization': 'Bearer $token'},
        );
      } else {
        response = await http.patch(
          Uri.parse('$baseUrl/tasks/${task.id}/favourite'),
          headers: {'Authorization': 'Bearer $token'},
        );
      }

      print('📡 TOGGLE FAV status: ${response.statusCode}');
      print('📡 TOGGLE FAV body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ API: task ${task.id} favourite toggled in MySQL');
        final db = await DatabaseHelper.database;
        await db.update('tasks',
            {'is_favorite': isFav ? 0 : 1},
            where: 'id = ?',
            whereArgs: [task.id]);
      } else {
        throw Exception('API returned ${response.statusCode}: ${response.body}');
      }

    } catch (e) {
      print('📱 SQLITE: toggling locally - $e');
      final db = await DatabaseHelper.database;
      final newValue = task.isFavorite == 1 ? 0 : 1;
      await db.update('tasks',
          {'is_favorite': newValue},
          where: 'id = ?',
          whereArgs: [task.id]);
    }
  }

  // 🔹 MARK COMPLETE
  Future<void> markComplete(Task task) async {
    try {
      final token = await _authService.getToken();

      final response = await http.patch(
        Uri.parse('$baseUrl/tasks/${task.id}/complete'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 COMPLETE TASK status: ${response.statusCode}');
      print('📡 COMPLETE TASK body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ API: task ${task.id} marked complete in MySQL');
        final db = await DatabaseHelper.database;
        await db.update('tasks',
            {'is_completed': 1},
            where: 'id = ?',
            whereArgs: [task.id]);
      } else {
        throw Exception('API returned ${response.statusCode}: ${response.body}');
      }

    } catch (e) {
      print('📱 SQLITE: marking complete locally - $e');
      final db = await DatabaseHelper.database;
      await db.update('tasks',
          {'is_completed': 1},
          where: 'id = ?',
          whereArgs: [task.id]);
    }
  }
}