class TrackingMetric {
  final String id;
  final String name;
  final String frequency; // 'daily', 'weekly', 'monthly'
  final String petId;
  final double targetValue;
  final double currentValue;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final List<TrackingEntry> history;
  final String? description;
  final bool isActive;
  final String? category; // 'health', 'behavior', 'exercise', etc.

  TrackingMetric({
    required this.id,
    required this.name,
    required this.frequency,
    required this.petId,
    required this.targetValue,
    this.currentValue = 0.0,
    DateTime? createdAt,
    this.lastUpdated,
    List<TrackingEntry>? history,
    this.description,
    this.isActive = true,
    this.category,
  }) : createdAt = createdAt ?? DateTime.now(),
       history = history ?? [];

  factory TrackingMetric.fromJson(Map<String, dynamic> json) {
    return TrackingMetric(
      id: json['id'] as String? ?? 'metric_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Unknown Metric',
      frequency: json['frequency'] as String? ?? 'daily',
      petId: json['petId'] as String? ?? '',
      targetValue: (json['targetValue'] as num?)?.toDouble() ?? 10.0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'] as String) 
          : null,
      history: (json['history'] as List<dynamic>?)
          ?.map((e) => TrackingEntry.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'frequency': frequency,
      'petId': petId,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'history': history.map((e) => e.toJson()).toList(),
      'description': description,
      'isActive': isActive,
      'category': category,
    };
  }

  TrackingMetric copyWith({
    String? id,
    String? name,
    String? frequency,
    String? petId,
    double? targetValue,
    double? currentValue,
    DateTime? createdAt,
    DateTime? lastUpdated,
    List<TrackingEntry>? history,
    String? description,
    bool? isActive,
    String? category,
  }) {
    return TrackingMetric(
      id: id ?? this.id,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      petId: petId ?? this.petId,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      history: history ?? this.history,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
    );
  }

  // Helper methods
  double get progressPercentage {
    if (targetValue == 0) return 0;
    return (currentValue / targetValue * 100).clamp(0, 100);
  }

  bool get isOnTrack => currentValue >= targetValue;
  bool get needsAttention => progressPercentage < 50;

  String get status {
    if (isOnTrack) return 'On Track';
    if (needsAttention) return 'Needs Attention';
    return 'In Progress';
  }

  String get statusColor {
    if (isOnTrack) return '#44FF44';
    if (needsAttention) return '#FF4444';
    return '#FF8800';
  }

  // Check if metric is due today
  bool get isDueToday {
    if (lastUpdated == null) return true;
    
    final now = DateTime.now();
    final last = lastUpdated!;
    
    switch (frequency) {
      case 'daily':
        return now.difference(last).inDays >= 1;
      case 'weekly':
        return now.difference(last).inDays >= 7;
      case 'monthly':
        return now.difference(last).inDays >= 30;
      default:
        return true;
    }
  }

  // Get next due date
  DateTime get nextDueDate {
    if (lastUpdated == null) return DateTime.now();
    
    switch (frequency) {
      case 'daily':
        return lastUpdated!.add(const Duration(days: 1));
      case 'weekly':
        return lastUpdated!.add(const Duration(days: 7));
      case 'monthly':
        return lastUpdated!.add(const Duration(days: 30));
      default:
        return DateTime.now();
    }
  }

  // Add a new tracking entry
  TrackingMetric addEntry(double value, {String? notes}) {
    final entry = TrackingEntry(
      value: value,
      timestamp: DateTime.now(),
      notes: notes,
    );
    
    final updatedHistory = List<TrackingEntry>.from(history)..add(entry);
    
    return copyWith(
      currentValue: value,
      lastUpdated: DateTime.now(),
      history: updatedHistory,
    );
  }

  // Get recent entries
  List<TrackingEntry> getRecentEntries(int count) {
    final sortedHistory = List<TrackingEntry>.from(history)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedHistory.take(count).toList();
  }

  // Get trend (increasing, decreasing, stable)
  String get trend {
    if (history.length < 2) return 'Stable';
    
    final recent = getRecentEntries(5);
    if (recent.length < 2) return 'Stable';
    
    final first = recent.last.value;
    final last = recent.first.value;
    final difference = last - first;
    
    if (difference > 0) return 'Increasing';
    if (difference < 0) return 'Decreasing';
    return 'Stable';
  }
}

class TrackingEntry {
  final double value;
  final DateTime timestamp;
  final String? notes;

  TrackingEntry({
    required this.value,
    required this.timestamp,
    this.notes,
  });

  factory TrackingEntry.fromJson(Map<String, dynamic> json) {
    return TrackingEntry(
      value: (json['value'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }
}
