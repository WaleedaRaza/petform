import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  
  // Posts are now handled globally by the FeedProvider
  // AppStateProvider no longer manages posts
  
  // Saved posts management
  Future<void> _loadSavedPosts() async {
    try {
      // Get user email from Firebase Auth instead of SharedPreferences
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email;
      
      if (kDebugMode) {
        print('AppStateProvider._loadSavedPosts: Starting to load saved posts');
        print('AppStateProvider._loadSavedPosts: User email: $userEmail');
      }
      
      if (userEmail == null) {
        _savedPosts = [];
        if (kDebugMode) {
          print('AppStateProvider._loadSavedPosts: No user email found, setting empty saved posts');
        }
        return;
      }
      
      // Use user-specific key for saved posts
      final sanitizedEmail = userEmail.replaceAll('@', '_at_').replaceAll('.', '_');
      final savedPostsKey = '${sanitizedEmail}_saved_posts';
      final prefs = await SharedPreferences.getInstance();
      final savedPostsJson = prefs.getString(savedPostsKey) ?? '[]';
      
      if (kDebugMode) {
        print('AppStateProvider._loadSavedPosts: Raw saved posts JSON: $savedPostsJson');
      }
      
      final List<dynamic> savedPostsData = jsonDecode(savedPostsJson);
      _savedPosts = savedPostsData.map((p) => Post.fromJson(p as Map<String, dynamic>)).toList();
      
      if (kDebugMode) {
        print('AppStateProvider._loadSavedPosts: Loaded ${_savedPosts.length} saved posts for user $userEmail');
        print('AppStateProvider._loadSavedPosts: Using key: $savedPostsKey');
        print('AppStateProvider._loadSavedPosts: Saved posts:');
        for (final post in _savedPosts) {
          print('  - ${post.title} (ID: ${post.id})');
        }
      }
    } catch (e) {
      _savedPosts = [];
      if (kDebugMode) {
        print('AppStateProvider._loadSavedPosts: Error loading saved posts: $e');
    }
  }
    // Don't call notifyListeners here - it will be called by initialize
  }
  
  Future<void> savePost(Post post) async {
    if (kDebugMode) {
      print('AppStateProvider.savePost: Attempting to save post ${post.id}');
      print('AppStateProvider.savePost: Current saved posts count: ${_savedPosts.length}');
      print('AppStateProvider.savePost: Post already saved: ${_savedPosts.any((p) => p.id == post.id)}');
    }
    
    if (!_savedPosts.any((p) => p.id == post.id)) {
      _savedPosts.add(post);
      // Save to local storage with user-specific key
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email;
      if (userEmail != null) {
        final sanitizedEmail = userEmail.replaceAll('@', '_at_').replaceAll('.', '_');
        final savedPostsKey = '${sanitizedEmail}_saved_posts';
        final savedPostsJson = jsonEncode(_savedPosts.map((p) => p.toJson()).toList());
        await prefs.setString(savedPostsKey, savedPostsJson);
        
        if (kDebugMode) {
          print('AppStateProvider.savePost: Saved post ${post.id} for user $userEmail');
          print('AppStateProvider.savePost: Using key: $savedPostsKey');
          print('AppStateProvider.savePost: Total saved posts after save: ${_savedPosts.length}');
        }
      } else {
        if (kDebugMode) {
          print('AppStateProvider.savePost: No user email found, cannot save');
        }
      }
      notifyListeners();
    } else {
      if (kDebugMode) {
        print('AppStateProvider.savePost: Post ${post.id} already saved, skipping');
      }
    }
  }
  
  Future<void> unsavePost(Post post) async {
    _savedPosts.removeWhere((p) => p.id == post.id);
    // Remove from local storage with user-specific key
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email;
    if (userEmail != null) {
      final sanitizedEmail = userEmail.replaceAll('@', '_at_').replaceAll('.', '_');
      final savedPostsKey = '${sanitizedEmail}_saved_posts';
      final savedPostsJson = jsonEncode(_savedPosts.map((p) => p.toJson()).toList());
      await prefs.setString(savedPostsKey, savedPostsJson);
      
      if (kDebugMode) {
        print('AppStateProvider.unsavePost: Unsaved post ${post.id} for user $userEmail');
        print('AppStateProvider.unsavePost: Using key: $savedPostsKey');
      }
    }
    notifyListeners();
  }
  
  bool isPostSaved(Post post) {
    final isSaved = _savedPosts.any((p) => p.id == post.id);
    if (kDebugMode) {
      print('AppStateProvider.isPostSaved: Checking if post ${post.id} is saved: $isSaved');
      print('AppStateProvider.isPostSaved: Total saved posts: ${_savedPosts.length}');
    }
    return isSaved;
  }
  
  // Clear all user data (for sign out or reset)
  Future<void> clearAllUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email;
      if (userEmail != null) {
        final sanitizedEmail = userEmail.replaceAll('@', '_at_').replaceAll('.', '_');
        
        // Clear all user-specific data
        await prefs.remove('${sanitizedEmail}_pets');
        await prefs.remove('${sanitizedEmail}_posts');
        await prefs.remove('${sanitizedEmail}_saved_posts');
        await prefs.remove('${sanitizedEmail}_shopping_items');
        await prefs.remove('${sanitizedEmail}_tracking_metrics');
        
        // Clear current app state
        _pets.clear();
        _posts.clear();
        _savedPosts.clear();
        _shoppingItems.clear();
        _trackingMetrics.clear();
        
        if (kDebugMode) {
          print('AppStateProvider.clearAllUserData: Cleared all data for user $userEmail');
        }
        
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider.clearAllUserData: Error clearing user data: $e');
      }
    }
  }
  
  // Shopping items management
  Future<void> _loadShoppingItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email;
      
      if (kDebugMode) {
        print('AppStateProvider._loadShoppingItems: Starting to load shopping items');
        print('AppStateProvider._loadShoppingItems: User email: $userEmail');
      }
      
      if (userEmail == null) {
        _shoppingItems = [];
        if (kDebugMode) {
          print('AppStateProvider._loadShoppingItems: No user email found, setting empty shopping items');
        }
        return;
      }
      
      // Use user-specific key for shopping items
      final sanitizedEmail = userEmail.replaceAll('@', '_at_').replaceAll('.', '_');
      final shoppingItemsKey = '${sanitizedEmail}_shopping_items';
      final shoppingItemsJson = prefs.getString(shoppingItemsKey) ?? '[]';
      
      if (kDebugMode) {
        print('AppStateProvider._loadShoppingItems: Raw shopping items JSON: $shoppingItemsJson');
      }
      
      final List<dynamic> shoppingItemsData = jsonDecode(shoppingItemsJson);
      _shoppingItems = shoppingItemsData.map((i) => ShoppingItem.fromJson(i as Map<String, dynamic>)).toList();
      
      if (kDebugMode) {
        print('AppStateProvider._loadShoppingItems: Loaded ${_shoppingItems.length} shopping items for user $userEmail');
        print('AppStateProvider._loadShoppingItems: Using key: $shoppingItemsKey');
        print('AppStateProvider._loadShoppingItems: Shopping items:');
        for (final item in _shoppingItems) {
          print('  - ${item.name} (ID: ${item.id})');
        }
      }
    } catch (e) {
    _shoppingItems = [];
      if (kDebugMode) {
        print('AppStateProvider._loadShoppingItems: Error loading shopping items: $e');
      }
    }
    // Don't call notifyListeners here - it will be called by initialize
  }
  
  Future<void> addShoppingItem(ShoppingItem item) async {
    if (kDebugMode) {
      print('AppStateProvider.addShoppingItem: Attempting to add shopping item ${item.id}');
      print('AppStateProvider.addShoppingItem: Current shopping items count: ${_shoppingItems.length}');
    }
    
    _shoppingItems.add(item);
    
    // Save to local storage with user-specific key
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email;
    if (userEmail != null) {
      final sanitizedEmail = userEmail.replaceAll('@', '_at_').replaceAll('.', '_');
      final shoppingItemsKey = '${sanitizedEmail}_shopping_items';
      final shoppingItemsJson = jsonEncode(_shoppingItems.map((i) => i.toJson()).toList());
      await prefs.setString(shoppingItemsKey, shoppingItemsJson);
      
      if (kDebugMode) {
        print('AppStateProvider.addShoppingItem: Added shopping item ${item.id} for user $userEmail');
        print('AppStateProvider.addShoppingItem: Using key: $shoppingItemsKey');
        print('AppStateProvider.addShoppingItem: Total shopping items after add: ${_shoppingItems.length}');
      }
    } else {
      if (kDebugMode) {
        print('AppStateProvider.addShoppingItem: No user email found, cannot save');
      }
    }
    notifyListeners();
  }
  
  Future<void> removeShoppingItem(ShoppingItem item) async {
    if (kDebugMode) {
      print('AppStateProvider.removeShoppingItem: Attempting to remove shopping item ${item.id}');
    }
    
    _shoppingItems.remove(item);
    
    // Remove from local storage with user-specific key
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email;
    if (userEmail != null) {
      final sanitizedEmail = userEmail.replaceAll('@', '_at_').replaceAll('.', '_');
      final shoppingItemsKey = '${sanitizedEmail}_shopping_items';
      final shoppingItemsJson = jsonEncode(_shoppingItems.map((i) => i.toJson()).toList());
      await prefs.setString(shoppingItemsKey, shoppingItemsJson);
      
      if (kDebugMode) {
        print('AppStateProvider.removeShoppingItem: Removed shopping item ${item.id} for user $userEmail');
        print('AppStateProvider.removeShoppingItem: Using key: $shoppingItemsKey');
      }
    }
    notifyListeners();
  }
  
  Future<void> updateShoppingItem(ShoppingItem item) async {
    if (kDebugMode) {
      print('AppStateProvider.updateShoppingItem: Attempting to update shopping item ${item.id}');
    }
    
    final index = _shoppingItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _shoppingItems[index] = item;
      
      // Update in local storage with user-specific key
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email;
      if (userEmail != null) {
        final sanitizedEmail = userEmail.replaceAll('@', '_at_').replaceAll('.', '_');
        final shoppingItemsKey = '${sanitizedEmail}_shopping_items';
        final shoppingItemsJson = jsonEncode(_shoppingItems.map((i) => i.toJson()).toList());
        await prefs.setString(shoppingItemsKey, shoppingItemsJson);
        
        if (kDebugMode) {
          print('AppStateProvider.updateShoppingItem: Updated shopping item ${item.id} for user $userEmail');
          print('AppStateProvider.updateShoppingItem: Using key: $shoppingItemsKey');
        }
      }
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email;
      if (userEmail != null) {
        final sanitizedEmail = userEmail.replaceAll('@', '_at_').replaceAll('.', '_');
        final trackingMetricsKey = '${sanitizedEmail}_tracking_metrics';
        final trackingMetricsJson = prefs.getString(trackingMetricsKey);
        
        if (trackingMetricsJson != null) {
          final List<dynamic> metricsList = jsonDecode(trackingMetricsJson);
          _trackingMetrics = metricsList
              .map((json) => TrackingMetric.fromJson(json as Map<String, dynamic>))
              .toList();
          
          if (kDebugMode) {
            print('AppStateProvider._loadTrackingMetrics: Loaded ${_trackingMetrics.length} tracking metrics for user $userEmail');
          }
        } else {
          _trackingMetrics = [];
          if (kDebugMode) {
            print('AppStateProvider._loadTrackingMetrics: No tracking metrics found for user $userEmail');
          }
        }
      } else {
        _trackingMetrics = [];
        if (kDebugMode) {
          print('AppStateProvider._loadTrackingMetrics: No user email found');
        }
      }
    } catch (e) {
    _trackingMetrics = [];
      if (kDebugMode) {
        print('AppStateProvider._loadTrackingMetrics: Error loading tracking metrics: $e');
      }
    }
    // Don't call notifyListeners here - it will be called by initialize
  }
  
  Future<void> addTrackingMetric(TrackingMetric metric) async {
    _trackingMetrics.add(metric);
    
    // Save to local storage with user-specific key
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email;
    if (userEmail != null) {
      final sanitizedEmail = userEmail.replaceAll('@', '_at_').replaceAll('.', '_');
      final trackingMetricsKey = '${sanitizedEmail}_tracking_metrics';
      final trackingMetricsJson = jsonEncode(_trackingMetrics.map((m) => m.toJson()).toList());
      await prefs.setString(trackingMetricsKey, trackingMetricsJson);
      
      if (kDebugMode) {
        print('AppStateProvider.addTrackingMetric: Added tracking metric ${metric.id} for user $userEmail');
        print('AppStateProvider.addTrackingMetric: Total tracking metrics after add: ${_trackingMetrics.length}');
      }
    } else {
      if (kDebugMode) {
        print('AppStateProvider.addTrackingMetric: No user email found, cannot save');
      }
    }
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
      
      // Save to local storage with user-specific key
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email;
      if (userEmail != null) {
        final sanitizedEmail = userEmail.replaceAll('@', '_at_').replaceAll('.', '_');
        final trackingMetricsKey = '${sanitizedEmail}_tracking_metrics';
        final trackingMetricsJson = jsonEncode(_trackingMetrics.map((m) => m.toJson()).toList());
        await prefs.setString(trackingMetricsKey, trackingMetricsJson);
        
        if (kDebugMode) {
          print('AppStateProvider.updateTrackingMetric: Updated tracking metric ${metric.id} for user $userEmail');
        }
      } else {
        if (kDebugMode) {
          print('AppStateProvider.updateTrackingMetric: No user email found, cannot save');
        }
      }
      notifyListeners();
    }
  }
  
  Future<void> removeTrackingMetric(TrackingMetric metric) async {
    _trackingMetrics.removeWhere((m) => m.id == metric.id);
    
    // Save to local storage with user-specific key
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email;
    if (userEmail != null) {
      final sanitizedEmail = userEmail.replaceAll('@', '_at_').replaceAll('.', '_');
      final trackingMetricsKey = '${sanitizedEmail}_tracking_metrics';
      final trackingMetricsJson = jsonEncode(_trackingMetrics.map((m) => m.toJson()).toList());
      await prefs.setString(trackingMetricsKey, trackingMetricsJson);
      
      if (kDebugMode) {
        print('AppStateProvider.removeTrackingMetric: Removed tracking metric ${metric.id} for user $userEmail');
        print('AppStateProvider.removeTrackingMetric: Total tracking metrics after remove: ${_trackingMetrics.length}');
      }
    } else {
      if (kDebugMode) {
        print('AppStateProvider.removeTrackingMetric: No user email found, cannot save');
      }
    }
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
  
  // Refresh only saved posts (for when navigating back to feed)
  Future<void> refreshSavedPosts() async {
    await _loadSavedPosts();
    notifyListeners();
  }
  
  // Refresh only shopping items (for when navigating to shopping screen)
  Future<void> refreshShoppingItems() async {
    await _loadShoppingItems();
    notifyListeners();
  }
  
  // Refresh only tracking metrics (for when navigating to tracking screen)
  Future<void> refreshTrackingMetrics() async {
    await _loadTrackingMetrics();
    notifyListeners();
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
    try {
      // Use API service to add comment (which handles user-specific storage)
      await _apiService.addComment(
        postId: postId,
        content: content,
        author: author,
      );
      
      // Refresh posts from API service to get updated data
      _posts = await _apiService.getPosts();
      notifyListeners();
      
      // Return the updated post
      return _posts.firstWhere((p) => p.id == postId);
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
    final prefs = await SharedPreferences.getInstance();
    // Use global posts key for community posts (shared across all users)
    final postsJson = prefs.getString('global_posts');
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
      await prefs.setString('global_posts', jsonEncode(postsData));
    }
    notifyListeners();
    return updatedPost;
  }
} 