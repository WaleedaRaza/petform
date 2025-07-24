import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../widgets/video_background.dart';
import '../widgets/rounded_button.dart';
import '../services/supabase_auth_service.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String? email;
  
  const EmailVerificationScreen({super.key, this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  final _authService = SupabaseAuthService();
  final _testEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _testEmailController.text = widget.email ?? '';
  }

  @override
  void dispose() {
    _testEmailController.dispose();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    try {
      if (kDebugMode) {
        print('EmailVerificationScreen: Attempting to resend email to: ${widget.email}');
      }
      
      await _authService.resendEmailVerification(_testEmailController.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent! Check your inbox and spam folder.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('EmailVerificationScreen: Resend email error: $e');
      }
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
    return VideoBackground(
      videoPath: 'lib/assets/animation2.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 100,
              ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                  // Header
                  const Icon(
                    Icons.mark_email_unread_outlined,
                        size: 80,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 24),
                  
                      Text(
                    'Check Your Email',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  
                      const SizedBox(height: 16),
                  
                  // Main message
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[850]!.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                      Text(
                          'We\'ve sent you a verification email to complete your account setup.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                        
                        if (widget.email != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.email, color: Colors.orange[300], size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  widget.email!,
                                  style: TextStyle(
                                    color: Colors.orange[300],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 20),
                        
                        // Instructions
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue[300], size: 20),
                                  const SizedBox(width: 8),
                      Text(
                                    'What to do next:',
                                    style: TextStyle(
                          fontWeight: FontWeight.bold,
                                      color: Colors.blue[300],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInstruction('1. Check your email inbox'),
                              _buildInstruction('2. Look in your spam/junk folder'),
                              _buildInstruction('3. Click the verification link'),
                              _buildInstruction('4. Return here and sign in'),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Tips
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Colors.orange[300], size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tip: The email might take a few minutes to arrive',
                                  style: TextStyle(
                                    color: Colors.orange[300],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action buttons
                  Column(
                    children: [
                      RoundedButton(
                        text: 'Resend Email',
                        onPressed: _isResending ? null : _resendEmail,
                        isLoading: _isResending,
                      ),
                      
                                              if (kDebugMode) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Debug: Test Email',
                                  style: TextStyle(
                                    color: Colors.blue[300],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _testEmailController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Test Email',
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
                                  ),
                                ),
                                const SizedBox(height: 8),
                                                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (kDebugMode) {
                                              print('EmailVerificationScreen: Debug info:');
                                              print('- Original Email: ${widget.email}');
                                              print('- Test Email: ${_testEmailController.text}');
                                              print('- Auth service: $_authService');
                                              print('- Current user: ${_authService.currentUser}');
                                            }
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Debug info logged. Test Email: ${_testEmailController.text}'),
                                                backgroundColor: Colors.blue,
                                              ),
                                            );
                                          },
                                          child: const Text('Debug Info'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              final result = await _authService.testSupabaseConnection();
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Connection test: ${result.toString()}'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } catch (e) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Connection test failed: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Test Connection'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                          onPressed: () async {
                                            try {
                                              final result = await _authService.testEmailSending(_testEmailController.text.trim());
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Email test: ${result.toString()}'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } catch (e) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Email test failed: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Test Email'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              final result = await _authService.debugEmailConfirmation(_testEmailController.text.trim());
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Debug confirmation: ${result.toString()}'),
                                                  backgroundColor: Colors.blue,
                                                ),
                                              );
                                            } catch (e) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Debug failed: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Debug Confirmation'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              final result = await _authService.testSMTPConfiguration();
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('SMTP Test: ${result.toString()}'),
                                                  backgroundColor: result['smtp_working'] == true ? Colors.green : Colors.orange,
                                                ),
                                              );
                                            } catch (e) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('SMTP test failed: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Test SMTP'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              final result = await _authService.testSMTPConnection();
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('SMTP Connection: ${result.toString()}'),
                                                  backgroundColor: result['smtp_working'] == true ? Colors.green : Colors.red,
                                                ),
                                              );
                                            } catch (e) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('SMTP connection failed: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Test Connection'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              // Test with the token hash from your email
                                              const testTokenHash = 'pkce_47e931ac86e06446fa412bc998a9b67bd2606fdc70750b76162cf910';
                                              final result = await _authService.testTokenHashVerification(testTokenHash);
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Token Test: ${result.toString()}'),
                                                  backgroundColor: result['verification_success'] == true ? Colors.green : Colors.red,
                                                ),
                                              );
                                            } catch (e) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Token test failed: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Test Token'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              // Test with the full URL from your email
                                              const testUrl = 'https://qpyiugmianjimjfxadcm.supabase.co/auth/v1/verify?token_hash=pkce_47e931ac86e06446fa412bc998a9b67bd2606fdc70750b76162cf910&type=signup&next=com.waleedraza.petform://login-callback';
                                              final result = await _authService.handleEmailConfirmation(testUrl);
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('URL Test: ${result.toString()}'),
                                                  backgroundColor: result['verification_success'] == true ? Colors.green : Colors.red,
                                                ),
                                              );
                                            } catch (e) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('URL test failed: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Test URL'),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
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
                          'Back to Sign In',
                                style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Footer
                  Text(
                    'Already verified?',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Sign In Now',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 