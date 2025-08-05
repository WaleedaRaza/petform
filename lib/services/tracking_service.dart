import '../models/tracking_metric.dart';

class TrackingService {
  // Predefined tracking metrics for different pet types
  static List<TrackingMetric> getDefaultMetricsForPet(String petType) {
    switch (petType.toLowerCase()) {
      case 'dog':
        return [
          TrackingMetric(
            id: '', // Let database generate UUID
            name: 'Exercise Time',
            frequency: 'daily',
            petId: '',
            targetValue: 60.0,
            description: 'Track daily exercise to keep your dog healthy and happy.',
            category: 'exercise',
          ),
          TrackingMetric(
            id: '', // Let database generate UUID
            name: 'Feeding',
            frequency: 'daily',
            petId: '',
            targetValue: 2.0,
            description: 'Monitor feeding frequency to maintain consistent nutrition.',
            category: 'nutrition',
          ),
          TrackingMetric(
            id: '', // Let database generate UUID
            name: 'Daily Walks',
            frequency: 'daily',
            petId: '',
            targetValue: 3.0,
            description: 'Track daily walks for exercise and bathroom breaks.',
            category: 'exercise',
          ),
        ];
        
      case 'cat':
        return [
          TrackingMetric(
            id: '', // Let database generate UUID
            name: 'Litter Box Usage',
            frequency: 'daily',
            petId: '',
            targetValue: 3.0,
            description: 'Track litter box usage to monitor health.',
            category: 'health',
          ),
          TrackingMetric(
            id: '', // Let database generate UUID
            name: 'Feeding',
            frequency: 'daily',
            petId: '',
            targetValue: 2.0,
            description: 'Monitor feeding frequency and portion sizes.',
            category: 'nutrition',
          ),
          TrackingMetric(
            id: '', // Let database generate UUID
            name: 'Playtime',
            frequency: 'daily',
            petId: '',
            targetValue: 20.0,
            description: 'Daily playtime helps with exercise and bonding.',
            category: 'exercise',
          ),
        ];
        
      case 'bird':
        return [
          TrackingMetric(
            id: '', // Let database generate UUID
            name: 'Feeding',
            frequency: 'daily',
            petId: '',
            targetValue: 2.0,
            description: 'Regular feeding with fresh food and water.',
            category: 'nutrition',
          ),
          TrackingMetric(
            id: '', // Let database generate UUID
            name: 'Socialization Time',
            frequency: 'daily',
            petId: '',
            targetValue: 45.0,
            description: 'Time spent interacting and bonding with your bird.',
            category: 'behavior',
          ),
        ];
        
      case 'fish':
        return [
          TrackingMetric(
            id: '', // Let database generate UUID
            name: 'Feeding',
            frequency: 'daily',
            petId: '',
            targetValue: 2.0,
            description: 'Regular feeding with appropriate portions.',
            category: 'nutrition',
          ),
          TrackingMetric(
            id: '', // Let database generate UUID
            name: 'Water Changes',
            frequency: 'weekly',
            petId: '',
            targetValue: 1.0,
            description: 'Regular water changes to maintain water quality.',
            category: 'care',
          ),
        ];
        
      case 'hamster':
      case 'guinea pig':
      case 'rabbit':
        return [
          TrackingMetric(
            id: '', // Let database generate UUID
            name: 'Feeding',
            frequency: 'daily',
            petId: '',
            targetValue: 2.0,
            description: 'Regular feeding with fresh food and water.',
            category: 'nutrition',
          ),
          TrackingMetric(
            id: '', // Let database generate UUID
            name: 'Exercise Time',
            frequency: 'daily',
            petId: '',
            targetValue: 30.0,
            description: 'Supervised exercise time outside the cage.',
            category: 'exercise',
          ),
        ];
        
      default:
        return [
          TrackingMetric(
            id: 'feeding_default_${DateTime.now().millisecondsSinceEpoch}',
            name: 'Feeding',
            frequency: 'daily',
            petId: '',
            targetValue: 2.0,
            description: 'Track feeding frequency and portions.',
            category: 'nutrition',
          ),
        ];
    }
  }
  
  // Get popular tracking metrics
  static List<TrackingMetric> getPopularMetrics() {
    return [
      TrackingMetric(
        id: 'weight_popular_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Weight Check',
        frequency: 'monthly',
        petId: '',
        targetValue: 25.0,
        description: 'Most important health metric for all pets.',
        category: 'health',
      ),
      TrackingMetric(
        id: 'exercise_popular_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Exercise Time',
        frequency: 'daily',
        petId: '',
        targetValue: 30.0,
        description: 'Essential for physical and mental health.',
        category: 'exercise',
      ),
      TrackingMetric(
        id: 'feeding_popular_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Feeding',
        frequency: 'daily',
        petId: '',
        targetValue: 2.0,
        description: 'Consistent nutrition tracking.',
        category: 'nutrition',
      ),
      TrackingMetric(
        id: 'grooming_popular_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Grooming',
        frequency: 'weekly',
        petId: '',
        targetValue: 1.0,
        description: 'Regular care and bonding time.',
        category: 'care',
      ),
    ];
  }
  
  // Search tracking suggestions
  static List<TrackingMetric> searchSuggestions(String query) {
    final allSuggestions = [
      ...getPopularMetrics(),
      TrackingMetric(
        id: 'vet_visit_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Vet Visit',
        frequency: 'monthly',
        petId: '',
        targetValue: 1.0,
        description: 'Regular veterinary checkups.',
        category: 'health',
      ),
      TrackingMetric(
        id: 'medication_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Medication',
        frequency: 'daily',
        petId: '',
        targetValue: 1.0,
        description: 'Track medication compliance.',
        category: 'health',
      ),
      TrackingMetric(
        id: 'training_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Training Session',
        frequency: 'daily',
        petId: '',
        targetValue: 15.0,
        description: 'Mental stimulation and obedience training.',
        category: 'behavior',
      ),
    ];
    
    if (query.isEmpty) return allSuggestions;
    
    return allSuggestions.where((metric) {
      return metric.name.toLowerCase().contains(query.toLowerCase()) ||
             metric.description?.toLowerCase().contains(query.toLowerCase()) == true ||
             metric.category?.toLowerCase().contains(query.toLowerCase()) == true;
    }).toList();
  }
  
  // Get tracking tips by category
  static List<String> getTrackingTips(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return [
          'Weigh your pet at the same time each day for consistency',
          'Monitor for sudden changes which may indicate health issues',
          'Keep a record of any unusual symptoms or behaviors',
          'Regular vet checkups are essential for preventive care',
        ];
      case 'exercise':
        return [
          'Start with short sessions and gradually increase duration',
          'Mix different types of exercise for variety',
          'Consider your pet\'s age and fitness level',
          'Exercise should be fun for both you and your pet',
        ];
      case 'nutrition':
        return [
          'Measure food portions accurately',
          'Stick to a consistent feeding schedule',
          'Monitor treat consumption to prevent overfeeding',
          'Ensure fresh water is always available',
        ];
      case 'behavior':
        return [
          'Positive reinforcement works best for training',
          'Be patient and consistent with behavioral goals',
          'Socialization is important for mental health',
          'Address behavioral issues early before they become habits',
        ];
      case 'care':
        return [
          'Regular grooming helps with bonding and health',
          'Keep grooming sessions short and positive',
          'Schedule vet visits at least annually',
          'Maintain a clean living environment',
        ];
      default:
        return [
          'Start with one or two metrics and gradually add more',
          'Be consistent with tracking for best results',
          'Celebrate progress and milestones',
          'Adjust goals based on your pet\'s individual needs',
        ];
    }
  }
} 