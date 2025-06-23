import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> deletePet(int petId) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getString('pets') ?? '[]';
    final List<dynamic> petsData = jsonDecode(petsJson);
    final index = petsData.indexWhere((p) => p['id'] == petId);
    if (index != -1) {
      petsData.removeAt(index);
      await prefs.setString('pets', jsonEncode(petsData));
      if (kDebugMode) {
        print('ApiService.deletePet: Deleted pet $petId');
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
    await prefs.setString('pets', '[]');
    if (kDebugMode) {
      print('ApiService.clearAllPets: Cleared all pets');
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
      id: (postsData.length + 1).toString(),
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
    required String postId,
    required String content,
    required String author,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getString('posts') ?? jsonEncode(_mockPosts);
    final List<dynamic> postsData = jsonDecode(postsJson);
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
      await prefs.setString('posts', jsonEncode(postsData));
      if (kDebugMode) {
        print('ApiService.addComment: Added comment to post $postId');
      }
    }
  }

  Future<Post> getPost(String postId) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getString('posts') ?? jsonEncode(_mockPosts);
    final List<dynamic> postsData = jsonDecode(postsJson);
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
}