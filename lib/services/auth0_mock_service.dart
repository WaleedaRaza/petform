import 'package:flutter/foundation.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'clerk_token_service.dart';

class Auth0MockService {
  static Auth0MockService? _instance;
  static Auth0MockService get instance => _instance ??= Auth0MockService._();
  
  Auth0MockService._();
  
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
  
  // Initialize Auth0 (mock)
  Future<void> initialize() async {
    try {
      if (kDebugMode) {
        print('Auth0MockService: Initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth0MockService: Initialization error: $e');
      }
      rethrow;
    }
  }
  
  // Sign up with email and password (mock)
  Future<Credentials> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create mock credentials
      final mockCredentials = Credentials(
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        idToken: 'mock_id_token_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        scope: 'openid profile email',
        tokenType: 'Bearer',
        user: UserProfile(
          sub: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: username ?? email.split('@')[0],
          nickname: username ?? email.split('@')[0],
          pictureUrl: null,
          isEmailVerified: true,
        ),
      );
      
      _credentials = mockCredentials;
      _userProfile = mockCredentials.user;
      
      // Store token securely
      await ClerkTokenService.storeToken(mockCredentials.accessToken);
      
      // Store user data
      await ClerkTokenService.storeUser({
        'id': _userProfile!.sub,
        'email': _userProfile!.email,
        'name': _userProfile!.name,
        'nickname': _userProfile!.nickname,
        'picture': _userProfile!.pictureUrl,
      });
      
      if (kDebugMode) {
        print('Auth0MockService: Mock sign up successful for: $email');
      }
      
      return mockCredentials;
    } catch (e) {
      if (kDebugMode) {
        print('Auth0MockService: Mock sign up error: $e');
      }
      rethrow;
    }
  }
  
  // Sign in with email and password (mock)
  Future<Credentials> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create mock credentials
      final mockCredentials = Credentials(
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        idToken: 'mock_id_token_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        scope: 'openid profile email',
        tokenType: 'Bearer',
        user: UserProfile(
          sub: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: email.split('@')[0],
          nickname: email.split('@')[0],
          pictureUrl: null,
          isEmailVerified: true,
        ),
      );
      
      _credentials = mockCredentials;
      _userProfile = mockCredentials.user;
      
      // Store token securely
      await ClerkTokenService.storeToken(mockCredentials.accessToken);
      
      // Store user data
      await ClerkTokenService.storeUser({
        'id': _userProfile!.sub,
        'email': _userProfile!.email,
        'name': _userProfile!.name,
        'nickname': _userProfile!.nickname,
        'picture': _userProfile!.pictureUrl,
      });
      
      if (kDebugMode) {
        print('Auth0MockService: Mock sign in successful for: $email');
      }
      
      return mockCredentials;
    } catch (e) {
      if (kDebugMode) {
        print('Auth0MockService: Mock sign in error: $e');
      }
      rethrow;
    }
  }
  
  // Sign in with social provider (mock)
  Future<Credentials> signInWithSocial(String connection) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create mock credentials for social login
      final mockCredentials = Credentials(
        accessToken: 'mock_social_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_social_refresh_${DateTime.now().millisecondsSinceEpoch}',
        idToken: 'mock_social_id_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        scope: 'openid profile email',
        tokenType: 'Bearer',
        user: UserProfile(
          sub: 'mock_social_user_${DateTime.now().millisecondsSinceEpoch}',
          email: 'user@example.com',
          name: 'Social User',
          nickname: 'socialuser',
          pictureUrl: 'https://via.placeholder.com/150',
          isEmailVerified: true,
        ),
      );
      
      _credentials = mockCredentials;
      _userProfile = mockCredentials.user;
      
      // Store token securely
      await ClerkTokenService.storeToken(mockCredentials.accessToken);
      
      // Store user data
      await ClerkTokenService.storeUser({
        'id': _userProfile!.sub,
        'email': _userProfile!.email,
        'name': _userProfile!.name,
        'nickname': _userProfile!.nickname,
        'picture': _userProfile!.pictureUrl,
      });
      
      if (kDebugMode) {
        print('Auth0MockService: Mock social sign in successful with: $connection');
      }
      
      return mockCredentials;
    } catch (e) {
      if (kDebugMode) {
        print('Auth0MockService: Mock social sign in error: $e');
      }
      rethrow;
    }
  }
  
  // Sign out (mock)
  Future<void> signOut() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      _credentials = null;
      _userProfile = null;
      await ClerkTokenService.clearAll();
      
      if (kDebugMode) {
        print('Auth0MockService: Mock sign out successful');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth0MockService: Mock sign out error: $e');
      }
      rethrow;
    }
  }
  
  // Check for existing session (mock)
  Future<bool> checkExistingSession() async {
    try {
      final token = await ClerkTokenService.getToken();
      final user = await ClerkTokenService.getUser();
      
      if (token != null && user != null) {
        // Create mock user profile from stored data
        _userProfile = UserProfile(
          sub: user['id'] ?? 'mock_user',
          email: user['email'] ?? 'user@example.com',
          name: user['name'] ?? 'Mock User',
          nickname: user['nickname'] ?? 'mockuser',
          pictureUrl: user['picture'],
          isEmailVerified: true,
        );
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Auth0MockService: Check session error: $e');
      }
      return false;
    }
  }
  
  // Get user profile data (mock)
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