import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../tasks/task_list_screen.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final UserService userService = UserService();

  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Email
              TextFormField(
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) =>
                    value!.isEmpty ? "Email is required" : null,
                onSaved: (value) => email = value!,
              ),

              // Password
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
                validator: (value) =>
                    value!.isEmpty ? "Password is required" : null,
                onSaved: (value) => password = value!,
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    var user = await userService.login(email, password);

                    if (user != null) {
                      final authService = AuthService(); // new
                      await authService.saveSession(user.id!);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskListScreen(userId: user.id!),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Invalid Email or Password")),
                      );
                    }
                  }
                },
                child: Text("Login"),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/signup");
                },
                child: Text("Create new account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
