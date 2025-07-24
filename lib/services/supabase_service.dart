import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/post.dart';

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
      final response = await client
          .from('pets')
          .select()
          .eq('user_id', client.auth.currentUser!.id)
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting pets: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> createPet(Map<String, dynamic> petData) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      petData['user_id'] = user.id;
      await client.from('pets').insert(petData);
      
      if (kDebugMode) {
        print('SupabaseService: Pet created successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error creating pet: $e');
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
          .select('*, profiles(username, display_name)')
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
      final user = client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      postData['user_id'] = user.id;
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
          .select('*, profiles(username, display_name)')
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
  
  static Future<void> createComment(String postId, String content) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      await client.from('comments').insert({
        'post_id': postId,
        'user_id': user.id,
        'content': content,
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
      await client
          .from('tracking_metrics')
          .insert(metricData);
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error creating tracking metric: $e');
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
  
  static Future<List<Map<String, dynamic>>> getShoppingItems() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      final response = await client
          .from('shopping_items')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting shopping items: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> addShoppingItem(Map<String, dynamic> itemData) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      itemData['user_id'] = user.id;
      await client.from('shopping_items').insert(itemData);
      
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
  
  static Future<void> removeShoppingItem(String itemId) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      await client
          .from('shopping_items')
          .delete()
          .eq('id', itemId)
          .eq('user_id', user.id);
      
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
      final user = client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      await client
          .from('shopping_items')
          .delete()
          .eq('user_id', user.id);
      
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
} 