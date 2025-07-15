import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import '../models/username_reservation.dart';

class UserProvider with ChangeNotifier {
  final Box<User> _userBox = Hive.box<User>('users');
  final Box<UsernameReservation> _usernameBox = Hive.box<UsernameReservation>('usernameReservations');

  List<User> get users => _userBox.values.toList();

  Future<void> addUser(User user) async {
    await _userBox.add(user);
    notifyListeners();
  }

  Future<void> updateUser(int key, User user) async {
    await _userBox.put(key, user);
    notifyListeners();
  }

  Future<void> deleteUser(int key) async {
    await _userBox.delete(key);
    notifyListeners();
  }

  // Username reservation logic
  Future<bool> isUsernameUnique(String username) async {
    UsernameReservation? reserved;
    try {
      reserved = _usernameBox.values.firstWhere(
        (r) => r.username.toLowerCase() == username.toLowerCase(),
      );
    } catch (_) {
      reserved = null;
    }
    return reserved == null;
  }

  Future<void> reserveUsername(String username, String userId, String email) async {
    UsernameReservation? existing;
    try {
      existing = _usernameBox.values.firstWhere((r) => r.userId == userId);
    } catch (_) {
      existing = null;
    }
    if (existing != null) {
      await existing.delete();
    }
    UsernameReservation? taken;
    try {
      taken = _usernameBox.values.firstWhere((r) => r.username.toLowerCase() == username.toLowerCase());
    } catch (_) {
      taken = null;
    }
    if (taken != null) {
      await taken.delete();
    }
    await _usernameBox.add(UsernameReservation(username: username, userId: userId, email: email));
    notifyListeners();
  }

  Future<void> releaseUsername(String username) async {
    UsernameReservation? reservation;
    try {
      reservation = _usernameBox.values.firstWhere((r) => r.username.toLowerCase() == username.toLowerCase());
    } catch (_) {
      reservation = null;
    }
    if (reservation != null) {
      await reservation.delete();
      notifyListeners();
    }
  }

  String? getUserIdByUsername(String username) {
    UsernameReservation? reservation;
    try {
      reservation = _usernameBox.values.firstWhere((r) => r.username.toLowerCase() == username.toLowerCase());
    } catch (_) {
      reservation = null;
    }
    return reservation?.userId;
  }
}
