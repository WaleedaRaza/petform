
import 'shopping_item.dart';
import 'tracking_metric.dart';

class Pet {
  final String? id;
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
  final String? photoUrl;
  final Map<String, dynamic>? customFields;
  final List<ShoppingItem> shoppingList;
  final List<TrackingMetric> trackingMetrics;

  Pet({
    this.id,
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
    this.photoUrl,
    this.customFields,
    this.shoppingList = const [],
    this.trackingMetrics = const [],
  });

  Pet copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    int? age,
    String? personality,
    String? foodSource,
    String? favoritePark,
    String? leashSource,
    String? litterType,
    String? waterProducts,
    String? tankSize,
    String? cageSize,
    String? favoriteToy,
    String? photoUrl,
    Map<String, dynamic>? customFields,
    List<ShoppingItem>? shoppingList,
    List<TrackingMetric>? trackingMetrics,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      personality: personality ?? this.personality,
      foodSource: foodSource ?? this.foodSource,
      favoritePark: favoritePark ?? this.favoritePark,
      leashSource: leashSource ?? this.leashSource,
      litterType: litterType ?? this.litterType,
      waterProducts: waterProducts ?? this.waterProducts,
      tankSize: tankSize ?? this.tankSize,
      cageSize: cageSize ?? this.cageSize,
      favoriteToy: favoriteToy ?? this.favoriteToy,
      photoUrl: photoUrl ?? this.photoUrl,
      customFields: customFields ?? this.customFields,
      shoppingList: shoppingList ?? this.shoppingList,
      trackingMetrics: trackingMetrics ?? this.trackingMetrics,
    );
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String?,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      age: json['age'] as int?, // This will be null if age column doesn't exist
      personality: json['personality'] as String?,
      foodSource: json['foodSource'] as String?,
      favoritePark: json['favoritePark'] as String?,
      leashSource: json['leashSource'] as String?,
      litterType: json['litterType'] as String?,
      waterProducts: json['waterProducts'] as String?,
      tankSize: json['tankSize'] as String?,
      cageSize: json['cageSize'] as String?,
      favoriteToy: json['favoriteToy'] as String?,
      photoUrl: json['photoUrl'] as String?,
      customFields: Map<String, dynamic>.from(json['customFields'] ?? {}),
      shoppingList: (json['shoppingList'] as List<dynamic>?)
              ?.map((item) => ShoppingItem.fromJson(item))
              .toList() ??
          [],
      trackingMetrics: (json['trackingMetrics'] as List<dynamic>?)
              ?.map((metric) => TrackingMetric.fromJson(metric))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'personality': personality,
      'foodSource': foodSource,
      'photoUrl': photoUrl,
      // Removed customFields and other fields that don't exist in Supabase table:
      // 'customFields': customFields,
      // 'age': age,
      // 'favoritePark': favoritePark,
      // 'leashSource': leashSource,
      // 'litterType': litterType,
      // 'waterProducts': waterProducts,
      // 'tankSize': tankSize,
      // 'cageSize': cageSize,
      // 'favoriteToy': favoriteToy,
      // 'shoppingList': shoppingList.map((item) => item.toJson()).toList(),
      // 'trackingMetrics': trackingMetrics.map((metric) => metric.toJson()).toList(),
    };
  }
}
