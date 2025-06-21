import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import '../widgets/rounded_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Petform',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your pet management companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              RoundedButton(
                text: 'Sign Up',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
              ),
              const SizedBox(height: 10),
              RoundedButton(
                text: 'Log In',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
              ),
              const SizedBox(height: 20),
              const Text(
                'Or continue with',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _SocialButton(
                      text: 'Google',
                      icon: Icons.g_mobiledata,
                      onPressed: () => _signInWithGoogle(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SocialButton(
                      text: 'Apple',
                      icon: Icons.apple,
                      onPressed: () => _signInWithApple(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              RoundedButton(
                text: 'Continue as Guest',
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => _adminLogin(context),
                child: const Text(
                  'Admin Login',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.signInWithGoogle();
      if (context.mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign in failed: $e')),
        );
      }
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.signInWithApple();
      if (context.mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Apple sign in failed: $e')),
        );
      }
    }
  }

  Future<void> _adminLogin(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.adminLogin();
      if (context.mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin login successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Admin login failed: $e')),
        );
      }
    }
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}