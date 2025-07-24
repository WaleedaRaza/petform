import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../services/shopping_service.dart';
import '../models/shopping_item.dart';

class ShoppingProvider with ChangeNotifier {
  List<ShoppingItem> _items = [];

  List<ShoppingItem> get items => _items;

  Future<void> loadItems() async {
    try {
      // For now, use the static shopping service
      final shoppingItems = ShoppingService.getAllProducts();
      _items = shoppingItems;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('ShoppingProvider: Error loading items: $e');
      }
      rethrow;
    }
  }

  Future<void> addItem(ShoppingItem item) async {
    try {
      // For now, just add to local list since we're using static data
      _items.add(item);
    notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('ShoppingProvider: Error adding item: $e');
      }
      rethrow;
    }
  }

  Future<void> updateItem(String id, ShoppingItem item) async {
    try {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index] = item;
    notifyListeners();
  }
    } catch (e) {
      if (kDebugMode) {
        print('ShoppingProvider: Error updating item: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      _items.removeWhere((item) => item.id == id);
    notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('ShoppingProvider: Error deleting item: $e');
      }
      rethrow;
    }
  }

  ShoppingItem? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ShoppingItem> getItemsByCategory(String category) {
    return _items.where((item) => item.category == category).toList();
  }

  List<ShoppingItem> searchItems(String query) {
    return _items.where((item) => 
      item.name.toLowerCase().contains(query.toLowerCase()) ||
      (item.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }
} 