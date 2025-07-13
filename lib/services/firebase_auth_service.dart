import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Get current user
  auth.User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<auth.User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<auth.UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
      if (kDebugMode) {
        print('FirebaseAuthService: Attempting to sign up user: $email');
      }
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Send email verification
      await credential.user?.sendEmailVerification();
      
      if (kDebugMode) {
        print('FirebaseAuthService: User signed up successfully: ${credential.user?.email}');
        print('FirebaseAuthService: Email verification sent to: ${credential.user?.email}');
      }
      return credential;
    } on auth.FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthService: Sign up error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<auth.UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      if (kDebugMode) {
        print('FirebaseAuthService: Attempting to sign in user: $email');
      }
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) {
        print('FirebaseAuthService: User signed in successfully: ${credential.user?.email}');
      }
      return credential;
    } on auth.FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthService: Sign in error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (kDebugMode) {
        print('FirebaseAuthService: User signed out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthService: Sign out error: $e');
      }
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
      if (kDebugMode) {
        print('FirebaseAuthService: User account deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthService: Delete account error: $e');
      }
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (kDebugMode) {
        print('FirebaseAuthService: Password reset email sent to $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthService: Reset password error: $e');
      }
      rethrow;
    }
  }

  // Check if email is verified
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Reload user to get latest verification status
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      if (kDebugMode) {
        print('FirebaseAuthService: Email verification resent to ${_auth.currentUser?.email}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthService: Resend email verification error: $e');
      }
      rethrow;
    }
  }

  // Update display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      if (kDebugMode) {
        print('FirebaseAuthService: Display name updated to: $displayName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthService: Update display name error: $e');
      }
      rethrow;
    }
  }

  // Handle Firebase auth exceptions
  String _handleAuthException(auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
} 