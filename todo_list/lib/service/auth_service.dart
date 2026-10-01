import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_list/theme/colors.dart';

class AuthService {
  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Check if username already exists
      final usernameQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        Fluttertoast.showToast(
          msg: 'Username is already taken.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return false;
      }

      // Create Firebase Authentication account
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Create Firestore user document
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': username,
        'email': email,
      });

      Fluttertoast.showToast(
        msg: 'Account created successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.mainButton,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong.';

      if (e.code == 'weak-password' ||
          e.code == 'password-does-not-meet-requirements') {
        message =
            'Password must contain a capital letter, a number, and a special character.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with this email.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor:const Color(0xFFFFE5E5),
        textColor: Colors.white,
        fontSize: 14.0,
      );

      return false;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Unable to create account. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor:const Color(0xFFFFE5E5),
        textColor: Colors.white,
        fontSize: 14.0,
      );

      return false;
    }
  }

  Future<bool> logIn({
    required String identifier,
    required String password,
  }) async {
    try {
      String email = identifier.trim();

      // If the user entered a username, find the linked email.
      if (!identifier.contains('@')) {
        final usernameQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: identifier.trim())
            .limit(1)
            .get();

        if (usernameQuery.docs.isEmpty) {
          Fluttertoast.showToast(
            msg: 'No account found with this username.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14.0,
          );

          return false;
        }

        email = usernameQuery.docs.first.data()['email'];
      }

      // Firebase Authentication verifies the password.
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Fluttertoast.showToast(
        msg: 'Login successful!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.mainButton,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed.';

      if (e.code == 'user-not-found') {
        message = 'No account found.';
      } else if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Incorrect username/email or password.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor:const Color(0xFFFFE5E5),
        textColor: const Color(0xFFB00020),
        fontSize: 14.0,
      );

      return false;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Unable to log in. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor:const Color(0xFFFFE5E5),
        textColor: Colors.white,
        fontSize: 14.0,
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