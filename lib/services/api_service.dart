import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';
import '../models/post.dart';

class ApiService {
  // Five mock posts for the UI foundation
  static final List<Map<String, dynamic>> _mockPosts = [
    {
      'id': 1,
      'title': 'Puppy Training 101',
      'content': 'Start with treats and patience to teach sit and stay.',
      'author': 'DogLover',
      'petType': 'Dog',
      'imageUrl': null, // No images for mock posts
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

  Future<void> signup(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);
    await prefs.setInt('user_id', DateTime.now().millisecondsSinceEpoch);
    await prefs.setString('pets', '[]');
    await prefs.setString('posts', '[]'); // Initialize posts storage
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
    final newPet = pet.toJson()..['id'] = petsData.length + 1;
    petsData.add(newPet);
    await prefs.setString('pets', jsonEncode(petsData));
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