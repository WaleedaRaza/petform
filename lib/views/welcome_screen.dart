import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import '../widgets/rounded_button.dart';
import '../widgets/video_background.dart';
import '../services/supabase_auth_service.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _authService = SupabaseAuthService();
  late AppLinks _appLinks;
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    
    // Handle incoming links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (kDebugMode) {
        print('WelcomeScreen: Deep link received: $uri');
        print('WelcomeScreen: URI query parameters: ${uri?.queryParameters}');
      }
      
      if (uri != null) {
        // Check for token_hash parameter
        final tokenHash = uri.queryParameters['token_hash'];
        if (tokenHash != null) {
          if (kDebugMode) {
            print('WelcomeScreen: Found token_hash: $tokenHash');
          }
          _handleEmailConfirmation(uri.toString());
        } else {
          // Try to extract token from the URL path or other parameters
          if (kDebugMode) {
            print('WelcomeScreen: No token_hash found, checking other parameters...');
          }
          
          // Check if this is a Supabase confirmation link
          if (uri.toString().contains('token_hash=') || uri.toString().contains('type=')) {
            if (kDebugMode) {
              print('WelcomeScreen: This looks like a Supabase confirmation link');
            }
            _handleEmailConfirmation(uri.toString());
          }
        }
      }
    }, onError: (err) {
      if (kDebugMode) {
        print('WelcomeScreen: Deep link error: $err');
      }
    });
  }

  Future<void> _checkAuthState() async {
    try {
      // Check if user is authenticated
      final user = Supabase.instance.client.auth.currentUser;
      
      if (kDebugMode) {
        print('WelcomeScreen: Current user: ${user?.email}');
        print('WelcomeScreen: Email confirmed: ${user?.emailConfirmedAt}');
      }
      
      // If user is authenticated and email is confirmed, navigate to main app
      if (user != null && user.emailConfirmedAt != null) {
        if (kDebugMode) {
          print('WelcomeScreen: User is authenticated and email confirmed, navigating to main app');
        }
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
      }
    } catch (e) {
      if (kDebugMode) {
        print('WelcomeScreen: Auth state check error: $e');
      }
    }
  }

  // Handle email confirmation from deep link
  Future<void> _handleEmailConfirmation(String url) async {
    try {
      if (kDebugMode) {
        print('WelcomeScreen: Handling email confirmation from URL: $url');
      }
      
      final result = await _authService.handleEmailConfirmation(url);
      
      if (result['verification_success'] == true) {
        if (kDebugMode) {
          print('WelcomeScreen: Email confirmation successful');
        }
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email confirmed successfully! Welcome ${result['email']}'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        if (kDebugMode) {
          print('WelcomeScreen: Email confirmation failed: ${result['error']}');
        }
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email confirmation failed: ${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('WelcomeScreen: Email confirmation error: $e');
      }
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email confirmation error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      videoPath: 'lib/assets/animation.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                const Spacer(),
                RoundedButton(
                  text: 'Sign Up',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                ),
                const SizedBox(height: 16),
                RoundedButton(
                  text: 'Log In',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                ),
                const SizedBox(height: 16),
                RoundedButton(
                  text: 'Auth0 Sign Up',
                  onPressed: () => Navigator.pushNamed(context, '/auth0-signup'),
                  backgroundColor: const Color(0xFF10B981),
                ),
                const SizedBox(height: 16),
                RoundedButton(
                  text: 'Auth0 Sign In',
                  onPressed: () => Navigator.pushNamed(context, '/auth0-signin'),
                  backgroundColor: const Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 16),
                RoundedButton(
                  text: 'Auth0 Test',
                  onPressed: () => Navigator.pushNamed(context, '/auth0-test'),
                  backgroundColor: const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}