import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  String get _requireUserId {
    final uid = _userId;
    if (uid == null) throw StateError('No authenticated user');
    return uid;
  }

  // ─── Products ───────────────────────────────────────────────

  Stream<List<ProductModel>> getProducts() {
    return _firestore.collection('products').snapshots().map(
          (snap) => snap.docs
              .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // ─── Cart ───────────────────────────────────────────────────

  Stream<List<CartModel>> getCart() {
    return _firestore
        .collection('users')
        .doc(_requireUserId)
        .collection('cart')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CartModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> addToCart(CartModel item) async {
    final docId = '${item.product.id}_${item.selectedSize}';
    await _firestore
        .collection('users')
        .doc(_requireUserId)
        .collection('cart')
        .doc(docId)
        .set(item.toMap());
  }

  Future<void> updateCartQuantity(
    String productId,
    String selectedSize,
    int newQty,
  ) async {
    final docId = '${productId}_$selectedSize';
    if (newQty <= 0) {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .doc(docId)
          .delete();
    } else {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .doc(docId)
          .update({'quantity': newQty});
    }
  }

  Future<void> removeFromCart(String productId, String selectedSize) async {
    final docId = '${productId}_$selectedSize';
    await _firestore
        .collection('users')
        .doc(_requireUserId)
        .collection('cart')
        .doc(docId)
        .delete();
  }

  Future<void> clearCart() async {
    final batch = _firestore.batch();
    final snap = await _firestore
        .collection('users')
        .doc(_requireUserId)
        .collection('cart')
        .get();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ─── Wishlist ───────────────────────────────────────────────

  Stream<List<ProductModel>> getWishlist() {
    return _firestore
        .collection('users')
        .doc(_requireUserId)
        .collection('wishlist')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addToWishlist(ProductModel product) async {
    await _firestore
        .collection('users')
        .doc(_requireUserId)
        .collection('wishlist')
        .doc(product.id)
        .set(product.toMap());
  }

  Future<void> removeFromWishlist(String productId) async {
    await _firestore
        .collection('users')
        .doc(_requireUserId)
        .collection('wishlist')
        .doc(productId)
        .delete();
  }

  // ─── Orders ─────────────────────────────────────────────────

  Stream<List<OrderModel>> getOrders() {
    return _firestore
        .collection('users')
        .doc(_requireUserId)
        .collection('orders')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> placeOrder(OrderModel order) async {
    await _firestore
        .collection('users')
        .doc(_requireUserId)
        .collection('orders')
        .doc(order.id)
        .set(order.toMap());
  }

  // ─── Profile ────────────────────────────────────────────────

  Stream<UserModel?> getUserProfile() {
    return _firestore
        .collection('users')
        .doc(_requireUserId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.id, doc.data()!);
    });
  }

  Future<void> saveUserProfile(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(_requireUserId)
        .set(user.toMap(), SetOptions(merge: true));
  }
}
