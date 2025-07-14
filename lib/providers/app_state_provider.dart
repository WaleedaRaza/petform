import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:hive/hive.dart';
import '../services/api_service.dart';
import '../services/shopping_service.dart';
import '../services/tracking_service.dart';
import '../models/pet.dart';
import '../models/post.dart';
import '../models/shopping_item.dart';
import '../models/tracking_metric.dart';
import '../models/user.dart';

class AppStateProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Hive boxes
  late Box<Pet> _petBox;
  late Box<Post> _postBox;
  late Box<ShoppingItem> _shoppingBox;
  late Box<TrackingMetric> _trackingBox;
  late Box<User> _userBox;
  
  // UI state
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters that read from Hive boxes
  List<Pet> get pets => _petBox.values.toList();
  List<Post> get posts => _postBox.values.toList();
  List<ShoppingItem> get shoppingItems => _shoppingBox.values.toList();
  List<TrackingMetric> get trackingMetrics => _trackingBox.values.toList();
  List<Post> get savedPosts => _postBox.values.where((post) => post.isSaved).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Computed properties
  int get petsCount => pets.length;
  int get shoppingItemsCount => shoppingItems.length;
  int get trackingMetricsCount => trackingMetrics.length;
  int get savedPostsCount => savedPosts.length;
  
  // Initialize app state
  Future<void> initialize() async {
    if (_isLoading) return; // Prevent multiple simultaneous initializations
    
    _setLoading(true);
    try {
      // Initialize Hive boxes
      _petBox = Hive.box<Pet>('pets');
      _postBox = Hive.box<Post>('posts');
      _shoppingBox = Hive.box<ShoppingItem>('shoppingItems');
      _trackingBox = Hive.box<TrackingMetric>('trackingMetrics');
      _userBox = Hive.box<User>('users');
      
      await Future.wait([
        _loadPets(),
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
      // Load pets from API and sync with Hive
      final apiPets = await _apiService.getPets();
      
      // Clear existing pets and add from API
      await _petBox.clear();
      for (final pet in apiPets) {
        await _petBox.add(pet);
      }
      
      if (kDebugMode) {
        print('AppStateProvider._loadPets: Loaded ${apiPets.length} pets from API');
      }
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
      await _petBox.add(pet);
      
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
      
      // Find the pet in Hive and update it
      final keys = _petBox.keys.toList();
      for (final key in keys) {
        final existingPet = _petBox.get(key);
        if (existingPet?.id == pet.id) {
          await _petBox.put(key, pet);
          break;
        }
      }
      
      notifyListeners();
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
      
      // Remove from Hive
      final keys = _petBox.keys.toList();
      for (final key in keys) {
        final existingPet = _petBox.get(key);
        if (existingPet?.id == pet.id) {
          await _petBox.delete(key);
          break;
        }
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to remove pet: $e');
      rethrow;
    }
  }
  
  // Saved posts management
  Future<void> _loadSavedPosts() async {
    try {
      // Saved posts are now managed through the Post model's isSaved property
      // No separate loading needed as it's handled by the getter
      if (kDebugMode) {
        print('AppStateProvider._loadSavedPosts: Saved posts loaded from Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider._loadSavedPosts: Error loading saved posts: $e');
    }
  }
  }
  
  Future<void> savePost(Post post) async {
    if (kDebugMode) {
      print('AppStateProvider.savePost: Attempting to save post ${post.id}');
    }
    
    // Find the post in Hive and mark it as saved
    final keys = _postBox.keys.toList();
    for (final key in keys) {
      final existingPost = _postBox.get(key);
      if (existingPost?.id == post.id) {
        final savedPost = post.copyWith(isSaved: true);
        await _postBox.put(key, savedPost);
      notifyListeners();
        return;
      }
    }
    
    // If post not found, add it as saved
    final savedPost = post.copyWith(isSaved: true);
    await _postBox.add(savedPost);
    notifyListeners();
  }
  
  Future<void> unsavePost(Post post) async {
    // Find the post in Hive and mark it as not saved
    final keys = _postBox.keys.toList();
    for (final key in keys) {
      final existingPost = _postBox.get(key);
      if (existingPost?.id == post.id) {
        final unsavedPost = post.copyWith(isSaved: false);
        await _postBox.put(key, unsavedPost);
    notifyListeners();
        return;
      }
    }
  }
  
  bool isPostSaved(Post post) {
    return savedPosts.any((p) => p.id == post.id);
  }
  
  // Clear all user data (for sign out or reset)
  Future<void> clearAllUserData() async {
    try {
      // Clear all Hive boxes
      await _petBox.clear();
      await _postBox.clear();
      await _shoppingBox.clear();
      await _trackingBox.clear();
      await _userBox.clear();
      
      if (kDebugMode) {
        print('AppStateProvider.clearAllUserData: Cleared all Hive data');
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider.clearAllUserData: Error clearing user data: $e');
      }
    }
  }
  
  // Shopping items management
  Future<void> _loadShoppingItems() async {
    try {
      // Shopping items are now managed by Hive
      // No separate loading needed as they're already in the box
      if (kDebugMode) {
        print('AppStateProvider._loadShoppingItems: Shopping items loaded from Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider._loadShoppingItems: Error loading shopping items: $e');
      }
    }
  }
  
  Future<void> addShoppingItem(ShoppingItem item) async {
    if (kDebugMode) {
      print('AppStateProvider.addShoppingItem: Adding shopping item ${item.id}');
    }
    
    await _shoppingBox.add(item);
    notifyListeners();
  }
  
  Future<void> removeShoppingItem(ShoppingItem item) async {
    if (kDebugMode) {
      print('AppStateProvider.removeShoppingItem: Removing shopping item ${item.id}');
    }
    
    // Find and remove the item from Hive
    final keys = _shoppingBox.keys.toList();
    for (final key in keys) {
      final existingItem = _shoppingBox.get(key);
      if (existingItem?.id == item.id) {
        await _shoppingBox.delete(key);
        break;
      }
    }
    
    notifyListeners();
  }
  
  Future<void> updateShoppingItem(ShoppingItem item) async {
    if (kDebugMode) {
      print('AppStateProvider.updateShoppingItem: Updating shopping item ${item.id}');
    }
    
    // Find and update the item in Hive
    final keys = _shoppingBox.keys.toList();
    for (final key in keys) {
      final existingItem = _shoppingBox.get(key);
      if (existingItem?.id == item.id) {
        await _shoppingBox.put(key, item);
        break;
      }
    }
    
    notifyListeners();
  }
  
  // Smart shopping suggestions based on pets
  List<ShoppingItem> getSmartShoppingSuggestions() {
    List<ShoppingItem> suggestions = [];
    
    // Get suggestions from ShoppingService based on user's pets
    for (final pet in pets) {
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
    try {
      // Tracking metrics are now managed by Hive
      // No separate loading needed as they're already in the box
      if (kDebugMode) {
        print('AppStateProvider._loadTrackingMetrics: Tracking metrics loaded from Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider._loadTrackingMetrics: Error loading tracking metrics: $e');
      }
    }
  }
  
  Future<void> addTrackingMetric(TrackingMetric metric) async {
    if (kDebugMode) {
      print('AppStateProvider.addTrackingMetric: Adding tracking metric ${metric.id}');
    }
    
    await _trackingBox.add(metric);
    notifyListeners();
  }
  
  Future<void> updateTrackingMetric(TrackingMetric metric) async {
    if (kDebugMode) {
      print('AppStateProvider.updateTrackingMetric: Updating tracking metric ${metric.id}');
    }
    
    // Find and update the metric in Hive
    final keys = _trackingBox.keys.toList();
    for (final key in keys) {
      final existingMetric = _trackingBox.get(key);
      if (existingMetric?.id == metric.id) {
        await _trackingBox.put(key, metric);
        break;
      }
    }
    
    notifyListeners();
  }
  
  Future<void> removeTrackingMetric(TrackingMetric metric) async {
    if (kDebugMode) {
      print('AppStateProvider.removeTrackingMetric: Removing tracking metric ${metric.id}');
    }
    
    // Find and remove the metric from Hive
    final keys = _trackingBox.keys.toList();
    for (final key in keys) {
      final existingMetric = _trackingBox.get(key);
      if (existingMetric?.id == metric.id) {
        await _trackingBox.delete(key);
        break;
      }
    }
    
    notifyListeners();
  }
  
  // Smart tracking suggestions using TrackingService
  List<TrackingMetric> getSmartTrackingSuggestions() {
    List<TrackingMetric> suggestions = [];
    
    for (final pet in pets) {
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
    return trackingMetrics.where((metric) => metric.petId == petId).toList();
  }
  
  // Get metrics by category
  List<TrackingMetric> getMetricsByCategory(String category) {
    return trackingMetrics.where((metric) => metric.category?.toLowerCase() == category.toLowerCase()).toList();
  }
  
  // Get metrics that need attention
  List<TrackingMetric> getMetricsNeedingAttention() {
    return trackingMetrics.where((metric) => metric.needsAttention).toList();
  }
  
  // Get metrics on track
  List<TrackingMetric> getMetricsOnTrack() {
    return trackingMetrics.where((metric) => metric.isOnTrack).toList();
  }
  
  // Get recent metrics (updated in last 7 days)
  List<TrackingMetric> getRecentMetrics() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return trackingMetrics.where((metric) => 
      metric.lastUpdated != null && metric.lastUpdated!.isAfter(weekAgo)
    ).toList();
  }
  
  // Get metrics with trends
  List<TrackingMetric> getMetricsWithTrend(String trend) {
    return trackingMetrics.where((metric) => metric.trend.toLowerCase() == trend.toLowerCase()).toList();
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
  
  // Refresh only saved posts (for when navigating back to feed)
  Future<void> refreshSavedPosts() async {
    // No separate refresh needed as saved posts are managed through Hive
    notifyListeners();
  }
  
  // Refresh only shopping items (for when navigating to shopping screen)
  Future<void> refreshShoppingItems() async {
    // No separate refresh needed as shopping items are managed through Hive
    notifyListeners();
  }
  
  // Refresh only tracking metrics (for when navigating to tracking screen)
  Future<void> refreshTrackingMetrics() async {
    // No separate refresh needed as tracking metrics are managed through Hive
    notifyListeners();
  }
  
  // Clear all data (for debugging)
  Future<void> clearAllData() async {
    try {
      await _apiService.clearAllPets();
      await _petBox.clear();
      await _shoppingBox.clear();
      await _trackingBox.clear();
      await _postBox.clear();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear data: $e');
      rethrow;
    }
  }

  // Add this method to get a post by ID from the current state
  Post? getPostById(String id) {
    try {
      return posts.firstWhere((p) => p.id == id);
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
    try {
      // Use API service to add comment (which handles user-specific storage)
      await _apiService.addComment(
        postId: postId,
        content: content,
        author: author,
      );
      
      // Refresh posts from API service to get updated data
      final apiPosts = await _apiService.getPosts();
      
      // Update posts in Hive
      await _postBox.clear();
      for (final post in apiPosts) {
        await _postBox.add(post);
      }
      
      notifyListeners();
      
      // Return the updated post
      return posts.firstWhere((p) => p.id == postId);
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider.addCommentToPost: Error adding comment: $e');
      }
      rethrow;
    }
  }

  // Add this method to update a post and persist
  Future<Post?> updatePost({
    required String postId,
    required String title,
    required String content,
    required String petType,
    String? imageBase64,
  }) async {
    // Find the post in Hive
    final keys = _postBox.keys.toList();
    for (final key in keys) {
      final existingPost = _postBox.get(key);
      if (existingPost?.id == postId) {
        final updatedPost = existingPost!.copyWith(
          title: title,
          content: content,
          petType: petType,
          imageUrl: imageBase64 != null ? 'data:image/jpeg;base64,$imageBase64' : existingPost.imageUrl,
          editedAt: DateTime.now(),
        );
        
        await _postBox.put(key, updatedPost);
        notifyListeners();
        return updatedPost;
      }
    }
    
    return null;
  }
} 