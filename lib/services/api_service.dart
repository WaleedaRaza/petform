import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';

class ApiService {
  Future<void> signup(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);
    await prefs.setInt('user_id', DateTime.now().millisecondsSinceEpoch);
    await prefs.setString('pets', '[]');
  }

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('user_email');
    final storedPassword = prefs.getString('user_password');
    if (storedEmail != email || storedPassword != password) {
      throw Exception('Invalid credentials');
    }
  }

  Future<List<Pet>> getPets() async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getString('pets') ?? '[]';
    final List<dynamic> petsData = jsonDecode(petsJson);
    return petsData.map((p) => Pet.fromJson(p)).toList();
  }

  Future<void> createPet(Pet pet) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getString('pets') ?? '[]';
    final List<dynamic> petsData = jsonDecode(petsJson);
    final newPet = pet.toJson()..['id'] = petsData.length + 1;
    petsData.add(newPet);
    await prefs.setString('pets', jsonEncode(petsData));
  }
}