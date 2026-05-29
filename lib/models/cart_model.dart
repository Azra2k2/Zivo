import 'product_model.dart';

class CartModel {
  final ProductModel product;
  final String selectedSize;
  final int quantity;

  CartModel({
    required this.product,
    required this.selectedSize,
    required this.quantity,
  });

  factory CartModel.fromMap(Map<String, dynamic> map) {
    final product = ProductModel(
      id: map['productId'] ?? '',
      name: map['productName'] ?? '',
      brand: map['productBrand'] ?? '',
      price: (map['productPrice'] ?? 0).toDouble(),
      imageUrl: map['productImageUrl'] ?? '',
      category: map['productCategory'] ?? '',
      description: map['productDescription'] ?? '',
      sizes: List<String>.from(map['productSizes'] ?? []),
    );
    return CartModel(
      product: product,
      selectedSize: map['selectedSize'] ?? '',
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name,
      'productBrand': product.brand,
      'productPrice': product.price,
      'productImageUrl': product.imageUrl,
      'productCategory': product.category,
      'productDescription': product.description,
      'productSizes': product.sizes,
      'selectedSize': selectedSize,
      'quantity': quantity,
    };
  }
}
