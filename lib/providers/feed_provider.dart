import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../services/api_service.dart';
import '../models/pet_types.dart';
import '../models/post.dart';
import '../models/reddit_post.dart';
import '../providers/app_state_provider.dart';

class FeedProvider with ChangeNotifier {
  String _selectedPetType = 'All';
  String _selectedPostType = 'All';
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _isFetching = false; // Prevent multiple simultaneous fetches

  String get selectedPetType => _selectedPetType;
  String get selectedPostType => _selectedPostType;
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  void setPetType(String petType) {
    if (_selectedPetType != petType) {
      _selectedPetType = petType;
      // Don't call notifyListeners here - fetchPosts will call it
    }
  }

  void setPostType(String postType) {
    if (_selectedPostType != postType) {
      _selectedPostType = postType;
      // Don't call notifyListeners here - fetchPosts will call it
    }
  }

  Future<void> fetchPosts(BuildContext context) async {
    if (_isFetching) return; // Prevent multiple simultaneous fetches
    
    _isFetching = true;
    _isLoading = true;
    notifyListeners();

    try {
      List<Post> allPosts = [];
      
      // Get community posts from Supabase
      List<Map<String, dynamic>> communityPosts = await SupabaseService.getPosts();
      List<Post> supabasePosts = communityPosts.map((p) => Post.fromJson(p)).toList();
      allPosts.addAll(supabasePosts);
      
      if (kDebugMode) {
        print('FeedProvider: Loaded ${supabasePosts.length} community posts from Supabase');
      }
      
      // Get Reddit posts (only if not filtering by post type or if Reddit is selected)
      if (_selectedPostType == 'All' || _selectedPostType == 'Reddit') {
        try {
          final apiService = ApiService();
          List<RedditPost> redditPosts = await apiService.fetchRedditPosts(subreddit: 'pets', limit: 10);
          allPosts.addAll(redditPosts);
          
          if (kDebugMode) {
            print('FeedProvider: Loaded ${redditPosts.length} Reddit posts');
          }
        } catch (e) {
          if (kDebugMode) {
            print('FeedProvider: Error loading Reddit posts: $e');
          }
          // Continue without Reddit posts if there's an error
        }
      }
      
      // Filter posts based on selection
      if (_selectedPetType != 'All') {
        allPosts = allPosts.where((post) => post.petType == _selectedPetType).toList();
      }
        
      if (_selectedPostType != 'All') {
        allPosts = allPosts.where((post) => post.postType == _selectedPostType.toLowerCase()).toList();
      }
      
      _posts = allPosts;
      
      // Sort by date (descending)
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      if (kDebugMode) {
        print('FeedProvider: Total posts after filtering: ${_posts.length}');
        print('FeedProvider: Selected pet type: $_selectedPetType');
        print('FeedProvider: Selected post type: $_selectedPostType');
      }
    } catch (e) {
      _posts = [];
      if (kDebugMode) {
        print('FeedProvider: error fetching posts: $e');
      }
    }

    _isLoading = false;
    _isFetching = false;
    notifyListeners();
  }

  Future<void> addPost(Post post) async {
    try {
      await SupabaseService.createPost(post.toJson());
      // Refresh posts after adding new one
      await _loadPosts();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('FeedProvider: Error adding post: $e');
      }
      rethrow;
    }
  }

  Future<void> updatePost(String id, Post post) async {
    try {
      await SupabaseService.updatePost(id, post.toJson());
      // Refresh posts after updating
      await _loadPosts();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('FeedProvider: Error updating post: $e');
      }
      rethrow;
    }
  }

  Future<void> deletePost(String id) async {
    try {
      await SupabaseService.deletePost(id);
      // Refresh posts after deleting
      await _loadPosts();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('FeedProvider: Error deleting post: $e');
      }
      rethrow;
    }
  }

  Post? getPostById(String id) {
    try {
      return _posts.firstWhere((post) => post.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await SupabaseService.getPosts();
      _posts = posts.map((p) => Post.fromJson(p)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('FeedProvider: Error loading posts: $e');
      }
      rethrow;
    }
  }
}
