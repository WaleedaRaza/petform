import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/post.dart';

class PostProvider with ChangeNotifier {
  final Box<Post> _postBox = Hive.box<Post>('posts');

  List<Post> get posts => _postBox.values.toList();

  Future<void> addPost(Post post) async {
    await _postBox.add(post);
    notifyListeners();
  }

  Future<void> updatePost(int key, Post post) async {
    await _postBox.put(key, post);
    notifyListeners();
  }

  Future<void> deletePost(int key) async {
    await _postBox.delete(key);
    notifyListeners();
  }
} 