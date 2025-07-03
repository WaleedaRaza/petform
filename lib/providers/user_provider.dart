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
  bool get isAdmin => _firebaseUser != null && _authService.isAdmin(_firebaseUser!);

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
  Future<void> signUp(String email, String username, String password, [String? profilePhotoBase64]) async {
    try {
      await _authService.signUpWithEmailAndPassword(email, password);
      _username = username;
      // Save username to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_username', username);
      if (profilePhotoBase64 != null) {
        await prefs.setString('user_profile_photo', profilePhotoBase64);
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

  // Google sign in
  Future<void> signInWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      if (kDebugMode) {
        print('UserProvider: Google sign in error: $e');
      }
      rethrow;
    }
  }

  // Apple sign in
  Future<void> signInWithApple() async {
    try {
      await _authService.signInWithApple();
    } catch (e) {
      if (kDebugMode) {
        print('UserProvider: Apple sign in error: $e');
      }
      rethrow;
    }
  }

  // Admin login
  Future<void> adminLogin() async {
    try {
      await _authService.adminLogin();
    } catch (e) {
      if (kDebugMode) {
        print('UserProvider: Admin login error: $e');
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
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
    _username = newUsername;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_username', newUsername);
    notifyListeners();
  }

  // Update profile photo
  Future<void> updateProfilePhoto(String base64Photo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile_photo', base64Photo);
    notifyListeners();
  }
}
