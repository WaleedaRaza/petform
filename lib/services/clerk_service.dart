import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/clerk_config.dart';
import '../models/clerk_error.dart';
import 'clerk_token_service.dart';

class ClerkService {
  static ClerkService? _instance;
  static ClerkService get instance => _instance ??= ClerkService._();
  
  ClerkService._();
  
  // Use Clerk configuration
  static const String _secretKey = ClerkConfig.secretKey;
  static const String _baseUrl = ClerkConfig.baseUrl;
  
  String? _sessionToken;
  Map<String, dynamic>? _currentUser;
  
  // Get current user
  Map<String, dynamic>? get currentUser => _currentUser;
  
  // Check if user is signed in
  bool get isSignedIn => _sessionToken != null && _currentUser != null;
  
  // Get user ID
  String? get currentUserId => _currentUser?['id'];
  
  // Get user email
  String? get currentUserEmail {
    final emailAddresses = _currentUser?['email_addresses'] as List?;
    return emailAddresses?.isNotEmpty == true 
        ? emailAddresses!.first['email_address'] 
        : _currentUser?['email_address'];
  }
  
  // Get username
  String? get currentUsername => _currentUser?['username'];
  
  // Get display name
  String? get currentDisplayName => _currentUser?['display_name'];
  
  // Initialize Clerk (check for existing session)
  Future<void> initialize() async {
    try {
      // Check for existing session token in local storage
      // For now, we'll start fresh
      if (kDebugMode) {
        print('ClerkService: Initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ClerkService: Initialization error: $e');
      }
      rethrow;
    }
  }
  
  // Sign up with email
  Future<ClerkApiResponse<Map<String, dynamic>>> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      // For now, let's simulate a successful signup since Clerk's API is complex
      // In a real implementation, you'd use Clerk's client-side SDK
      final mockUser = {
        'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'email_addresses': [
          {
            'email_address': email,
            'id': 'email_${DateTime.now().millisecondsSinceEpoch}',
            'verification': {
              'status': 'unverified',
            },
          }
        ],
        'username': username,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      _currentUser = mockUser;
      
      // Store user data
      await ClerkTokenService.storeUser(mockUser);
      
      // Generate a mock token
      final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      await ClerkTokenService.storeToken(mockToken);
      
      if (kDebugMode) {
        print('ClerkService: Mock sign up successful for: $email');
      }
      return ClerkApiResponse.success(mockUser);
    } catch (e) {
      if (kDebugMode) {
        print('ClerkService: Sign up error: $e');
      }
      return ClerkApiResponse.error([
        ClerkError(
          message: 'Network error: $e',
          code: ClerkErrorCodes.networkError,
        ),
      ]);
    }
  }
  
  // Sign in with email
  Future<ClerkApiResponse<Map<String, dynamic>>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // For now, let's simulate a successful signin
      // In a real implementation, you'd use Clerk's client-side SDK
      if (_currentUser == null) {
        // Create a mock user for signin
        final mockUser = {
          'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
          'email_addresses': [
            {
              'email_address': email,
              'id': 'email_${DateTime.now().millisecondsSinceEpoch}',
              'verification': {
                'status': 'verified',
              },
            }
          ],
          'username': email.split('@')[0],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        _currentUser = mockUser;
        
        // Store user data
        await ClerkTokenService.storeUser(mockUser);
        
        // Generate a mock token
        final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        await ClerkTokenService.storeToken(mockToken);
        
        if (kDebugMode) {
          print('ClerkService: Mock sign in successful for: $email');
        }
        return ClerkApiResponse.success(mockUser);
      } else {
        // User already exists, return current user
        if (kDebugMode) {
          print('ClerkService: Sign in successful for existing user: $email');
        }
        return ClerkApiResponse.success(_currentUser!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('ClerkService: Sign in error: $e');
      }
      return ClerkApiResponse.error([
        ClerkError(
          message: 'Network error: $e',
          code: ClerkErrorCodes.networkError,
        ),
      ]);
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      _sessionToken = null;
      _currentUser = null;
      await ClerkTokenService.clearAll();
      
      if (kDebugMode) {
        print('ClerkService: Sign out successful');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ClerkService: Sign out error: $e');
      }
      rethrow;
    }
  }
  
  // Update user attributes
  Future<void> updateUserAttributes({
    String? username,
    String? displayName,
    String? firstName,
    String? lastName,
  }) async {
    try {
      if (_currentUser == null) throw Exception('No user logged in');
      
      final response = await http.patch(
        Uri.parse('$_baseUrl/users/${_currentUser!['id']}'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (username != null) 'username': username,
          if (displayName != null) 'display_name': displayName,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = data;
        
        if (kDebugMode) {
          print('ClerkService: User attributes updated');
        }
      } else {
        throw Exception('Update failed: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ClerkService: Update user attributes error: $e');
      }
      rethrow;
    }
  }
  
  // Get user profile data
  Map<String, dynamic>? getUserProfile() {
    if (_currentUser == null) return null;
    
    return {
      'id': _currentUser!['id'],
      'email': currentUserEmail,
      'username': currentUsername,
      'firstName': _currentUser!['first_name'],
      'lastName': _currentUser!['last_name'],
      'displayName': currentDisplayName,
      'createdAt': _currentUser!['created_at'],
      'updatedAt': _currentUser!['updated_at'],
    };
  }
  
  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      // This would need to be implemented with your database
      // For now, we'll return true (you'll need to check against your profiles table)
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('ClerkService: Username availability check error: $e');
      }
      return false;
    }
  }
  
  // Create user profile in database
  Future<void> createUserProfile({
    required String email,
    required String username,
    String? displayName,
  }) async {
    try {
      // This would create a profile in your Supabase database
      // You'll need to implement this based on your existing SupabaseService
      if (kDebugMode) {
        print('ClerkService: User profile creation not implemented yet');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ClerkService: Create user profile error: $e');
      }
      rethrow;
    }
  }
  
  // Verify email
  Future<void> verifyEmail(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
        }),
      );
      
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('ClerkService: Email verified successfully');
        }
      } else {
        throw Exception('Email verification failed: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ClerkService: Email verification error: $e');
      }
      rethrow;
    }
  }
} 