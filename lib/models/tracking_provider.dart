import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../models/tracking_metric.dart';
import '../services/api_service.dart';

class TrackingProvider with ChangeNotifier {
  List<TrackingMetric> _metrics = [];
  bool _isLoading = false;

  List<TrackingMetric> get metrics => _metrics;
  bool get isLoading => _isLoading;

  Future<void> loadMetrics(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.pets.isNotEmpty) {
        final pet = userProvider.pets.first;
        _metrics = pet.trackingMetrics;
        
        if (kDebugMode) {
          print('TrackingProvider: Loaded ${_metrics.length} metrics');
        }
      }
    } catch (e) {
      _metrics = [];
      if (kDebugMode) {
        print('TrackingProvider: Error loading metrics: $e');
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> addMetric(BuildContext context, TrackingMetric newMetric) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final apiService = Provider.of<ApiService>(context, listen: false);
      
      if (userProvider.pets.isNotEmpty) {
        final pet = userProvider.pets.first;
        pet.trackingMetrics.add(newMetric);
        await apiService.updatePet(pet);
        await loadMetrics(context);
      }
    } catch (e) {
      if (kDebugMode) {
        print('TrackingProvider: Error adding metric: $e');
      }
      rethrow;
    }
  }
  
  Future<void> deleteMetric(BuildContext context, TrackingMetric metric) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final apiService = Provider.of<ApiService>(context, listen: false);
      
      if (userProvider.pets.isNotEmpty) {
        final pet = userProvider.pets.first;
        pet.trackingMetrics.removeWhere((m) => m.name == metric.name);
        await apiService.updatePet(pet);
        await loadMetrics(context);
      }
    } catch (e) {
      if (kDebugMode) {
        print('TrackingProvider: Error deleting metric: $e');
      }
      rethrow;
    }
  }
}