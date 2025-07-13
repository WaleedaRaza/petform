import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/comment.dart';

class CommentProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = auth.FirebaseAuth.instance;

  Stream<List<Comment>> getComments(String postId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> addComment(String postId, Comment comment) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add(comment.toJson());
    notifyListeners();
  }

  Future<void> updateComment(String postId, String commentId, Comment comment) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .update(comment.toJson());
    notifyListeners();
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
    notifyListeners();
  }
} 