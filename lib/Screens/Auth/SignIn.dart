import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/SignInController.getx.dart';
import '../../Widgets/Auth_Widgets.dart';
import 'SignUp.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final SignInController signInController = SignInController.instance;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0).copyWith(
            top: screenHeight * 0.1, // Adjust top padding dynamically
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                'Sign In',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Obx(() {
                return CustomTextField(
                  hintText: 'Email',
                  controller: signInController.emailController,
                  icon: Icons.email,
                  errorText: signInController.emailError.value,
                );
              }),
              const SizedBox(height: 16.0),
              Obx(() {
                return CustomTextField(
                  hintText: 'Password',
                  controller: signInController.passwordController,
                  icon: Icons.lock,
                  obscureText: true,
                  errorText: signInController.passwordError.value,
                );
              }),
              const SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color(0xFFA8D5BA),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Obx(() {
                return signInController.signInError.value != ''
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          signInController.signInError.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox();
              }),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Get.to(() => const SignUpScreen());
                  },
                  child: const Text(
                    "Don't have an account? Sign up here",
                    style: TextStyle(
                      color: Color(0xFFA8D5BA),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Obx(
                () => ElevatedButton(
                  onPressed: signInController.loading.value
                      ? null
                      : signInController.checkEmailAndPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA8D5BA),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: signInController.loading.value
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
