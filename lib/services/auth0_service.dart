import 'package:flutter/foundation.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import '../config/auth0_config.dart';
import 'clerk_token_service.dart';

class Auth0Service {
  static Auth0Service? _instance;
  static Auth0Service get instance => _instance ??= Auth0Service._();
  
  Auth0Service._();
  
  Auth0? _auth0;
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
      _auth0 = Auth0(
        Auth0Config.domain,
        Auth0Config.clientId,
      );
      
      if (kDebugMode) {
        print('Auth0Service: Initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Initialization error: $e');
      }
      rethrow;
    }
  }
  
  // Sign up with email and password
  Future<Credentials> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      if (_auth0 == null) {
        await initialize();
      }
      
      // For now, we'll use the same login method for both signup and signin
      // Auth0 will handle user creation if the user doesn't exist
      final credentials = await _auth0!.webAuthentication().login(
        username: email,
        password: password,
        connection: 'Username-Password-Authentication',
      );
      
      _credentials = credentials;
      await _loadUserProfile();
      
      // Store token securely
      if (_credentials?.accessToken != null) {
        await ClerkTokenService.storeToken(_credentials!.accessToken!);
      }
      
      if (kDebugMode) {
        print('Auth0Service: Sign up successful for: $email');
      }
      
      return credentials;
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Sign up error: $e');
      }
      rethrow;
    }
  }
  
  // Sign in with email and password
  Future<Credentials> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (_auth0 == null) {
        await initialize();
      }
      
      final credentials = await _auth0!.webAuthentication().login(
        username: email,
        password: password,
        connection: 'Username-Password-Authentication',
      );
      
      _credentials = credentials;
      await _loadUserProfile();
      
      // Store token securely
      if (_credentials?.accessToken != null) {
        await ClerkTokenService.storeToken(_credentials!.accessToken!);
      }
      
      if (kDebugMode) {
        print('Auth0Service: Sign in successful for: $email');
      }
      
      return credentials;
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Sign in error: $e');
      }
      rethrow;
    }
  }
  
  // Sign in with social provider
  Future<Credentials> signInWithSocial(String connection) async {
    try {
      if (_auth0 == null) {
        await initialize();
      }
      
      final credentials = await _auth0!.webAuthentication().login(
        connection: connection,
      );
      
      _credentials = credentials;
      await _loadUserProfile();
      
      // Store token securely
      if (_credentials?.accessToken != null) {
        await ClerkTokenService.storeToken(_credentials!.accessToken!);
      }
      
      if (kDebugMode) {
        print('Auth0Service: Social sign in successful with: $connection');
      }
      
      return credentials;
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Social sign in error: $e');
      }
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      if (_auth0 != null) {
        await _auth0!.webAuthentication().logout();
      }
      
      _credentials = null;
      _userProfile = null;
      await ClerkTokenService.clearAll();
      
      if (kDebugMode) {
        print('Auth0Service: Sign out successful');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Sign out error: $e');
      }
      rethrow;
    }
  }
  
  // Load user profile
  Future<void> _loadUserProfile() async {
    try {
      if (_auth0 != null && _credentials != null) {
        _userProfile = await _auth0!.userProfile();
        
        // Store user data
        if (_userProfile != null) {
          await ClerkTokenService.storeUser({
            'id': _userProfile!.sub,
            'email': _userProfile!.email,
            'name': _userProfile!.name,
            'nickname': _userProfile!.nickname,
            'picture': _userProfile!.pictureUrl,
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Load user profile error: $e');
      }
    }
  }
  
  // Check for existing session
  Future<bool> checkExistingSession() async {
    try {
      final token = await ClerkTokenService.getToken();
      if (token != null && _auth0 != null) {
        // Try to get user profile with existing token
        _userProfile = await _auth0!.userProfile();
        return _userProfile != null;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Check session error: $e');
      }
      return false;
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? nickname,
    String? picture,
  }) async {
    try {
      if (_auth0 == null || _credentials == null) {
        throw Exception('Not authenticated');
      }
      
      // Update user metadata via Auth0 Management API
      // This would require a backend service or Auth0 Actions
      
      if (kDebugMode) {
        print('Auth0Service: Update user profile not implemented yet');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth0Service: Update user profile error: $e');
      }
      rethrow;
    }
  }
  
  // Get user profile data
  Map<String, dynamic>? getUserProfile() {
    if (_userProfile == null) return null;
    
    return {
      'id': _userProfile!.sub,
      'email': _userProfile!.email,
      'name': _userProfile!.name,
      'nickname': _userProfile!.nickname,
      'picture': _userProfile!.pictureUrl,
      'emailVerified': _userProfile!.isEmailVerified,
    };
  }
} 