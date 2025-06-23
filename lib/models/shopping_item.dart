class ShoppingItem {
  final String id;
  final String name;
  final String category;
  final String priority; // 'High', 'Medium', 'Low'
  final double estimatedCost;
  final String? petId; // Associated pet
  final String? description;
  final String? brand;
  final String? store;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<String> tags;
  final String? imageUrl;
  final int quantity;
  final String? notes;

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
    );
  }

  // Helper methods
  bool get isHighPriority => priority == 'High';
  bool get isMediumPriority => priority == 'Medium';
  bool get isLowPriority => priority == 'Low';
  
  double get totalCost => estimatedCost * quantity;
  
  String get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return '#FF4444';
      case 'medium':
        return '#FF8800';
      case 'low':
        return '#44FF44';
      default:
        return '#888888';
    }
  }
}