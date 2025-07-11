import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import '../widgets/rounded_button.dart';
import '../widgets/video_background.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      videoPath: 'lib/assets/animation.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
      child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
          children: [
                const Spacer(),
                const Spacer(),
            RoundedButton(
              text: 'Sign Up',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
            ),
                const SizedBox(height: 16),
            RoundedButton(
              text: 'Log In',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
            ),
                const SizedBox(height: 40),
          ],
        ),
      ),
        ),
      ),
    );
  }
}