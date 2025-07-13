import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = auth.FirebaseAuth.instance;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  Future<User?> getUserProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return User.fromJson(doc.data()!);
  }

  Future<void> setUserProfile(User user) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore.collection('users').doc(userId).set(user.toJson());
    notifyListeners();
  }

  Future<void> updateUserProfile(User user) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore.collection('users').doc(userId).update(user.toJson());
    notifyListeners();
  }

  // Username management methods
  Future<bool> isUsernameUnique(String username) async {
    final normalizedUsername = username.toLowerCase();
    final query = await _firestore
        .collection('username_reservations')
        .where('username', isEqualTo: normalizedUsername)
        .get();
    return query.docs.isEmpty;
  }

  Future<void> reserveUsername(String username, String userId, String email) async {
    final normalizedUsername = username.toLowerCase();
    await _firestore.collection('username_reservations').doc(normalizedUsername).set({
      'username': normalizedUsername,
      'userId': userId,
      'email': email,
      'reservedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> releaseUsername(String username) async {
    final normalizedUsername = username.toLowerCase();
    await _firestore.collection('username_reservations').doc(normalizedUsername).delete();
  }

  Future<void> updateUsername(String oldUsername, String newUsername, String userId) async {
    final normalizedOldUsername = oldUsername.toLowerCase();
    final normalizedNewUsername = newUsername.toLowerCase();
    
    // Release old username
    await releaseUsername(normalizedOldUsername);
    
    // Reserve new username
    await _firestore.collection('username_reservations').doc(normalizedNewUsername).set({
      'username': normalizedNewUsername,
      'userId': userId,
      'reservedAt': FieldValue.serverTimestamp(),
    });
  }
}
