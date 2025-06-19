class ShoppingItem {
  final String name;
  final bool isPurchased;
  final String? url;
  final String? category;
  final int? quantity;
  final String? notes;

  ShoppingItem({
    required this.name,
    this.isPurchased = false,
    this.url,
    this.category,
    this.quantity,
    this.notes,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      name: json['name'] as String,
      isPurchased: json['isPurchased'] as bool,
      url: json['url'] as String?,
      category: json['category'] as String?,
      quantity: json['quantity'] as int?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isPurchased': isPurchased,
      'url': url,
      'category': category,
      'quantity': quantity,
      'notes': notes,
    };
  }
}