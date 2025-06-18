import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';
import '../widgets/rounded_button.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  Future<Pet> _loadPet() async {
    final prefs = await SharedPreferences.getInstance();
    final pets = prefs.getString('pets') ?? '[]';
    final petsList = jsonDecode(pets) as List;
    if (petsList.isEmpty) throw Exception('No pet found');
    return Pet.fromJson(petsList.first as Map<String, dynamic>);
  }

  Future<void> _togglePurchaseStatus(Pet pet, ShoppingItem item) async {
    final index = pet.shoppingList.indexWhere((i) => i.name == item.name);
    if (index != -1) {
      pet.shoppingList[index] = ShoppingItem(
        name: item.name,
        isPurchased: !item.isPurchased,
      );
      final prefs = await SharedPreferences.getInstance();
      final pets = jsonDecode(prefs.getString('pets') ?? '[]') as List;
      if (pets.isNotEmpty) {
        pets[0] = pet.toJson();
        await prefs.setString('pets', jsonEncode(pets));
        if (kDebugMode) {
          print('ShoppingListScreen: Toggled purchase status for ${item.name}');
        }
      }
      if (mounted) {
        setState(() {}); // Rebuild UI
      }
    }
  }

  Future<void> _addItem(Pet pet) async {
    String name = '';
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Shopping Item'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Item Name'),
            onChanged: (value) => name = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name.trim().isNotEmpty) {
                  Navigator.pop(context, name);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      pet.shoppingList.add(ShoppingItem(name: result, isPurchased: false));
      final prefs = await SharedPreferences.getInstance();
      final pets = jsonDecode(prefs.getString('pets') ?? '[]') as List;
      if (pets.isNotEmpty) {
        pets[0] = pet.toJson();
        await prefs.setString('pets', jsonEncode(pets));
        if (kDebugMode) {
          print('ShoppingListScreen: Added new item $result');
        }
      }
      if (mounted) {
        setState(() {}); // Rebuild UI
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      body: FutureBuilder<Pet>(
        future: _loadPet(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('No pet found'));
          }
          final pet = snapshot.data!;
          if (pet.shoppingList.isEmpty) {
            return const Center(child: Text('No shopping items added yet'));
          }
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: pet.shoppingList.map((item) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(item.name),
                  trailing: item.isPurchased
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : RoundedButton(
                          text: 'Purchased',
                          onPressed: () => _togglePurchaseStatus(pet, item),
                        ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FutureBuilder<Pet>(
        future: _loadPet(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final pet = snapshot.data!;
          return FloatingActionButton(
            onPressed: () => _addItem(pet),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }
}