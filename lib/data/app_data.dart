import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

class AppData extends ChangeNotifier {
  UserModel? _currentUser;
  List<CartModel> _cart = [];
  List<ProductModel> _wishlist = [];
  List<OrderModel> _orders = [];

  final FirestoreService _firestore = FirestoreService();
  StreamSubscription<List<CartModel>>? _cartSub;
  StreamSubscription<List<ProductModel>>? _wishlistSub;
  StreamSubscription<List<OrderModel>>? _ordersSub;

  UserModel? get currentUser => _currentUser;
  List<CartModel> get cart => List.unmodifiable(_cart);
  List<ProductModel> get wishlist => List.unmodifiable(_wishlist);
  List<OrderModel> get orders => List.unmodifiable(_orders);

  static const products = <ProductModel>[
    ProductModel(
      id: '1',
      brand: 'Maison Arte',
      name: 'Oversized Cashmere Tunic',
      price: 420,
      category: 'Knitwear',
      description:
          'A masterclass in elevated comfort. Crafted from heavyweight cashmere blend, this oversized tunic offers a structured yet fluid drape. Inspired by Mediterranean earth tones, the neutral pigment is achieved through a sustainable mineral-dyeing process.',
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBI_1LuDHEA491y77F8xdye_vuagBGMUdgddLw2rSYEoqgFCY05LsnzdXzNyd_FnvR_M5UMKdxgJeVaJBeJYp9xS_1SRHT52ul2bPSULv494F21E_wT9BGsdPCpbqivKLzpykIyYsGuzWWw2OzAKqjQ9d21OXRd2n6zcp7Eb4HQlh6mBFipIn2oTfeXT3b709gUHem52i1ruzK8kVamO-UAIlHzs2WjqiJHf8HdA6Cb6Anxo-KRMV5DD3RXBWnaQUNNW8wH7D6x6lk',
    ),
    ProductModel(
      id: '2',
      brand: 'Zivo Signature',
      name: 'The Horizon Tote',
      price: 890,
      category: 'Accessories',
      description:
          'Structured luxury leather tote with architectural silhouette. Hand-finished in a deep rust tone using vegetable-tanned leather from artisanal Italian tanneries. Fits a 13" laptop with room for daily essentials.',
      sizes: ['One Size'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD7sdneWFpq1fl6vjwDOEl_nXDnPvd3ktDRNd45vdJ_ixgFc-BjHncDyi1v86PRe0XApY94yHGr43f58aBxU_7Ar3ej_gsdy5t-t_ogZO6WxyRIvTg0zfg-3VjyYpEAZorLi-nGwQknHZ8z5Kp1gqGiP9iL7wUJRCh4UKhMY8ojZZV1VmGh469hITqY_m6JQZSnmI_CfJfylR1gKIxR_8MkgmX6Nd2ljMusnBwBELToAmSktUJZsr6h6TpCx4Pv-rl_9Ry2pRKUIkw',
    ),
    ProductModel(
      id: '3',
      brand: 'Optical Studio',
      name: 'Cat-Eye Archive Frames',
      price: 285,
      category: 'Eyewear',
      description:
          'Minimalist tortoiseshell cat-eye frames in lightweight acetate. Hand-finished with spring hinges and UV400 polarised lenses. A timeless editorial silhouette updated for the modern wardrobe.',
      sizes: ['One Size'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBg8DwBf3JEROsIGCI5eajps8LDNDRxTLrrQbf9bV8L6WJf1szf6fpAVmf6jWGqsSxBeqm8W4zdDNOW4wJYrcyVZEdL2kEKT6u4LlkfpAlinT3UDPFFLhR0EcNGv-DNlvfhWm-QUaMVf0KJxGnELuEVKgHD0SyfGp7-RUKTqpVuVVHb9wwTzgjXAXBt6NVumwBOLB_PMOgkvfwlo7W06V6r0AMdziEOp2XNz_-mFqOjIos2CBt1zaSC9lS-mdjLHKjEUONBUsAQ4fo',
    ),
    ProductModel(
      id: '4',
      brand: 'Maison Arte',
      name: 'Ethereal Flora Scarf',
      price: 155,
      category: 'Accessories',
      description:
          'Intricate printed silk scarf with hand-painted floral motifs in earthy ochre and rust. Woven from pure 100% habotai silk in Como, Italy. Versatile enough to wear as a neckerchief, headscarf, or belt.',
      sizes: ['One Size'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB_9RA9MpD9AsE2RbEBSxof9j-8QjmDA09-iToGGdr2NFzG5gn_JAyGjax7alCF34hRr43b4Mja3JmaHo6vfFJDwkIw5BzPWF18hKckATMmMRnSbOtIguOPdMaZ6RsSpfej685O4NeQa7GbZj_7L6TlcoaccYZiDVT2ah_M5vBf2FB-PCgVU9amMaE-Q2pt7R_SgZOUYVS0FnvSGOizKuL5-dblnM2wHdqBN5YSsXpY2LWEH4IKtVBWEpSk3FLZ2tM45ZMexkJHUI4',
    ),
    ProductModel(
      id: '5',
      brand: 'Zivo',
      name: 'Linen Structured Shirt',
      price: 240,
      category: 'Tops',
      description:
          'Crisp structured shirt in stonewashed linen. Relaxed fit with a hidden button placket and straight hem. A minimal wardrobe staple elevated by fabric quality and precise tailoring.',
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBiZ9HLgmsQPZ85oM0rMrp3sYNSaS3YilFdPGnvRXItpAc_CU4OevWwjjtc94KSenWbGEDij5hkTs8fOCnlS_JzgyaKkEWN6fyGItDm313FXc0Ui3-ntmCasE3oPp6qz5F-u3EM4FPgNlhul7z-4Vk2NRHHKTky79_d5mKXVK4MdNOnCE05yiqL4rbkcd__6-smi927gO40QdAKx0aiDZuXOy03__sfU4OfpoKRdMoCKTlnLRB_rco2RQcKa_7ytKE-0B4BvZCMNu4',
    ),
    ProductModel(
      id: '6',
      brand: 'Zivo',
      name: 'Tailored Trousers',
      price: 310,
      category: 'Bottoms',
      description:
          'Charcoal wool-blend tailored trousers with a mid-rise fit and wide leg silhouette. Fully lined with a side-zip fastening and pressed front crease. Dry-clean only.',
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDdxGcv-FYgtGWJHHaHS3Cxb5IWizQKQTClUVuZTBIrUDGVW5qzauIRBWkTc4hYmOlfJomYq8u7W-JFXpmunzSDjNRyNgCDci4FNiy8kab6mU1kFsocwRpiTPyetHsTYQwgf0gctuON--kRqoJS6pR_7VKUNXN_wRGek_ugUa3MCwbOTAEgIzIKVJ5L_0ajSsrz6Nl6eYNL1QnO858JePLjS_bCqMrpD6xsmdTWkR8OCUAySZOFL9L4kfLK47I8BkIZOhc20yRjbSo',
    ),
    ProductModel(
      id: '7',
      brand: 'Zivo',
      name: 'Oversized Wool Knit',
      price: 450,
      category: 'Knitwear',
      description:
          'Voluminous terracotta wool-blend knit in a relaxed boxy silhouette. Chunky ribbed cuffs and hem with a dropped shoulder seam. Made in Portugal from 90% merino wool.',
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBqfJwKacPMpgWYLMmjBY0eSckthSWvXSZRbJG1sTERKxoawUjMEzfEKixUFmOlHUDHklB9Yh9olBhJmTxzcktpWzGZ3WUGZxqxGGAiWo0T7eQH1yYmvZ_a8K0cI-V2x_mmwLSt2zaBybebcYVrKdW6VqbNBEkWlomXX_TM_9haroZ1zEA5M63nsozRrI-QHpj-99uJS763y0_Q6kYz3qHjo0YKzco4AE8EsVEw1vbyJMT2y9P-95wyxiqcaCqyZRmw9lFF8ax-whM',
    ),
    ProductModel(
      id: '8',
      brand: 'Zivo',
      name: 'Raw Denim Shell',
      price: 380,
      category: 'Outerwear',
      description:
          'Deconstructed raw selvedge denim jacket with exposed stitching and a boxy cut. Unwashed 14oz Japanese denim that develops a unique patina with wear. Chest and side pockets.',
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA20AlLrtmrRa8CRY7hporK-UPdMNDeNpJWWf17AX5804O3Vkz-Tk-t8erb7V4c-bHIXL3KUa3gX6mHwdHj1ZPz8_R3TqJ_XEfCsJKN2OBYhsDPoYX8QE6MJNjoQE36uA29qCyehkOnIzI73S9H9NVuUjNugPj90NZxk8V9MTu1iF4S4dyA7HCf-ZGw1opP2jdWQKeEAYXimzLedeM8deN5UYp6S6no2hf1AUyOsrLD0ddQRxHxq6ngAlhbVyCa0eHeYV2V_HfHACw',
    ),
  ];

  void initFirestore() {
    _cancelSubscriptions();
    _cartSub = _firestore.getCart().listen((cart) {
      _cart = cart;
      notifyListeners();
    });
    _wishlistSub = _firestore.getWishlist().listen((wishlist) {
      _wishlist = wishlist;
      notifyListeners();
    });
    _ordersSub = _firestore.getOrders().listen((orders) {
      _orders = orders;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  void _cancelSubscriptions() {
    _cartSub?.cancel();
    _wishlistSub?.cancel();
    _ordersSub?.cancel();
  }

  Stream<List<ProductModel>> getProductsStream() {
    return _firestore.getProducts();
  }

  Stream<UserModel?> getUserProfileStream() {
    return _firestore.getUserProfile();
  }

  // Auth
  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _cancelSubscriptions();
    _currentUser = null;
    _cart.clear();
    _wishlist.clear();
    notifyListeners();
  }

  // Cart
  void addToCart(ProductModel product, String selectedSize, int quantity) {
    final idx = _cart.indexWhere(
      (i) => i.product.id == product.id && i.selectedSize == selectedSize,
    );
    if (idx != -1) {
      _firestore.updateCartQuantity(
        product.id,
        selectedSize,
        _cart[idx].quantity + quantity,
      );
    } else {
      _firestore.addToCart(CartModel(
          product: product, selectedSize: selectedSize, quantity: quantity));
    }
  }

  void updateCartQuantity(
      String productId, String selectedSize, int newQty) {
    _firestore.updateCartQuantity(productId, selectedSize, newQty);
  }

  void removeFromCart(String productId, String selectedSize) {
    _firestore.removeFromCart(productId, selectedSize);
  }

  void clearCart() {
    _firestore.clearCart();
  }

  // Wishlist
  void addToWishlist(ProductModel product) {
    if (!_wishlist.any((i) => i.id == product.id)) {
      _firestore.addToWishlist(product);
    }
  }

  void removeFromWishlist(String productId) {
    _firestore.removeFromWishlist(productId);
  }

  bool isInWishlist(String productId) =>
      _wishlist.any((i) => i.id == productId);

  // Orders
  void placeOrder(String deliveryAddress) {
    if (_cart.isEmpty) return;
    final total =
        _cart.fold(0.0, (s, i) => s + i.product.price * i.quantity);
    final order = OrderModel(
      id: 'ZV-${DateTime.now().millisecondsSinceEpoch % 100000}',
      items: List.from(_cart),
      totalPrice: total,
      date: DateTime.now(),
      status: 'Processing',
      deliveryAddress: deliveryAddress,
    );
    _firestore.placeOrder(order);
    clearCart();
  }

  double getCartTotal() =>
      _cart.fold(0.0, (s, i) => s + i.product.price * i.quantity);

  int getCartItemCount() =>
      _cart.fold(0, (s, i) => s + i.quantity);
}
