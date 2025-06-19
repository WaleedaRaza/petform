class TrackingMetric {
  final String? id;
  final String? petId;
  final String? name;
  final String? frequency;
  final DateTime? lastCompletion;
  final List<MetricHistory> history;

  TrackingMetric({
    this.id,
    this.petId,
    this.name,
    this.frequency,
    this.lastCompletion,
    this.history = const [],
  });

  factory TrackingMetric.fromJson(Map<String, dynamic> json) {
    return TrackingMetric(
      id: json['id'] as String?,
      petId: json['petId'] as String?,
      name: json['name'] as String?,
      frequency: json['frequency'] as String?,
      lastCompletion: json['lastCompletion'] != null ? DateTime.parse(json['lastCompletion'] as String) : null,
      history: (json['history'] as List<dynamic>?)
          ?.map((h) => MetricHistory.fromJson(h as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'frequency': frequency,
      'lastCompletion': lastCompletion?.toIso8601String(),
      'history': history.map((h) => h.toJson()).toList(),
    };
  }
}

class MetricHistory {
  final DateTime timestamp;
  final String? value;

  MetricHistory({required this.timestamp, this.value});

  factory MetricHistory.fromJson(Map<String, dynamic> json) {
    return MetricHistory(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: json['value'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'value': value,
    };
  }
}