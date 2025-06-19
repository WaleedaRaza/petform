import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/pet.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pet Profile')),
      body: FutureBuilder<Pet>(
        future: _loadPet(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error loading pet'));
          }
          final pet = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${pet.name}', style: TextStyle(fontSize: 18)),
                Text('Type: ${pet.type}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                ...pet.fields.entries.map((entry) {
                  return Text('${entry.key}: ${entry.value}', style: TextStyle(fontSize: 16));
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Pet> _loadPet() async {
    final prefs = await SharedPreferences.getInstance();
    final pets = prefs.getString('pets') ?? '[]';
    final petsList = jsonDecode(pets) as List;
    if (petsList.isEmpty) throw Exception('No pet found');
    return Pet.fromJson(petsList.first as Map<String, dynamic>);
  }
}
