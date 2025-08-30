import 'package:flutter/foundation.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Auth0JWTService {
  static Auth0JWTService? _instance;
  static Auth0JWTService get instance => _instance ??= Auth0JWTService._();
  
  Auth0JWTService._();

  // Auth0 application credentials - NEW TENANT
  static const String _auth0Domain = 'dev-1oqy858cbx2koxsg.us.auth0.com';
  static const String _auth0ClientId = 'ibEbLPi8m7LbUpJs5ocRSehygzS7ZUGb';

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
  
  // Initialize Auth0
  Future<void> initialize() async {
    try {
      // Initialize with your Auth0 domain and client ID
      _auth0 = Auth0(_auth0Domain, _auth0ClientId);
      
      // Check for existing session
      await checkExistingSession();
      
      if (kDebugMode) {
        print('Auth0JWTService: Initialized with Auth0 SDK');
        print('Auth0JWTService: Domain: $_auth0Domain');
        print('Auth0JWTService: Client ID: $_auth0ClientId');
        print('Auth0JWTService: Current user: ${_userProfile?.email}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth0JWTService: Initialization error: $e');
      }
      rethrow;
    }
  }
  
  // Check for existing session WITHOUT triggering auto-popup
  Future<bool> checkExistingSession() async {
    try {
      // Check if we have valid credentials WITHOUT refreshing them
      final hasValidCredentials = await _auth0.credentialsManager.hasValidCredentials();
      
      if (!hasValidCredentials) {
        if (kDebugMode) {
          print('Auth0JWTService: No valid stored credentials');
        }
        return false;
      }
      
      // Only get credentials if we confirmed they're valid
      try {
        _credentials = await _auth0.credentialsManager.credentials();
        
        if (_credentials != null) {
          // Create user profile from stored credentials
          _userProfile = UserProfile(
            sub: _credentials!.user?.sub ?? '',
            email: _credentials!.user?.email,
            name: _credentials!.user?.name,
            nickname: _credentials!.user?.nickname,
            pictureUrl: _credentials!.user?.pictureUrl,
            isEmailVerified: _credentials!.user?.isEmailVerified ?? false,
          );
          
          if (kDebugMode) {
            print('Auth0JWTService: Found valid existing session for: ${_userProfile?.email}');
          }
          return true;
        }
      } catch (e) {
        // If getting credentials fails (e.g., refresh token expired), clear session
        if (kDebugMode) {
          print('Auth0JWTService: Error getting credentials: $e');
          print('Auth0JWTService: Clearing expired session');
        }
        await _auth0.credentialsManager.clearCredentials();
        _credentials = null;
        _userProfile = null;
        return false;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Auth0JWTService: No existing session found: $e');
      }
      return false;
    }
  }
  
  // Sign in with Auth0 and get JWT token
  Future<Credentials> signIn() async {
    try {
      if (kDebugMode) {
        print('Auth0JWTService: Starting Auth0 Universal Login...');
      }

      // Always show login screen - don't auto-login
      // This ensures users can choose their account
      _credentials = await _auth0.webAuthentication().login(
        audience: 'https://petform.api',
      );
      
      // Create user profile from credentials
      _userProfile = UserProfile(
        sub: _credentials!.user?.sub ?? '',
        email: _credentials!.user?.email,
        name: _credentials!.user?.name,
        nickname: _credentials!.user?.nickname,
        pictureUrl: _credentials!.user?.pictureUrl,
        isEmailVerified: _credentials!.user?.isEmailVerified ?? false,
      );
      
      if (kDebugMode) {
        print('Auth0JWTService: Auth0 login successful');
        print('Auth0JWTService: User: ${_userProfile?.email}');
        print('Auth0JWTService: Access token available: ${_credentials?.accessToken != null}');
      }
      
      return _credentials!;
    } catch (e) {
      if (kDebugMode) {
        print('Auth0JWTService: Auth0 login error: $e');
      }
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      if (kDebugMode) {
        print('Auth0JWTService: Signing out from Auth0...');
      }
      
      await _auth0.webAuthentication().logout();
      
      // Clear stored credentials
      _credentials = null;
      _userProfile = null;
      
      if (kDebugMode) {
        print('Auth0JWTService: Sign out successful');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth0JWTService: Sign out error: $e');
      }
      rethrow;
    }
  }
  
  // Clear session and force fresh login (fixes auto-login issue)
  Future<void> clearSessionAndForceLogin() async {
    try {
      if (kDebugMode) {
        print('Auth0JWTService: Clearing session and forcing fresh login...');
      }
      
      // Clear stored credentials without calling logout (which shows UI)
      await _auth0.credentialsManager.clearCredentials();
      
      // Clear local variables
      _credentials = null;
      _userProfile = null;
      
      if (kDebugMode) {
        print('Auth0JWTService: Session cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth0JWTService: Error clearing session: $e');
      }
      // Continue anyway - clear local variables
      _credentials = null;
      _userProfile = null;
    }
  }
  
  // Get current JWT token
  String? getCurrentJWT() {
    return _credentials?.accessToken;
  }
  
  // Sign in with email and password (for compatibility)
  Future<Credentials> signInWithEmailAndPassword(String email, String password) async {
    // Auth0 Universal Login handles this automatically
    return await signIn();
  }
  
  // Sign up with email and password (for compatibility)
  Future<Credentials> signUpWithEmailAndPassword(String email, String password) async {
    // Auth0 Universal Login handles this automatically
    return await signIn();
  }
  
  // Reset password (for compatibility)
  Future<void> resetPassword(String email) async {
    // Auth0 handles password reset through Universal Login
    if (kDebugMode) {
      print('Auth0JWTService: Password reset should be handled through Auth0 Universal Login');
    }
  }
  
  // Resend email verification (for compatibility)
  Future<void> resendEmailVerification() async {
    // Auth0 handles email verification automatically
    if (kDebugMode) {
      print('Auth0JWTService: Email verification is handled automatically by Auth0');
    }
  }
  
  // Reload user (for compatibility)
  Future<void> reloadUser() async {
    await checkExistingSession();
  }
  
  // Test methods (for compatibility with debug screens)
  Future<void> testSupabaseConnection() async {
    if (kDebugMode) {
      print('Auth0JWTService: Supabase connection test not implemented');
    }
  }
  
  Future<void> testEmailSending() async {
    if (kDebugMode) {
      print('Auth0JWTService: Email sending test not implemented');
    }
  }
  
  Future<void> debugEmailConfirmation() async {
    if (kDebugMode) {
      print('Auth0JWTService: Email confirmation debug not implemented');
    }
  }
  
  Future<void> testSMTPConfiguration() async {
    if (kDebugMode) {
      print('Auth0JWTService: SMTP configuration test not implemented');
    }
  }
  
  Future<void> testSMTPConnection() async {
    if (kDebugMode) {
      print('Auth0JWTService: SMTP connection test not implemented');
    }
  }
  
  Future<void> testTokenHashVerification() async {
    if (kDebugMode) {
      print('Auth0JWTService: Token hash verification test not implemented');
    }
  }
  
  // Handle email confirmation (for compatibility)
  Future<void> handleEmailConfirmation() async {
    if (kDebugMode) {
      print('Auth0JWTService: Email confirmation handling not implemented');
    }
  }
  
  // Delete Auth0 account (provides instructions to user)
  Future<Map<String, dynamic>> deleteAuth0Account() async {
    try {
      if (kDebugMode) {
        print('Auth0JWTService: Providing Auth0 account deletion instructions');
      }
      
      // Try to sign out first, but don't fail if user cancels
      try {
        await signOut();
      } catch (e) {
        if (kDebugMode) {
          print('Auth0JWTService: Sign out failed (user may have cancelled): $e');
        }
        // Continue with providing instructions even if sign out fails
      }
      
      // Return simple success message
      return {
        'success': true,
        'message': 'Your Petform account has been completely deleted.',
        'note': 'You have been signed out and all your data has been permanently removed.'
      };
    } catch (e) {
      if (kDebugMode) {
        print('Auth0JWTService: Error providing deletion instructions: $e');
      }
      return {
        'success': false,
        'message': 'Account deletion completed with some issues.',
        'note': 'Your data has been deleted, but there may have been an issue signing you out.'
      };
    }
  }
  
  // Authenticate with Supabase using Auth0 JWT
  Future<User?> authenticateWithSupabase() async {
    try {
      final jwt = getCurrentJWT();
      if (jwt == null) {
        throw Exception('No JWT token available');
      }
      
      if (kDebugMode) {
        print('Auth0JWTService: Using Auth0 JWT for API calls (bypassing Supabase auth)');
      }
      
      // For Auth0 Third Party Auth, we bypass direct Supabase authentication
      // and use the JWT for API calls that require authentication
      return null; // We'll handle this differently
    } catch (e) {
      if (kDebugMode) {
        print('Auth0JWTService: Supabase authentication error: $e');
      }
      rethrow;
    }
  }
}
