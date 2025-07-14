import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/shopping_item.dart';

class ShoppingProvider with ChangeNotifier {
  final Box<ShoppingItem> _shoppingBox = Hive.box<ShoppingItem>('shoppingItems');

  List<ShoppingItem> get items => _shoppingBox.values.toList();

  Future<void> addItem(ShoppingItem item) async {
    await _shoppingBox.add(item);
    notifyListeners();
  }

  Future<void> updateItem(int key, ShoppingItem item) async {
    await _shoppingBox.put(key, item);
    notifyListeners();
  }

  Future<void> deleteItem(int key) async {
    await _shoppingBox.delete(key);
    notifyListeners();
  }
} 