import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static Database? _database;

  // ================= GET DB =================
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // ================= INIT DB =================
  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'student.db');

    return await openDatabase(
      path,
      version: 2, //1
      onCreate: (db, version) async {

        // USERS TABLE
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullName TEXT,
            email TEXT UNIQUE,
            studentId TEXT,
            gender TEXT,
            level TEXT,
            password TEXT,
            profileImagePath TEXT
          )
        ''');

        // TASKS TABLE
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
        onUpgrade: _onUpgrade,
    );
  }
    // ================= UPGRADE DB =================
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE users ADD COLUMN profileImagePath TEXT'
      );
    }
  }

  // ================= TASKS CRUD =================

  static Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  static Future<List<Task>> getTasks(int userId) async {
    final db = await database;

    final result = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return result.map((e) => Task.fromMap(e)).toList();
  }

  static Future<int> updateTask(Task task) async {
    final db = await database;

    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  static Future<int> deleteTask(int id) async {
    final db = await database;

    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}