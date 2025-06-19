import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/post.dart';

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
      _posts = await apiService.getPosts(
        petType: _selectedPetType == 'All' ? null : _selectedPetType,
        postType: _selectedPostType == 'All' ? null : _selectedPostType,
      );
      if (kDebugMode) {
        print('FeedProvider: fetched ${_posts.length} posts');
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
