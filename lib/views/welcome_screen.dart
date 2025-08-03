import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'auth0_signup_screen.dart';
import '../widgets/rounded_button.dart';
import '../widgets/video_background.dart';
import '../services/auth0_service.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late AppLinks _appLinks;
  StreamSubscription? _linkSubscription;
  bool _hasCheckedAuth = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    // Check auth state after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthState();
    });
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
    }, onError: (err) {
      if (kDebugMode) {
        print('WelcomeScreen: Deep link error: $err');
      }
    });
  }

  Future<void> _checkAuthState() async {
    if (_hasCheckedAuth) return; // Prevent multiple checks
    _hasCheckedAuth = true;
    
    try {
      // Check if user is authenticated with Auth0
      final auth0User = Auth0Service.instance.currentUser;
      
      if (kDebugMode) {
        print('WelcomeScreen: Auth0 user: ${auth0User?.email}');
      }
      
      // If user is authenticated with Auth0, navigate to main app
      if (auth0User != null) {
        if (kDebugMode) {
          print('WelcomeScreen: Auth0 user is authenticated, navigating to main app');
        }
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (kDebugMode) {
          print('WelcomeScreen: No Auth0 user found, staying on welcome screen');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('WelcomeScreen: Auth state check error: $e');
      }
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
                // Continue with existing Auth0 session
                RoundedButton(
                  text: 'Continue with Auth0',
                  onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const Auth0SignupScreen())
                  ),
                  backgroundColor: const Color(0xFF3B82F6),
                ),
                const SizedBox(height: 16),
                // Create new account (force clear session)
                RoundedButton(
                  text: 'Create New Account',
                  onPressed: () async {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const Auth0SignupScreen())
                    );
                  },
                  backgroundColor: Colors.orange,
                ),
                const SizedBox(height: 16),
                // Clear Auth0 cache (for testing)
                RoundedButton(
                  text: 'Clear Auth0 Cache',
                  onPressed: () async {
                    await Auth0Service.instance.clearAuth0Cache();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Auth0 cache cleared!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  backgroundColor: Colors.red,
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