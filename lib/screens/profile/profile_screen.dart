import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  User? _user;
  bool _isEditing = false;
  bool _isLoading = true;

  late TextEditingController _nameController;
  late TextEditingController _studentIdController;
  String? _selectedGender;
  String? _selectedLevel;
  String? _profileImagePath;

  final List<String> _levels = ['1', '2', '3', '4'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _studentIdController = TextEditingController();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await _userService.getUserById(widget.userId);
    if (user != null) {
      setState(() {
        _user = user;
        _nameController.text = user.fullName;
        _studentIdController.text = user.studentId;
        _selectedGender = user.gender;
        _profileImagePath = user.profileImagePath;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

   final updatedUser = User(
  id: _user!.id,
  fullName: _nameController.text.trim(),
  gender: _selectedGender ?? _user!.gender,
  level: _selectedLevel ?? _user!.level,
  email: _user!.email,
  studentId: _studentIdController.text.trim(),
  password: _user!.password,
  profileImagePath: _profileImagePath ?? _user!.profileImagePath,
);

    await _userService.updateUser(updatedUser);

    setState(() {
      _user = updatedUser;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _authService.logout();
             Navigator.pushNamedAndRemoveUntil(
                context,
                '/',        // ← بدل '/login'
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Profile',
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _confirmLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Photo
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _profileImagePath != null
                                ? FileImage(File(_profileImagePath!))
                                : null,
                            child: _profileImagePath == null
                                ? const Icon(Icons.person,
                                    size: 60, color: Colors.grey)
                                : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showImageSourceDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!_isEditing)
                      Text(
                        _user?.email ?? '',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    const SizedBox(height: 24),

                    // Full Name
                    TextFormField(
                      controller: _nameController,
                      readOnly: !_isEditing,
                      decoration: _inputDecoration('Full Name', Icons.person),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Student ID
                    TextFormField(
                      controller: _studentIdController,
                      readOnly: !_isEditing,
                      decoration:
                          _inputDecoration('Student ID', Icons.badge),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Student ID is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Email (read-only always)
                    TextFormField(
                      initialValue: _user?.email,
                      readOnly: true,
                      decoration: _inputDecoration('University Email', Icons.email)
                          .copyWith(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Gender
                    if (_isEditing) ...[
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration:
                            _inputDecoration('Gender (optional)', Icons.wc),
                        items: ['Male', 'Female']
                            .map((g) => DropdownMenuItem(
                                value: g, child: Text(g)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedGender = v),
                      ),
                    ] else ...[
                      TextFormField(
                        initialValue: _selectedGender ?? 'Not specified',
                        readOnly: true,
                        decoration:
                            _inputDecoration('Gender', Icons.wc),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Academic Level
                    if (_isEditing) ...[
                      DropdownButtonFormField<String>(
                        value: _selectedLevel,
                        decoration: _inputDecoration(
                            'Academic Level (optional)', Icons.school),
                        items: _levels
                            .map((l) => DropdownMenuItem(
                                value: l, child: Text('Level $l')))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedLevel = v),
                      ),
                    ] else ...[
                      TextFormField(
                        initialValue: _selectedLevel != null
                            ? 'Level $_selectedLevel'
                            : 'Not specified',
                        readOnly: true,
                        decoration:
                            _inputDecoration('Academic Level', Icons.school),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Buttons
                    if (_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  // reset fields
                                  _nameController.text =
                                      _user!.fullName;
                                  _studentIdController.text =
                                      _user!.studentId;
                                  _selectedGender = _user!.gender;
                                  _selectedLevel =
                                      _user!.level;
                                  _profileImagePath =
                                      _user!.profileImagePath;
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue),
                              child: const Text('Save',
                                  style:
                                      TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: !_isEditing,
      fillColor: !_isEditing ? Colors.grey.shade50 : null,
    );
  }
}