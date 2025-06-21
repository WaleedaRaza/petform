import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';
import '../models/post.dart';
import '../models/tracking_metric.dart';
import '../models/shopping_item.dart';
import 'package:http/http.dart' as http;
import '../models/reddit_post.dart';

class ApiService {
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
      'postType': 'reddit',
      'redditUrl': 'https://www.reddit.com/r/pets/comments/123456/puppy_training_101/',
      'comments': [],
    },
    {
      'id': 2,
      'title': 'Cat Scratching Fix',
      'content': 'A tall scratching post saved my couch!',
      'author': 'CatFan',
      'petType': 'Cat',
      'upvotes': 30,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'postType': 'community',
      'redditUrl': null,
      'comments': [
        {'id': 1, 'content': 'Great tip!', 'author': 'User1', 'createdAt': DateTime.now().toIso8601String()},
      ],
    },
    {
      'id': 3,
      'title': 'Turtle Tank Setup',
      'content': 'Clean water and UVB light are must-haves.',
      'author': 'TurtleGuru',
      'petType': 'Turtle',
      'upvotes': 20,
      'createdAt': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
      'postType': 'reddit',
      'redditUrl': 'https://www.reddit.com/r/pets/comments/789012/turtle_tank_setup/',
      'comments': [],
    },
    {
      'id': 4,
      'title': 'Dog Park Vibes',
      'content': 'My pup had a blast chasing balls today.',
      'author': 'PetWalker',
      'petType': 'Dog',
      'upvotes': 45,
      'createdAt': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
      'postType': 'community',
      'redditUrl': null,
      'comments': [],
    },
    {
      'id': 5,
      'title': 'Cat Toy Picks',
      'content': 'My kitty loves feather wands and laser pointers.',
      'author': 'KittyMom',
      'petType': 'Cat',
      'upvotes': 25,
      'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      'postType': 'community',
      'redditUrl': null,
      'comments': [],
    },
  ];

  Future<void> signup(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);
    await prefs.setInt('user_id', DateTime.now().millisecondsSinceEpoch);
    await prefs.setString('pets', '[]');
    await prefs.setString('posts', jsonEncode(_mockPosts));
    if (kDebugMode) {
      print('ApiService.signup: User $email signed up, initialized pets and posts');
    }
  }

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('user_email');
    final storedPassword = prefs.getString('user_password');
    if (storedEmail != email || storedPassword != password) {
      if (kDebugMode) {
        print('ApiService.login: Invalid credentials for $email');
      }
      throw Exception('Invalid credentials');
    }
    if (kDebugMode) {
      print('ApiService.login: User $email logged in');
    }
  }

  Future<List<Pet>> getPets() async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getString('pets') ?? '[]';
    if (kDebugMode) {
      print('ApiService.getPets: Retrieved pets JSON: $petsJson');
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
    final petsJson = prefs.getString('pets') ?? '[]';
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
    await prefs.setString('pets', jsonEncode(petsData));
    if (kDebugMode) {
      print('ApiService.createPet: Created pet ${newPet.name}');
    }
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

  Future<List<Post>> getPosts({String? petType, String? postType}) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getString('posts') ?? jsonEncode(_mockPosts);
    final List<dynamic> postsData = jsonDecode(postsJson);
    var posts = postsData.map((p) => Post.fromJson(p)).toList();
    if (petType != null) {
      posts = posts.where((p) => p.petType == petType).toList();
    }
    if (postType != null) {
      posts = posts.where((p) => p.postType == postType.toLowerCase()).toList();
    }
    if (kDebugMode) {
      print('ApiService.getPosts: Returning ${posts.length} posts for petType: $petType, postType: $postType');
    }
    return posts;
  }

  Future<void> createPost({
    required String title,
    required String content,
    required String petType,
    required String author,
    String? imageUrl,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getString('posts') ?? jsonEncode(_mockPosts);
    final List<dynamic> postsData = jsonDecode(postsJson);
    final newPost = Post(
      id: postsData.length + 1,
      title: title,
      content: content,
      author: author,
      petType: petType,
      imageUrl: imageUrl,
      upvotes: 0,
      createdAt: DateTime.now(),
      postType: 'community',
      redditUrl: null,
    );
    postsData.add(newPost.toJson());
    await prefs.setString('posts', jsonEncode(postsData));
    if (kDebugMode) {
      print('ApiService.createPost: Created post ${newPost.id}');
    }
  }

  Future<void> addComment({
    required int postId,
    required String content,
    required String author,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getString('posts') ?? jsonEncode(_mockPosts);
    final List<dynamic> postsData = jsonDecode(postsJson);
    final index = postsData.indexWhere((p) => p['id'] == postId);
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
      await prefs.setString('posts', jsonEncode(postsData));
      if (kDebugMode) {
        print('ApiService.addComment: Added comment to post $postId');
      }
    }
  }

  Future<Post> getPost(int postId) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getString('posts') ?? jsonEncode(_mockPosts);
    final List<dynamic> postsData = jsonDecode(postsJson);
    final postData = postsData.firstWhere((p) => p['id'] == postId, orElse: () => null);
    if (postData == null) throw Exception('Post not found');
    return Post.fromJson(postData);
  }

  Future<List<RedditPost>> fetchRedditPosts({String subreddit = 'pets', int limit = 10}) async {
    final url = Uri.https('www.reddit.com', '/r/$subreddit/hot.json', {'limit': '$limit'});
    final response = await http.get(url, headers: {'User-Agent': 'petform-app/1.0'});
    if (response.statusCode != 200) {
      throw Exception('Failed to load Reddit posts');
    }
    final data = jsonDecode(response.body);
    final List posts = data['data']['children'];
    return posts.map((item) {
      final postData = item['data'];
      return RedditPost(
        title: postData['title'] ?? '',
        subreddit: postData['subreddit'] ?? subreddit,
        author: postData['author'] ?? 'Redditor',
        url: 'https://www.reddit.com${postData['permalink']}',
        thumbnail: (postData['thumbnail'] != null && postData['thumbnail'].startsWith('http')) ? postData['thumbnail'] : '',
        content: postData['selftext'] ?? '',
      );
    }).toList();
  }
}