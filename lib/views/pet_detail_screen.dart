import 'package:flutter/material.dart';
import 'package:petform/models/pet.dart';

class PetDetailScreen extends StatelessWidget {
  final Pet pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pet.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Species: ${pet.species}'),
            if (pet.breed != null) Text('Breed: ${pet.breed}'),
            if (pet.age != null) Text('Age: ${pet.age}'),
            if (pet.personality != null) Text('Personality: ${pet.personality}'),
            if (pet.foodSource != null) Text('Food Source: ${pet.foodSource}'),
            if (pet.favoritePark != null) Text('Favorite Park: ${pet.favoritePark}'),
            if (pet.leashSource != null) Text('Leash Source: ${pet.leashSource}'),
            if (pet.litterType != null) Text('Litter Type: ${pet.litterType}'),
            if (pet.waterProducts != null) Text('Water Products: ${pet.waterProducts}'),
          ],
        ),
      ),
    );
  }
}