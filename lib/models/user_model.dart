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
}