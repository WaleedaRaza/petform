import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import 'welcome_screen.dart';
import '../widgets/rounded_button.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  Future<Pet?> _loadPet() async {
    final prefs = await SharedPreferences.getInstance();
    final pets = prefs.getString('pets') ?? '[]';
    final petsList = jsonDecode(pets) as List;
    if (petsList.isEmpty) return null;
    return Pet.fromJson(petsList.first as Map<String, dynamic>);
  }

  Future<void> _addShoppingItem(BuildContext context, Pet pet) async {
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
      await Provider.of<ApiService>(context, listen: false).updatePet(pet);
      if (kDebugMode) {
        print('ProfileSettingsScreen: Added shopping item $result');
      }
      // Force rebuild
      (context as Element).markNeedsBuild();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<Pet?>(
        future: _loadPet(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final pet = snapshot.data;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User: ${userProvider.email ?? 'N/A'}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (pet != null) ...[
                  Text(
                    'Pet Profile',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Name: ${pet.name}', style: const TextStyle(fontSize: 16)),
                  Text('Species: ${pet.species}', style: const TextStyle(fontSize: 16)),
                  if (pet.breed != null) Text('Breed: ${pet.breed}', style: const TextStyle(fontSize: 16)),
                  if (pet.age != null) Text('Age: ${pet.age}', style: const TextStyle(fontSize: 16)),
                  if (pet.litterType != null) Text('Litter Type: ${pet.litterType}', style: const TextStyle(fontSize: 16)),
                  if (pet.tankSize != null) Text('Tank Size: ${pet.tankSize}', style: const TextStyle(fontSize: 16)),
                  if (pet.cageSize != null) Text('Cage Size: ${pet.cageSize}', style: const TextStyle(fontSize: 16)),
                  if (pet.favoriteToy != null) Text('Favorite Toy: ${pet.favoriteToy}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  const SizedBox(height: 8),
                const Spacer(),
                RoundedButton(
                  text: 'Sign Out',
                  onPressed: () {
                    userProvider.clearUser();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    );
                  },
                ),
              ],
            ]),
          );
        },
      ),
    );
  }
}