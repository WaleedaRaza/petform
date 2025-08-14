import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/supabase_auth_service.dart';
import 'home_screen.dart';
import '../widgets/rounded_button.dart';
import '../widgets/video_background.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (_emailController.text.trim().isEmpty || 
        _usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    // Validate username format
    final username = _usernameController.text.trim();
    if (username.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username must be at least 3 characters')),
      );
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username can only contain letters, numbers, and underscores')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final isUnique = await userProvider.isUsernameUnique(username);
      if (!isUnique) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username is already taken. Please choose another.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final authService = SupabaseAuthService();
      final credential = await authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      // Since email confirmation is disabled, user should be automatically logged in
      if (credential.user != null) {
        // Reserve username and create user profile
        final userId = credential.user!.id;
        await userProvider.reserveUsername(username, userId, _emailController.text.trim());
        
        if (!mounted) return;
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome to Petform, $username!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Navigate to main app
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        throw Exception('Signup failed - no user returned');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
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
          title: const Text('Sign Up'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Form Fields
              Card(
                color: Colors.grey[850]!.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
          children: [
            TextField(
              controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                labelText: 'Email',
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
              keyboardType: TextInputType.emailAddress,
            ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Username',
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
                          helperText: '3+ characters, letters, numbers, underscores only. Must be unique.',
                          helperStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                labelText: 'Password',
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
                helperText: 'Must be at least 6 characters',
                          helperStyle: TextStyle(color: Colors.grey[400]),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                labelText: 'Confirm Password',
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
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : RoundedButton(text: 'Sign Up', onPressed: _signup),
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