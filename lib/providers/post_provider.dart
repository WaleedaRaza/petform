import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/post.dart';

class PostProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = auth.FirebaseAuth.instance;

  Stream<List<Post>> get posts {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('posts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromJson(doc.data()..['id'] = doc.id))
            .toList());
  }

  Future<void> addPost(Post post) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('posts')
        .add(post.toJson());
    notifyListeners();
  }

  Future<void> updatePost(String postId, Post post) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('posts')
        .doc(postId)
        .update(post.toJson());
    notifyListeners();
  }

  Future<void> deletePost(String postId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('posts')
        .doc(postId)
        .delete();
    notifyListeners();
  }
} 