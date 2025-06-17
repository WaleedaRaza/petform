import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import '../widgets/rounded_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoundedButton(
              text: 'Sign Up',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
            ),
            const SizedBox(height: 10),
            RoundedButton(
              text: 'Log In',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
            ),
          ],
        ),
      ),
    );
  }
}