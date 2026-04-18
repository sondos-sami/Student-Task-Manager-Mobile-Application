import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'student_tasks.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            title TEXT,
            description TEXT,
            due_date TEXT,
            priority TEXT,
            is_completed INTEGER
          )
        ''');
      },
    );
  }
  
  // INSERT TASK
static Future<int> insertTask(Task task) async {
  final db = await database;
  return await db.insert('tasks', task.toMap());
}

// GET ALL TASKS FOR USER
static Future<List<Task>> getTasks(int userId) async {
  final db = await database;
  final result = await db.query(
    'tasks',
    where: 'user_id = ?',
    whereArgs: [userId],
  );

  return result.map((e) => Task.fromMap(e)).toList();
}

// UPDATE TASK
static Future<int> updateTask(Task task) async {
  final db = await database;
  return await db.update(
    'tasks',
    task.toMap(),
    where: 'id = ?',
    whereArgs: [task.id],
  );
}

// DELETE TASK
static Future<int> deleteTask(int id) async {
  final db = await database;
  return await db.delete(
    'tasks',
    where: 'id = ?',
    whereArgs: [id],
  );
}
}

