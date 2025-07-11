import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/firebase_auth_service.dart';
import '../widgets/video_background.dart';
import '../widgets/rounded_button.dart';
import 'pet_profile_creation_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;
  bool _isResending = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    try {
      await _authService.reloadUser();
      if (_authService.isEmailVerified()) {
        _timer?.cancel();
        if (!mounted) return;
        
        // Navigate to pet creation screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PetProfileCreationScreen()),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('EmailVerificationScreen: Error checking verification: $e');
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);
    try {
      await _authService.resendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent! Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final email = user?.email ?? 'your email';

    return VideoBackground(
      videoPath: 'lib/assets/animation2.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Verify Email'),
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
                        Icons.mark_email_unread,
                        size: 80,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Verify Your Email',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'We\'ve sent a verification email to:',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Please check your email and click the verification link to continue.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        RoundedButton(
                          text: 'I\'ve Verified My Email',
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            await _checkEmailVerification();
                            setState(() => _isLoading = false);
                          },
                        ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _isResending ? null : _resendVerificationEmail,
                        child: _isResending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Resend Verification Email',
                                style: TextStyle(color: Colors.orange),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Didn\'t receive the email? Check your spam folder.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
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