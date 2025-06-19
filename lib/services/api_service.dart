import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/pet.dart';
import '../models/post.dart' as post_model;
import '../models/comment.dart' as user_comment;
import '../models/tracking_metric.dart';
import '../models/shopping_item.dart';

class ApiService {
  Future<void> signup(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);
    await prefs.setInt('user_id', DateTime.now().millisecondsSinceEpoch);
    await prefs.setString('pets', '[]');
    await prefs.setString('posts', jsonEncode([]));
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
    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getString('pets') ?? '[]';
    final List<dynamic> petsData = jsonDecode(petsJson);
    return petsData.map((p) => Pet.fromJson(p)).toList();
  }

  Future<void> createPet(Pet pet) async {
    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getString('pets') ?? '[]';
    final List<dynamic> petsData = jsonDecode(petsJson);
    final newPet = pet.copyWith(id: pet.id ?? petsData.length + 1);
    petsData.add(newPet.toJson());
    await prefs.setString('pets', jsonEncode(petsData));
  }

  Future<void> updatePet(Pet pet) async {
    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getString('pets') ?? '[]';
    final List<dynamic> petsData = jsonDecode(petsJson);
    final index = petsData.indexWhere((p) => p['id'] == pet.id);
    if (index != -1) {
      petsData[index] = pet.toJson();
      await prefs.setString('pets', jsonEncode(petsData));
    }
  }

  Future<List<post_model.Post>> getPosts({String? petType, String? postType}) async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getString('posts') ?? '[]';
    final List<dynamic> postsData = jsonDecode(postsJson);
    var posts = postsData.map((p) => post_model.Post.fromJson(p)).toList();

    if (postType == null || postType == 'All' || postType.toLowerCase() == 'community') {
      if (petType != null && petType != 'All') {
        posts = posts.where((p) => p.petType == petType).toList();
      }
    } else {
      posts = [];
    }

    if (postType == null || postType == 'All' || postType.toLowerCase() == 'reddit') {
      final redditPosts = await fetchRedditPosts(petType: petType);
      posts.addAll(redditPosts);
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
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getString('posts') ?? '[]';
    final List<dynamic> postsData = jsonDecode(postsJson);
    final newPost = post_model.Post(
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
  }

  Future<void> addComment({
    required int postId,
    required String content,
    required String author,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getString('posts') ?? '[]';
    final List<dynamic> postsData = jsonDecode(postsJson);
    final index = postsData.indexWhere((p) => p['id'] == postId);
    if (index != -1) {
      final post = post_model.Post.fromJson(postsData[index]);
      final newComment = user_comment.Comment(
        id: post.comments.length + 1,
        content: content,
        author: author,
        createdAt: DateTime.now(),
      );
      post.comments.add(newComment);
      postsData[index] = post.toJson();
      await prefs.setString('posts', jsonEncode(postsData));
    }
  }

  Future<post_model.Post> getPost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getString('posts') ?? '[]';
    final List<dynamic> postsData = jsonDecode(postsJson);
    final postData = postsData.firstWhere((p) => p['id'] == postId, orElse: () => null);
    if (postData == null) throw Exception('Post not found');
    return post_model.Post.fromJson(postData);
  }

  Future<List<post_model.Post>> fetchRedditPosts({String? petType}) async {
    try {
final Map<String, String> subredditMap = {
  'Dog': 'dogtraining',
  'Cat': 'cats',
  'Turtle': 'turtle',
  'Bird': 'birds',
  'Hamster': 'hamsters',
  'Ferret': 'ferrets',
  'Parrot': 'parrots',
  'Rabbit': 'rabbits',
  'Snake': 'snakes',
  'Lizard': 'lizards',
  'Fish': 'Aquariums',
  'Hedgehog': 'hedgehogs',
  'Guinea Pig': 'guineapigs',
  'Chinchilla': 'chinchilla',
  'Frog': 'frogs',
  'Tarantula': 'tarantulas',
  'Axolotl': 'axolotls',
  'Mouse': 'PetMice',
  'Chicken': 'petchickens',
  'Goat': 'goats',
};



      final subreddit = petType != null && subredditMap.containsKey(petType)
          ? subredditMap[petType]
          : 'pets';

      final url = Uri.parse('https://www.reddit.com/r/$subreddit/hot.json?limit=10');
      final response = await http.get(url, headers: {'User-Agent': 'petform-app'});

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch Reddit posts');
      }

      final json = jsonDecode(response.body);
      final children = json['data']['children'] as List;

      return children.map((child) {
        final data = child['data'];
        return post_model.Post(
          id: null,
          title: data['title'] ?? 'Untitled',
          content: data['selftext'] ?? '',
          author: data['author'] ?? 'unknown',
          petType: petType ?? 'All',
          upvotes: data['ups'] ?? 0,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            (data['created_utc'] as num).toInt() * 1000,
            isUtc: true,
          ).toLocal(),
          postType: 'reddit',
          redditUrl: 'https://www.reddit.com${data['permalink']}',
          imageUrl: (data['thumbnail'] != null && data['thumbnail'].startsWith('http'))
              ? data['thumbnail']
              : null,
          comments: [],
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) print('fetchRedditPosts error: $e');
      return [];
    }
  }
}
