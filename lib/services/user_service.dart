import '../database/database_helper.dart';
import '../models/user_model.dart';
import 'dart:convert'; 
import 'package:http/http.dart' as http; 
import 'dart:io'; 
import '../services/auth_service.dart';

const String baseUrl = "http://192.168.1.5:3000";
class UserService {

 final AuthService _authService = AuthService();
  // 🔹 REGISTER USER
 Future<String> registerUser(User user) async {
  try {
    // 1. Send to your API first (MySQL is source of truth)
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toMap()),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // 2. API success → now save to local SQLite as a cache
      final db = await DatabaseHelper.database;
      await db.insert('users', {
        'id': data['user']['id'],      // use the ID MySQL assigned
        'fullName': user.fullName,
        'email': user.email,
        'studentId': user.studentId,
        'gender': user.gender,
        'level': user.level,
        'password': user.password,
        'profileImagePath': user.profileImagePath,
      });

      // 3. Save session
      await _authService.saveSession(data['user']['id']);
      return 'success';

    } else {
      return data['message'] ?? 'error';
    }

  } catch (e) {
    print(e);
    return 'error';
  }
}

  // 🔹 LOGIN
Future<User?> login(String email, String password) async {
  try {
    // 1. Try API first
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userData = data['data']['user'];
      final token = data['data']['token'];

      // 2. Sync user into SQLite (update if exists, insert if not)
      final db = await DatabaseHelper.database;
      final existing = await db.query('users',
          where: 'id = ?', whereArgs: [userData['id']]);

      if (existing.isEmpty) {
        await db.insert('users', {
          'id': userData['id'],
          'fullName': userData['fullName'],
          'email': userData['email'],
          'studentId': '',   // API login doesn't return these
          'gender': '',      // so we leave them empty until profile loads
          'level': '',
          'password': '',    // never store plain password
          'profileImagePath': '',
        });
      }

      // 3. Save session with token
      await _authService.saveSession(userData['id'], token: token);
      return User.fromMap({...userData, 'studentId': '', 'gender': '', 'level': '', 'password': '', 'profileImagePath': ''});
    }

    return null;

  } catch (e) {
    // 4. If API is unreachable → fall back to SQLite
    print('API failed, trying SQLite: $e');
    final db = await DatabaseHelper.database;
    final result = await db.query('users',
        where: 'email = ?', whereArgs: [email]);

    if (result.isNotEmpty) {
      return User.fromMap(result.first as Map<String, dynamic>);
    }
    return null;
  }
}
// 🔹 GET USER BY ID — replace the existing one
Future<User?> getUserById(int id) async {
  try {
    // 1. Fetch from API
    final response = await http.get(
      Uri.parse('$baseUrl/profile/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userData = data['data'];

      // 2. Sync into SQLite
      final db = await DatabaseHelper.database;
      final existing = await db.query('users',
          where: 'id = ?', whereArgs: [id]);

      if (existing.isEmpty) {
        await db.insert('users', {
          'id': userData['id'],
          'fullName': userData['fullName'],
          'email': userData['email'],
          'studentId': userData['studentId'],
          'gender': userData['gender'],
          'level': userData['level'],
          'password': '',
          'profileImagePath': userData['profileImagePath'] ?? '',
        });
      } else {
        await db.update('users', {
          'fullName': userData['fullName'],
          'email': userData['email'],
          'studentId': userData['studentId'],
          'gender': userData['gender'],
          'level': userData['level'],
          'profileImagePath': userData['profileImagePath'] ?? '',
        }, where: 'id = ?', whereArgs: [id]);
      }

      // 3. Return from SQLite
      final result = await db.query('users',
          where: 'id = ?', whereArgs: [id]);
      return result.isNotEmpty ? User.fromMap(result.first) : null;
    }

    throw Exception('API error');

  } catch (e) {
    // Offline → load from SQLite
    print('API failed, loading from SQLite: $e');
    final db = await DatabaseHelper.database;
    final result = await db.query('users',
        where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }
}

// 🔹 UPDATE USER — replace the existing one
Future<bool> updateUser(User user) async {
  try {
    // 1. Update name + gender in API
    final response = await http.put(
      Uri.parse('$baseUrl/profile/${user.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': user.fullName,
        'gender': user.gender,
      }),
    );

    if (response.statusCode == 200) {
      // 2. Sync into SQLite
      final db = await DatabaseHelper.database;
      await db.update('users', user.toMap(),
          where: 'id = ?', whereArgs: [user.id]);

      // 3. Upload image if changed
      if (user.profileImagePath.isNotEmpty) {
        final imageFile = File(user.profileImagePath);
        if (await imageFile.exists()) {
          final request = http.MultipartRequest(
            'PUT',
            Uri.parse('$baseUrl/profile/image/${user.id}'),
          );
          request.files.add(await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
          ));
          await request.send();
        }
      }

      return true;
    }

    throw Exception('API error');

  } catch (e) {
    // Offline → update SQLite only
    print('API failed, updating locally: $e');
    final db = await DatabaseHelper.database;
    await db.update('users', user.toMap(),
        where: 'id = ?', whereArgs: [user.id]);
    return false;
  }
}
}