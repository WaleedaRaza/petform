import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../services/shopping_service.dart';
import '../services/tracking_service.dart';
import '../models/pet.dart';
import '../models/post.dart';
import '../models/shopping_item.dart';
import '../models/tracking_metric.dart';

class AppStateProvider with ChangeNotifier {
  // UI state
  bool _isLoading = false;
  String? _errorMessage;
  
  // Data state
  List<Pet> _pets = [];
  List<Post> _posts = [];
  List<ShoppingItem> _shoppingItems = [];
  List<TrackingMetric> _trackingMetrics = [];
  
  // Getters
  List<Pet> get pets => _pets;
  List<Post> get posts => _posts;
  List<ShoppingItem> get shoppingItems => _shoppingItems;
  List<TrackingMetric> get trackingMetrics => _trackingMetrics;
  List<Post> get savedPosts => _posts.where((post) => post.isSaved).toList();
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
      await Future.wait([
        _loadPets(),
        _loadPosts(),
        _loadShoppingItems(),
        _loadTrackingMetrics(),
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
      final pets = await SupabaseService.getPets();
      _pets = pets.map((p) => Pet.fromJson(p)).toList();
      
      if (kDebugMode) {
        print('AppStateProvider._loadPets: Loaded ${_pets.length} pets from Supabase');
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
      await SupabaseService.createPet(pet.toJson());
      await _loadPets(); // Reload pets from database
      // Add default tracking metrics for the new pet
      await addDefaultMetricsForPet(pet.id!);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add pet: $e');
      rethrow;
    }
  }
  
  Future<void> updatePet(String id, Pet pet) async {
    try {
      await SupabaseService.updatePet(id, pet.toJson());
      await _loadPets(); // Reload pets from database
      notifyListeners();
    } catch (e) {
      _setError('Failed to update pet: $e');
      rethrow;
    }
  }
  
  Future<void> removePet(String id) async {
    try {
      await SupabaseService.deletePet(id);
      await _loadPets(); // Reload pets from database
      notifyListeners();
    } catch (e) {
      _setError('Failed to remove pet: $e');
      rethrow;
    }
  }
  
  // Post management
  Future<void> _loadPosts() async {
    try {
      final posts = await SupabaseService.getPosts();
      _posts = posts.map((p) => Post.fromJson(p)).toList();
      
      if (kDebugMode) {
        print('AppStateProvider._loadPosts: Loaded ${_posts.length} posts from Supabase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error loading posts: $e');
      }
      rethrow;
    }
  }
  
  Future<void> addPost(Post post) async {
    try {
      await SupabaseService.createPost(post.toJson());
      await _loadPosts(); // Reload posts from database
      notifyListeners();
    } catch (e) {
      _setError('Failed to add post: $e');
      rethrow;
    }
  }
  
  Future<void> updatePost(String id, Post post) async {
    try {
      await SupabaseService.updatePost(id, post.toJson());
      await _loadPosts(); // Reload posts from database
        notifyListeners();
    } catch (e) {
      _setError('Failed to update post: $e');
      rethrow;
    }
  }
  
  Future<void> removePost(String id) async {
    try {
      await SupabaseService.deletePost(id);
      await _loadPosts(); // Reload posts from database
        notifyListeners();
    } catch (e) {
      _setError('Failed to remove post: $e');
      rethrow;
    }
  }
  
  // Saved posts management
  Future<void> savePost(String postId) async {
    try {
      await SupabaseService.updatePost(postId, {'is_saved': true});
      await _loadPosts(); // Reload posts from database
      notifyListeners();
    } catch (e) {
      _setError('Failed to save post: $e');
      rethrow;
    }
  }
  
  Future<void> unsavePost(String postId) async {
    try {
      await SupabaseService.updatePost(postId, {'is_saved': false});
      await _loadPosts(); // Reload posts from database
      notifyListeners();
    } catch (e) {
      _setError('Failed to unsave post: $e');
      rethrow;
    }
  }
  
  // Shopping items management
  Future<void> _loadShoppingItems() async {
    try {
      // Load user's saved shopping items from Supabase
      final items = await SupabaseService.getShoppingItems();
      _shoppingItems = items.map((item) => ShoppingItem.fromJson(item)).toList();
      
      if (kDebugMode) {
        print('AppStateProvider._loadShoppingItems: Loaded ${_shoppingItems.length} user shopping items');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error loading shopping items: $e');
      }
      // Initialize with empty list if no items found
      _shoppingItems = [];
    }
  }
  
  // Tracking metrics management
  Future<void> _loadTrackingMetrics() async {
    try {
      // For now, we'll load tracking metrics when needed for specific pets
      _trackingMetrics = [];
      
      if (kDebugMode) {
        print('AppStateProvider._loadTrackingMetrics: Tracking metrics loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error loading tracking metrics: $e');
      }
      rethrow;
    }
  }
  
  Future<void> addDefaultMetricsForPet(String petId) async {
    try {
      // Add default tracking metrics for the pet
      final defaultMetrics = [
        {
          'pet_id': petId,
          'name': 'Weight',
          'category': 'Health',
          'unit': 'lbs',
          'target_value': null,
        },
        {
          'pet_id': petId,
          'name': 'Food Intake',
          'category': 'Nutrition',
          'unit': 'cups',
          'target_value': null,
        },
        {
          'pet_id': petId,
          'name': 'Exercise',
          'category': 'Activity',
          'unit': 'minutes',
          'target_value': null,
        },
      ];
      
      for (final metric in defaultMetrics) {
        await SupabaseService.createTrackingMetric(metric);
      }
      
    if (kDebugMode) {
        print('AppStateProvider: Added default tracking metrics for pet $petId');
    }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error adding default metrics: $e');
      }
      rethrow;
    }
  }
  
  // Error handling
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void clearError() {
    _setError(null);
    }
    
  // Tracking Metrics Methods
  List<TrackingMetric> getMetricsOnTrack() {
    return _trackingMetrics.where((metric) => metric.status == 'On Track').toList();
  }
  
  List<TrackingMetric> getMetricsNeedingAttention() {
    return _trackingMetrics.where((metric) => metric.status == 'Needs Attention').toList();
  }
  
  List<TrackingMetric> getRecentMetrics() {
    // Return the 5 most recent metrics
    final sorted = List<TrackingMetric>.from(_trackingMetrics);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }
  
  Future<void> addTrackingMetric(TrackingMetric metric) async {
    try {
      await SupabaseService.createTrackingMetric(metric.toJson());
      await _loadTrackingMetrics();
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error adding tracking metric: $e');
      }
      rethrow;
    }
  }

  Future<void> updateTrackingMetric(String id, TrackingMetric metric) async {
    try {
      await SupabaseService.updateTrackingMetric(id, metric.toJson());
      await _loadTrackingMetrics();
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error updating tracking metric: $e');
  }
      rethrow;
    }
  }

  Future<void> removeTrackingMetric(String id) async {
    try {
      await SupabaseService.deleteTrackingMetric(id);
      await _loadTrackingMetrics();
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error removing tracking metric: $e');
      }
      rethrow;
    }
  }

  List<TrackingMetric> getMetricsByPet(String petId) {
    return _trackingMetrics.where((metric) => metric.petId == petId).toList();
  }
  
  // Shopping Items Methods
  Future<void> refreshShoppingItems() async {
    try {
      await _loadShoppingItems();
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error refreshing shopping items: $e');
      }
      rethrow;
    }
  }

  Future<void> addShoppingItem(ShoppingItem item) async {
    try {
      await SupabaseService.addShoppingItem(item.toJson());
      await _loadShoppingItems(); // Reload from database
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error adding shopping item: $e');
      }
      rethrow;
    }
  }

  Future<void> updateShoppingItem(String id, ShoppingItem item) async {
    try {
      final index = _shoppingItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        _shoppingItems[index] = item;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error updating shopping item: $e');
      }
      rethrow;
    }
  }

  Future<void> removeShoppingItem(String itemId) async {
    try {
      await SupabaseService.removeShoppingItem(itemId);
      await _loadShoppingItems(); // Reload from database
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error removing shopping item: $e');
      }
      rethrow;
    }
  }

  Future<void> clearShoppingList() async {
    try {
      await SupabaseService.clearShoppingList();
      await _loadShoppingItems(); // Reload from database
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error clearing shopping list: $e');
      }
      rethrow;
    }
  }

  // User Data Methods
  Future<void> clearAllUserData() async {
    try {
      _pets.clear();
      _posts.clear();
      _trackingMetrics.clear();
      _shoppingItems.clear();
        notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error clearing user data: $e');
      }
      rethrow;
    }
  }
} 