import 'package:flutter/material.dart';
import '../services/supabase_auth_service.dart';
import '../widgets/video_background.dart';
import '../widgets/rounded_button.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final SupabaseAuthService _authService = SupabaseAuthService();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _emailSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent! Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reset email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      videoPath: 'assets/backdrop2.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Forgot Password'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.grey[850]!.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Reset Your Password',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Enter your email address and we\'ll send you a link to reset your password.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (!_emailSent) ...[
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: const TextStyle(color: Colors.white),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[700]!),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                            filled: true,
                            fillColor: Colors.grey[800],
                            prefixIcon: const Icon(Icons.email, color: Colors.grey),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : RoundedButton(
                                text: 'Send Reset Email',
                                onPressed: _resetPassword,
                              ),
                      ] else ...[
                        Icon(
                          Icons.check_circle,
                          size: 60,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Email Sent!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check your email for password reset instructions.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[300],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        RoundedButton(
                          text: 'Back to Login',
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
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