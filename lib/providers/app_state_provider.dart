import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/shopping_service.dart';
import '../services/tracking_service.dart';
import '../models/pet.dart';
import '../models/post.dart';
import '../models/shopping_item.dart';
import '../models/tracking_metric.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppStateProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Core data
  List<Pet> _pets = [];
  List<Post> _posts = [];
  List<ShoppingItem> _shoppingItems = [];
  List<TrackingMetric> _trackingMetrics = [];
  List<Post> _savedPosts = [];
  
  // UI state
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<Pet> get pets => _pets;
  List<Post> get posts => _posts;
  List<ShoppingItem> get shoppingItems => _shoppingItems;
  List<TrackingMetric> get trackingMetrics => _trackingMetrics;
  List<Post> get savedPosts => _savedPosts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Computed properties
  int get petsCount => _pets.length;
  int get shoppingItemsCount => _shoppingItems.length;
  int get trackingMetricsCount => _trackingMetrics.length;
  int get savedPostsCount => _savedPosts.length;
  
  // Initialize app state
  Future<void> initialize() async {
    if (_isLoading) return; // Prevent multiple simultaneous initializations
    
    _setLoading(true);
    try {
      await Future.wait([
        _loadPets(),
        _loadPosts(),
        _loadShoppingItems(),
        _loadTrackingMetrics(),
        _loadSavedPosts(),
      ]);
      _setError(null);
    } catch (e) {
      _setError('Failed to initialize app: $e');
      if (kDebugMode) {
        print('AppStateProvider: Error initializing: $e');
      }
    } finally {
      _setLoading(false);
    }
  }
  
  // Pet management
  Future<void> _loadPets() async {
    try {
      _pets = await _apiService.getPets();
      // Don't call notifyListeners here - it will be called by initialize
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error loading pets: $e');
      }
      rethrow;
    }
  }
  
  Future<void> addPet(Pet pet) async {
    try {
      await _apiService.createPet(pet);
      _pets.add(pet);
      
      // Add default tracking metrics for the new pet with correct pet ID
      await addDefaultMetricsForPet(pet);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to add pet: $e');
      rethrow;
    }
  }
  
  Future<void> updatePet(Pet pet) async {
    try {
      await _apiService.updatePet(pet);
      final index = _pets.indexWhere((p) => p.id == pet.id);
      if (index != -1) {
        _pets[index] = pet;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update pet: $e');
      rethrow;
    }
  }
  
  Future<void> removePet(Pet pet) async {
    try {
      if (pet.id == null) {
        throw Exception('Cannot remove pet without an ID');
      }
      await _apiService.deletePet(pet.id!);
      _pets.removeWhere((p) => p.id == pet.id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to remove pet: $e');
      rethrow;
    }
  }
  
  // Post management
  Future<void> _loadPosts() async {
    try {
      _posts = await _apiService.getPosts();
      // Don't call notifyListeners here - it will be called by initialize
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error loading posts: $e');
      }
      rethrow;
    }
  }
  
  Future<void> addPost(Post post) async {
    try {
      await _apiService.createPost(
        title: post.title,
        content: post.content,
        petType: post.petType,
        author: post.author,
      );
      _posts.add(post);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add post: $e');
      rethrow;
    }
  }
  
  // Saved posts management
  Future<void> _loadSavedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPostsJson = prefs.getString('saved_posts') ?? '[]';
      final List<dynamic> savedPostsData = jsonDecode(savedPostsJson);
      _savedPosts = savedPostsData.map((p) => Post.fromJson(p as Map<String, dynamic>)).toList();
    } catch (e) {
      _savedPosts = [];
    }
    // Don't call notifyListeners here - it will be called by initialize
  }
  
  Future<void> savePost(Post post) async {
    if (!_savedPosts.any((p) => p.id == post.id)) {
      _savedPosts.add(post);
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      final savedPostsJson = jsonEncode(_savedPosts.map((p) => p.toJson()).toList());
      await prefs.setString('saved_posts', savedPostsJson);
      notifyListeners();
    }
  }
  
  Future<void> unsavePost(Post post) async {
    _savedPosts.removeWhere((p) => p.id == post.id);
    // Remove from local storage
    final prefs = await SharedPreferences.getInstance();
    final savedPostsJson = jsonEncode(_savedPosts.map((p) => p.toJson()).toList());
    await prefs.setString('saved_posts', savedPostsJson);
    notifyListeners();
  }
  
  bool isPostSaved(Post post) {
    return _savedPosts.any((p) => p.id == post.id);
  }
  
  // Shopping items management
  Future<void> _loadShoppingItems() async {
    // TODO: Implement shopping items loading
    _shoppingItems = [];
    // Don't call notifyListeners here - it will be called by initialize
  }
  
  Future<void> addShoppingItem(ShoppingItem item) async {
    _shoppingItems.add(item);
    // TODO: Save to storage
    notifyListeners();
  }
  
  Future<void> removeShoppingItem(ShoppingItem item) async {
    _shoppingItems.remove(item);
    // TODO: Remove from storage
    notifyListeners();
  }
  
  Future<void> updateShoppingItem(ShoppingItem item) async {
    final index = _shoppingItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _shoppingItems[index] = item;
      // TODO: Update in storage
      notifyListeners();
    }
  }
  
  // Smart shopping suggestions based on pets
  List<ShoppingItem> getSmartShoppingSuggestions() {
    List<ShoppingItem> suggestions = [];
    
    // Get suggestions from ShoppingService based on user's pets
    for (final pet in _pets) {
      suggestions.addAll(ShoppingService.getSuggestionsForPet(pet.species));
    }
    
    // If no pets, return popular items
    if (suggestions.isEmpty) {
      suggestions = ShoppingService.getPopularItems();
    }
    
    return suggestions;
  }
  
  // Get suggestions by category
  List<ShoppingItem> getSuggestionsByCategory(String category) {
    return ShoppingService.getSuggestionsByCategory(category);
  }
  
  // Get suggestions by priority
  List<ShoppingItem> getSuggestionsByPriority(String priority) {
    return ShoppingService.getSuggestionsByPriority(priority);
  }
  
  // Search suggestions
  List<ShoppingItem> searchSuggestions(String query) {
    return ShoppingService.searchSuggestions(query);
  }
  
  // Get budget-friendly suggestions
  List<ShoppingItem> getBudgetSuggestions() {
    return ShoppingService.getBudgetSuggestions();
  }
  
  // Get premium suggestions
  List<ShoppingItem> getPremiumSuggestions() {
    return ShoppingService.getPremiumSuggestions();
  }
  
  // Tracking metrics management
  Future<void> _loadTrackingMetrics() async {
    // TODO: Implement tracking metrics loading from storage
    _trackingMetrics = [];
    // Don't call notifyListeners here - it will be called by initialize
  }
  
  Future<void> addTrackingMetric(TrackingMetric metric) async {
    _trackingMetrics.add(metric);
    // TODO: Save to storage
    notifyListeners();
  }
  
  Future<void> updateTrackingMetric(TrackingMetric metric) async {
    final index = _trackingMetrics.indexWhere((m) => m.id == metric.id);
    if (index != -1) {
      // Preserve the history and other properties from the existing metric
      final existingMetric = _trackingMetrics[index];
      final updatedMetric = metric.copyWith(
        history: existingMetric.history,
        lastUpdated: existingMetric.lastUpdated,
        description: existingMetric.description,
        category: existingMetric.category,
      );
      _trackingMetrics[index] = updatedMetric;
      // TODO: Update in storage
      notifyListeners();
    }
  }
  
  Future<void> removeTrackingMetric(TrackingMetric metric) async {
    _trackingMetrics.removeWhere((m) => m.id == metric.id);
    // TODO: Remove from storage
    notifyListeners();
  }
  
  // Smart tracking suggestions using TrackingService
  List<TrackingMetric> getSmartTrackingSuggestions() {
    List<TrackingMetric> suggestions = [];
    
    for (final pet in _pets) {
      // Get pet-specific suggestions from TrackingService
      suggestions.addAll(TrackingService.getDefaultMetricsForPet(pet.species));
    }
    
    // If no pets, return popular metrics
    if (suggestions.isEmpty) {
      suggestions = TrackingService.getPopularMetrics();
    }
    
    return suggestions;
  }
  
  // Search tracking suggestions
  List<TrackingMetric> searchTrackingSuggestions(String query) {
    return TrackingService.searchSuggestions(query);
  }
  
  // Get tracking tips by category
  List<String> getTrackingTips(String category) {
    return TrackingService.getTrackingTips(category);
  }
  
  // Get metrics by pet
  List<TrackingMetric> getMetricsByPet(String petId) {
    return _trackingMetrics.where((metric) => metric.petId == petId).toList();
  }
  
  // Get metrics by category
  List<TrackingMetric> getMetricsByCategory(String category) {
    return _trackingMetrics.where((metric) => metric.category?.toLowerCase() == category.toLowerCase()).toList();
  }
  
  // Get metrics that need attention
  List<TrackingMetric> getMetricsNeedingAttention() {
    return _trackingMetrics.where((metric) => metric.needsAttention).toList();
  }
  
  // Get metrics on track
  List<TrackingMetric> getMetricsOnTrack() {
    return _trackingMetrics.where((metric) => metric.isOnTrack).toList();
  }
  
  // Get recent metrics (updated in last 7 days)
  List<TrackingMetric> getRecentMetrics() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _trackingMetrics.where((metric) => 
      metric.lastUpdated != null && metric.lastUpdated!.isAfter(weekAgo)
    ).toList();
  }
  
  // Get metrics with trends
  List<TrackingMetric> getMetricsWithTrend(String trend) {
    return _trackingMetrics.where((metric) => metric.trend.toLowerCase() == trend.toLowerCase()).toList();
  }
  
  // Add default metrics for a new pet
  Future<void> addDefaultMetricsForPet(Pet pet) async {
    if (pet.id == null) {
      throw Exception('Cannot add metrics for pet without an ID');
    }
    
    final defaultMetrics = TrackingService.getDefaultMetricsForPet(pet.species);
    
    for (final metric in defaultMetrics) {
      final newMetric = metric.copyWith(
        id: '${metric.id}_${pet.id}',
        petId: pet.id.toString(),
      );
      await addTrackingMetric(newMetric);
    }
  }
  
  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Refresh all data
  Future<void> refresh() async {
    await initialize();
  }
  
  // Clear all data (for debugging)
  Future<void> clearAllData() async {
    try {
      await _apiService.clearAllPets();
      _pets.clear();
      _shoppingItems.clear();
      _trackingMetrics.clear();
      _savedPosts.clear();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear data: $e');
      rethrow;
    }
  }

  // Add this method to get a post by ID from the current state
  Post? getPostById(String id) {
    try {
      return _posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // Add this method to add a comment to a post and persist
  Future<Post?> addCommentToPost({
    required String postId,
    required String content,
    required String author,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getString('posts');
    final List<dynamic> postsData = postsJson != null ? List<Map<String, dynamic>>.from(jsonDecode(postsJson)) : [];
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return null;
    final post = _posts[index];
    final newComment = Comment(
      id: post.comments.length + 1,
      content: content,
      author: author,
      createdAt: DateTime.now(),
    );
    final updatedComments = List<Comment>.from(post.comments)..add(newComment);
    final updatedPost = Post(
      id: post.id,
      title: post.title,
      content: post.content,
      author: post.author,
      petType: post.petType,
      imageUrl: post.imageUrl,
      upvotes: post.upvotes,
      createdAt: post.createdAt,
      postType: post.postType,
      redditUrl: post.redditUrl,
      comments: updatedComments,
    );
    _posts[index] = updatedPost;
    // Update in postsData for persistence
    final dataIdx = postsData.indexWhere((p) => p['id'].toString() == postId);
    if (dataIdx != -1) {
      postsData[dataIdx] = updatedPost.toJson();
      await prefs.setString('posts', jsonEncode(postsData));
    }
    notifyListeners();
    return updatedPost;
  }

  // Add this method to update a post and persist
  Future<Post?> updatePost({
    required String postId,
    required String title,
    required String content,
    required String petType,
    String? imageBase64,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getString('posts');
    final List<dynamic> postsData = postsJson != null ? List<Map<String, dynamic>>.from(jsonDecode(postsJson)) : [];
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return null;
    
    final originalPost = _posts[index];
    final updatedPost = Post(
      id: originalPost.id,
      title: title,
      content: content,
      author: originalPost.author,
      petType: petType,
      imageUrl: imageBase64 != null ? 'data:image/jpeg;base64,$imageBase64' : originalPost.imageUrl,
      upvotes: originalPost.upvotes,
      createdAt: originalPost.createdAt,
      editedAt: DateTime.now(),
      postType: originalPost.postType,
      redditUrl: originalPost.redditUrl,
      comments: originalPost.comments,
    );
    
    _posts[index] = updatedPost;
    // Update in postsData for persistence
    final dataIdx = postsData.indexWhere((p) => p['id'].toString() == postId);
    if (dataIdx != -1) {
      postsData[dataIdx] = updatedPost.toJson();
      await prefs.setString('posts', jsonEncode(postsData));
    }
    notifyListeners();
    return updatedPost;
  }
} 