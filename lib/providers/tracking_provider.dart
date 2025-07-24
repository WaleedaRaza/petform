import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../models/tracking_metric.dart';

class TrackingProvider with ChangeNotifier {
  List<TrackingMetric> _metrics = [];

  List<TrackingMetric> get metrics => _metrics;

  Future<void> loadMetrics() async {
    try {
      final metrics = await SupabaseService.getTrackingMetrics('current_user_id');
      _metrics = metrics.map((m) => TrackingMetric.fromJson(m)).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('TrackingProvider: Error loading metrics: $e');
      }
      rethrow;
    }
  }

  Future<void> loadMetricsForPet(String petId) async {
    try {
      final metrics = await SupabaseService.getTrackingMetricsForPet(petId);
      _metrics = metrics.map((m) => TrackingMetric.fromJson(m)).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('TrackingProvider: Error loading metrics for pet: $e');
      }
      rethrow;
    }
  }

  Future<void> addMetric(TrackingMetric metric) async {
    try {
      await SupabaseService.createTrackingMetric(metric.toJson());
      await loadMetrics(); // Reload metrics from database
    } catch (e) {
      if (kDebugMode) {
        print('TrackingProvider: Error adding metric: $e');
      }
      rethrow;
    }
  }

  Future<void> updateMetric(String id, TrackingMetric metric) async {
    try {
      await SupabaseService.updateTrackingMetric(id, metric.toJson());
      await loadMetrics(); // Reload metrics from database
    } catch (e) {
      if (kDebugMode) {
        print('TrackingProvider: Error updating metric: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteMetric(String id) async {
    try {
      await SupabaseService.deleteTrackingMetric(id);
      await loadMetrics(); // Reload metrics from database
    } catch (e) {
      if (kDebugMode) {
        print('TrackingProvider: Error deleting metric: $e');
      }
      rethrow;
    }
  }

  TrackingMetric? getMetricById(String id) {
    try {
      return _metrics.firstWhere((metric) => metric.id == id);
    } catch (_) {
      return null;
    }
  }

  List<TrackingMetric> getMetricsByPet(String petId) {
    return _metrics.where((metric) => metric.petId == petId).toList();
  }

  List<TrackingMetric> getMetricsByCategory(String category) {
    return _metrics.where((metric) => metric.category == category).toList();
  }

  Future<void> addTrackingEntry(String metricId, Map<String, dynamic> entryData) async {
    try {
      await SupabaseService.createTrackingEntry({
        'metric_id': metricId,
        ...entryData,
      });
      // Reload metrics to get updated data
      await loadMetrics();
    } catch (e) {
      if (kDebugMode) {
        print('TrackingProvider: Error adding tracking entry: $e');
      }
      rethrow;
    }
  }
} 