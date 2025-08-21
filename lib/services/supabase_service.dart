import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/post.dart';
import '../models/shopping_item.dart';
import 'auth0_jwt_service.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  // ===== AUTHENTICATION METHODS =====
  
  static Future<AuthResponse> signUp(String email, String password) async {
    try {
      if (kDebugMode) {
        print('SupabaseService: Attempting to sign up user: $email');
      }
      
      final response = await client.auth.signUp(email: email, password: password);
      
      if (kDebugMode) {
        print('SupabaseService: User signed up successfully: ${response.user?.email}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Sign up error: $e');
      }
      rethrow;
    }
  }
  
  static Future<AuthResponse> signIn(String email, String password) async {
    try {
      if (kDebugMode) {
        print('SupabaseService: Attempting to sign in user: $email');
      }
      
      final response = await client.auth.signInWithPassword(email: email, password: password);
      
      if (kDebugMode) {
        print('SupabaseService: User signed in successfully: ${response.user?.email}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Sign in error: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
      if (kDebugMode) {
        print('SupabaseService: User signed out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Sign out error: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
      if (kDebugMode) {
        print('SupabaseService: Password reset email sent to $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Reset password error: $e');
      }
      rethrow;
    }
  }
  
  // Get current user
  static User? get currentUser => null; // We use Auth0JWTService instead
  
  // Get current user ID
  static String? getCurrentUserId() {
    final auth0User = Auth0JWTService.instance.currentUser;
    if (auth0User != null) {
      return 'auth0_${auth0User.sub}';
    }
    return null;
  }
  
  // Get or create username for current user
  static Future<String?> getOrCreateUsername(String email, String? displayName) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) {
          print('SupabaseService: No user ID available for username creation');
        }
        return null;
      }
      
      // For now, just return a simple username
      final username = displayName ?? email.split('@')[0];
      
      if (kDebugMode) {
        print('SupabaseService: Username created/retrieved: $username');
      }
      
      return username;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting/creating username: $e');
      }
      return null;
    }
  }
  
  // Get user profile (including username and display name)
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) {
          print('SupabaseService: No user ID available for profile retrieval');
        }
        return null;
      }
      
      // Try to get profile from database
      Map<String, dynamic>? response;
      try {
        response = await client
            .from('profiles')
            .select('*')
            .eq('id', userId)
            .maybeSingle();
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error getting profile from database: $e');
        }
      }
      
      // If no profile exists, create a basic one from Auth0 data
      if (response == null) {
        final auth0User = Auth0JWTService.instance.currentUser;
        if (auth0User != null) {
          response = {
            'id': userId,
            'email': auth0User.email,
            'username': auth0User.nickname ?? auth0User.name ?? 'user',
            'display_name': auth0User.name ?? 'User',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };
        }
      }
      
      if (kDebugMode) {
        print('SupabaseService: User profile retrieved: $response');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting user profile: $e');
      }
      return null;
    }
  }
  
  // Update display name for current user
  static Future<String?> updateDisplayName(String newDisplayName) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) {
          print('SupabaseService: No user ID available for display name update');
        }
        return null;
      }
      
      // Try to update profile in database
      try {
        await client
            .from('profiles')
            .upsert({
              'id': userId,
              'display_name': newDisplayName,
              'username': newDisplayName,
              'updated_at': DateTime.now().toIso8601String(),
            });
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error updating profile in database: $e');
        }
      }
      
      if (kDebugMode) {
        print('SupabaseService: Display name updated: $newDisplayName');
      }
      
      return newDisplayName;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error updating display name: $e');
      }
      rethrow;
    }
  }
  
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  static bool isEmailVerified() {
    return Auth0JWTService.instance.isEmailVerified;
  }
  
  static Future<void> resendEmailVerification() async {
    try {
      await client.auth.resend(
        type: OtpType.signup,
        email: Auth0JWTService.instance.currentUserEmail ?? '',
      );
      if (kDebugMode) {
        print('SupabaseService: Email verification resent');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Resend email verification error: $e');
      }
      rethrow;
    }
  }
  
  // ===== PROFILE METHODS =====
  
  static Future<void> createProfile(String email, String username) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('No user logged in');
      }
      
      await client.from('profiles').insert({
        'id': userId,
        'email': email,
        'username': username,
        'display_name': username,
      });
      
      if (kDebugMode) {
        print('SupabaseService: Profile created successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error creating profile: $e');
      }
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return null;
      
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting profile: $e');
      }
      return null;
    }
  }
  
  static Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('No user logged in');
      
      await client
          .from('profiles')
          .update(profileData)
          .eq('id', userId);
      
      if (kDebugMode) {
        print('SupabaseService: Profile updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error updating profile: $e');
      }
      rethrow;
    }
  }
  
  // ===== PET METHODS =====
  
  static Future<List<Map<String, dynamic>>> getPets() async {
    try {
      if (kDebugMode) {
        print('SupabaseService.getPets: Starting to get pets...');
      }
      
      final userId = getCurrentUserId();
      
      if (userId == null) {
        if (kDebugMode) {
          print('SupabaseService.getPets: ERROR - No user logged in');
        }
        throw Exception('No user logged in');
      }
      
      if (kDebugMode) {
        print('SupabaseService.getPets: Querying pets table for user_id: $userId');
      }
      
      final response = await client
          .from('pets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
          
      if (kDebugMode) {
        print('SupabaseService.getPets: Query returned ${response.length} pets');
        if (response.isNotEmpty) {
          print('SupabaseService.getPets: First pet: ${response.first}');
        }
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting pets: $e');
        print('SupabaseService: Stack trace: ${StackTrace.current}');
      }
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>?> createPet(Map<String, dynamic> petData) async {
    try {
      if (kDebugMode) {
        print('SupabaseService: Starting pet creation...');
      }
      
      final userId = getCurrentUserId();
      
      if (userId == null) throw Exception('No user logged in');
      
      petData['user_id'] = userId;
      
      if (kDebugMode) {
        print('SupabaseService: Creating pet with data: $petData');
      }
      
      final response = await client.from('pets').insert(petData).select();
      
      if (kDebugMode) {
        print('SupabaseService: Pet created successfully');
        print('SupabaseService: Created pet data: $response');
      }
      
      return response.isNotEmpty ? response.first : null;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error creating pet: $e');
        print('SupabaseService: Pet data that failed: $petData');
      }
      rethrow;
    }
  }
  
  static Future<void> updatePet(String id, Map<String, dynamic> petData) async {
    try {
      await client
          .from('pets')
          .update(petData)
          .eq('id', id);
      
      if (kDebugMode) {
        print('SupabaseService: Pet updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error updating pet: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> deletePet(String id) async {
    try {
      await client
          .from('pets')
          .delete()
          .eq('id', id);
      
      if (kDebugMode) {
        print('SupabaseService: Pet deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error deleting pet: $e');
      }
      rethrow;
    }
  }
  
  // ===== POST METHODS =====
  
  static Future<List<Map<String, dynamic>>> getPosts() async {
    try {
      final response = await client
          .from('posts')
          .select('*, comments(*)')
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting posts: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> createPost(Map<String, dynamic> postData) async {
    try {
      final userId = getCurrentUserId();
      
      if (userId == null) throw Exception('No user logged in');
      
      postData['user_id'] = userId;
      await client.from('posts').insert(postData);
      
      if (kDebugMode) {
        print('SupabaseService: Post created successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error creating post: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> updatePost(String id, Map<String, dynamic> postData) async {
    try {
      await client
          .from('posts')
          .update(postData)
          .eq('id', id);
      
      if (kDebugMode) {
        print('SupabaseService: Post updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error updating post: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> deletePost(String id) async {
    try {
      await client
          .from('posts')
          .delete()
          .eq('id', id);
      
      if (kDebugMode) {
        print('SupabaseService: Post deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error deleting post: $e');
      }
      rethrow;
    }
  }
  
  // ===== COMMENT METHODS =====
  
  static Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      final response = await client
          .from('comments')
          .select('*')
          .eq('post_id', postId)
          .order('created_at', ascending: true);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting comments: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> createComment(String postId, String content, String author) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('No user logged in');
      
      await client.from('comments').insert({
        'post_id': postId,
        'user_id': userId,
        'content': content,
        'author': author,
      });
      
      if (kDebugMode) {
        print('SupabaseService: Comment created successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error creating comment: $e');
      }
      rethrow;
    }
  }

  static Future<void> addComment(String postId, String content, String author) async {
    try {
      await client
          .from('comments')
          .insert({
            'post_id': postId,
            'content': content,
            'author': author,
            'created_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error adding comment: $e');
      }
      rethrow;
    }
  }

  static Future<void> deleteComment(String postId, String commentId) async {
    try {
      await client
          .from('comments')
          .delete()
          .eq('id', commentId)
          .eq('post_id', postId);
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error deleting comment: $e');
      }
      rethrow;
    }
  }

  static Future<Post> getPost(String postId) async {
    try {
      final response = await client
          .from('posts')
          .select()
          .eq('id', postId)
          .single();
      return Post.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting post: $e');
      }
      rethrow;
    }
  }
  
  // ===== TRACKING METHODS =====
  
  static Future<List<Map<String, dynamic>>> getTrackingMetrics(String userId) async {
    try {
      final response = await client
          .from('tracking_metrics')
          .select()
          .eq('user_id', userId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting tracking metrics: $e');
      }
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getTrackingMetricsForPet(String petId) async {
    try {
      final response = await client
          .from('tracking_metrics')
          .select()
          .eq('pet_id', petId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting tracking metrics for pet: $e');
      }
      rethrow;
    }
  }

  static Future<void> createTrackingMetric(Map<String, dynamic> metricData) async {
    try {
      // Ensure all required fields are present with defaults
      final safeData = {
        'name': metricData['name'] ?? 'Unknown Metric',
        'category': metricData['category'] ?? 'Health',
        'pet_id': metricData['pet_id'] ?? '',
        'target_value': metricData['target_value'] ?? 0.0,
        'current_value': metricData['current_value'] ?? 0.0,
        'frequency': metricData['frequency'] ?? 'daily',
        'description': metricData['description'] ?? '',
        'is_active': metricData['is_active'] ?? true,
        'unit': metricData['unit'] ?? '',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (kDebugMode) {
        print('SupabaseService: Creating tracking metric with data: $safeData');
      }
      
      await client
          .from('tracking_metrics')
          .insert(safeData);
          
      if (kDebugMode) {
        print('SupabaseService: Tracking metric created successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error creating tracking metric: $e');
        print('SupabaseService: Data that failed: $metricData');
      }
      rethrow;
    }
  }

  static Future<void> updateTrackingMetric(String id, Map<String, dynamic> metricData) async {
    try {
      await client
          .from('tracking_metrics')
          .update(metricData)
          .eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error updating tracking metric: $e');
      }
      rethrow;
    }
  }

  static Future<void> deleteTrackingMetric(String id) async {
    try {
      await client
          .from('tracking_metrics')
          .delete()
          .eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error deleting tracking metric: $e');
      }
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getTrackingEntries(String metricId) async {
    try {
      final response = await client
          .from('tracking_entries')
          .select()
          .eq('metric_id', metricId)
          .order('entry_date', ascending: false);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting tracking entries: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> createTrackingEntry(Map<String, dynamic> entryData) async {
    try {
      await client.from('tracking_entries').insert(entryData);
      
      if (kDebugMode) {
        print('SupabaseService: Tracking entry created successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error creating tracking entry: $e');
      }
      rethrow;
    }
  }
  
  // ===== REAL-TIME SUBSCRIPTIONS =====
  
  static RealtimeChannel subscribeToPosts(Function(Map<String, dynamic>) onData) {
    return client
        .channel('posts')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'posts',
          callback: (payload) => onData(payload.newRecord),
        )
        .subscribe();
  }
  
  static RealtimeChannel subscribeToComments(String postId, Function(Map<String, dynamic>) onData) {
    return client
        .channel('comments')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'comments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'post_id',
            value: postId,
          ),
          callback: (payload) => onData(payload.newRecord),
        )
        .subscribe();
  }
  
  // ===== FILE UPLOAD METHODS =====
  
  static Future<String> uploadFile(String bucket, String path, List<int> bytes) async {
    try {
      final response = await client.storage
          .from(bucket)
          .uploadBinary(path, Uint8List.fromList(bytes));
      
      if (kDebugMode) {
        print('SupabaseService: File uploaded successfully: $response');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error uploading file: $e');
      }
      rethrow;
    }
  }
  
  static String getPublicUrl(String bucket, String path) {
    return client.storage
        .from(bucket)
        .getPublicUrl(path);
  }
  
  static Future<void> deleteFile(String bucket, String path) async {
    try {
      await client.storage
          .from(bucket)
          .remove([path]);
      
      if (kDebugMode) {
        print('SupabaseService: File deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error deleting file: $e');
      }
      rethrow;
    }
  }

  // ===== SHOPPING METHODS =====
  
  // Helper function to convert ShoppingItem model to database format (camelCase to snake_case)
  static Map<String, dynamic> _shoppingItemToDb(ShoppingItem item, {bool includeId = false}) {
    final data = {
      'name': item.name,
      'category': item.category,
      'priority': item.priority,
      'estimated_cost': item.estimatedCost,
      'pet_id': item.petId,
      'description': item.description,
      'brand': item.brand,
      'store': item.store,
      'is_completed': item.isCompleted,
      'created_at': item.createdAt.toIso8601String(),
      'completed_at': item.completedAt?.toIso8601String(),
      'tags': item.tags,
      'image_url': item.imageUrl,
      'quantity': item.quantity,
      'notes': item.notes,
      'chewy_url': item.chewyUrl,
      'rating': item.rating,
      'review_count': item.reviewCount,
      'in_stock': item.inStock,
      'auto_ship': item.autoShip,
      'free_shipping': item.freeShipping,
    };
    
    // Only include ID if explicitly requested (for updates)
    if (includeId) {
      data['id'] = item.id;
    }
    
    return data;
  }

  // Helper function to convert database format to ShoppingItem model (snake_case to camelCase)
  static ShoppingItem _dbToShoppingItem(Map<String, dynamic> dbData) {
    return ShoppingItem(
      id: dbData['id'] as String,
      name: dbData['name'] as String,
      category: dbData['category'] as String,
      priority: dbData['priority'] as String,
      estimatedCost: (dbData['estimated_cost'] as num).toDouble(),
      petId: dbData['pet_id'] as String?,
      description: dbData['description'] as String?,
      brand: dbData['brand'] as String?,
      store: dbData['store'] as String?,
      isCompleted: dbData['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(dbData['created_at'] as String),
      completedAt: dbData['completed_at'] != null 
          ? DateTime.parse(dbData['completed_at'] as String) 
          : null,
      tags: (dbData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      imageUrl: dbData['image_url'] as String?,
      quantity: dbData['quantity'] as int? ?? 1,
      notes: dbData['notes'] as String?,
      chewyUrl: dbData['chewy_url'] as String?,
      rating: dbData['rating'] as double?,
      reviewCount: dbData['review_count'] as int?,
      inStock: dbData['in_stock'] as bool?,
      autoShip: dbData['auto_ship'] as bool?,
      freeShipping: dbData['free_shipping'] as bool?,
    );
  }

  static Future<List<ShoppingItem>> getShoppingItems() async {
    try {
      final userId = getCurrentUserId();
      
      if (userId == null) throw Exception('No user logged in');
      
      final response = await client
          .from('shopping_items')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List).map((item) => _dbToShoppingItem(item)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting shopping items: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> addShoppingItem(ShoppingItem item) async {
    try {
      final userId = getCurrentUserId();
      
      if (userId == null) throw Exception('No user logged in');
      
      final dbData = _shoppingItemToDb(item, includeId: false);
      dbData['user_id'] = userId;
      await client.from('shopping_items').insert(dbData);
      
      if (kDebugMode) {
        print('SupabaseService: Shopping item added successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error adding shopping item: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> updateShoppingItem(ShoppingItem item) async {
    try {
      final userId = getCurrentUserId();
      
      if (userId == null) throw Exception('No user logged in');
      
      final dbData = _shoppingItemToDb(item, includeId: true);
      await client
          .from('shopping_items')
          .update(dbData)
          .eq('id', item.id)
          .eq('user_id', userId);
      
      if (kDebugMode) {
        print('SupabaseService: Shopping item updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error updating shopping item: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> removeShoppingItem(String itemId) async {
    try {
      final userId = getCurrentUserId();
      
      if (userId == null) throw Exception('No user logged in');
      
      await client
          .from('shopping_items')
          .delete()
          .eq('id', itemId)
          .eq('user_id', userId);
      
      if (kDebugMode) {
        print('SupabaseService: Shopping item removed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error removing shopping item: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> clearShoppingList() async {
    try {
      final userId = getCurrentUserId();
      
      if (userId == null) throw Exception('No user logged in');
      
      await client
          .from('shopping_items')
          .delete()
          .eq('user_id', userId);
      
      if (kDebugMode) {
        print('SupabaseService: Shopping list cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error clearing shopping list: $e');
      }
      rethrow;
    }
  }

  // ===== SAVED REDDIT POSTS METHODS =====
  
  static Future<void> saveRedditPost(String redditUrl, String title, String petType) async {
    try {
      final String? userId = getCurrentUserId();
      if (userId == null) throw Exception('No user logged in');
      
      // Use only the most basic columns that definitely exist
      await client.from('posts').upsert({
        'user_id': userId,
        'title': title,
        'content': redditUrl, // Store URL in content
      });
      
      if (kDebugMode) {
        print('SupabaseService: Saved Reddit post: $redditUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error saving Reddit post: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> unsaveRedditPost(String redditUrl) async {
    try {
      final String? userId = getCurrentUserId();
      if (userId == null) throw Exception('No user logged in');
      
      // Delete by content (which contains the URL)
      await client.from('posts')
          .delete()
          .eq('user_id', userId)
          .eq('content', redditUrl);
      
      if (kDebugMode) {
        print('SupabaseService: Unsaved Reddit post: $redditUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error unsaving Reddit post: $e');
      }
      rethrow;
    }
  }
  
  static Future<List<Map<String, dynamic>>> getSavedRedditPosts() async {
    try {
      final String? userId = getCurrentUserId();
      if (userId == null) throw Exception('No user logged in');
      
      // Get posts where content starts with http (Reddit URLs)
      final response = await client
          .from('posts')
          .select()
          .eq('user_id', userId)
          .like('content', 'http%')
          .order('created_at', ascending: false);
      
      if (kDebugMode) {
        print('SupabaseService: Loaded ${response.length} saved Reddit posts');
      }
      
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting saved Reddit posts: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // FOLLOW SYSTEM METHODS
  // ============================================================================

  /// Follow a user
  static Future<void> followUser(String userIdToFollow) async {
    try {
      if (kDebugMode) {
        print('SupabaseService: Attempting to follow user $userIdToFollow');
        final currentUser = client.auth.currentUser;
        print('SupabaseService: Current user: ${currentUser?.id}');
      }
      
      final userId = getCurrentUserId();
      if (kDebugMode) {
        print('SupabaseService: getCurrentUserId returned: $userId');
      }
      
      if (userId == null) throw Exception('No user logged in');
      
      if (userId == userIdToFollow) {
        throw Exception('Cannot follow yourself');
      }

      await client.from('follows').insert({
        'follower_id': userId,
        'following_id': userIdToFollow,
      });

      if (kDebugMode) {
        print('SupabaseService: Successfully followed user $userIdToFollow');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error following user: $e');
      }
      rethrow;
    }
  }

  /// Unfollow a user
  static Future<void> unfollowUser(String userIdToUnfollow) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('No user logged in');

      await client
          .from('follows')
          .delete()
          .eq('follower_id', userId)
          .eq('following_id', userIdToUnfollow);

      if (kDebugMode) {
        print('SupabaseService: Successfully unfollowed user $userIdToUnfollow');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error unfollowing user: $e');
      }
      rethrow;
    }
  }

  /// Check if current user is following another user
  static Future<bool> isFollowing(String userIdToCheck) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return false;

      final response = await client
          .from('follows')
          .select('id')
          .eq('follower_id', userId)
          .eq('following_id', userIdToCheck)
          .maybeSingle();

      return response != null;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error checking follow status: $e');
      }
      return false;
    }
  }

  /// Get follower count for a user
  static Future<int> getFollowerCount(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select('followers_count')
          .eq('id', userId)
          .single();

      return response['followers_count'] ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting follower count: $e');
      }
      return 0;
    }
  }

  /// Get following count for a user
  static Future<int> getFollowingCount(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select('following_count')
          .eq('id', userId)
          .single();

      return response['following_count'] ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting following count: $e');
      }
      return 0;
    }
  }

  /// Get user ID by username/display name
  static Future<String?> getUserIdByUsername(String username) async {
    try {
      final response = await client
          .from('profiles')
          .select('id')
          .eq('display_name', username)
          .maybeSingle();

      return response?['id'];
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting user ID by username: $e');
      }
      return null;
    }
  }

  // ============================================================================
  // PUBLIC PROFILE DATA METHODS
  // ============================================================================

  /// Get pets by user ID (public method for viewing other users' pets)
  static Future<List<Map<String, dynamic>>> getPetsByUserId(String userId) async {
    try {
      final response = await client
          .from('pets')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print('SupabaseService: Retrieved ${response.length} pets for user $userId');
      }
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting pets by user ID: $e');
      }
      return [];
    }
  }

  /// Get shopping items by user ID (public method for viewing other users' shopping lists)
  static Future<List<ShoppingItem>> getShoppingItemsByUserId(String userId) async {
    try {
      if (kDebugMode) {
        print('SupabaseService: Attempting to get shopping items for user ID: $userId');
      }
      
      final response = await client
          .from('shopping_items')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print('SupabaseService: Raw response: $response');
      }

      final items = response.map((item) => _dbToShoppingItem(item)).toList();
      
      if (kDebugMode) {
        print('SupabaseService: Retrieved ${items.length} shopping items for user $userId');
        if (items.isNotEmpty) {
          print('SupabaseService: First item: ${items.first.name}');
        }
      }
      return items;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting shopping items by user ID: $e');
        print('SupabaseService: Stack trace: ${StackTrace.current}');
      }
      return [];
    }
  }

  // ============================================================================
  // ACCOUNT DELETION AND DATA RESET METHODS
  // ============================================================================

  /// Delete all data for current user (keeps account, clears data)
  static Future<bool> deleteCurrentUserData() async {
    try {
      if (kDebugMode) {
        print('SupabaseService: Attempting to delete all user data');
      }
      
      final userId = getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) {
          print('SupabaseService: No user ID available for data deletion');
        }
        return false;
      }
      
      if (kDebugMode) {
        print('SupabaseService: Deleting all data for user: $userId');
      }
      
      // Delete all user data in the correct order (respecting foreign keys)
      try {
        // 1. Delete tracking metrics (linked to pets)
        await client
            .from('tracking_metrics')
            .delete()
            .eq('pet_id', client
                .from('pets')
                .select('id')
                .eq('user_id', userId));
        
        if (kDebugMode) {
          print('SupabaseService: Deleted tracking metrics');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error deleting tracking metrics: $e');
        }
      }
      
      try {
        // 2. Delete comments (linked to posts)
        await client
            .from('comments')
            .delete()
            .eq('post_id', client
                .from('posts')
                .select('id')
                .eq('user_id', userId));
        
        if (kDebugMode) {
          print('SupabaseService: Deleted comments');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error deleting comments: $e');
        }
      }
      
      try {
        // 3. Delete pets
        await client
            .from('pets')
            .delete()
            .eq('user_id', userId);
        
        if (kDebugMode) {
          print('SupabaseService: Deleted pets');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error deleting pets: $e');
        }
      }
      
      try {
        // 4. Delete posts
        await client
            .from('posts')
            .delete()
            .eq('user_id', userId);
        
        if (kDebugMode) {
          print('SupabaseService: Deleted posts');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error deleting posts: $e');
        }
      }
      
      try {
        // 4.5. Clear all saved posts for this user
        await clearAllSavedPosts();
        
        // 4.6. Reset all saved posts in database (since current architecture is global)
        await resetAllSavedPosts();
        
        if (kDebugMode) {
          print('SupabaseService: Cleared all saved posts');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error clearing saved posts: $e');
        }
      }
      
      try {
        // 5. Delete shopping items
        await client
            .from('shopping_items')
            .delete()
            .eq('user_id', userId);
        
        if (kDebugMode) {
          print('SupabaseService: Deleted shopping items');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error deleting shopping items: $e');
        }
      }
      
      try {
        // 6. Delete saved reddit posts (if table exists)
        await client
            .from('saved_reddit_posts')
            .delete()
            .eq('user_id', userId);
        
        if (kDebugMode) {
          print('SupabaseService: Deleted saved reddit posts');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Saved reddit posts table may not exist: $e');
        }
      }
      
      try {
        // 7. Delete follows (both as follower and following)
        await client
            .from('follows')
            .delete()
            .or('follower_id.eq.$userId,following_id.eq.$userId');
        
        if (kDebugMode) {
          print('SupabaseService: Deleted follows');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error deleting follows: $e');
        }
      }
      
      // Note: We keep the profile but reset it to basic info
      try {
        final auth0User = Auth0JWTService.instance.currentUser;
        await client
            .from('profiles')
            .upsert({
              'id': userId,
              'email': auth0User?.email ?? '',
              'username': auth0User?.nickname ?? auth0User?.name ?? 'user',
              'display_name': auth0User?.name ?? 'User',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
        
        if (kDebugMode) {
          print('SupabaseService: Reset profile to basic info');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error resetting profile: $e');
        }
      }
      
      if (kDebugMode) {
        print('SupabaseService: All user data deleted successfully');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error deleting user data: $e');
      }
      return false;
    }
  }

  /// Delete current user account completely
  static Future<bool> deleteCurrentUserAccount() async {
    try {
      if (kDebugMode) {
        print('SupabaseService: Attempting to delete current user account');
      }
      
      final userId = getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) {
          print('SupabaseService: No user to delete');
        }
        return false;
      }
      
      if (kDebugMode) {
        print('SupabaseService: Deleting all data for user: $userId');
      }
      
      // Delete all user data in the correct order (respecting foreign keys)
      try {
        // 1. Delete tracking metrics (linked to pets)
        await client
            .from('tracking_metrics')
            .delete()
            .eq('pet_id', client
                .from('pets')
                .select('id')
                .eq('user_id', userId));
        
        if (kDebugMode) {
          print('SupabaseService: Deleted tracking metrics');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error deleting tracking metrics: $e');
        }
      }
      
      try {
        // 2. Delete comments (linked to posts)
        await client
            .from('comments')
            .delete()
            .eq('post_id', client
                .from('posts')
                .select('id')
                .eq('user_id', userId));
        
        if (kDebugMode) {
          print('SupabaseService: Deleted comments');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error deleting comments: $e');
        }
      }
      
      try {
        // 3. Delete pets
        await client
            .from('pets')
            .delete()
            .eq('user_id', userId);
        
        if (kDebugMode) {
          print('SupabaseService: Deleted pets');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error deleting pets: $e');
        }
      }
      
      try {
        // 4. Delete posts
        await client
            .from('posts')
            .delete()
            .eq('user_id', userId);
        
        if (kDebugMode) {
          print('SupabaseService: Deleted posts');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error deleting posts: $e');
        }
      }
      
      try {
        // 4.5. Clear all saved posts for this user
        await clearAllSavedPosts();
        
        // 4.6. Reset all saved posts in database (since current architecture is global)
        await resetAllSavedPosts();
        
        if (kDebugMode) {
          print('SupabaseService: Cleared all saved posts');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error clearing saved posts: $e');
        }
      }
      
      try {
        // 5. Delete shopping items
        await client
            .from('shopping_items')
            .delete()
            .eq('user_id', userId);
        
        if (kDebugMode) {
          print('SupabaseService: Deleted shopping items');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error deleting shopping items: $e');
        }
      }
      
      try {
        // 6. Delete saved reddit posts (if table exists)
        await client
            .from('saved_reddit_posts')
            .delete()
            .eq('user_id', userId);
        
        if (kDebugMode) {
          print('SupabaseService: Deleted saved reddit posts');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Saved reddit posts table may not exist: $e');
        }
      }
      
      try {
        // 7. Delete follows (both as follower and following)
        await client
            .from('follows')
            .delete()
            .or('follower_id.eq.$userId,following_id.eq.$userId');
        
        if (kDebugMode) {
          print('SupabaseService: Deleted follows');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error deleting follows: $e');
        }
      }
      
      try {
        // 8. Delete profile
        await client
            .from('profiles')
            .delete()
            .eq('id', userId);
        
        if (kDebugMode) {
          print('SupabaseService: Deleted profile');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error deleting profile: $e');
        }
      }
      
      // 9. Sign out from Auth0 and provide deletion instructions
      try {
        final auth0Result = await Auth0JWTService.instance.deleteAuth0Account();
        if (kDebugMode) {
          print('SupabaseService: Auth0 account deletion result: $auth0Result');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error with Auth0 account deletion: $e');
        }
      }
      
      if (kDebugMode) {
        print('SupabaseService: User account and all data deleted successfully');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error deleting user account: $e');
      }
      return false;
    }
  }

  /// Reset all data for current user (keeps account, clears data)
  static Future<bool> resetUserData() async {
    try {
      if (kDebugMode) {
        print('SupabaseService: Attempting to reset user data');
      }
      
      // Call our new SQL function that handles data reset
      final result = await client.rpc('delete_current_user_data');
      
      if (kDebugMode) {
        print('SupabaseService: Reset user data result: $result');
      }
      
      return result == true;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error resetting user data: $e');
      }
      return false;
    }
  }

  /// Force clear all local data and cached state (for complete logout/clean slate)
  static Future<void> clearAllLocalData() async {
    try {
      if (kDebugMode) {
        print('SupabaseService: Force clearing all local data and cache');
      }
      
      // Clear any cached user data
      await client.auth.signOut();
      
      // Clear any local storage or cached data
      // This ensures no old data persists when user is deleted
      
      if (kDebugMode) {
        print('SupabaseService: All local data cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error clearing local data: $e');
      }
    }
  }

  /// Clear all saved posts for current user
  static Future<bool> clearAllSavedPosts() async {
    try {
      if (kDebugMode) {
        print('SupabaseService: Clearing all saved posts for user');
      }
      
      final userId = getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) {
          print('SupabaseService: No user ID available for clearing saved posts');
        }
        return false;
      }
      
      // Clear saved Reddit posts
      try {
        await client
            .from('saved_reddit_posts')
            .delete()
            .eq('user_id', userId);
        
        if (kDebugMode) {
          print('SupabaseService: Cleared saved Reddit posts');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error clearing saved Reddit posts: $e');
        }
      }
      
      // For community posts, we need to find all posts that this user has saved
      // Since we don't have a direct relationship, we'll need to handle this in the app state
      // The app state will be cleared when the user is deleted
      
      if (kDebugMode) {
        print('SupabaseService: Saved posts cleared successfully');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error clearing saved posts: $e');
      }
      return false;
    }
  }

  /// Reset all saved posts in the database (for account deletion)
  static Future<bool> resetAllSavedPosts() async {
    try {
      if (kDebugMode) {
        print('SupabaseService: Resetting all saved posts in database');
      }
      
      // Reset all posts to not saved
      await client
          .from('posts')
          .update({'is_saved': false})
          .eq('is_saved', true);
      
      if (kDebugMode) {
        print('SupabaseService: Reset all saved posts in database');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error resetting saved posts: $e');
      }
      return false;
    }
  }


} 