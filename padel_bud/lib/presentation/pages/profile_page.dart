import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:padel_bud/providers/user_provider.dart';
import 'package:padel_bud/core/app_localizations.dart';

import '../../providers/providers.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  TextEditingController? _firstNameController;
  TextEditingController? _lastNameController;
  TextEditingController? _emailController;
  TextEditingController? _phoneController;

  String? _profileImagePath;
  double? _selectedLevel;

  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _firstNameController?.dispose();
    _lastNameController?.dispose();
    _emailController?.dispose();
    _phoneController?.dispose();
    super.dispose();
  }

  void _initializeControllers(UserState user) {
    _firstNameController = TextEditingController(text: user.firstName ?? '');
    _lastNameController = TextEditingController(text: user.lastName ?? '');
    _emailController = TextEditingController(text: user.email ?? '');
    _phoneController = TextEditingController(text: user.phoneNumber ?? '');
    _profileImagePath = user.profilePictureUrl;
    _selectedLevel = user.level;

    _initialized = true;
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImagePath = pickedFile.path;
      });
    }
  }

  Future<String?> _uploadImageToFirebase(String imagePath) async {
    try {
      final userId = ref.read(authProvider).user?.uid;
      if (userId == null) return null;

      final file = File(imagePath);
      final fileName = 'profile_pictures/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final ref_ = FirebaseStorage.instance.ref().child(fileName);
      await ref_.putFile(file);
      
      final downloadUrl = await ref_.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context).failedToUploadImage}: $e')),
      );
      return null;
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      String? profilePictureUrl = _profileImagePath;

      // Check if the profile image path is a local file (not a URL)
      if (_profileImagePath != null && !_profileImagePath!.startsWith('http')) {
        // Upload to Firebase Storage
        profilePictureUrl = await _uploadImageToFirebase(_profileImagePath!);
        if (profilePictureUrl == null) {
          return; // Upload failed
        }
      }

      ref
          .read(userProvider.notifier)
          .updateUser(
            firstName: _firstNameController?.text,
            lastName: _lastNameController?.text,
            email: _emailController?.text,
            phoneNumber: _phoneController?.text,
            profilePictureUrl: profilePictureUrl,
            level: _selectedLevel,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).success)),
        );
        setState(() {
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${AppLocalizations.of(context).error}: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    if (!_initialized) {
      if (!user.initialized) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      _initializeControllers(user);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black26,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            AppLocalizations.of(context).editProfile,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickProfileImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: _profileImagePath != null
                        ? (_profileImagePath!.startsWith('http')
                              ? NetworkImage(_profileImagePath!)
                              : FileImage(File(_profileImagePath!))
                                    as ImageProvider)
                        : const AssetImage('assets/default_avatar.png'),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).changePhoto,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            _buildLanguageSelector(),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _firstNameController!,
              label: AppLocalizations.of(context).firstName,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _lastNameController!,
              label: AppLocalizations.of(context).lastName,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController!,
              label: AppLocalizations.of(context).email,
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController!,
              label: AppLocalizations.of(context).phoneNumber,
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: 16),
            _buildLevelSelector(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSaving ? Colors.grey : const Color(0xFF1E88E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context).loading,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        AppLocalizations.of(context).saveChanges,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Consumer(
      builder: (context, ref, child) {
        final currentLocale = ref.watch(localeProvider);
        final localization = AppLocalizations.of(context);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.language, color: const Color(0xFF1E88E5)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: currentLocale.languageCode,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: 'he',
                        child: Text('עברית'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(localeProvider.notifier).setLocale(
                              Locale(value),
                            );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.sports_tennis, color: const Color(0xFF1E88E5)),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<double>(
                value: _selectedLevel ?? 1.0,
                isExpanded: true,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                    value: 1.0,
                    child: Text('1.0'),
                  ),
                  DropdownMenuItem(
                    value: 1.5,
                    child: Text('1.5'),
                  ),
                  DropdownMenuItem(
                    value: 2.0,
                    child: Text('2.0'),
                  ),
                  DropdownMenuItem(
                    value: 2.5,
                    child: Text('2.5'),
                  ),
                  DropdownMenuItem(
                    value: 3.0,
                    child: Text('3.0'),
                  ),
                  DropdownMenuItem(
                    value: 3.5,
                    child: Text('3.5'),
                  ),
                  DropdownMenuItem(
                    value: 4.0,
                    child: Text('4.0'),
                  ),
                  DropdownMenuItem(
                    value: 4.5,
                    child: Text('4.5'),
                  ),
                  DropdownMenuItem(
                    value: 5.0,
                    child: Text('5.0'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLevel = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1E88E5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
