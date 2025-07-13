import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/shopping_item.dart';

class ShoppingProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = auth.FirebaseAuth.instance;

  Stream<List<ShoppingItem>> get shoppingItems {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('shoppingItems')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShoppingItem.fromJson(doc.data()..['id'] = doc.id))
            .toList());
  }

  Future<void> addShoppingItem(ShoppingItem item) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('shoppingItems')
        .add(item.toJson());
    notifyListeners();
  }

  Future<void> updateShoppingItem(String itemId, ShoppingItem item) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('shoppingItems')
        .doc(itemId)
        .update(item.toJson());
    notifyListeners();
  }

  Future<void> deleteShoppingItem(String itemId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('shoppingItems')
        .doc(itemId)
        .delete();
    notifyListeners();
  }
} 