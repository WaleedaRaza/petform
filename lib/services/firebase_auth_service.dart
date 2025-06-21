import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is admin
  bool isAdmin(User user) {
    return user.email == 'admin@petform.com' || 
           user.email == 'waleedraza1211@gmail.com';
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
      if (kDebugMode) {
        print('FirebaseAuthService: Attempting to sign up user: $email');
      }
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) {
        print('FirebaseAuthService: User signed up successfully: ${credential.user?.email}');
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthService: Sign up error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
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
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthService: Sign in error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        print('FirebaseAuthService: Attempting Google sign in');
      }
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google sign in was cancelled';
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (kDebugMode) {
        print('FirebaseAuthService: Google sign in successful: ${userCredential.user?.email}');
      }
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthService: Google sign in error: $e');
      }
      rethrow;
    }
  }

  // Sign in with Apple
  Future<UserCredential> signInWithApple() async {
    try {
      if (kDebugMode) {
        print('FirebaseAuthService: Attempting Apple sign in');
      }
      
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      if (kDebugMode) {
        print('FirebaseAuthService: Apple sign in successful: ${userCredential.user?.email}');
      }
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthService: Apple sign in error: $e');
      }
      rethrow;
    }
  }

  // Admin quick login
  Future<UserCredential> adminLogin() async {
    try {
      if (kDebugMode) {
        print('FirebaseAuthService: Attempting admin login');
      }
      
      // Try to sign in with admin credentials
      final credential = await _auth.signInWithEmailAndPassword(
        email: 'admin@petform.com',
        password: 'admin123456',
      );
      
      if (kDebugMode) {
        print('FirebaseAuthService: Admin login successful: ${credential.user?.email}');
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Create admin account if it doesn't exist
        if (kDebugMode) {
          print('FirebaseAuthService: Creating admin account');
        }
        return await _auth.createUserWithEmailAndPassword(
          email: 'admin@petform.com',
          password: 'admin123456',
        );
      }
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
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
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthService: Password reset error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions and convert to user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    if (kDebugMode) {
      print('FirebaseAuthService: Handling auth exception: ${e.code} - ${e.message}');
    }
    
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/Password authentication is not enabled. Please enable it in Firebase Console under Authentication > Sign-in method > Email/Password.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'internal-error':
        return 'Firebase configuration error. Please check your Firebase project setup.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
} 