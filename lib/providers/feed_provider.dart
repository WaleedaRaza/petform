import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/post.dart';
import '../models/pet_types.dart';
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
      final apiService = ApiService();
      List<Post> communityPosts = await apiService.getPosts(
        petType: _selectedPetType == 'All' ? null : _selectedPetType,
        postType: _selectedPostType == 'All' ? null : (_selectedPostType.toLowerCase() == 'community' ? 'community' : null),
      );
      
      // Posts are now global, so we don't need to merge user posts from AppStateProvider
      // All community posts are stored globally and accessible to all users
      
      List<Post> redditPosts = [];
      if (_selectedPostType == 'All' || _selectedPostType.toLowerCase() == 'reddit') {
        String subreddit = 'pets';
        if (_selectedPetType != 'All' && petTypeToSubreddit.containsKey(_selectedPetType)) {
          subreddit = petTypeToSubreddit[_selectedPetType]!;
        }
        
        try {
          var redditRaw = await apiService.fetchRedditPosts(subreddit: subreddit);
          
          // Fallback to 'pets' if no posts found and we're not already on 'pets'
          if (redditRaw.isEmpty && subreddit != 'pets') {
            if (kDebugMode) {
              print('FeedProvider: No posts found in r/$subreddit, trying r/pets');
            }
            redditRaw = await apiService.fetchRedditPosts(subreddit: 'pets');
          }
          
          redditPosts = redditRaw.map((r) => r as Post).toList();
          
          if (kDebugMode) {
            print('FeedProvider: Successfully fetched ${redditPosts.length} Reddit posts');
          }
        } catch (e) {
          if (kDebugMode) {
            print('FeedProvider: Failed to fetch Reddit posts: $e');
          }
          // Continue with community posts only - don't crash the app
          redditPosts = [];
        }
      }
      
      // Merge community and reddit posts and sort by date (descending)
      _posts = [...communityPosts, ...redditPosts];
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      if (kDebugMode) {
        print('FeedProvider: Total posts: ${_posts.length} (${communityPosts.length} community + ${redditPosts.length} reddit)');
        print('FeedProvider: Community posts:');
        for (final post in communityPosts) {
          print('  - ${post.title} by ${post.author} (ID: ${post.id})');
        }
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
}
