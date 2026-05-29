class ProductModel {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String imageUrl;
  final String category;
  final String description;
  final List<String> sizes;

  const ProductModel({
    required this.id,
    required this.name,
    this.brand = '',
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.description,
    required this.sizes,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      sizes: List<String>.from(map['sizes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'description': description,
      'sizes': sizes,
    };
  }
}
