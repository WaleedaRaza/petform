import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class FeedProvider with ChangeNotifier {
  String _selectedPetType = 'All'; // Default filter
  List<Post> _posts = [];
  bool _isLoading = false;

  String get selectedPetType => _selectedPetType;
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  void setPetType(String petType) {
    _selectedPetType = petType;
    notifyListeners();
  }

  Future<void> fetchPosts(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final apiService = Provider.of<ApiService>(context, listen: false);
    _posts = await apiService.getPosts(petType: _selectedPetType);

    _isLoading = false;
    notifyListeners();
  }
}