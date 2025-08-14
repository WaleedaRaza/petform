import 'package:flutter/material.dart';
import '../services/clerk_service.dart';
import '../widgets/video_background.dart';
import 'clerk_user_management_screen.dart';
import 'clerk_debug_screen.dart';

class ClerkTestScreen extends StatefulWidget {
  const ClerkTestScreen({super.key});

  @override
  State<ClerkTestScreen> createState() => _ClerkTestScreenState();
}

class _ClerkTestScreenState extends State<ClerkTestScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _testSignUp() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing sign up...';
    });

    try {
      final result = await ClerkService.instance.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text.isNotEmpty ? _usernameController.text : null,
      );

      if (result.success) {
        setState(() {
          _statusMessage = 'Sign up successful! User ID: ${result.data?['id']}';
        });
      } else {
        setState(() {
          _statusMessage = 'Sign up failed: ${result.errors?.first.message ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Sign up failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignIn() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing sign in...';
    });

    try {
      final result = await ClerkService.instance.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (result.success) {
        final emailAddresses = result.data?['email_addresses'] as List?;
        final email = emailAddresses?.isNotEmpty == true 
            ? emailAddresses!.first['email_address'] 
            : result.data?['email_address'];
        
        setState(() {
          _statusMessage = 'Sign in successful! User: $email';
        });
      } else {
        setState(() {
          _statusMessage = 'Sign in failed: ${result.errors?.first.message ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Sign in failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignOut() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing sign out...';
    });

    try {
      await ClerkService.instance.signOut();
      setState(() {
        _statusMessage = 'Sign out successful!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Sign out failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkAuthStatus() {
    final isSignedIn = ClerkService.instance.isSignedIn;
    final user = ClerkService.instance.currentUser;
    
    setState(() {
      _statusMessage = 'Auth Status: ${isSignedIn ? "Signed In" : "Signed Out"}\n'
          'User: ${user?['email_addresses']?[0]?['email_address'] ?? "None"}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      videoPath: 'lib/assets/backdrop2.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Clerk Test'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Clerk Authentication Test',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testSignUp,
                      child: const Text('Test Sign Up'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testSignIn,
                      child: const Text('Test Sign In'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testSignOut,
                      child: const Text('Test Sign Out'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _checkAuthStatus,
                      child: const Text('Check Status'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ClerkUserManagementScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                      ),
                      child: const Text('Manage Users'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ClerkDebugScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                      ),
                      child: const Text('Debug Info'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_statusMessage),
                      if (_isLoading) ...[
                        const SizedBox(height: 8),
                        const LinearProgressIndicator(),
                      ],
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