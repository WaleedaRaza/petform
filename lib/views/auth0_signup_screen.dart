import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import '../providers/user_provider.dart';
import '../services/auth0_service.dart';
import '../widgets/rounded_button.dart';
import '../widgets/video_background.dart';
import 'auth0_profile_view.dart';

class Auth0SignupScreen extends StatefulWidget {
  const Auth0SignupScreen({Key? key}) : super(key: key);

  @override
  State<Auth0SignupScreen> createState() => _Auth0SignupScreenState();
}

class _Auth0SignupScreenState extends State<Auth0SignupScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  Credentials? _credentials;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth0();
  }

  Future<void> _initializeAuth0() async {
    try {
      await Auth0Service.instance.initialize();
      if (kDebugMode) {
        print('Auth0SignupScreen: Auth0 initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth0SignupScreen: Initialization error: $e');
      }
    }
  }

  Future<void> _signUpWithAuth0() async {
    if (_isLoading) return; // Prevent multiple calls
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await Auth0Service.instance.signIn(); // Auth0 Universal Login handles both signup and login

      if (!mounted || _hasNavigated) return;

      setState(() {
        _credentials = result;
      });

      // Update UserProvider with the authenticated user
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setCurrentUser(
        result.user.sub,
        result.user.nickname ?? result.user.name ?? result.user.email?.split('@')[0] ?? 'user',
        result.user.email ?? '',
      );

      if (kDebugMode) {
        print('Auth0 signup/login successful');
        print('Auth0 user: ${result.user.email}');
        print('Auth0 user ID: ${result.user.sub}');
      }

      // Show profile view first, then navigate to main app
      if (!mounted || _hasNavigated) return;
      
      _hasNavigated = true;
      
      // Navigate to profile view
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Auth0ProfileView(user: result.user),
        ),
      );
      
      // Navigate to main app after profile view is dismissed
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Signup/Login failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      videoPath: 'lib/assets/animation.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Sign Up with Auth0'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  'Welcome to Petform!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sign up or log in with your preferred method',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                RoundedButton(
                  text: _isLoading ? 'Signing up...' : 'Continue with Auth0',
                  onPressed: _isLoading ? null : _signUpWithAuth0,
                  backgroundColor: const Color(0xFF3B82F6),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Back to Welcome',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 