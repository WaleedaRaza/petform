import 'shopping_item.dart';
import 'tracking_metric.dart';

class Pet {
  final int id;
  final String name;
  final String species;
  final String? breed;
  final int? age;
  final String? personality;
  final String? foodSource;
  final String? favoritePark;
  final String? leashSource;
  final String? litterType;
  final String? waterProducts;
  final String? tankSize;
  final String? cageSize;
  final String? favoriteToy;
  final Map<String, dynamic> customFields;
  final List<ShoppingItem> shoppingList;
  final List<TrackingMetric> trackingMetrics;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.age,
    this.personality,
    this.foodSource,
    this.favoritePark,
    this.leashSource,
    this.litterType,
    this.waterProducts,
    this.tankSize,
    this.cageSize,
    this.favoriteToy,
    this.customFields = const {},
    this.shoppingList = const [],
    this.trackingMetrics = const [],
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as int,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      age: json['age'] as int?,
      personality: json['personality'] as String?,
      foodSource: json['foodSource'] as String?,
      favoritePark: json['favoritePark'] as String?,
      leashSource: json['leashSource'] as String?,
      litterType: json['litterType'] as String?,
      waterProducts: json['waterProducts'] as String?,
      tankSize: json['tankSize'] as String?,
      cageSize: json['cageSize'] as String?,
      favoriteToy: json['favoriteToy'] as String?,
      customFields: json['customFields'] as Map<String, dynamic>? ?? {},
      shoppingList: (json['shoppingList'] as List<dynamic>?)
          ?.map((item) => ShoppingItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      trackingMetrics: (json['trackingMetrics'] as List<dynamic>?)
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
      'personality': personality,
      'foodSource': foodSource,
      'favoritePark': favoritePark,
      'leashSource': leashSource,
      'litterType': litterType,
      'waterProducts': waterProducts,
      'tankSize': tankSize,
      'cageSize': cageSize,
      'favoriteToy': favoriteToy,
      'customFields': customFields,
      'shoppingList': shoppingList.map((item) => item.toJson()).toList(),
      'trackingMetrics': trackingMetrics.map((m) => m.toJson()).toList(),
    };
  }
}