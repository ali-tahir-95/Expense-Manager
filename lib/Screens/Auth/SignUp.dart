import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Widgets/Auth_Widgets.dart';
import '../Admin/Dashboard.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _loading = false;
  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _fullNameError = _validateFullName(_fullNameController.text);
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _confirmPasswordError =
          _validateConfirmPassword(_passwordController.text, _confirmPasswordController.text);
    });

    if (_fullNameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null) {
      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Set the display name to the full name entered by the user
        await userCredential.user!.updateDisplayName(_fullNameController.text);

        await addUser();
        Get.offAll(DashboardScreen(
          userId: userCredential.user!.uid,
        ));
      } catch (e) {
        // Registration failed
        print('Error registering user: $e');
      } finally {
        setState(() {
          _loading = false;
        });
      }
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> addUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email!;
      String name = user.displayName ?? ''; // Use empty string if display name is null
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'name': name, 'email': email})
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    }
  }

  String? _validateFullName(String fullName) {
    if (fullName.isEmpty) {
      return 'Full Name cannot be empty';
    }
    return null;
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

  String? _validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Confirm Password cannot be empty';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFA8D5BA),
        elevation: 0, // Optional: removes shadow/elevation of the app bar
        iconTheme: const IconThemeData(color: Colors.black), // Change the icon color to black
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(
                Icons.account_balance_wallet,
                size: 100,
                color: Color(0xFFA8D5BA),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Expense Manager',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA8D5BA),
                ),
              ),
              const SizedBox(height: 32.0),
              const Text(
                'Sign Up',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Ensures the text is black
                ),
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                hintText: 'Full Name',
                icon: Icons.person,
                controller: _fullNameController,
                errorText: _fullNameError,
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                hintText: 'Email',
                icon: Icons.email,
                controller: _emailController,
                errorText: _emailError,
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                hintText: 'Password',
                icon: Icons.lock,
                obscureText: true,
                controller: _passwordController,
                errorText: _passwordError,
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                hintText: 'Confirm Password',
                icon: Icons.lock,
                obscureText: true,
                controller: _confirmPasswordController,
                errorText: _confirmPasswordError,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA8D5BA),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
              ),
              const SizedBox(height: 16.0), // Add some space after the button
            ],
          ),
        ),
      ),
    );
  }
}
