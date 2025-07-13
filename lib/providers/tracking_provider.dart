import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/tracking_metric.dart';

class TrackingProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = auth.FirebaseAuth.instance;

  Stream<List<TrackingMetric>> get metrics {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('trackingMetrics')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TrackingMetric.fromJson(doc.data()..['id'] = doc.id))
            .toList());
  }

  Future<void> addMetric(TrackingMetric metric) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('trackingMetrics')
        .add(metric.toJson());
    notifyListeners();
  }

  Future<void> updateMetric(String metricId, TrackingMetric metric) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('trackingMetrics')
        .doc(metricId)
        .update(metric.toJson());
    notifyListeners();
  }

  Future<void> deleteMetric(String metricId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('trackingMetrics')
        .doc(metricId)
        .delete();
    notifyListeners();
  }
} 