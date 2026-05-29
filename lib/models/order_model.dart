import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_model.dart';

class OrderModel {
  final String id;
  final List<CartModel> items;
  final double totalPrice;
  final DateTime date;
  final String status;
  final String deliveryAddress;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.date,
    required this.status,
    required this.deliveryAddress,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    final itemsList = (map['items'] as List<dynamic>? ?? [])
        .map((item) => CartModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();
    return OrderModel(
      id: id,
      items: itemsList,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? '',
      deliveryAddress: map['deliveryAddress'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'date': date,
      'status': status,
      'deliveryAddress': deliveryAddress,
    };
  }
}
