import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/auth0_mock_service.dart';
import '../widgets/video_background.dart';
import 'auth0_signup_screen.dart';
import 'auth0_signin_screen.dart';

class Auth0TestScreen extends StatefulWidget {
  const Auth0TestScreen({super.key});

  @override
  State<Auth0TestScreen> createState() => _Auth0TestScreenState();
}

class _Auth0TestScreenState extends State<Auth0TestScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAuth0();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _initializeAuth0() async {
    try {
      await Auth0MockService.instance.initialize();
      _checkAuthStatus();
    } catch (e) {
      setState(() {
        _statusMessage = 'Auth0 initialization failed: $e';
      });
    }
  }

  Future<void> _testSignUp() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing Auth0 sign up...';
    });

    try {
      final result = await Auth0MockService.instance.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _statusMessage = 'Auth0 sign up successful! User: ${result.user?.email}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Auth0 sign up error: $e';
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
      _statusMessage = 'Testing Auth0 sign in...';
    });

    try {
      final result = await Auth0MockService.instance.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _statusMessage = 'Auth0 sign in successful! User: ${result.user?.email}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Auth0 sign in error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing Auth0 Google sign in...';
    });

    try {
      final result = await Auth0MockService.instance.signInWithSocial('google-oauth2');

      setState(() {
        _statusMessage = 'Auth0 Google sign in successful! User: ${result.user?.email}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Auth0 Google sign in error: $e';
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
      _statusMessage = 'Testing Auth0 sign out...';
    });

    try {
      await Auth0MockService.instance.signOut();
      setState(() {
        _statusMessage = 'Auth0 sign out successful!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Auth0 sign out error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkAuthStatus() {
    final isSignedIn = Auth0MockService.instance.isSignedIn;
    final user = Auth0MockService.instance.currentUser;
    
    setState(() {
      _statusMessage = 'Auth0 Status: ${isSignedIn ? "Signed In" : "Signed Out"}\n'
          'User: ${user?.email ?? "None"}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      videoPath: 'lib/assets/animation2.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Auth0 Test'),
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
                        'Auth0 Authentication Test',
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
                      onPressed: _isLoading ? null : _testGoogleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4285F4),
                      ),
                      child: const Text('Google Sign In'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testSignOut,
                      child: const Text('Test Sign Out'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _checkAuthStatus,
                      child: const Text('Check Status'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Auth0SignupScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                      ),
                      child: const Text('Auth0 Signup'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Auth0SigninScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                ),
                child: const Text('Auth0 Signin'),
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