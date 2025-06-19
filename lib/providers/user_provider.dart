import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/pet.dart';

class UserProvider with ChangeNotifier {
  String? _email;
  List<Pet> _pets = [];
  final ApiService _apiService = ApiService();

  String? get email => _email;
  List<Pet> get pets => _pets;
  bool get isLoggedIn => _email != null;

  Future<void> setUser(String email) async {
    _email = email;
    try {
      _pets = await _apiService.getPets();
      if (kDebugMode) {
        print('UserProvider: Set user $email with ${_pets.length} pets');
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserProvider: Error loading pets: $e');
      }
      _pets = [];
    }
    notifyListeners();
  }

  void clearUser() {
    _email = null;
    _pets = [];
    if (kDebugMode) {
      print('UserProvider: Cleared user');
    }
    notifyListeners();
  }
}