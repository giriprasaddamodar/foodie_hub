class FoodItem {
  final String name;
  final String image;
  final double? price;
  final String? category;
  int? quantity;

  FoodItem({
    required this.name,
    required this.image,
    this.price,
    this.category,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'price': price,
      'category': category,
      'quantity': quantity, //  include in map for cart operations
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'],
      image: map['image'],
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] as num).toDouble(),
      category: map['category'],
      quantity: (map['quantity'] is int)
          ? map['quantity']
          : int.tryParse(map['quantity'].toString()) ?? 1,
    );
  }
}
