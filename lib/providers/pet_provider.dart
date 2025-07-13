import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/pet.dart';

class PetProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = auth.FirebaseAuth.instance;

  // Stream of pets for real-time updates
  Stream<List<Pet>> get pets {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pet.fromJson(doc.data()..['id'] = doc.id))
            .toList());
  }

  Future<void> addPet(Pet pet) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .add(pet.toJson());
    notifyListeners();
  }

  Future<void> updatePet(String petId, Pet pet) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(petId)
        .update(pet.toJson());
    notifyListeners();
  }

  Future<void> deletePet(String petId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(petId)
        .delete();
    notifyListeners();
  }
} 