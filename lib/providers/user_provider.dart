import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

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
      final currentUser = SupabaseService.client.auth.currentUser;
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
}
