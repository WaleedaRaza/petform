import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../models/post.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];

  List<Post> get posts => _posts;

  Future<void> loadPosts() async {
    try {
      final posts = await SupabaseService.getPosts();
      _posts = posts.map((p) => Post.fromJson(p)).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('PostProvider: Error loading posts: $e');
      }
      rethrow;
    }
  }

  Future<void> addPost(Post post) async {
    try {
      await SupabaseService.createPost(post.toJson());
      await loadPosts(); // Reload posts from database
    } catch (e) {
      if (kDebugMode) {
        print('PostProvider: Error adding post: $e');
      }
      rethrow;
    }
  }

  Future<void> updatePost(String id, Post post) async {
    try {
      await SupabaseService.updatePost(id, post.toJson());
      await loadPosts(); // Reload posts from database
    } catch (e) {
      if (kDebugMode) {
        print('PostProvider: Error updating post: $e');
      }
      rethrow;
    }
  }

  Future<void> deletePost(String id) async {
    try {
      await SupabaseService.deletePost(id);
      await loadPosts(); // Reload posts from database
    } catch (e) {
      if (kDebugMode) {
        print('PostProvider: Error deleting post: $e');
      }
      rethrow;
    }
  }

  Post? getPostById(String id) {
    try {
      return _posts.firstWhere((post) => post.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Post> getSavedPosts() {
    return _posts.where((post) => post.isSaved).toList();
  }
} 