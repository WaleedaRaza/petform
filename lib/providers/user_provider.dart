import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/firebase_auth_service.dart';
import '../models/pet.dart';

class UserProvider with ChangeNotifier {
  User? _firebaseUser;
  String? _username;
  List<Pet> _pets = [];
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ApiService _apiService = ApiService();

  User? get firebaseUser => _firebaseUser;
  String? get email => _firebaseUser?.email;
  String? get username => _username;
  List<Pet> get pets => _pets;
  bool get isLoggedIn => _firebaseUser != null;
  FirebaseAuthService get authService => _authService;

  UserProvider() {
    // Listen to Firebase auth state changes
    _authService.authStateChanges.listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _loadUserData();
      } else {
        _clearUserData();
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    try {
      // Load user data from API or local storage
      final prefs = await SharedPreferences.getInstance();
      _username = prefs.getString('user_username');
      _pets = await _apiService.getPets();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('UserProvider: Error loading user data: $e');
      }
    }
  }

  void _clearUserData() {
    _pets = [];
    notifyListeners();
  }

  // Email/Password sign up
  Future<void> signUp(String email, String username, String password) async {
    try {
      // Check if username is unique
      final isUnique = await _apiService.isUsernameUnique(username);
      if (!isUnique) {
        throw Exception('Username "$username" is already taken. Please choose a different username.');
      }
      
      await _authService.signUpWithEmailAndPassword(email, password);
      _username = username;
      
      // Register the username globally
      await _apiService.registerUsername(username, email);
      
      // Save username to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_username', username);
      
      // Initialize user data in API service
      await _apiService.signup(email, password);
      
      if (kDebugMode) {
        print('UserProvider: User signed up and data initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserProvider: Sign up error: $e');
      }
      rethrow;
    }
  }

  // Email/Password sign in
  Future<void> signIn(String email, String password) async {
    try {
      await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      if (kDebugMode) {
        print('UserProvider: Sign in error: $e');
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      // Clear user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_password');
      await prefs.remove('user_username');
      await prefs.remove('user_id');
      
      if (kDebugMode) {
        print('UserProvider: Cleared user data on sign out');
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserProvider: Sign out error: $e');
      }
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      await _authService.deleteAccount();
    } catch (e) {
      if (kDebugMode) {
        print('UserProvider: Delete account error: $e');
      }
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      if (kDebugMode) {
        print('UserProvider: Reset password error: $e');
      }
      rethrow;
    }
  }

  // Add pet
  void addPet(Pet pet) {
    _pets.add(pet);
    notifyListeners();
  }

  // Remove pet
  void removePet(String petId) {
    _pets.removeWhere((pet) => pet.id == petId);
    notifyListeners();
  }

  // Update pet
  void updatePet(Pet updatedPet) {
    final index = _pets.indexWhere((pet) => pet.id == updatedPet.id);
    if (index != -1) {
      _pets[index] = updatedPet;
      notifyListeners();
    }
  }

  // Update username
  Future<void> updateUsername(String newUsername) async {
    final currentUsername = _username;
    final userEmail = _firebaseUser?.email;
    
    if (userEmail == null) {
      throw Exception('No user logged in');
    }
    
    // If username hasn't changed, no need to update
    if (currentUsername == newUsername) {
      return;
    }
    
    // Check if the new username is unique (excluding current user)
    final isUnique = await _apiService.isUsernameUnique(newUsername, currentUserEmail: userEmail);
    if (!isUnique) {
      throw Exception('Username "$newUsername" is already taken. Please choose a different username.');
    }
    
    // Remove old username from global list if it exists
    if (currentUsername != null) {
      await _apiService.removeUsername(currentUsername);
    }
    
    // Update local username
    _username = newUsername;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_username', newUsername);
    
    // Register the new username globally
    await _apiService.registerUsername(newUsername, userEmail);
    
    notifyListeners();
  }
}
