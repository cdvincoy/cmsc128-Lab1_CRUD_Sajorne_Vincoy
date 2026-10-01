
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_list/theme/colors.dart';

class AuthService {

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Fluttertoast.showToast(
        msg: 'Account created successfully!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.mainButton,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('FIREBASE SIGNUP ERROR: ${e.code} - ${e.message}');
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Please enter a valid email address.';
      } else if (e.code == 'password-does-not-meet-requirements') {
        final message = e.message ?? '';

        final requirements = <String>[];

        if (message.contains('upper case character')) {
          requirements.add('at least one uppercase letter (A–Z)');
        }

        if (message.contains('lower case character')) {
          requirements.add('at least one lowercase letter (a–z)');
        }

        if (message.contains('numeric character')) {
          requirements.add('at least one number (0–9)');
        }

        if (message.contains('non-alphanumeric character')) {
          requirements.add('at least one special character (e.g., !, @, #)');
        }

        if (requirements.isNotEmpty) {
          errorMessage =
              'Your password must contain:\n'
              '${requirements.map((requirement) => '• $requirement').join('\n')}';
        } else {
          errorMessage =
              'Your password does not meet the required security rules.';
        }
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor:const Color(0xFFFFE5E5),
        textColor: Colors.white,
        fontSize: 16.0,
      );

      return false;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Something went wrong. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor:const Color(0xFFFFE5E5),
        textColor: Colors.white,
        fontSize: 16.0,
      );

      return false;
    }
  }

  Future<bool> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Fluttertoast.showToast(
        msg: 'Login successful!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.mainButton,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Please enter a valid email address.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Incorrect email or password.';
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor:const Color(0xFFFFE5E5),
        textColor: const Color(0xFFB00020),
        fontSize: 16.0,
      );

      return false;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Something went wrong. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor:const Color(0xFFFFE5E5),
        textColor: Colors.white,
        fontSize: 16.0,
      );

      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      Fluttertoast.showToast(
        msg: 'Password recovery link sent to your email.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.mainButton,
        textColor: Colors.white,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      if (e.code == 'invalid-email') {
        errorMessage = 'Please enter a valid email address.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No account found for that email.';
      } else {
        errorMessage = 'Unable to send recovery email. Please try again.';
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor:const Color(0xFFFFE5E5),
        textColor: Colors.white,
      );

      return false;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Something went wrong. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor:const Color(0xFFFFE5E5),
        textColor: Colors.white,
      );

      return false;
    }
  }
}