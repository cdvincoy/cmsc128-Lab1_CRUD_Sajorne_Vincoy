import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final document = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = document.data();

    usernameController.text = data?['username'] ?? '';
    emailController.text = data?['email'] ?? user.email ?? '';

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final newPassword = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.isNotEmpty && newPassword != confirmPassword) {
      Fluttertoast.showToast(
        msg: 'Passwords do not match.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        );
        return;
    }

    if (username.isEmpty || email.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Username and email are required.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Check if another account is already using this username.
      final usernameQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (usernameQuery.docs.isNotEmpty &&
          usernameQuery.docs.first.id != user.uid) {
        Fluttertoast.showToast(
          msg: 'Username is already taken.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );

        setState(() {
          isSaving = false;
        });

        return;
      }

      // Update email in Firebase Authentication.
      if (email != user.email) {
        await user.verifyBeforeUpdateEmail(email);
      }

      // Update username and email in Firestore.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'username': username,
        'email': email,
      });

      // Update password if the user entered a new one.
      if (newPassword.isNotEmpty) {
        if (newPassword.length < 6) {
          Fluttertoast.showToast(
            msg: 'Password must be at least 6 characters.',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );

          setState(() {
            isSaving = false;
          });

          return;
        }

        await user.updatePassword(newPassword);
      }

      Fluttertoast.showToast(
        msg: 'Profile updated successfully!',
        backgroundColor: const Color(0xFF002366),
        textColor: Colors.white,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'Unable to update profile.';

      if (e.code == 'requires-recent-login') {
        message =
            'Please log out and log in again before changing your email or password.';
      } else if (e.code == 'email-already-in-use') {
        message = 'That email is already being used by another account.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.code == 'weak-password') {
        message = 'The new password is too weak.';
      }

      Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Unable to update profile. Please try again.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F7F9),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F9),
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),

        child: Column(
          children: [
            const SizedBox(height: 30),

            // Profile picture
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundColor: Color(0xFF002366),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                // Change profile picture button
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Fluttertoast.showToast(
                        msg: 'Profile picture upload coming soon.',
                      );
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF002366),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Username
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Username',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                hintText: 'Enter your username',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Email
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Password
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'New Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Leave blank to keep current password',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: confirmPasswordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Confirm new password',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    });
                  },
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            

            const SizedBox(height: 30),

            // Save Changes button
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: isSaving ? null : saveProfile,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002366),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),

                child: isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 15),

            // Cancel button
            SizedBox(
              width: double.infinity,
              height: 50,

              child: TextButton(
                onPressed: isSaving
                    ? null
                    : () {
                        Navigator.pop(context);
                      },

                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF777777),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}