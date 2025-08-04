import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import '../services/auth0_service.dart';
import '../widgets/rounded_button.dart';

class EmailVerificationRequiredScreen extends StatefulWidget {
  final UserProfile user;

  const EmailVerificationRequiredScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EmailVerificationRequiredScreen> createState() => _EmailVerificationRequiredScreenState();
}

class _EmailVerificationRequiredScreenState extends State<EmailVerificationRequiredScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Email Verification Required'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Prevent back button
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Warning icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: const Icon(
                  Icons.warning,
                  color: Colors.orange,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Title
              const Text(
                'Email Verification Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Message
              Text(
                'Please verify your email address before continuing.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // User email
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email, color: Colors.white70),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.user.email ?? 'No email available',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'What to do:',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Check your email inbox\n'
                      '2. Look for a verification email from Auth0\n'
                      '3. Click the verification link\n'
                      '4. Return to the app and try again',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // I've verified button
              RoundedButton(
                text: _isLoading ? 'Checking...' : 'I\'ve Verified My Email',
                onPressed: _isLoading ? null : _checkVerificationStatus,
                backgroundColor: Colors.orange,
              ),
              
              const SizedBox(height: 16),
              
              // Sign out button
              TextButton(
                onPressed: _isLoading ? null : _signOut,
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (kDebugMode) {
        print('EmailVerificationRequiredScreen: User clicked "I\'ve Verified My Email"');
      }

      // Force a fresh sign in to check verification status
      final result = await Auth0Service.instance.signIn();
      
      if (kDebugMode) {
        print('EmailVerificationRequiredScreen: Email verified: ${result.user.isEmailVerified}');
      }

      if (result.user.isEmailVerified ?? false) {
        if (kDebugMode) {
          print('EmailVerificationRequiredScreen: Email verified, proceeding to app');
        }
        
        if (!mounted) return;
        
        // Navigate to main app
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        if (kDebugMode) {
          print('EmailVerificationRequiredScreen: Email still not verified');
        }
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email not verified yet. Please check your inbox and click the verification link.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('EmailVerificationRequiredScreen: Error checking verification: $e');
      }
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking verification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await Auth0Service.instance.signOut();
      if (!mounted) return;
      
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      if (kDebugMode) {
        print('EmailVerificationRequiredScreen: Sign out error: $e');
      }
    }
  }
} 