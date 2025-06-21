import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/post.dart';
import '../models/reddit_post.dart';
import '../models/pet_types.dart';

class FeedProvider with ChangeNotifier {
  String _selectedPetType = 'All';
  String _selectedPostType = 'All';
  List<Post> _posts = [];
  bool _isLoading = false;

  String get selectedPetType => _selectedPetType;
  String get selectedPostType => _selectedPostType;
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  void setPetType(String petType) {
    _selectedPetType = petType;
    notifyListeners();
  }

  void setPostType(String postType) {
    _selectedPostType = postType;
    notifyListeners();
  }

  Future<void> fetchPosts(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiService = ApiService();
      List<Post> communityPosts = await apiService.getPosts(
        petType: _selectedPetType == 'All' ? null : _selectedPetType,
        postType: _selectedPostType == 'All' ? null : (_selectedPostType.toLowerCase() == 'community' ? 'community' : null),
      );
      List<Post> redditPosts = [];
      if (_selectedPostType == 'All' || _selectedPostType.toLowerCase() == 'reddit') {
        String subreddit = 'pets';
        if (_selectedPetType != 'All' && petTypeToSubreddit.containsKey(_selectedPetType)) {
          subreddit = petTypeToSubreddit[_selectedPetType]!;
        }
        var redditRaw = await apiService.fetchRedditPosts(subreddit: subreddit);
        // Fallback to 'pets' if no posts found
        if (redditRaw.isEmpty && subreddit != 'pets') {
          redditRaw = await apiService.fetchRedditPosts(subreddit: 'pets');
        }
        redditPosts = redditRaw.map((r) => r as Post).toList();
      }
      // Merge and sort by date (descending)
      _posts = [...communityPosts, ...redditPosts];
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (kDebugMode) {
        print('FeedProvider: fetched ${_posts.length} posts (community + reddit)');
      }
    } catch (e) {
      _posts = [];
      if (kDebugMode) {
        print('FeedProvider: error fetching posts: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}
