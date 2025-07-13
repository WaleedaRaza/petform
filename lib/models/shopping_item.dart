import 'package:hive/hive.dart';
part 'shopping_item.g.dart';

@HiveType(typeId: 2)
class ShoppingItem extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String category;
  @HiveField(3)
  final String priority; // 'High', 'Medium', 'Low'
  @HiveField(4)
  final double estimatedCost;
  @HiveField(5)
  final String? petId; // Associated pet
  @HiveField(6)
  final String? description;
  @HiveField(7)
  final String? brand;
  @HiveField(8)
  final String? store;
  @HiveField(9)
  final bool isCompleted;
  @HiveField(10)
  final DateTime createdAt;
  @HiveField(11)
  final DateTime? completedAt;
  @HiveField(12)
  final List<String> tags;
  @HiveField(13)
  final String? imageUrl;
  @HiveField(14)
  final int quantity;
  @HiveField(15)
  final String? notes;
  
  // Chewy-specific fields
  @HiveField(16)
  final String? chewyUrl;
  @HiveField(17)
  final double? rating;
  @HiveField(18)
  final int? reviewCount;
  @HiveField(19)
  final bool? inStock;
  @HiveField(20)
  final bool? autoShip;
  @HiveField(21)
  final bool? freeShipping;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.priority,
    required this.estimatedCost,
    this.petId,
    this.description,
    this.brand,
    this.store,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
    List<String>? tags,
    this.imageUrl,
    this.quantity = 1,
    this.notes,
    this.chewyUrl,
    this.rating,
    this.reviewCount,
    this.inStock,
    this.autoShip,
    this.freeShipping,
  }) : createdAt = createdAt ?? DateTime.now(),
       tags = tags ?? [];

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      petId: json['petId'] as String?,
      description: json['description'] as String?,
      brand: json['brand'] as String?,
      store: json['store'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      imageUrl: json['imageUrl'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      notes: json['notes'] as String?,
      chewyUrl: json['chewyUrl'] as String?,
      rating: json['rating'] as double?,
      reviewCount: json['reviewCount'] as int?,
      inStock: json['inStock'] as bool?,
      autoShip: json['autoShip'] as bool?,
      freeShipping: json['freeShipping'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'priority': priority,
      'estimatedCost': estimatedCost,
      'petId': petId,
      'description': description,
      'brand': brand,
      'store': store,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'tags': tags,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'notes': notes,
      'chewyUrl': chewyUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'inStock': inStock,
      'autoShip': autoShip,
      'freeShipping': freeShipping,
    };
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    String? category,
    String? priority,
    double? estimatedCost,
    String? petId,
    String? description,
    String? brand,
    String? store,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    List<String>? tags,
    String? imageUrl,
    int? quantity,
    String? notes,
    String? chewyUrl,
    double? rating,
    int? reviewCount,
    bool? inStock,
    bool? autoShip,
    bool? freeShipping,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      petId: petId ?? this.petId,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      store: store ?? this.store,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      chewyUrl: chewyUrl ?? this.chewyUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      inStock: inStock ?? this.inStock,
      autoShip: autoShip ?? this.autoShip,
      freeShipping: freeShipping ?? this.freeShipping,
    );
  }

  // Helper methods
  bool get isHighPriority => priority == 'High';
  bool get isMediumPriority => priority == 'Medium';
  bool get isLowPriority => priority == 'Low';
  
  double get totalCost => estimatedCost * quantity;
  
  // Chewy-specific helper methods
  bool get isChewyProduct => store?.toLowerCase() == 'chewy';
  bool get hasRating => rating != null && rating! > 0;
  bool get hasReviews => reviewCount != null && reviewCount! > 0;
  bool get isTopRated => rating != null && rating! >= 4.5;
  bool get isBestSeller => reviewCount != null && reviewCount! >= 1000;
  bool get isAutoShipEligible => autoShip == true;
  bool get hasFreeShipping => freeShipping == true;
}