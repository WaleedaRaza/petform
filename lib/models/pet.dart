
import 'shopping_item.dart';
import 'tracking_metric.dart';
import 'package:hive/hive.dart';
part 'pet.g.dart';

@HiveType(typeId: 1)
class Pet extends HiveObject {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String species;
  @HiveField(3)
  final String? breed;
  @HiveField(4)
  final int? age;
  @HiveField(5)
  final String? personality;
  @HiveField(6)
  final String? foodSource;
  @HiveField(7)
  final String? favoritePark;
  @HiveField(8)
  final String? leashSource;
  @HiveField(9)
  final String? litterType;
  @HiveField(10)
  final String? waterProducts;
  @HiveField(11)
  final String? tankSize;
  @HiveField(12)
  final String? cageSize;
  @HiveField(13)
  final String? favoriteToy;
  @HiveField(14)
  final String? photoUrl;
  @HiveField(15)
  final Map<String, dynamic>? customFields;
  @HiveField(16)
  final List<ShoppingItem> shoppingList;
  @HiveField(17)
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
    int? id,
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
      id: json['id'] as int?,
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
      'photoUrl': photoUrl,
      'customFields': customFields,
      'shoppingList': shoppingList.map((item) => item.toJson()).toList(),
      'trackingMetrics': trackingMetrics.map((metric) => metric.toJson()).toList(),
    };
  }
}
