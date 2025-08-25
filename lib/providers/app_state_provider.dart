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
  // Check if a Reddit post is saved
  bool isRedditPostSaved(String redditUrl) {
    // Check if this Reddit URL exists in our saved posts from database
    // For now, we'll track saved Reddit posts in memory
    return _savedRedditUrls.contains(redditUrl);
  }
  
  // Track saved Reddit URLs in memory
  Set<String> _savedRedditUrls = {};
  
  // Get saved posts (both community and Reddit posts)
  List<Post> get savedPosts {
    final savedCommunityPosts = _posts.where((post) => post.isSaved).toList();
    
    if (kDebugMode) {
      print('AppStateProvider.savedPosts: Found ${savedCommunityPosts.length} saved community posts');
      print('AppStateProvider.savedPosts: Found ${_savedRedditUrls.length} saved Reddit URLs');
    }
    
    // Convert saved Reddit URLs to Post objects with actual titles
    final savedRedditPosts = _savedRedditUrls.map((url) {
      // Try to find the original post title from the database
      final savedPost = _posts.firstWhere(
        (post) => post.content == url,
        orElse: () => Post(
          title: 'Saved Reddit Post',
          content: url,
          author: 'Reddit',
          petType: 'All',
          postType: 'reddit', // Ensure this is set to reddit
          redditUrl: url,
          isSaved: true,
          createdAt: DateTime.now(),
        ),
      );
      
      if (kDebugMode) {
        print('AppStateProvider.savedPosts: Processing saved post - title: ${savedPost.title}, postType: ${savedPost.postType}, content: ${savedPost.content}');
      }
      
      // Ensure the post type is set to reddit for saved Reddit posts
      if (savedPost.content.startsWith('http')) {
        final redditPost = savedPost.copyWith(
          postType: 'reddit',
          redditUrl: savedPost.content,
        );
        
        if (kDebugMode) {
          print('AppStateProvider.savedPosts: Converted to reddit post - title: ${redditPost.title}, postType: ${redditPost.postType}');
        }
        
        return redditPost;
      }
      
      return savedPost;
    }).toList();
    
    if (kDebugMode) {
      print('AppStateProvider.savedPosts: Returning ${savedCommunityPosts.length} community posts + ${savedRedditPosts.length} reddit posts');
    }
    
    return [...savedCommunityPosts, ...savedRedditPosts];
  }
  
  // Get count of saved posts
  int get savedPostsCount {
    final savedCommunityCount = _posts.where((post) => post.isSaved).length;
    final savedRedditCount = _savedRedditUrls.length;
    return savedCommunityCount + savedRedditCount;
  }
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Computed properties
  int get petsCount => pets.length;
  int get shoppingItemsCount => shoppingItems.length;
  int get trackingMetricsCount => trackingMetrics.length;
  
  // Initialize app state
  Future<void> initialize() async {
    try {
      await Future.wait([
        _loadPets(),
        loadPosts(),
        _loadShoppingItems(),
        _loadTrackingMetrics(),
        _loadSavedRedditUrls(), // Load saved Reddit URLs
      ]);
      
      if (kDebugMode) {
        print('AppStateProvider: Initialization complete');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error during initialization: $e');
      }
    }
  }
  
  // Pet management
  Future<void> _loadPets() async {
    try {
      if (kDebugMode) {
        print('AppStateProvider._loadPets: Starting to load pets...');
        final currentUserId = await SupabaseService.getCurrentUserId();
        print('AppStateProvider._loadPets: Current user ID: $currentUserId');
      }
      
      final pets = await SupabaseService.getPets();
      _pets = pets.map((p) => Pet.fromJson(p)).toList();
      
      if (kDebugMode) {
        print('AppStateProvider._loadPets: Loaded ${_pets.length} pets from Supabase');
        if (_pets.isNotEmpty) {
          print('AppStateProvider._loadPets: Pet names: ${_pets.map((p) => p.name).join(", ")}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error loading pets: $e');
        print('AppStateProvider: Stack trace: ${StackTrace.current}');
      }
      rethrow;
    }
  }
  
  Future<void> addPet(Pet pet) async {
    try {
      final createdPet = await SupabaseService.createPet(pet.toJson());
      await _loadPets(); // Reload pets from database
      // Add default tracking metrics for the new pet using the created pet's ID
      if (createdPet != null && createdPet['id'] != null) {
        await addDefaultMetricsForPet(createdPet['id']);
      }
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
  Future<void> loadPosts() async {
    try {
      final posts = await SupabaseService.getPosts();
      _posts = posts.map((p) => Post.fromJson(p)).toList();
      
      if (kDebugMode) {
        print('AppStateProvider.loadPosts: Loaded ${_posts.length} posts from Supabase');
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
      await loadPosts(); // Reload posts from database
      notifyListeners();
    } catch (e) {
      _setError('Failed to add post: $e');
      rethrow;
    }
  }
  
  Future<void> updatePost(String id, Post post) async {
    try {
      await SupabaseService.updatePost(id, post.toJson());
      await loadPosts(); // Reload posts from database
        notifyListeners();
    } catch (e) {
      _setError('Failed to update post: $e');
      rethrow;
    }
  }
  
  Future<void> removePost(String id) async {
    try {
      await SupabaseService.deletePost(id);
      await loadPosts(); // Reload posts from database
        notifyListeners();
    } catch (e) {
      _setError('Failed to remove post: $e');
      rethrow;
    }
  }
  
  // Saved posts management
  Future<void> savePost(Post post) async {
    try {
      if (kDebugMode) {
        print('AppStateProvider.savePost: Saving post: ${post.title} (ID: ${post.id})');
        print('AppStateProvider.savePost: Post type: ${post.postType}');
        print('AppStateProvider.savePost: Reddit URL: ${post.redditUrl}');
      }
      
      if (post.postType == 'reddit') {
        // For Reddit posts, save the Reddit URL to user's saved posts
        if (post.redditUrl != null) {
          // Check if already saved to prevent duplicates
          if (isRedditPostSaved(post.redditUrl!)) {
            if (kDebugMode) {
              print('AppStateProvider.savePost: Reddit post already saved, skipping');
            }
            return;
          }
          
          await _saveRedditPost(post.redditUrl!, post.title, post.petType);
          if (kDebugMode) {
            print('AppStateProvider.savePost: Saved Reddit post URL: ${post.redditUrl}');
          }
          
          // Don't add saved Reddit posts to the main feed
          // They should only appear in the saved posts section
          
          // Update UI immediately
          notifyListeners();
        } else {
          if (kDebugMode) {
            print('AppStateProvider.savePost: Reddit post has no URL, cannot save');
          }
          return;
        }
      } else {
        // For community posts, save the actual post data
        if (post.id != null && _isValidUUID(post.id!)) {
          await SupabaseService.updatePost(post.id!, {'is_saved': true});
          
          // Update the local post in the posts list
          final postIndex = _posts.indexWhere((p) => p.id == post.id);
          if (postIndex != -1) {
            _posts[postIndex] = _posts[postIndex].copyWith(isSaved: true);
          }
          
          if (kDebugMode) {
            print('AppStateProvider.savePost: Saved community post with ID: ${post.id}');
          }
        } else {
          if (kDebugMode) {
            print('AppStateProvider.savePost: Invalid UUID for community post: ${post.id}');
          }
          return;
        }
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider.savePost: Error saving post: $e');
      }
      // Show error to user instead of failing silently
      _setError('Failed to save post: $e');
      rethrow;
    }
  }
  
  Future<void> unsavePost(Post post) async {
    try {
      if (kDebugMode) {
        print('AppStateProvider.unsavePost: Unsaving post: ${post.title} (ID: ${post.id})');
      }
      
      if (post.postType == 'reddit') {
        // For Reddit posts, remove the Reddit URL from user's saved posts
        if (post.redditUrl != null) {
          await _unsaveRedditPost(post.redditUrl!);
          if (kDebugMode) {
            print('AppStateProvider.unsavePost: Unsaved Reddit post URL: ${post.redditUrl}');
          }
          
          // Remove saved Reddit URL from memory
          _savedRedditUrls.remove(post.redditUrl!);
          if (kDebugMode) {
            print('AppStateProvider.unsavePost: Removed from saved Reddit URLs: ${post.redditUrl}');
          }
          
          // Update UI immediately
          notifyListeners();
        }
      } else {
        // For community posts, unsave the actual post data
        if (post.id != null && _isValidUUID(post.id!)) {
          await SupabaseService.updatePost(post.id!, {'is_saved': false});
          
          // Update the local post in the posts list
          final postIndex = _posts.indexWhere((p) => p.id == post.id);
          if (postIndex != -1) {
            _posts[postIndex] = _posts[postIndex].copyWith(isSaved: false);
          }
          
          if (kDebugMode) {
            print('AppStateProvider.unsavePost: Unsaved community post with ID: ${post.id}');
          }
        } else {
          if (kDebugMode) {
            print('AppStateProvider.unsavePost: Invalid UUID for community post: ${post.id}');
          }
          return;
        }
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider.unsavePost: Error unsaving post: $e');
      }
      // Show error to user instead of failing silently
      _setError('Failed to unsave post: $e');
      rethrow;
    }
  }
  
  // Helper method to save Reddit post URL
  Future<void> _saveRedditPost(String redditUrl, String title, String petType) async {
    try {
      await SupabaseService.saveRedditPost(redditUrl, title, petType);
      
      // Add to in-memory tracking for immediate UI update
      _savedRedditUrls.add(redditUrl);
    notifyListeners();
  
    if (kDebugMode) {
        print('AppStateProvider._saveRedditPost: Saved Reddit URL: $redditUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider._saveRedditPost: Error: $e');
      }
      rethrow;
    }
  }
  
  // Helper method to unsave Reddit post URL
  Future<void> _unsaveRedditPost(String redditUrl) async {
    try {
      await SupabaseService.unsaveRedditPost(redditUrl);
      
      // Remove from in-memory tracking for immediate UI update
      _savedRedditUrls.remove(redditUrl);
      notifyListeners();
      
    if (kDebugMode) {
        print('AppStateProvider._unsaveRedditPost: Unsaved Reddit URL: $redditUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider._unsaveRedditPost: Error: $e');
      }
      rethrow;
    }
  }
  
  Future<void> _loadSavedRedditUrls() async {
    try {
      if (kDebugMode) {
        print('AppStateProvider._loadSavedRedditUrls: Loading saved Reddit URLs from database');
      }
      
      final savedPosts = await SupabaseService.getSavedRedditPosts();
      _savedRedditUrls = savedPosts
          .map((post) => post['reddit_url'] as String) // Get URL from reddit_url field
          .toSet();
      
      if (kDebugMode) {
        print('AppStateProvider._loadSavedRedditUrls: Loaded ${savedPosts.length} saved Reddit posts');
        print('AppStateProvider._loadSavedRedditUrls: URLs: ${_savedRedditUrls.join(", ")}');
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider._loadSavedRedditUrls: Error loading saved Reddit posts: $e');
      }
      // Don't rethrow - let the app continue with empty saved posts
      _savedRedditUrls = {};
    }
  }
  
  // Helper method to validate UUID format
  bool _isValidUUID(String? uuid) {
    if (uuid == null) return false;
    // UUID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
    return uuidRegex.hasMatch(uuid);
  }
  
  // Shopping items management
  Future<void> _loadShoppingItems() async {
    try {
      // Load user's saved shopping items from Supabase
      final items = await SupabaseService.getShoppingItems();
      _shoppingItems = items;
      
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
      if (kDebugMode) {
        print('AppStateProvider._loadTrackingMetrics: Loading tracking metrics from database');
      }
      
      // Get current user ID
      final userId = await SupabaseService.getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) {
          print('AppStateProvider._loadTrackingMetrics: No user ID found');
        }
        _trackingMetrics = [];
        return;
      }
      
      // Load all pets for the user
      final pets = await SupabaseService.getPets();
      if (pets.isEmpty) {
        if (kDebugMode) {
          print('AppStateProvider._loadTrackingMetrics: No pets found');
        }
        _trackingMetrics = [];
        return;
      }
      
      // Load tracking metrics for all pets
      final allMetrics = <TrackingMetric>[];
      for (final pet in pets) {
        try {
          final petId = pet['id'] as String?;
          final petName = pet['name'] as String?;
          
          if (petId == null) {
            if (kDebugMode) {
              print('AppStateProvider._loadTrackingMetrics: Pet has no ID, skipping');
            }
            continue;
          }
          
          final petMetrics = await SupabaseService.getTrackingMetricsForPet(petId);
          for (final metricData in petMetrics) {
            try {
              final metric = TrackingMetric.fromJson(metricData);
              allMetrics.add(metric);
              if (kDebugMode) {
                print('AppStateProvider._loadTrackingMetrics: Loaded metric: ${metric.name} for pet: ${petName ?? 'Unknown'}');
              }
            } catch (e) {
              if (kDebugMode) {
                print('AppStateProvider._loadTrackingMetrics: Error parsing metric: $e');
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('AppStateProvider._loadTrackingMetrics: Error loading metrics for pet: $e');
          }
        }
      }
      
      _trackingMetrics = allMetrics;
      
      if (kDebugMode) {
        print('AppStateProvider._loadTrackingMetrics: Loaded ${_trackingMetrics.length} tracking metrics');
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error loading tracking metrics: $e');
      }
      _trackingMetrics = [];
      // Don't rethrow - let the app continue
    }
  }
  
  Future<void> addDefaultMetricsForPet(String petId) async {
    try {
      if (kDebugMode) {
        print('AppStateProvider: Adding default metrics for pet $petId');
      }
      
      // Create simple, bulletproof default metrics
      final defaultMetrics = [
        {
          'pet_id': petId,
          'name': 'Weight',
          'category': 'Health',
          'unit': 'lbs',
          'target_value': 0.0,
          'current_value': 0.0,
          'frequency': 'daily',
          'description': 'Weight tracking',
          'is_active': true,
        },
        {
          'pet_id': petId,
          'name': 'Food Intake',
          'category': 'Nutrition',
          'unit': 'cups',
          'target_value': 0.0,
          'current_value': 0.0,
          'frequency': 'daily',
          'description': 'Food intake tracking',
          'is_active': true,
        },
        {
          'pet_id': petId,
          'name': 'Exercise',
          'category': 'Activity',
          'unit': 'minutes',
          'target_value': 0.0,
          'current_value': 0.0,
          'frequency': 'daily',
          'description': 'Exercise tracking',
          'is_active': true,
        },
      ];
      
      for (final metric in defaultMetrics) {
        try {
          await SupabaseService.createTrackingMetric(metric);
          if (kDebugMode) {
            print('AppStateProvider: Successfully created metric: ${metric['name']}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('AppStateProvider: Failed to create metric ${metric['name']}: $e');
          }
          // Continue with other metrics even if one fails
        }
      }
      
      if (kDebugMode) {
        print('AppStateProvider: Finished adding default tracking metrics for pet $petId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error adding default metrics: $e');
      }
      // Don't rethrow - let the app continue
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
      if (kDebugMode) {
        print('AppStateProvider: Adding tracking metric: ${metric.name}');
        print('AppStateProvider: Pet ID: ${metric.petId}');
        print('AppStateProvider: Current user ID: ${SupabaseService.getCurrentUserId()}');
        print('AppStateProvider: Current metrics count: ${_trackingMetrics.length}');
      }
      
      // Create metric with temporary ID for immediate display
      final displayMetric = TrackingMetric(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        name: metric.name,
        frequency: metric.frequency,
        petId: metric.petId,
        targetValue: metric.targetValue,
        currentValue: metric.currentValue,
        description: metric.description,
        isActive: metric.isActive,
        category: metric.category,
      );
      
      // IMMEDIATELY add to local list and update UI
      _trackingMetrics.add(displayMetric);
      notifyListeners(); // CRITICAL: Update UI FIRST
      
      if (kDebugMode) {
        print('AppStateProvider: IMMEDIATELY added metric to UI, total metrics now: ${_trackingMetrics.length}');
      }
      
      // Now try to save to database in background
      try {
        final metricData = {
          'name': metric.name,
          'category': metric.category ?? 'Health',
          'pet_id': metric.petId,
          'target_value': metric.targetValue,
          'current_value': metric.currentValue,
          'frequency': metric.frequency,
          'description': metric.description ?? '',
          'is_active': metric.isActive,
          'unit': metric.description ?? '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        await SupabaseService.createTrackingMetric(metricData);
        
        if (kDebugMode) {
          print('AppStateProvider: Successfully saved tracking metric to database');
        }
      } catch (dbError) {
        if (kDebugMode) {
          print('AppStateProvider: Database save failed but metric is still visible: $dbError');
        }
        // Keep the metric in UI even if database save fails
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error adding tracking metric: $e');
      }
      // Don't rethrow - let the app continue
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

  Future<void> refreshTrackingMetrics() async {
    if (kDebugMode) {
      print('AppStateProvider: Refreshing tracking metrics...');
    }
    await _loadTrackingMetrics();
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
      await SupabaseService.addShoppingItem(item);
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
      await SupabaseService.updateShoppingItem(item);
      await _loadShoppingItems(); // Reload from database
      notifyListeners();
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
      _savedRedditUrls.clear();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error clearing user data: $e');
      }
      rethrow;
    }
  }

  // Force refresh user data (for account switching)
  Future<void> refreshForNewUser() async {
    try {
      if (kDebugMode) {
        print('AppStateProvider: Refreshing data for new user');
      }
      await clearAllUserData();
      await initialize();
      if (kDebugMode) {
        print('AppStateProvider: Data refresh complete - ${_pets.length} pets, ${_shoppingItems.length} shopping items');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error refreshing for new user: $e');
      }
      rethrow;
    }
  }
} 