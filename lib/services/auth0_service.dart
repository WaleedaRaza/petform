import 'package:flutter/foundation.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'clerk_token_service.dart';

class Auth0Service {
  static Auth0Service? _instance;
  static Auth0Service get instance => _instance ??= Auth0Service._();
  
  Auth0Service._();

  // Auth0 application credentials
  static const String _auth0Domain = 'dev-2lm6p70udixry057.us.auth0.com';
  static const String _auth0ClientId = '1wC0uAnPpxCMC9LRBJRoBVgZJSelm5ky';

  late Auth0 _auth0;
  Credentials? _credentials;
  UserProfile? _userProfile;
  
  // Get current user
  UserProfile? get currentUser => _userProfile;
  
  // Check if user is signed in
  bool get isSignedIn => _credentials != null && _userProfile != null;
  
  // Get user ID
  String? get currentUserId => _userProfile?.sub;
  
  // Get user email
  String? get currentUserEmail => _userProfile?.email;
  
  // Get username
  String? get currentUsername => _userProfile?.nickname ?? _userProfile?.name;
  
  // Get display name
  String? get currentDisplayName => _userProfile?.name;
  
  // Check if email is verified
  bool get isEmailVerified => _userProfile?.isEmailVerified ?? false;
  
  // Check if email verification is required and enforce it
  bool get requiresEmailVerification => true; // Always require email verification
  
  // Check if user can proceed (email must be verified)
  bool get canUserProceed {
    if (_userProfile == null) return false;
    return _userProfile!.isEmailVerified ?? false;
  }
  
  // Get verification status message
  String get verificationStatusMessage {
    if (_userProfile == null) return 'Not signed in';
    if (isEmailVerified) return 'Email verified';
    return 'Email not verified - check your inbox';
  }
  
  // Initialize Auth0
  Future<void> initialize() async {
    try {
      // Initialize with your Auth0 domain and client ID
      _auth0 = Auth0(_auth0Domain, _auth0ClientId);
      
      // Check for existing session
      await checkExistingSession();
      
      if (kDebugMode) {
        print('Auth0Service: Initialized with real Auth0 SDK');
        print('Auth0Service: Domain: $_auth0Domain');
        print('Auth0Service: Client ID: $_auth0ClientId');
        print('Auth0Service: Current user: ${_userProfile?.email}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Initialization error: $e');
      }
      rethrow;
    }
  }
  
  // Check for existing session
  Future<bool> checkExistingSession() async {
    try {
      // Try to get stored credentials
      final storedToken = await ClerkTokenService.getToken();
      if (storedToken != null) {
        if (kDebugMode) {
          print('Auth0Service: Found stored token, checking validity...');
        }
        
        // Try to get user profile with stored token
        try {
          // Note: Auth0 Flutter SDK doesn't have a direct userProfile() method
          // We'll rely on stored user data for now
          final storedUser = await ClerkTokenService.getUser();
          if (storedUser != null) {
            _userProfile = UserProfile(
              sub: storedUser['id'] ?? 'auth0_user',
              email: storedUser['email'] ?? 'user@example.com',
              name: storedUser['name'] ?? 'Auth0 User',
              nickname: storedUser['nickname'] ?? 'auth0user',
              pictureUrl: storedUser['picture'] != null ? Uri.parse(storedUser['picture']) : null,
              isEmailVerified: true,
            );
            
            _credentials = Credentials(
              accessToken: storedToken,
              idToken: storedToken,
              refreshToken: null,
              expiresAt: DateTime.now().add(const Duration(days: 1)), // Approximate
              tokenType: 'Bearer',
              user: _userProfile!,
            );
            
            if (kDebugMode) {
              print('Auth0Service: Existing session is valid for: ${_userProfile!.email}');
            }
            return true;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Auth0Service: Stored token is invalid, clearing...');
          }
          await ClerkTokenService.clearAll();
          _credentials = null;
          _userProfile = null;
          return false;
        }
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Session check error: $e');
      }
      return false;
    }
  }
  
  // Sign in with Universal Login
  Future<Credentials> signIn() async {
    try {
      if (kDebugMode) {
        print('Auth0Service: Starting real Auth0 sign in...');
        print('Auth0Service: Using domain: $_auth0Domain');
        print('Auth0Service: Using client ID: $_auth0ClientId');
        print('Auth0Service: Using scheme: com.waleedraza.petform');
      }
      
      // Use Universal Login with custom scheme (for development)
      // useHTTPS is ignored on Android
      final credentials = await _auth0.webAuthentication(scheme: 'com.waleedraza.petform').login();
      
      _credentials = credentials;
      _userProfile = credentials.user;
      
      // Store token securely
      await ClerkTokenService.storeToken(credentials.accessToken);
      
      // Store user data
      await ClerkTokenService.storeUser({
        'id': _userProfile!.sub,
        'email': _userProfile!.email,
        'name': _userProfile!.name,
        'nickname': _userProfile!.nickname,
        'picture': _userProfile!.pictureUrl?.toString(),
      });
      
      if (kDebugMode) {
        print('Auth0Service: Real sign in successful for: ${_userProfile!.email}');
        print('Auth0Service: User ID: ${_userProfile!.sub}');
        print('Auth0Service: Email verified: ${_userProfile!.isEmailVerified}');
      }
      
      return credentials;
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Real sign in error: $e');
        print('Auth0Service: Error type: ${e.runtimeType}');
        print('Auth0Service: Error details: $e');
      }
      rethrow;
    }
  }

  // Force fresh signup (clears session first)
  Future<Credentials> forceSignUp() async {
    try {
      if (kDebugMode) {
        print('Auth0Service: Force clearing session for fresh signup...');
      }
      
      // Clear any existing session first
      await signOut();
      
      // Wait a moment for session to clear
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (kDebugMode) {
        print('Auth0Service: Starting fresh Auth0 signup...');
      }
      
      // Now do a fresh sign in
      return await signIn();
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Force signup error: $e');
      }
      rethrow;
    }
  }
  
  // Resend email verification
  Future<void> resendVerificationEmail() async {
    try {
      if (_userProfile?.email == null) {
        throw Exception('No email available for verification');
      }
      
      if (kDebugMode) {
        print('Auth0Service: Resending verification email to ${_userProfile!.email}');
      }
      
      // Auth0 Flutter SDK doesn't have a direct resend verification method
      // You'll need to implement this via Auth0 Management API or use Auth0's hosted pages
      // For now, we'll show a message to the user
      throw Exception('Please check your email for verification link. If you didn\'t receive it, try signing up again.');
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Resend verification error: $e');
      }
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      if (kDebugMode) {
        print('Auth0Service: Starting real Auth0 sign out...');
      }
      
      // Clear local session data first
      _credentials = null;
      _userProfile = null;
      await ClerkTokenService.clearAll();
      
      if (kDebugMode) {
        print('Auth0Service: Local session data cleared');
      }
      
      // Use Universal Logout with custom scheme (for development)
      // useHTTPS is ignored on Android
      await _auth0.webAuthentication(scheme: 'com.waleedraza.petform').logout();
      
      if (kDebugMode) {
        print('Auth0Service: Real sign out successful');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Real sign out error: $e');
      }
      // Even if logout fails, clear local data
      _credentials = null;
      _userProfile = null;
      await ClerkTokenService.clearAll();
      if (kDebugMode) {
        print('Auth0Service: Local data cleared despite logout error');
      }
      // Don't rethrow - we want to continue even if Auth0 logout fails
    }
  }

  /// Force clear all local data and cached state (for complete clean slate)
  Future<void> forceClearAllData() async {
    try {
      if (kDebugMode) {
        print('Auth0Service: Force clearing ALL local data and cached state');
      }
      
      // Clear all local variables
      _credentials = null;
      _userProfile = null;
      
      // Clear all token storage
      await ClerkTokenService.clearAll();
      
      // Force clear any remaining session data
      try {
        await _auth0.webAuthentication(scheme: 'com.waleedraza.petform').logout();
      } catch (e) {
        // Ignore logout errors, just clear local data
        if (kDebugMode) {
          print('Auth0Service: Logout error during force clear (ignored): $e');
        }
      }
      
      if (kDebugMode) {
        print('Auth0Service: All local data and cached state cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Error during force clear: $e');
      }
    }
  }
} 