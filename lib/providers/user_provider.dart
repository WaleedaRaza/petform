import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../services/auth0_jwt_service.dart'; // Added import for Auth0JWTService

class UserProvider with ChangeNotifier {
  String? _currentUserId;
  String? _currentUsername;
  String? _currentEmail;

  String? get currentUserId => _currentUserId;
  String? get currentUsername => _currentUsername;
  String? get currentEmail => _currentEmail;
  bool get isLoggedIn => _currentUserId != null;

  // Set current user
  void setCurrentUser(String userId, String username, String email) {
    _currentUserId = userId;
    _currentUsername = username;
    _currentEmail = email;
    notifyListeners();
  }

  // Clear current user
  void clearCurrentUser() {
    _currentUserId = null;
    _currentUsername = null;
    _currentEmail = null;
    notifyListeners();
  }

  // Username reservation logic using Supabase
  Future<bool> isUsernameUnique(String username) async {
    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select('username')
          .eq('username', username)
          .single();
      
      // If we get a response, username is taken
      return false;
    } catch (e) {
      // If no response, username is available
      return true;
    }
  }

  Future<void> reserveUsername(String username, String userId, String email) async {
    try {
      // Check if user is currently logged in
      final currentUser = Auth0JWTService.instance.currentUser;
      if (currentUser == null) {
        if (kDebugMode) {
          print('UserProvider: No user logged in, skipping profile creation. Email confirmation may be required.');
        }
        // Store username temporarily for later use when user confirms email
        _currentUsername = username;
        _currentEmail = email;
        notifyListeners();
        return;
      }
      
      // Create profile with username
      await SupabaseService.createProfile(email, username);
      
      // Update current user
      setCurrentUser(userId, username, email);
      
      if (kDebugMode) {
        print('UserProvider: Username reserved successfully: $username');
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserProvider: Error reserving username: $e');
      }
      rethrow;
    }
  }

  Future<void> releaseUsername(String username) async {
    try {
      // This would typically be handled by deleting the profile
      // For now, we'll just clear the current user
      clearCurrentUser();
      
      if (kDebugMode) {
        print('UserProvider: Username released: $username');
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserProvider: Error releasing username: $e');
      }
      rethrow;
    }
  }

  String? getUserIdByUsername(String username) {
    // For now, return current user ID if username matches
    if (_currentUsername?.toLowerCase() == username.toLowerCase()) {
      return _currentUserId;
    }
    return null;
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      return await SupabaseService.getProfile();
    } catch (e) {
      if (kDebugMode) {
        print('UserProvider: Error getting current user profile: $e');
      }
      return null;
    }
  }

  // Update current user profile
  Future<void> updateCurrentUserProfile(Map<String, dynamic> profileData) async {
    try {
      await SupabaseService.updateProfile(profileData);
      
      // Update local state if username or display_name changed
      if (profileData['username'] != null) {
        _currentUsername = profileData['username'];
      }
      
      notifyListeners();
      
      if (kDebugMode) {
        print('UserProvider: Profile updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserProvider: Error updating profile: $e');
      }
      rethrow;
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      final currentUser = Auth0JWTService.instance.currentUser;
      if (currentUser != null) {
        _currentUserId = currentUser.sub;
        _currentEmail = currentUser.email;
        
        // Get username from database first (for persistence)
        String? databaseUsername = await SupabaseService.getCurrentUsername();
        
        if (databaseUsername != null) {
          // Use database username (persistent)
          _currentUsername = databaseUsername;
          if (kDebugMode) {
            print('UserProvider: Using persistent username from database: $databaseUsername');
          }
        } else {
          // No database username - create one from Auth0 data
          final auth0Username = currentUser.nickname ?? currentUser.name ?? _currentEmail?.split('@')[0] ?? 'user';
          
          // Check if this username is available
          bool isAvailable = await SupabaseService.isUsernameAvailable(auth0Username);
          String finalUsername = auth0Username;
          
          // If not available, append numbers until we find an available one
          int counter = 1;
          while (!isAvailable && counter <= 100) {
            finalUsername = '${auth0Username}$counter';
            isAvailable = await SupabaseService.isUsernameAvailable(finalUsername);
            counter++;
          }
          
          if (counter > 100) {
            // Fallback to user ID if we can't find available username
            finalUsername = 'user_${currentUser.sub.substring(0, 8)}';
          }
          
          _currentUsername = finalUsername;
          
          if (kDebugMode) {
            print('UserProvider: Creating new unique username: $finalUsername');
          }
          
          // Create profile with unique username
          if (_currentEmail != null) {
            try {
              await SupabaseService.createProfile(_currentEmail!, finalUsername);
              if (kDebugMode) {
                print('UserProvider: Profile created with unique username: $finalUsername');
              }
            } catch (e) {
              if (kDebugMode) {
                print('UserProvider: Error creating profile: $e');
              }
              // If username was taken between check and creation, try with timestamp
              final timestampUsername = '${auth0Username}_${DateTime.now().millisecondsSinceEpoch}';
              try {
                await SupabaseService.createProfile(_currentEmail!, timestampUsername);
                _currentUsername = timestampUsername;
                if (kDebugMode) {
                  print('UserProvider: Created profile with timestamp username: $timestampUsername');
                }
              } catch (e2) {
                if (kDebugMode) {
                  print('UserProvider: Final fallback failed: $e2');
                }
              }
            }
          }
        }
        
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserProvider: Error loading current user: $e');
      }
    }
  }

  /// Update username (with uniqueness check)
  Future<bool> updateUsername(String newUsername) async {
    try {
      // Check if username is available
      final isAvailable = await SupabaseService.isUsernameAvailable(newUsername);
      if (!isAvailable) {
        if (kDebugMode) {
          print('UserProvider: Username $newUsername is not available');
        }
        return false;
      }
      
      // Update in database
      if (_currentEmail != null) {
        await SupabaseService.createProfile(_currentEmail!, newUsername);
        _currentUsername = newUsername;
        notifyListeners();
        
        if (kDebugMode) {
          print('UserProvider: Username updated to: $newUsername');
        }
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('UserProvider: Error updating username: $e');
      }
      return false;
    }
  }
}
