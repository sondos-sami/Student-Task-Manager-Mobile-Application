import '../database/database_helper.dart';
import '../models/task_model.dart';

class TaskService {
  Future<List<Task>> getTasks(int userId) async {
    final db = await DatabaseHelper.database;

    final result = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return result.map((e) => Task.fromMap(e)).toList();
  }

  Future<int> addTask(Task task) async {
    final db = await DatabaseHelper.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<int> updateTask(Task task) async {
    final db = await DatabaseHelper.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await DatabaseHelper.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= FAVORITE TOGGLE =================
  Future<void> toggleFavorite(Task task) async {
    final db = await DatabaseHelper.database;

    final newValue = task.isFavorite == 1 ? 0 : 1;

    await db.update('tasks',
      {'is_favorite': newValue},
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}