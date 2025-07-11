import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pet.dart';
import '../models/post.dart';
import 'package:http/http.dart' as http;
import '../models/reddit_post.dart';

class ApiService {
  static final List<Map<String, dynamic>> _mockPosts = [
    {
      'id': '2',
      'title': 'Cat Scratching Fix',
      'content': 'A tall scratching post saved my couch! My cat loves it and no more damage to furniture.',
      'author': 'CatFan',
      'petType': 'Cat',
      'upvotes': 30,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'postType': 'community',
      'redditUrl': null,
      'imageUrl': 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
      'comments': [
        {'id': 1, 'content': 'Great tip! I need to try this.', 'author': 'User1', 'createdAt': DateTime.now().toIso8601String()},
      ],
    },
    {
      'id': '4',
      'title': 'Dog Park Vibes',
      'content': 'My pup had a blast chasing balls today. The new dog park in town is amazing!',
      'author': 'PetWalker',
      'petType': 'Dog',
      'upvotes': 45,
      'createdAt': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
      'postType': 'community',
      'redditUrl': null,
      'imageUrl': 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=300&fit=crop',
      'comments': [],
    },
    {
      'id': '5',
      'title': 'Cat Toy Picks',
      'content': 'My kitty loves feather wands and laser pointers. Any other toy recommendations?',
      'author': 'KittyMom',
      'petType': 'Cat',
      'upvotes': 25,
      'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      'postType': 'community',
      'redditUrl': null,
      'imageUrl': 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400&h=300&fit=crop',
      'comments': [],
    },
    {
      'id': '6',
      'title': 'Turtle Tank Maintenance',
      'content': 'Just cleaned my turtle\'s tank and added new plants. The water quality is perfect now!',
      'author': 'TurtleGuru',
      'petType': 'Turtle',
      'upvotes': 18,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'postType': 'community',
      'redditUrl': null,
      'imageUrl': 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&h=300&fit=crop',
      'comments': [],
    },
    {
      'id': '7',
      'title': 'Hamster Cage Setup',
      'content': 'Built a multi-level hamster cage with tunnels and hideouts. My hamster is so happy!',
      'author': 'HamsterLover',
      'petType': 'Hamster',
      'upvotes': 22,
      'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      'postType': 'community',
      'redditUrl': null,
      'imageUrl': 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=400&h=300&fit=crop',
      'comments': [],
    },
  ];

  // Helper method to get user-specific storage keys
  String _getUserKey(String baseKey) {
    final prefs = SharedPreferences.getInstance();
    // For now, we'll use a simple approach - in a real app, you'd get the current user
    // This is a temporary solution until we implement proper user session management
    return 'user_$baseKey';
  }

  // Helper method to get current user email from Firebase Auth
  Future<String?> _getCurrentUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (kDebugMode) {
        print('ApiService._getCurrentUserEmail: No Firebase user found');
      }
      return null;
    }
    if (kDebugMode) {
      print('ApiService._getCurrentUserEmail: Found Firebase user: ${user.email}');
    }
    return user.email;
  }

  // Helper method to get user-specific key with email
  Future<String> _getUserSpecificKey(String baseKey) async {
    final userEmail = await _getCurrentUserEmail();
    if (userEmail == null) {
      throw Exception('No user logged in');
    }
    // Sanitize email for use as key (replace @ and . with _)
    final sanitizedEmail = userEmail.replaceAll('@', '_at_').replaceAll('.', '_');
    return '${sanitizedEmail}_$baseKey';
  }

  Future<void> signup(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Initialize user-specific storage for pets
    final petsKey = await _getUserSpecificKey('pets');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(petsKey, '[]');
    
    // Initialize global posts storage (shared across all users)
    final globalPostsKey = 'global_posts';
    if (prefs.getString(globalPostsKey) == null) {
      // Only initialize global posts if they don't exist yet - START EMPTY
      await prefs.setString(globalPostsKey, jsonEncode([]));
      if (kDebugMode) {
        print('ApiService.signup: Initialized global posts with empty array');
      }
    }
    
    if (kDebugMode) {
      print('ApiService.signup: User $email signed up, initialized pets');
      print('ApiService.signup: Using pets key: $petsKey');
      print('ApiService.signup: Global posts key: $globalPostsKey');
    }
  }

  // Check if username is unique
  Future<bool> isUsernameUnique(String username, {String? currentUserEmail}) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final usernamesKey = 'global_usernames';
    final usernamesJson = prefs.getString(usernamesKey);
    
    List<String> usernames;
    if (usernamesJson == null || usernamesJson.isEmpty || usernamesJson == '[]') {
      usernames = [];
    } else {
      usernames = List<String>.from(jsonDecode(usernamesJson));
    }
    
    // Check if username exists
    final usernameExists = usernames.contains(username.toLowerCase());
    
    if (usernameExists && currentUserEmail != null) {
      // If username exists, check if it belongs to the current user
      final existingEmail = await getEmailByUsername(username);
      if (existingEmail == currentUserEmail) {
        // Username belongs to current user, so it's considered "unique" for them
        if (kDebugMode) {
          print('ApiService.isUsernameUnique: Username "$username" belongs to current user');
        }
        return true;
      }
    }
    
    final isUnique = !usernameExists;
    
    if (kDebugMode) {
      print('ApiService.isUsernameUnique: Checking username "$username"');
      print('ApiService.isUsernameUnique: Existing usernames: $usernames');
      print('ApiService.isUsernameUnique: Is unique: $isUnique');
    }
    
    return isUnique;
  }

  // Register a username (add to global list)
  Future<void> registerUsername(String username, String email) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final usernamesKey = 'global_usernames';
    final usernamesJson = prefs.getString(usernamesKey);
    
    List<String> usernames;
    if (usernamesJson == null || usernamesJson.isEmpty || usernamesJson == '[]') {
      usernames = [];
    } else {
      usernames = List<String>.from(jsonDecode(usernamesJson));
    }
    
    // Add username to the list (store in lowercase for case-insensitive comparison)
    usernames.add(username.toLowerCase());
    await prefs.setString(usernamesKey, jsonEncode(usernames));
    
    // Also store username-to-email mapping for future reference
    final usernameMappingKey = 'global_username_mapping';
    final mappingJson = prefs.getString(usernameMappingKey);
    
    Map<String, String> usernameMapping;
    if (mappingJson == null || mappingJson.isEmpty || mappingJson == '{}') {
      usernameMapping = {};
    } else {
      usernameMapping = Map<String, String>.from(jsonDecode(mappingJson));
    }
    
    usernameMapping[username.toLowerCase()] = email;
    await prefs.setString(usernameMappingKey, jsonEncode(usernameMapping));
    
    if (kDebugMode) {
      print('ApiService.registerUsername: Registered username "$username" for email $email');
      print('ApiService.registerUsername: Total usernames: ${usernames.length}');
    }
  }

  // Remove a username from the global list
  Future<void> removeUsername(String username) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final usernamesKey = 'global_usernames';
    final usernamesJson = prefs.getString(usernamesKey);
    
    List<String> usernames;
    if (usernamesJson == null || usernamesJson.isEmpty || usernamesJson == '[]') {
      return; // Nothing to remove
    } else {
      usernames = List<String>.from(jsonDecode(usernamesJson));
    }
    
    // Remove username from the list (case-insensitive)
    usernames.remove(username.toLowerCase());
    await prefs.setString(usernamesKey, jsonEncode(usernames));
    
    // Also remove from username-to-email mapping
    final usernameMappingKey = 'global_username_mapping';
    final mappingJson = prefs.getString(usernameMappingKey);
    
    if (mappingJson != null && mappingJson.isNotEmpty && mappingJson != '{}') {
      Map<String, String> usernameMapping = Map<String, String>.from(jsonDecode(mappingJson));
      usernameMapping.remove(username.toLowerCase());
      await prefs.setString(usernameMappingKey, jsonEncode(usernameMapping));
    }
    
    if (kDebugMode) {
      print('ApiService.removeUsername: Removed username "$username"');
      print('ApiService.removeUsername: Remaining usernames: ${usernames.length}');
    }
  }

  // Get email by username
  Future<String?> getEmailByUsername(String username) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final usernameMappingKey = 'global_username_mapping';
    final mappingJson = prefs.getString(usernameMappingKey);
    
    if (mappingJson == null || mappingJson.isEmpty || mappingJson == '{}') {
      return null;
    }
    
    final usernameMapping = Map<String, String>.from(jsonDecode(mappingJson));
    return usernameMapping[username.toLowerCase()];
  }

  // Debug method to list all usernames
  Future<List<String>> getAllUsernames() async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final usernamesKey = 'global_usernames';
    final usernamesJson = prefs.getString(usernamesKey);
    
    List<String> usernames;
    if (usernamesJson == null || usernamesJson.isEmpty || usernamesJson == '[]') {
      usernames = [];
    } else {
      usernames = List<String>.from(jsonDecode(usernamesJson));
    }
    
    if (kDebugMode) {
      print('ApiService.getAllUsernames: Found ${usernames.length} usernames: $usernames');
    }
    
    return usernames;
  }

  // Debug method to clear all usernames (for testing)
  Future<void> clearAllUsernames() async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('global_usernames');
    await prefs.remove('global_username_mapping');
    
      if (kDebugMode) {
      print('ApiService.clearAllUsernames: Cleared all usernames and mappings');
    }
  }

  // Clean up duplicate usernames
  Future<void> cleanupDuplicateUsernames() async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final usernamesKey = 'global_usernames';
    final usernamesJson = prefs.getString(usernamesKey);
    
    if (usernamesJson == null || usernamesJson.isEmpty || usernamesJson == '[]') {
      return; // Nothing to clean up
    }
    
    List<String> usernames = List<String>.from(jsonDecode(usernamesJson));
    final originalCount = usernames.length;
    
    // Remove duplicates while preserving order
    final uniqueUsernames = <String>[];
    for (final username in usernames) {
      if (!uniqueUsernames.contains(username)) {
        uniqueUsernames.add(username);
      }
    }
    
    // Update the stored list
    await prefs.setString(usernamesKey, jsonEncode(uniqueUsernames));
    
    // Also clean up the mapping to remove any orphaned entries
    final usernameMappingKey = 'global_username_mapping';
    final mappingJson = prefs.getString(usernameMappingKey);
    
    if (mappingJson != null && mappingJson.isNotEmpty && mappingJson != '{}') {
      Map<String, String> usernameMapping = Map<String, String>.from(jsonDecode(mappingJson));
      
      // Remove mappings for usernames that no longer exist
      final keysToRemove = <String>[];
      for (final key in usernameMapping.keys) {
        if (!uniqueUsernames.contains(key)) {
          keysToRemove.add(key);
        }
      }
      
      for (final key in keysToRemove) {
        usernameMapping.remove(key);
      }
      
      await prefs.setString(usernameMappingKey, jsonEncode(usernameMapping));
    }
    
    if (kDebugMode) {
      print('ApiService.cleanupDuplicateUsernames: Removed ${originalCount - uniqueUsernames.length} duplicate usernames');
      print('ApiService.cleanupDuplicateUsernames: Original count: $originalCount, New count: ${uniqueUsernames.length}');
      print('ApiService.cleanupDuplicateUsernames: Clean usernames: $uniqueUsernames');
    }
  }

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    // Firebase Auth handles the actual authentication
    // This method is kept for compatibility but doesn't need to validate credentials
    if (kDebugMode) {
      print('ApiService.login: User $email logged in via Firebase');
    }
  }

  Future<List<Pet>> getPets() async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final petsKey = await _getUserSpecificKey('pets');
    final petsJson = prefs.getString(petsKey) ?? '[]';
    if (kDebugMode) {
      print('ApiService.getPets: Retrieved pets JSON: $petsJson');
      print('ApiService.getPets: Using key: $petsKey');
    }
    try {
      final List<dynamic> petsData = jsonDecode(petsJson);
      final pets = petsData.map((p) => Pet.fromJson(p)).toList();
      if (kDebugMode) {
        print('ApiService.getPets: Loaded ${pets.length} pets');
        for (var pet in pets) {
          print('ApiService.getPets: Pet ${pet.name}');
        }
      }
      return pets;
    } catch (e) {
      if (kDebugMode) {
        print('ApiService.getPets: Error decoding pets: $e');
      }
      return [];
    }
  }

  Future<void> createPet(Pet pet) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final petsKey = await _getUserSpecificKey('pets');
    final petsJson = prefs.getString(petsKey) ?? '[]';
    final List<dynamic> petsData = jsonDecode(petsJson);
    final newPet = Pet(
      id: pet.id ?? (petsData.length + 1),
      name: pet.name,
      species: pet.species,
      breed: pet.breed,
      age: pet.age,
      personality: pet.personality,
      foodSource: pet.foodSource,
      favoritePark: pet.favoritePark,
      leashSource: pet.leashSource,
      litterType: pet.litterType,
      waterProducts: pet.waterProducts,
      tankSize: pet.tankSize,
      cageSize: pet.cageSize,
      favoriteToy: pet.favoriteToy,
      customFields: pet.customFields,
      shoppingList: pet.shoppingList,
      trackingMetrics: pet.trackingMetrics,
    );
    petsData.add(newPet.toJson());
    await prefs.setString(petsKey, jsonEncode(petsData));
    if (kDebugMode) {
      print('ApiService.createPet: Created pet ${newPet.name}');
      print('ApiService.createPet: Using key: $petsKey');
    }
  }

  Future<void> updatePet(Pet pet) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final petsKey = await _getUserSpecificKey('pets');
    final petsJson = prefs.getString(petsKey) ?? '[]';
    final List<dynamic> petsData = jsonDecode(petsJson);
    final index = petsData.indexWhere((p) => p['id'] == pet.id);
    if (index != -1) {
      petsData[index] = pet.toJson();
      await prefs.setString(petsKey, jsonEncode(petsData));
      if (kDebugMode) {
        print('ApiService.updatePet: Updated pet ${pet.id}');
        print('ApiService.updatePet: Using key: $petsKey');
      }
    } else {
      if (kDebugMode) {
        print('ApiService.updatePet: Pet ${pet.id} not found');
      }
    }
  }

  Future<void> deletePet(int petId) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final petsKey = await _getUserSpecificKey('pets');
    final petsJson = prefs.getString(petsKey) ?? '[]';
    final List<dynamic> petsData = jsonDecode(petsJson);
    final index = petsData.indexWhere((p) => p['id'] == petId);
    if (index != -1) {
      petsData.removeAt(index);
      await prefs.setString(petsKey, jsonEncode(petsData));
      if (kDebugMode) {
        print('ApiService.deletePet: Deleted pet $petId');
        print('ApiService.deletePet: Using key: $petsKey');
      }
    } else {
      if (kDebugMode) {
        print('ApiService.deletePet: Pet $petId not found');
      }
    }
  }

  Future<void> clearAllPets() async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final petsKey = await _getUserSpecificKey('pets');
    await prefs.setString(petsKey, '[]');
    if (kDebugMode) {
      print('ApiService.clearAllPets: Cleared all pets');
      print('ApiService.clearAllPets: Using key: $petsKey');
    }
  }

  Future<List<Post>> getPosts({String? petType, String? postType}) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    // Use global posts key for community posts (shared across all users)
    final postsKey = 'global_posts';
    final postsJson = prefs.getString(postsKey);
    
    List<dynamic> postsData;
    if (postsJson == null || postsJson.isEmpty || postsJson == '[]') {
      // If no posts exist, return empty array - DON'T WRITE TO STORAGE
      postsData = [];
      if (kDebugMode) {
        print('ApiService.getPosts: No posts found, returning empty array');
      }
    } else {
      postsData = jsonDecode(postsJson);
    }
    
    var posts = postsData.map((p) => Post.fromJson(p)).toList();
    if (petType != null) {
      posts = posts.where((p) => p.petType == petType).toList();
    }
    if (postType != null) {
      posts = posts.where((p) => p.postType == postType.toLowerCase()).toList();
    }
    if (kDebugMode) {
      print('ApiService.getPosts: Returning ${posts.length} posts for petType: $petType, postType: $postType');
      print('ApiService.getPosts: Using global key: $postsKey');
      print('ApiService.getPosts: Raw posts JSON length: ${postsJson?.length ?? 0}');
      print('ApiService.getPosts: All posts:');
      for (final post in posts) {
        print('  - ${post.title} by ${post.author} (ID: ${post.id})');
      }
    }
    return posts;
  }

  Future<void> createPost({
    required String title,
    required String content,
    required String petType,
    required String author,
    String? imageUrl,
    String? imageBase64,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    // Use global posts key for community posts (shared across all users)
    final postsKey = 'global_posts';
    final postsJson = prefs.getString(postsKey);
    
    List<dynamic> postsData;
    if (postsJson == null || postsJson.isEmpty || postsJson == '[]') {
      // If no posts exist, start with empty array
      postsData = [];
      if (kDebugMode) {
        print('ApiService.createPost: No existing posts, starting fresh');
      }
    } else {
      postsData = jsonDecode(postsJson);
    }
    
    // Generate a unique ID using timestamp and microseconds
    final now = DateTime.now();
    final uniqueId = '${now.millisecondsSinceEpoch}_${now.microsecond}';
    
    // Handle image URL - use base64 if provided, otherwise use imageUrl
    String? finalImageUrl;
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      finalImageUrl = 'data:image/jpeg;base64,$imageBase64';
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      finalImageUrl = imageUrl;
    }
    
    final newPost = Post(
      id: uniqueId,
      title: title,
      content: content,
      author: author,
      petType: petType,
      imageUrl: finalImageUrl,
      upvotes: 0,
      createdAt: DateTime.now(),
      editedAt: null,
      postType: 'community',
      redditUrl: null,
    );
    postsData.add(newPost.toJson());
    await prefs.setString(postsKey, jsonEncode(postsData));
    if (kDebugMode) {
      print('ApiService.createPost: Created post ${newPost.id}');
      print('ApiService.createPost: Using global key: $postsKey');
      print('ApiService.createPost: Post title: $title');
      print('ApiService.createPost: Post author: $author');
      print('ApiService.createPost: Total posts after creation: ${postsData.length}');
      // Verify the post was saved by reading it back
      final verifyJson = prefs.getString(postsKey);
      final verifyData = jsonDecode(verifyJson!);
      print('ApiService.createPost: Verification - stored posts count: ${verifyData.length}');
      print('ApiService.createPost: Verification - latest post: ${verifyData.last['title']}');
    }
  }

  Future<void> addComment({
    required String postId,
    required String content,
    required String author,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    // Use global posts key for community posts (shared across all users)
    final postsKey = 'global_posts';
    final postsJson = prefs.getString(postsKey);
    
    List<dynamic> postsData;
    if (postsJson == null || postsJson.isEmpty || postsJson == '[]') {
      postsData = [];
    } else {
      postsData = jsonDecode(postsJson);
    }
    final index = postsData.indexWhere((p) => p['id'].toString() == postId);
    if (index != -1) {
      final post = Post.fromJson(postsData[index]);
      final newComment = Comment(
        id: post.comments.length + 1,
        content: content,
        author: author,
        createdAt: DateTime.now(),
      );
      post.comments.add(newComment);
      postsData[index] = post.toJson();
      await prefs.setString(postsKey, jsonEncode(postsData));
      if (kDebugMode) {
        print('ApiService.addComment: Added comment to post $postId');
        print('ApiService.addComment: Using global key: $postsKey');
      }
    }
  }

  Future<void> deleteComment({
    required String postId,
    required int commentId,
    required String author, // To verify the user can delete this comment
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    // Use global posts key for community posts (shared across all users)
    final postsKey = 'global_posts';
    final postsJson = prefs.getString(postsKey);
    
    List<dynamic> postsData;
    if (postsJson == null || postsJson.isEmpty || postsJson == '[]') {
      postsData = [];
    } else {
      postsData = jsonDecode(postsJson);
    }
    final index = postsData.indexWhere((p) => p['id'].toString() == postId);
    if (index != -1) {
      final post = Post.fromJson(postsData[index]);
      // Find and remove the comment if the author matches
      final commentIndex = post.comments.indexWhere((c) => c.id == commentId && c.author == author);
      if (commentIndex != -1) {
        post.comments.removeAt(commentIndex);
        postsData[index] = post.toJson();
        await prefs.setString(postsKey, jsonEncode(postsData));
        if (kDebugMode) {
          print('ApiService.deleteComment: Deleted comment $commentId from post $postId');
          print('ApiService.deleteComment: Using global key: $postsKey');
        }
      } else {
        if (kDebugMode) {
          print('ApiService.deleteComment: Comment not found or user not authorized to delete');
        }
      }
    }
  }

  Future<void> deletePost({
    required String postId,
    required String author, // To verify the user can delete this post
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    // Use global posts key for community posts (shared across all users)
    final postsKey = 'global_posts';
    final postsJson = prefs.getString(postsKey);
    
    List<dynamic> postsData;
    if (postsJson == null || postsJson.isEmpty || postsJson == '[]') {
      postsData = [];
    } else {
      postsData = jsonDecode(postsJson);
    }
    final index = postsData.indexWhere((p) => p['id'].toString() == postId);
    if (index != -1) {
      final post = Post.fromJson(postsData[index]);
      // Only allow deletion if the user is the author of the post
      if (post.author == author) {
        postsData.removeAt(index);
        await prefs.setString(postsKey, jsonEncode(postsData));
        if (kDebugMode) {
          print('ApiService.deletePost: Deleted post $postId by author $author');
          print('ApiService.deletePost: Using global key: $postsKey');
        }
      } else {
        if (kDebugMode) {
          print('ApiService.deletePost: User not authorized to delete this post');
        }
        throw Exception('You can only delete your own posts');
      }
    } else {
      if (kDebugMode) {
        print('ApiService.deletePost: Post $postId not found');
      }
      throw Exception('Post not found');
    }
  }

  Future<Post> getPost(String postId) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    // Use global posts key for community posts (shared across all users)
    final postsKey = 'global_posts';
    final postsJson = prefs.getString(postsKey);
    
    List<dynamic> postsData;
    if (postsJson == null || postsJson.isEmpty || postsJson == '[]') {
      postsData = [];
    } else {
      postsData = jsonDecode(postsJson);
    }
    final postData = postsData.firstWhere((p) => p['id'].toString() == postId, orElse: () => null);
    if (postData == null) throw Exception('Post not found');
    return Post.fromJson(postData);
  }

  Future<List<RedditPost>> fetchRedditPosts({String subreddit = 'pets', int limit = 10}) async {
    try {
      // Use proper User-Agent and add delay to respect rate limits
      await Future.delayed(const Duration(milliseconds: 500));
      
      final url = Uri.https('www.reddit.com', '/r/$subreddit/hot.json', {
        'limit': '$limit',
        'raw_json': '1',
      });
      
      final response = await http.get(
        url, 
        headers: {
          'User-Agent': 'PetformApp/1.0 (by /u/petform_dev)',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('Reddit API error: ${response.statusCode} - ${response.body}');
        }
        throw Exception('Reddit API returned status ${response.statusCode}');
      }
      
      final data = jsonDecode(response.body);
      
      // Check if we got valid Reddit data
      if (data == null || data['data'] == null || data['data']['children'] == null) {
        throw Exception('Invalid Reddit API response format');
      }
      
      final List posts = data['data']['children'];
      
      if (posts.isEmpty) {
        if (kDebugMode) {
          print('No Reddit posts found for subreddit: $subreddit');
        }
        return [];
      }
      
      final redditPosts = posts.map((item) {
        final postData = item['data'];
        
        // Validate required fields
        if (postData['title'] == null || postData['title'].toString().isEmpty) {
          return null; // Skip posts without titles
        }
        
        // Skip stickied posts and announcements
        if (postData['stickied'] == true || postData['distinguished'] != null) {
          return null;
        }
        
        // Skip posts with no content and no external links
        final hasContent = postData['selftext'] != null && postData['selftext'].toString().isNotEmpty;
        final hasExternalLink = postData['url'] != null && 
                               postData['url'].toString().startsWith('http') &&
                               !postData['url'].toString().contains('reddit.com');
        
        if (!hasContent && !hasExternalLink) {
          return null; // Skip low-effort posts
        }
        
        // Extract the best available image URL
        String imageUrl = '';
        
        // Check for preview images (highest quality)
        if (postData['preview'] != null && 
            postData['preview']['images'] != null && 
            postData['preview']['images'].isNotEmpty) {
          final previewImage = postData['preview']['images'][0];
          if (previewImage['source'] != null && 
              previewImage['source']['url'] != null) {
            imageUrl = previewImage['source']['url'].toString()
                .replaceAll('&amp;', '&'); // Fix HTML entities
          }
        }
        
        // Fallback to thumbnail if no preview image
        if (imageUrl.isEmpty && 
            postData['thumbnail'] != null && 
            postData['thumbnail'].toString().startsWith('http')) {
          imageUrl = postData['thumbnail'].toString();
        }
        
        // Fallback to external URL if it's an image
        if (imageUrl.isEmpty && 
            postData['url'] != null && 
            postData['url'].toString().startsWith('http') &&
            _isImageUrl(postData['url'].toString())) {
          imageUrl = postData['url'].toString();
        }
        
        return RedditPost(
          id: postData['id'] ?? '',
          title: postData['title'] ?? '',
          subreddit: postData['subreddit'] ?? subreddit,
          author: postData['author'] ?? 'Redditor',
          url: 'https://www.reddit.com${postData['permalink']}',
          thumbnail: imageUrl,
          content: postData['selftext'] ?? '',
        );
      }).where((post) => post != null).cast<RedditPost>().toList();
      
      if (kDebugMode) {
        print('Fetched ${redditPosts.length} valid Reddit posts from r/$subreddit');
      }
      
      return redditPosts;
      
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching Reddit posts from r/$subreddit: $e');
      }
      // Return empty list instead of throwing to prevent app crashes
      return [];
    }
  }

  bool _isImageUrl(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    final lowerUrl = url.toLowerCase();
    return imageExtensions.any((ext) => lowerUrl.endsWith(ext)) ||
           lowerUrl.contains('imgur.com') ||
           lowerUrl.contains('i.redd.it') ||
           lowerUrl.contains('preview.redd.it');
  }

  // Clear all posts and start fresh (for debugging)
  Future<void> clearAllPosts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('global_posts');
    // Also clear any other post-related keys that might exist
    await prefs.remove('posts');
    await prefs.remove('user_posts');
    if (kDebugMode) {
      print('ApiService.clearAllPosts: NUKED all posts from storage');
      print('ApiService.clearAllPosts: Removed global_posts, posts, user_posts');
    }
  }
}