import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/pet.dart';
import '../models/shopping_item.dart';
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
        url: item.url,
        category: item.category,
        quantity: item.quantity,
        notes: item.notes,
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
      if (mounted) setState(() {});
    }
  }

  Future<void> _addOrEditItem(Pet pet, {ShoppingItem? existingItem}) async {
    String name = existingItem?.name ?? '';
    String url = existingItem?.url ?? '';
    String category = existingItem?.category ?? '';
    int? quantity = existingItem?.quantity;
    String notes = existingItem?.notes ?? '';
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existingItem == null ? 'Add Shopping Item' : 'Edit Shopping Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Item Name'),
                      onChanged: (value) => name = value,
                      controller: TextEditingController(text: name)
                        ..selection = TextSelection.fromPosition(TextPosition(offset: name.length)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: 'URL (Optional)'),
                      onChanged: (value) => url = value,
                      controller: TextEditingController(text: url)
                        ..selection = TextSelection.fromPosition(TextPosition(offset: url.length)),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Category (Optional)'),
                      onChanged: (value) => category = value,
                      controller: TextEditingController(text: category)
                        ..selection = TextSelection.fromPosition(TextPosition(offset: category.length)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Quantity (Optional)'),
                      onChanged: (value) => quantity = int.tryParse(value),
                      controller: TextEditingController(text: quantity?.toString() ?? '')
                        ..selection = TextSelection.fromPosition(TextPosition(offset: (quantity?.toString() ?? '').length)),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                      onChanged: (value) => notes = value,
                      controller: TextEditingController(text: notes)
                        ..selection = TextSelection.fromPosition(TextPosition(offset: notes.length)),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (name.trim().isNotEmpty) {
                      Navigator.pop(context, {
                        'name': name,
                        'url': url.isNotEmpty ? url : null,
                        'category': category.isNotEmpty ? category : null,
                        'quantity': quantity,
                        'notes': notes.isNotEmpty ? notes : null,
                      });
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      final newItem = ShoppingItem(
        name: result['name'],
        isPurchased: existingItem?.isPurchased ?? false,
        url: result['url'],
        category: result['category'],
        quantity: result['quantity'],
        notes: result['notes'],
      );
      final prefs = await SharedPreferences.getInstance();
      final pets = jsonDecode(prefs.getString('pets') ?? '[]') as List;
      if (pets.isNotEmpty) {
        final petData = Pet.fromJson(pets[0]);
        if (existingItem != null) {
          final index = petData.shoppingList.indexWhere((i) => i.name == existingItem.name);
          if (index != -1) petData.shoppingList[index] = newItem;
        } else {
          petData.shoppingList.add(newItem);
        }
        pets[0] = petData.toJson();
        await prefs.setString('pets', jsonEncode(pets));
        if (kDebugMode) {
          print('ShoppingListScreen: ${existingItem == null ? 'Added' : 'Edited'} item ${result['name']}');
        }
      }
      if (mounted) setState(() {});
    }
  }

  Future<void> _deleteItem(Pet pet, ShoppingItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      pet.shoppingList.removeWhere((i) => i.name == item.name);
      final prefs = await SharedPreferences.getInstance();
      final pets = jsonDecode(prefs.getString('posts') ?? '[]') as List;
      if (pets.isNotEmpty) {
        pets[0] = pet.toJson();
        await prefs.setString('pets', jsonEncode(pets));
        if (kDebugMode) {
          print('ShoppingListScreen: Deleted item ${item.name}');
        }
      }
      if (mounted) setState(() {});
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.category != null) Text('Category: ${item.category}'),
                      if (item.quantity != null) Text('Quantity: ${item.quantity}'),
                      if (item.notes != null) Text('Notes: ${item.notes}'),
                      if (item.url != null)
                        GestureDetector(
                          onTap: () => _launchUrl(item.url!),
                          child: Text(
                            item.url!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.isPurchased)
                        const Icon(Icons.check_circle, color: Colors.green)
                      else
                        RoundedButton(
                          text: 'Purchased',
                          onPressed: () => _togglePurchaseStatus(pet, item),
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _addOrEditItem(pet, existingItem: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteItem(pet, item),
                      ),
                    ],
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
            onPressed: () => _addOrEditItem(pet),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}