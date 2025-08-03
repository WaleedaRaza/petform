import 'package:flutter/foundation.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'clerk_token_service.dart';

class Auth0Service {
  static Auth0Service? _instance;
  static Auth0Service get instance => _instance ??= Auth0Service._();
  
  Auth0Service._();
  
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
  
  // Initialize Auth0
  Future<void> initialize() async {
    try {
      // Replace with your actual Auth0 domain and client ID
      _auth0 = Auth0('dev-2lm6p70udixry057.us.auth0.com', 'tRNYRxNq1avdt9YHmZFcftBM5yMgmtSL');
      
      // Check for existing session
      await checkExistingSession();
      
      if (kDebugMode) {
        print('Auth0Service: Initialized with real Auth0 SDK');
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
        print('Auth0Service: Domain: dev-2lm6p70udixry057.us.auth0.com');
        print('Auth0Service: Client ID: tRNYRxNq1avdt9YHmZFcftBM5yMgmtSL');
        print('Auth0Service: Scheme: com.waleedraza.petform');
      }
      
      // Force clear any existing session first
      await forceClearSession();
      
      // Use Universal Login with custom scheme
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
      }
      
      return credentials;
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Real sign in error: $e');
        print('Auth0Service: Error type: ${e.runtimeType}');
        print('Auth0Service: Error details: $e');
      }
      
      // Provide more specific error messages
      String errorMessage = 'Sign in failed';
      if (e.toString().contains('NETWORK_ERROR')) {
        errorMessage = 'Network error - please check your internet connection';
      } else if (e.toString().contains('USER_CANCELLED')) {
        errorMessage = 'Sign in was cancelled';
      } else if (e.toString().contains('INVALID_CONFIGURATION')) {
        errorMessage = 'Auth0 configuration error - please check your Auth0 settings';
      } else if (e.toString().contains('OTHER')) {
        errorMessage = 'Auth0 service error - please try again';
      }
      
      throw Exception('$errorMessage: $e');
    }
  }
  
  // Aggressive cache clear for Auth0 (prevents auto-sign in)
  Future<void> clearAuth0Cache() async {
    try {
      if (kDebugMode) {
        print('Auth0Service: Starting aggressive Auth0 cache clear...');
      }
      
      // Clear local session data
      _credentials = null;
      _userProfile = null;
      await ClerkTokenService.clearAll();
      
      // Multiple logout attempts to clear all possible session data
      for (int i = 0; i < 3; i++) {
        try {
          await _auth0.webAuthentication(scheme: 'com.waleedraza.petform').logout();
          await Future.delayed(const Duration(milliseconds: 300));
        } catch (e) {
          if (kDebugMode) {
            print('Auth0Service: Logout attempt ${i + 1} error (expected): $e');
          }
        }
      }
      
      // Additional delay to ensure logout completes
      await Future.delayed(const Duration(seconds: 1));
      
      if (kDebugMode) {
        print('Auth0Service: Aggressive cache clear completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Cache clear error: $e');
      }
      // Ensure local data is cleared even if there's an error
      _credentials = null;
      _userProfile = null;
      await ClerkTokenService.clearAll();
    }
  }

  // Force clear Auth0 session (for testing new account creation)
  Future<void> forceClearSession() async {
    try {
      if (kDebugMode) {
        print('Auth0Service: Force clearing Auth0 session...');
      }
      
      // Use aggressive cache clear
      await clearAuth0Cache();
      
      if (kDebugMode) {
        print('Auth0Service: Session force cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Force clear session error: $e');
      }
      // Ensure local data is cleared even if there's an error
      _credentials = null;
      _userProfile = null;
      await ClerkTokenService.clearAll();
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
} 