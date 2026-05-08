class User {
  int? id;
  String fullName;
  String email;
  String studentId;
  String gender;
  String level;
  String password;
  String profileImagePath;


  User({
    this.id,
    required this.fullName,
    required this.email,
    required this.studentId,
    required this.gender,
    required this.level,
    required this.password,
    required this.profileImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'studentId': studentId,
      'gender': gender,
      'level': level,
      'password': password,
      'profileImagePath': profileImagePath,
    };
  }

// Add this factory inside the User class
factory User.fromMap(Map<String, dynamic> map) {
  return User(
    id: map['id'],
    fullName: map['fullName'],
    email: map['email'],
    studentId: map['studentId'],
    gender: map['gender'],
    level: map['level'],
    password: map['password'] ?? '',
    profileImagePath: map['profileImagePath'] ?? '',
  );
}
}