import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final UserService userService = UserService();

  String fullName = '';
  String email = '';
  String studentId = '';
  String password = '';
  String confirmPassword = '';
  String gender = 'Male';
  String level = '1';

  bool isValidEmail(String email) {
    return RegExp(r'^\d+@stud\.fci-cu\.edu\.eg$').hasMatch(email);
  }

  bool isValidPassword(String pass) {
    return pass.length >= 8 && RegExp(r'\d').hasMatch(pass);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // Full Name
              TextFormField(
                decoration: InputDecoration(labelText: "Full Name"),
                validator: (value) =>
                    value!.isEmpty ? "Full name is required" : null,
                onSaved: (value) => fullName = value!,
              ),

              // Email
              TextFormField(
                decoration: InputDecoration(labelText: "University Email"),
                validator: (value) {
                  if (value!.isEmpty) return "Email is required";
                  if (!isValidEmail(value)) return "Invalid FCI Email";
                  return null;
                },
                onSaved: (value) => email = value!,
              ),

              // Student ID
              TextFormField(
                decoration: InputDecoration(labelText: "Student ID"),
                validator: (value) =>
                    value!.isEmpty ? "Student ID is required" : null,
                onSaved: (value) => studentId = value!,
              ),

              // Gender
              Row(
                children: [
                  Text("Gender: "),
                  Radio(
                    value: "Male",
                    groupValue: gender,
                    onChanged: (val) =>
                        setState(() => gender = val.toString()),
                  ),
                  Text("Male"),
                  Radio(
                    value: "Female",
                    groupValue: gender,
                    onChanged: (val) =>
                        setState(() => gender = val.toString()),
                  ),
                  Text("Female"),
                ],
              ),

              // Level
              DropdownButtonFormField(
                value: level,
                decoration: InputDecoration(labelText: "Level"),
                items: ["1", "2", "3", "4"]
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => level = val.toString()),
              ),

              // Password
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
                validator: (value) {
                  if (value!.isEmpty) return "Password is required";
                  if (!isValidPassword(value))
                    return "Min 8 chars + at least one number";
                  return null;
                },
                onChanged: (val) => password = val,
              ),

              // Confirm Password
              TextFormField(
                obscureText: true,
                decoration:
                    InputDecoration(labelText: "Confirm Password"),
                validator: (value) {
                  if (value!.isEmpty) return "Confirm your password";
                  if (value != password)
                    return "Passwords do not match";
                  return null;
                },
                onSaved: (val) => confirmPassword = val!,
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Match email with student ID
                    if (!email.startsWith(studentId)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Student ID doesn't match email")),
                      );
                      return;
                    }

                    User user = User(
                      fullName: fullName,
                      email: email,
                      studentId: studentId,
                      gender: gender,
                      level: level,
                      password: password,
                      imagePath: "",
                    );

                    String result =
                        await userService.registerUser(user);

                    if (result == "success") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Signup Success")),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("Email already exists")),
                      );
                    }
                  }
                },
                child: Text("Signup"),
              ),
               TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/");
                },
                child: Text("if you have an account login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}