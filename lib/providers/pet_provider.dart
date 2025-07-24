import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../models/pet.dart';

class PetProvider with ChangeNotifier {
  List<Pet> _pets = [];

  List<Pet> get pets => _pets;

  Future<void> loadPets() async {
    try {
      final pets = await SupabaseService.getPets();
      _pets = pets.map((p) => Pet.fromJson(p)).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('PetProvider: Error loading pets: $e');
      }
      rethrow;
    }
  }

  Future<void> addPet(Pet pet) async {
    try {
      await SupabaseService.createPet(pet.toJson());
      await loadPets(); // Reload pets from database
    } catch (e) {
      if (kDebugMode) {
        print('PetProvider: Error adding pet: $e');
      }
      rethrow;
    }
  }

  Future<void> updatePet(String id, Pet pet) async {
    try {
      await SupabaseService.updatePet(id, pet.toJson());
      await loadPets(); // Reload pets from database
    } catch (e) {
      if (kDebugMode) {
        print('PetProvider: Error updating pet: $e');
      }
      rethrow;
    }
  }

  Future<void> deletePet(String id) async {
    try {
      await SupabaseService.deletePet(id);
      await loadPets(); // Reload pets from database
    } catch (e) {
      if (kDebugMode) {
        print('PetProvider: Error deleting pet: $e');
      }
      rethrow;
    }
  }

  Pet? getPetById(String id) {
    try {
      return _pets.firstWhere((pet) => pet.id == id);
    } catch (_) {
      return null;
    }
  }
} 