import '../database/database_helper.dart';
import '../models/user_model.dart';

class UserService {

  // 🔹 REGISTER USER
  Future<String> registerUser(User user) async {
    final db = await DatabaseHelper.database;

    try {
      await db.insert('users', user.toMap());
      return "success";
    } catch (e) {
      print(e);
     // return "email_exists";
     return"error";
    }
  }

  // 🔹 LOGIN
  Future<User?> login(String email, String password) async {
    final db = await DatabaseHelper.database;

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
        profileImagePath: result[0]['profileImagePath'], // 🔥 جديد
      );
    }

    return null;
  }

// ① جيب يوزر بالـ ID
Future<User?> getUserById(int id) async {
  final db = await DatabaseHelper.database;
  final maps = await db.query(
    'users',
    where: 'id = ?',
    whereArgs: [id],
    limit: 1,
  );
  if (maps.isEmpty) return null;
   return User(
    id: maps.first['id'] as int?,
    fullName: maps.first['fullName'] as String,
    email: maps.first['email'] as String,
    studentId: maps.first['studentId'] as String,
    gender: maps.first['gender'] as String,
    level: maps.first['level'] as String,
    password: maps.first['password'] as String,
    profileImagePath: maps.first['profileImagePath'] as String,
  );
}
 
// ② اپديت بيانات اليوزر
Future<int> updateUser(User user) async {
  final db = await DatabaseHelper.database;
  return await db.update(
    'users',
    user.toMap(),
    where: 'id = ?',
    whereArgs: [user.id],
  );
}
}