import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../widgets/video_background.dart';
import '../services/auth0_service.dart';
import '../services/supabase_service.dart';
import '../providers/user_provider.dart';
import '../providers/app_state_provider.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'email_verification_required_screen.dart';
import 'auth0_profile_view.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late AppLinks _appLinks;
  StreamSubscription? _linkSubscription;
  bool _hasCheckedAuth = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasNavigated = false;

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
      
      // If user is authenticated with Auth0, check email verification
      if (auth0User != null) {
        if (kDebugMode) {
          print('WelcomeScreen: Auth0 user is authenticated, checking email verification');
        }
        
        // Check if email verification is required and user is verified
        if (Auth0Service.instance.requiresEmailVerification && !Auth0Service.instance.isEmailVerified) {
          if (kDebugMode) {
            print('WelcomeScreen: Email not verified, showing verification required screen');
          }
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EmailVerificationRequiredScreen(user: auth0User!),
              ),
            );
          }
          return;
        }
        
        if (kDebugMode) {
          print('WelcomeScreen: Auth0 user is authenticated and verified, preparing user context');
        }

        // Ensure UserProvider has a persistent display name/username for this session
        try {
          final username = await SupabaseService.getOrCreateUsername(
            auth0User.email ?? '',
            auth0User.nickname ?? auth0User.name,
          );
          final userProfile = await SupabaseService.getUserProfile();
          final savedDisplayName = userProfile?['display_name'] ??
              username ??
              auth0User.nickname ??
              auth0User.name ??
              auth0User.email?.split('@')[0] ??
              'user';
          if (mounted) {
            final userProvider = Provider.of<UserProvider>(context, listen: false);
            final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
            
            userProvider.setCurrentUser(
              auth0User.sub,
              savedDisplayName,
              auth0User.email ?? '',
            );
            // Refresh app state for user (clears old data and loads new)
            await appStateProvider.refreshForNewUser();
          }
        } catch (e) {
          if (kDebugMode) {
            print('WelcomeScreen: Failed to prepare user context: $e');
          }
        }

        if (kDebugMode) {
          print('WelcomeScreen: Navigating to main app');
        }
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else { // Added else block
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

  // Direct Auth0 login/signup - no second screen needed
  Future<void> _handleAuth0Login() async {
    if (_isLoading) return; // Prevent multiple calls
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kDebugMode) {
        print('WelcomeScreen: Starting Auth0 Universal Login...');
      }

      // Auth0 Universal Login handles both signup and login automatically
      final result = await Auth0Service.instance.signIn();

      if (!mounted || _hasNavigated) return;

      // Get or create username and load saved display name
      final username = await SupabaseService.getOrCreateUsername(
        result.user.email ?? '',
        result.user.nickname ?? result.user.name,
      );
      
      // Get user profile to load saved display name
      final userProfile = await SupabaseService.getUserProfile();
      final savedDisplayName = userProfile?['display_name'] ?? username ?? result.user.nickname ?? result.user.name ?? result.user.email?.split('@')[0] ?? 'user';
      
      // Clear any cached data from previous user and set new user
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      
      userProvider.setCurrentUser(
        result.user.sub,
        savedDisplayName,
        result.user.email ?? '',
      );
      // Refresh app state for new user (clears old data and loads new)
      await appStateProvider.refreshForNewUser();

      if (kDebugMode) {
        print('Auth0 login/signup successful');
        print('Auth0 user: ${result.user.email}');
        print('Auth0 user ID: ${result.user.sub}');
        print('Email verified: ${result.user.isEmailVerified}');
      }

      // Check if email verification is required and enforced
      if (Auth0Service.instance.requiresEmailVerification && !(result.user.isEmailVerified ?? false)) {
        if (kDebugMode) {
          print('WelcomeScreen: Email not verified, showing verification required screen');
        }
        
        if (!mounted || _hasNavigated) return;
        _hasNavigated = true;
        
        // Show email verification required screen
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationRequiredScreen(user: result.user),
          ),
        );
        return;
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
        _errorMessage = 'Login/Signup failed: $e';
      });
      if (kDebugMode) {
        print('WelcomeScreen: Error during Auth0 login: $e');
      }
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
      videoPath: 'lib/assets/backdrop1.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                  'Login or create an account with Auth0',
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
                // Transparent button with white border and text
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: TextButton(
                    onPressed: _isLoading ? null : _handleAuth0Login,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      _isLoading ? 'Signing in...' : 'Login / Sign Up',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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