class TrackingMetric {
  final String? id;
  final String? petId;
  final String? name;
  final String? value;
  final DateTime? createdAt;

  TrackingMetric({
    this.id,
    this.petId,
    this.name,
    this.value,
    this.createdAt,
  });

  factory TrackingMetric.fromJson(Map<String, dynamic> json) {
    return TrackingMetric(
      id: json['id'] as String?,
      petId: json['petId'] as String?,
      name: json['name'] as String?,
      value: json['value'] as String?,
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
      'created_at': createdAt?.toIso8601String(),
    };
  }
}