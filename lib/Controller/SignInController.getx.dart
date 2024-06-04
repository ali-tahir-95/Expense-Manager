import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Screens/Admin/Dashboard.dart';

class SignInController extends GetxController {
  static SignInController instance = Get.find();
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final RxBool loading = false.obs;
  final RxString emailError = RxString('');
  final RxString passwordError = RxString('');
  final RxString signInError = RxString('');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  Future<void> checkEmailAndPassword() async {
    try {
      loading.value = true;
      emailError.value = _validateEmail(emailController.text) ?? '';
      passwordError.value = _validatePassword(passwordController.text) ?? '';
      signInError.value = ''; // Clear previous sign-in error message

      if (emailError.value.isEmpty && passwordError.value.isEmpty) {
        // Perform Firebase authentication
        try {
          final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );

          final User? user = userCredential.user;

          if (user != null) {
            Get.offAll(() => DashboardScreen(userId: user.uid));
            print('Sign in success');
            // Navigate to dashboard or any other screen
          } else {
            // Handle sign in failure
            signInError.value = 'User not registered. Please sign up.';
          }
        } catch (e) {
          if (e is FirebaseAuthException) {
            if (e.code == 'user-not-found') {
              signInError.value = 'User not found. Please sign up.';
            } else if (e.code == 'wrong-password') {
              signInError.value = 'Invalid password. Please try again.';
            } else {
              signInError.value = 'Error signing in. Please try again.';
            }
          } else {
            signInError.value = 'Error signing in. Please try again.';
          }
          print('Error signing in: $e');
        }
      } else {
        // Handle sign in failure due to validation errors
        signInError.value = 'Invalid email or password. Please try again.';
      }
    } catch (e) {
      // Handle general errors
      signInError.value = 'Error signing in. Please try again.';
      print('Error signing in: $e');
    } finally {
      loading.value = false;
    }
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email cannot be empty';
    }
    // Simple email validation regex
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }
}
