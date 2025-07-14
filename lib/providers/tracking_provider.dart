import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/tracking_metric.dart';

class TrackingProvider with ChangeNotifier {
  final Box<TrackingMetric> _trackingBox = Hive.box<TrackingMetric>('trackingMetrics');

  List<TrackingMetric> get metrics => _trackingBox.values.toList();

  Future<void> addMetric(TrackingMetric metric) async {
    await _trackingBox.add(metric);
    notifyListeners();
  }

  Future<void> updateMetric(int key, TrackingMetric metric) async {
    await _trackingBox.put(key, metric);
    notifyListeners();
  }

  Future<void> deleteMetric(int key) async {
    await _trackingBox.delete(key);
    notifyListeners();
  }
} 