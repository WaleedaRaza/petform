import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/pet.dart';

class PetProvider with ChangeNotifier {
  final Box<Pet> _petBox = Hive.box<Pet>('pets');

  List<Pet> get pets => _petBox.values.toList();

  Future<void> addPet(Pet pet) async {
    await _petBox.add(pet);
    notifyListeners();
  }

  Future<void> updatePet(int key, Pet pet) async {
    await _petBox.put(key, pet);
    notifyListeners();
  }

  Future<void> deletePet(int key) async {
    await _petBox.delete(key);
    notifyListeners();
  }
} 