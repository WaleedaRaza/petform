import 'tracking_metric.dart';

class Pet {
  final int? id;
  final String name;
  final String species; // e.g., Dog, Cat, Turtle
  final String? breed;
  final int? age;
  final String? litterType; // Cat-specific
  final String? tankSize; // Turtle-specific
  final String? cageSize; // Bird-specific
  final String? favoriteToy; // Dog-specific
  final List<TrackingMetric> metrics;

  Pet({
    this.id,
    required this.name,
    required this.species,
    this.breed,
    this.age,
    this.litterType,
    this.tankSize,
    this.cageSize,
    this.favoriteToy,
    this.metrics = const [],
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as int?,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      age: json['age'] as int?,
      litterType: json['litterType'] as String?,
      tankSize: json['tankSize'] as String?,
      cageSize: json['cageSize'] as String?,
      favoriteToy: json['favoriteToy'] as String?,
      metrics: (json['metrics'] as List<dynamic>?)
          ?.map((m) => TrackingMetric.fromJson(m as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'litterType': litterType,
      'tankSize': tankSize,
      'cageSize': cageSize,
      'favoriteToy': favoriteToy,
      'metrics': metrics.map((m) => m.toJson()).toList(),
    };
  }
}