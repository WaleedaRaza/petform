import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../models/shopping_item.dart';
import 'auth0_service.dart';

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
  
  static User? get currentUser => client.auth.currentUser;
  
  // Get current user from either Supabase or Auth0
  static dynamic getCurrentUser() {
    final supabaseUser = client.auth.currentUser;
    final auth0User = Auth0Service.instance.currentUser;
    
    if (supabaseUser != null) {
      return supabaseUser;
    } else if (auth0User != null) {
      return auth0User;
    }
    
    return null;
  }
  
  // Get user ID from either Supabase or Auth0 (PRODUCTION-READY)
  static Future<String?> getCurrentUserId() async {
    final supabaseUser = client.auth.currentUser;
    final auth0User = Auth0Service.instance.currentUser;
    
    if (supabaseUser != null) {
      return supabaseUser.id;
    } else if (auth0User != null) {
      try {
        // For Auth0 users, get the mapped Supabase user ID
        final result = await client.rpc('get_supabase_user_id_from_auth0', params: {
          'p_auth0_user_id': auth0User.sub,
        });
        
        if (kDebugMode) {
          print('SupabaseService: Auth0 user ID mapped to Supabase: $result');
        }
        
        return result?.toString();
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: Error getting Supabase user ID for Auth0 user: $e');
        }
        return null;
      }
    }
    
    return null;
  }
  
  // ===== USERNAME AND DISPLAY NAME MANAGEMENT =====
  
  // Get or create username for current user
  static Future<String?> getOrCreateUsername(String email, String? displayName) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) {
          print('SupabaseService: No user ID available for username creation');
        }
        return null;
      }
      
      final result = await client.rpc('get_or_create_username', params: {
        'p_user_id': userId,
        'p_email': email,
        'p_display_name': displayName,
      });
      
      if (kDebugMode) {
        print('SupabaseService: Username created/retrieved: $result');
      }
      
      return result?.toString();
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting/creating username: $e');
      }
      return null;
    }
  }
  
  // Update display name for current user
  static Future<String?> updateDisplayName(String newDisplayName) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) {
          print('SupabaseService: No user ID available for display name update');
        }
        return null;
      }
      
      // First, ensure the user has a profile
      await ensureUserProfile(userId);
      
      // Check if username is already taken by another user
      Map<String, dynamic>? existingUser;
      try {
        existingUser = await client
            .from('profiles')
            .select('user_id')
            .eq('username', newDisplayName)
            .neq('user_id', userId)
            .maybeSingle();
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: user_id column not found, trying id column for uniqueness check');
        }
        // Try with 'id' column instead
        existingUser = await client
            .from('profiles')
            .select('id')
            .eq('username', newDisplayName)
            .neq('id', userId)
            .maybeSingle();
      }
      
      if (existingUser != null) {
        if (kDebugMode) {
          print('SupabaseService: Username already taken: $newDisplayName');
        }
        throw Exception('Username "$newDisplayName" is already taken. Please choose a different name.');
      }
      
      // Try direct update instead of RPC to avoid column issues
      Map<String, dynamic>? result;
      try {
        // Try with user_id column first
        result = await client
            .from('profiles')
            .update({
              'display_name': newDisplayName,
              'username': newDisplayName,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .select('display_name')
            .single();
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: user_id column not found, trying id column for update');
        }
        // Try with 'id' column instead
        result = await client
            .from('profiles')
            .update({
              'display_name': newDisplayName,
              'username': newDisplayName,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId)
            .select('display_name')
            .single();
      }
      
      if (kDebugMode) {
        print('SupabaseService: Display name updated: $result');
      }
      
      return result?['display_name']?.toString();
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error updating display name: $e');
      }
      rethrow;
    }
  }
  
  // Ensure user has a profile in the profiles table
  static Future<void> ensureUserProfile(String userId) async {
    try {
      // Check if profile exists
      Map<String, dynamic>? existingProfile;
      try {
        existingProfile = await client
            .from('profiles')
            .select('*')
            .eq('user_id', userId)
            .maybeSingle();
      } catch (e) {
        // Try with 'id' column instead
        existingProfile = await client
            .from('profiles')
            .select('*')
            .eq('id', userId)
            .maybeSingle();
      }
      
      if (existingProfile == null) {
        // Create profile if it doesn't exist
        if (kDebugMode) {
          print('SupabaseService: Creating profile for user: $userId');
        }
        
        try {
          await client
              .from('profiles')
              .insert({
                'user_id': userId,
                'email': Auth0Service.instance.currentUser?.email ?? '',
                'username': Auth0Service.instance.currentUser?.email?.split('@')[0] ?? 'user',
                'display_name': Auth0Service.instance.currentUser?.name ?? 'User',
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              });
        } catch (e) {
          // Try with 'id' column instead
          await client
              .from('profiles')
              .insert({
                'id': userId,
                'email': Auth0Service.instance.currentUser?.email ?? '',
                'username': Auth0Service.instance.currentUser?.email?.split('@')[0] ?? 'user',
                'display_name': Auth0Service.instance.currentUser?.name ?? 'User',
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error ensuring user profile: $e');
      }
      // Don't rethrow - we'll continue with the update attempt
    }
  }
  
  // Get user profile (including username and display name)
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) {
          print('SupabaseService: No user ID available for profile retrieval');
        }
        return null;
      }
      
      // Try user_id first, then id if that fails
      Map<String, dynamic>? response;
      try {
        response = await client
            .from('profiles')
            .select('*')
            .eq('user_id', userId)
            .single();
      } catch (e) {
        if (kDebugMode) {
          print('SupabaseService: user_id column not found, trying id column');
        }
        // Try with 'id' column instead
        response = await client
            .from('profiles')
            .select('*')
            .eq('id', userId)
            .single();
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
  
  // Legacy method for backward compatibility
  static Future<String?> getAuth0UserUUID() async {
    return await getCurrentUserId();
  }
  
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  static bool isEmailVerified() {
    return client.auth.currentUser?.emailConfirmedAt != null;
  }
  
  static Future<void> resendEmailVerification() async {
    try {
      await client.auth.resend(
        type: OtpType.signup,
        email: client.auth.currentUser?.email ?? '',
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
      // Wait for user to be available (might take a moment after signup)
      User? user;
      int attempts = 0;
      while (user == null && attempts < 10) {
        user = client.auth.currentUser;
        if (user == null) {
          await Future.delayed(const Duration(milliseconds: 200));
          attempts++;
        }
      }
      
      if (user == null) {
        throw Exception('No user logged in after signup');
      }
      
      await client.from('profiles').insert({
        'id': user.id,
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
      final user = client.auth.currentUser;
      if (user == null) return null;
      
      final response = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
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
      final user = client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      await client
          .from('profiles')
          .update(profileData)
          .eq('id', user.id);
      
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
      final supabaseUser = client.auth.currentUser;
      String? userId;
      
      if (supabaseUser != null) {
        userId = supabaseUser.id;
      } else {
        // For Auth0 users, get the UUID mapping
        userId = await getAuth0UserUUID();
      }
      
      if (userId == null) throw Exception('No user logged in');
      
      final response = await client
          .from('pets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting pets: $e');
      }
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>?> createPet(Map<String, dynamic> petData) async {
    try {
      final supabaseUser = client.auth.currentUser;
      String? userId;
      
      if (supabaseUser != null) {
        userId = supabaseUser.id;
      } else {
        // For Auth0 users, get the UUID mapping
        userId = await getAuth0UserUUID();
      }
      
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
      final supabaseUser = client.auth.currentUser;
      String? userId;
      
      if (supabaseUser != null) {
        userId = supabaseUser.id;
      } else {
        // For Auth0 users, get the UUID mapping
        userId = await getAuth0UserUUID();
      }
      
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
      final user = client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      await client.from('comments').insert({
        'post_id': postId,
        'user_id': user.id,
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
      final supabaseUser = client.auth.currentUser;
      String? userId;
      
      if (supabaseUser != null) {
        userId = supabaseUser.id;
      } else {
        // For Auth0 users, get the UUID mapping
        userId = await getAuth0UserUUID();
      }
      
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
      final supabaseUser = client.auth.currentUser;
      String? userId;
      
      if (supabaseUser != null) {
        userId = supabaseUser.id;
      } else {
        // For Auth0 users, get the UUID mapping
        userId = await getAuth0UserUUID();
      }
      
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
      final supabaseUser = client.auth.currentUser;
      String? userId;
      
      if (supabaseUser != null) {
        userId = supabaseUser.id;
      } else {
        // For Auth0 users, get the UUID mapping
        userId = await getAuth0UserUUID();
      }
      
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
      final supabaseUser = client.auth.currentUser;
      String? userId;
      
      if (supabaseUser != null) {
        userId = supabaseUser.id;
      } else {
        // For Auth0 users, get the UUID mapping
        userId = await getAuth0UserUUID();
      }
      
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
      final supabaseUser = client.auth.currentUser;
      String? userId;
      
      if (supabaseUser != null) {
        userId = supabaseUser.id;
      } else {
        // For Auth0 users, get the UUID mapping
        userId = await getAuth0UserUUID();
      }
      
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
      final String? userId = await getCurrentUserId();
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
      final String? userId = await getCurrentUserId();
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
      final String? userId = await getCurrentUserId();
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
} 