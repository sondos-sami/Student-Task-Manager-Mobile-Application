 import '../db/database_helper.dart';
import '../models/user_model.dart';

class UserService {
  final dbHelper = DatabaseHelper();

  // 🔹 INSERT USER
  Future<String> registerUser(User user) async {
    final db = await dbHelper.db;

    try {
      await db.insert('users', user.toMap());
      return "success";
    } catch (e) {
      return "email_exists";
    }
  }

  // 🔹 LOGIN
  Future<User?> login(String email, String password) async {
    final db = await dbHelper.db;

    List<Map> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return User(
        id: result[0]['id'],
        fullName: result[0]['fullName'],
        email: result[0]['email'],
        studentId: result[0]['studentId'],
        gender: result[0]['gender'],
        level: result[0]['level'],
        password: result[0]['password'],
        imagePath: result[0]['imagePath'],
      );
    }

    return null;
  }
}