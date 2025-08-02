import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import '../services/auth0_service.dart';
import '../providers/user_provider.dart';
import '../widgets/rounded_button.dart';
import 'auth0_profile_view.dart';

class Auth0LoginScreen extends StatefulWidget {
  const Auth0LoginScreen({Key? key}) : super(key: key);

  @override
  State<Auth0LoginScreen> createState() => _Auth0LoginScreenState();
}

class _Auth0LoginScreenState extends State<Auth0LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  Credentials? _credentials;

  @override
  void initState() {
    super.initState();
    _initializeAuth0();
  }

  Future<void> _initializeAuth0() async {
    try {
      await Auth0Service.instance.initialize();
    } catch (e) {
      if (kDebugMode) {
        print('Auth0LoginScreen: Initialization error: $e');
      }
    }
  }

  Future<void> _signInWithAuth0() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await Auth0Service.instance.signIn();

      if (!mounted) return;

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
        print('Auth0 login successful');
      }

      // Show profile view first, then navigate to main app
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Auth0ProfileView(user: result.user),
        ),
      );
      
      // Navigate to main app after showing profile
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Login failed: $e';
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF60A5FA),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo/Title
                      const Icon(
                        Icons.pets,
                        size: 64,
                        color: Color(0xFF3B82F6),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome to PetForm',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in with Auth0 to continue',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Error message
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      // Auth0 Login Button
                      if (_credentials == null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: RoundedButton(
                            text: _isLoading ? 'Signing In...' : 'Sign In with Auth0',
                            onPressed: _isLoading ? null : _signInWithAuth0,
                            backgroundColor: const Color(0xFF3B82F6),
                            isLoading: _isLoading,
                          ),
                        ),
                      ] else ...[
                        // Show logout button if user is signed in
                        SizedBox(
                          width: double.infinity,
                          child: RoundedButton(
                            text: 'Sign Out',
                            onPressed: () async {
                              await Auth0Service.instance.signOut();
                              setState(() {
                                _credentials = null;
                              });
                            },
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Info text
                      const Text(
                        'This will open Auth0 Universal Login in your browser',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 