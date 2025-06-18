import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';
import '../models/post.dart';
import '../models/tracking_metric.dart';

class ApiService {
  // Five mock posts for the UI foundation
  static final List<Map<String, dynamic>> _mockPosts = [
    {
      'id': 1,
      'title': 'Puppy Training 101',
      'content': 'Start with treats and patience to teach sit and stay.',
      'author': 'DogLover',
      'petType': 'Dog',
      'imageUrl': null,
      'upvotes': 50,
      'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'id': 2,
      'title': 'Cat Scratching Fix',
      'content': 'A tall scratching post saved my couch!',
      'author': 'CatFan',
      'petType': 'Cat',
      'upvotes': 30,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
    {
      'id': 3,
      'title': 'Turtle Tank Setup',
      'content': 'Clean water and UVB light are must-haves.',
      'author': 'TurtleGuru',
      'petType': 'Turtle',
      'upvotes': 20,
      'createdAt': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
    },
    {
      'id': 4,
      'title': 'Dog Park Vibes',
      'content': 'My pup had a blast chasing balls today.',
      'author': 'PetWalker',
      'petType': 'Dog',
      'upvotes': 45,
      'createdAt': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
    },
    {
      'id': 5,
      'title': 'Cat Toy Picks',
      'content': 'My kitty loves feather wands and laser pointers.',
      'author': 'KittyMom',
      'petType': 'Cat',
      'upvotes': 25,
      'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
    },
  ];

  // Default metrics for each pet species
  static final Map<String, List<Map<String, String>>> _defaultMetrics = {
    'Dog': [
      {'name': 'Walking', 'frequency': 'daily'},
      {'name': 'Feeding', 'frequency': 'daily'},
      {'name': 'Grooming', 'frequency': 'weekly'},
    ],
    'Cat': [
      {'name': 'Litter Replacement', 'frequency': 'daily'},
      {'name': 'Feeding', 'frequency': 'daily'},
      {'name': 'Playtime', 'frequency': 'daily'},
    ],
    'Turtle': [
      {'name': 'Water Changes', 'frequency': 'weekly'},
      {'name': 'Feeding', 'frequency': 'daily'},
      {'name': 'UVB Light Check', 'frequency': 'monthly'},
    ],
    'Bird': [
      {'name': 'Cage Cleaning', 'frequency': 'weekly'},
      {'name': 'Feeding', 'frequency': 'daily'},
      {'name': 'Social Interaction', 'frequency': 'daily'},
    ],
  };

  Future<void> signup(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);
    await prefs.setInt('user_id', DateTime.now().millisecondsSinceEpoch);
    await prefs.setString('pets', '[]');
    await prefs.setString('posts', '[]');
  }

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('user_email');
    final storedPassword = prefs.getString('user_password');
    if (storedEmail != email || storedPassword != password) {
      throw Exception('Invalid credentials');
    }
  }

  Future<List<Pet>> getPets() async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getString('pets') ?? '[]';
    final List<dynamic> petsData = jsonDecode(petsJson);
    return petsData.map((p) => Pet.fromJson(p)).toList();
  }

  Future<void> createPet(Pet pet) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getString('pets') ?? '[]';
    final List<dynamic> petsData = jsonDecode(petsJson);
    final defaultMetrics = _defaultMetrics[pet.species] ?? [];
    final newPet = Pet(
      id: petsData.length + 1,
      name: pet.name,
      species: pet.species,
      breed: pet.breed,
      age: pet.age,
      litterType: pet.litterType,
      tankSize: pet.tankSize,
      cageSize: pet.cageSize,
      favoriteToy: pet.favoriteToy,
      metrics: defaultMetrics.map((m) => TrackingMetric(
        id: '${petsData.length + 1}-${m['name']}',
        petId: '${petsData.length + 1}',
        name: m['name'],
        frequency: m['frequency'],
        createdAt: DateTime.now(),
      )).toList(),
      shoppingList: pet.shoppingList,
    );
    petsData.add(newPet.toJson());
    await prefs.setString('pets', jsonEncode(petsData));
  }

  Future<void> updatePet(Pet pet) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getString('pets') ?? '[]';
    final List<dynamic> petsData = jsonDecode(petsJson);
    final index = petsData.indexWhere((p) => p['id'] == pet.id);
    if (index != -1) {
      petsData[index] = pet.toJson();
      await prefs.setString('pets', jsonEncode(petsData));
      if (kDebugMode) {
        print('ApiService.updatePet: Updated pet ${pet.id}');
      }
    } else {
      if (kDebugMode) {
        print('ApiService.updatePet: Pet ${pet.id} not found');
      }
    }
  }

  Future<List<Post>> getPosts({String? petType}) async {
    final posts = _mockPosts.map((p) => Post.fromJson(p)).toList();
    if (kDebugMode) {
      print('ApiService.getPosts: Returning ${posts.length} posts for petType: $petType');
    }
    if (petType == null || petType == 'All') return posts;
    final filteredPosts = posts.where((p) => p.petType == petType).toList();
    if (kDebugMode) {
      print('ApiService.getPosts: Filtered to ${filteredPosts.length} posts for $petType');
    }
    return filteredPosts;
  }
}