class ShoppingItem {
  final String name;
  final bool isPurchased;

  ShoppingItem({required this.name, this.isPurchased = false});

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      name: json['name'] as String,
      isPurchased: json['isPurchased'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isPurchased': isPurchased,
    };
  }
}