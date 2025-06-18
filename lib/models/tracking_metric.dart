class TrackingMetric {
  final String? id;
  final String? petId;
  final String? name;
  final String? value;
  final String? frequency; // daily, weekly, monthly
  final DateTime? lastCompletion;
  final DateTime? createdAt;

  TrackingMetric({
    this.id,
    this.petId,
    this.name,
    this.value,
    this.frequency,
    this.lastCompletion,
    this.createdAt,
  });

  factory TrackingMetric.fromJson(Map<String, dynamic> json) {
    return TrackingMetric(
      id: json['id'] as String?,
      petId: json['petId'] as String?,
      name: json['name'] as String?,
      value: json['value'] as String?,
      frequency: json['frequency'] as String?,
      lastCompletion: json['last_completion'] != null
          ? DateTime.parse(json['last_completion'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'value': value,
      'frequency': frequency,
      'last_completion': lastCompletion?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}