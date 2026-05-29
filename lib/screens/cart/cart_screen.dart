import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/app_data.dart';
import '../../models/cart_model.dart';
import '../../widgets/bottom_nav_bar.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _currentIndex = 2;

  static const _primary = Color(0xFFa03c01);
  static const _primaryContainer = Color(0xFFc0541c);
  static const _surface = Color(0xFFfef9f1);
  static const _surfaceContainerLowest = Color(0xFFffffff);
  static const _surfaceContainer = Color(0xFFf2ede5);
  static const _surfaceContainerHigh = Color(0xFFece8e0);
  static const _onSurface = Color(0xFF1d1c17);
  static const _onSurfaceVariant = Color(0xFF57423a);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, _) {
        final cartItems = appData.cart;
        return Scaffold(
          backgroundColor: _surface,
          extendBody: true,
          appBar: _buildAppBar(),
          body: cartItems.isEmpty
              ? _buildEmptyState()
              : _buildCartBody(cartItems, appData),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
              _navigateToScreen(index);
            },
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: _onSurface),
        onPressed: () {},
      ),
      title: Text(
        'ZIVO',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _onSurface,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined, color: _onSurface),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCartBody(List<CartModel> cartItems, AppData appData) {
    final subtotal = appData.getCartTotal();
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
      children: [
        _buildHeading(cartItems.length),
        const SizedBox(height: 32),
        ...cartItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildCartItem(item, appData),
          ),
        ),
        const SizedBox(height: 24),
        _buildOrderSummary(subtotal),
      ],
    );
  }

  Widget _buildHeading(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Cart',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 52,
            fontWeight: FontWeight.w600,
            color: _onSurface,
            height: 1.0,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$count ${count == 1 ? 'Item' : 'Items'} Selected',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: _onSurfaceVariant,
            letterSpacing: 2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartModel item, AppData appData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 100,
              height: 128,
              child: Image.network(
                item.product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(color: _surfaceContainerHigh),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 128,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.selectedSize.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: _onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => appData.removeFromCart(
                          item.product.id,
                          item.selectedSize,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQtyStepper(item, appData),
                      Text(
                        '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyStepper(CartModel item, AppData appData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => appData.updateCartQuantity(
              item.product.id,
              item.selectedSize,
              item.quantity - 1,
            ),
            child: const Icon(Icons.remove, size: 18, color: _onSurface),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${item.quantity}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _onSurface,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => appData.updateCartQuantity(
              item.product.id,
              item.selectedSize,
              item.quantity + 1,
            ),
            child: const Icon(Icons.add, size: 18, color: _onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal) {
    return Column(
      children: [
        const Divider(color: _surfaceContainerHigh, thickness: 2, height: 32),
        _buildSummaryRow(
          'Subtotal',
          '\$${subtotal.toStringAsFixed(2)}',
          bold: false,
        ),
        const SizedBox(height: 12),
        _buildSummaryRow(
          'Shipping',
          'Calculated at checkout',
          bold: false,
          small: true,
        ),
        const SizedBox(height: 20),
        _buildSummaryRow(
          'Total',
          '\$${subtotal.toStringAsFixed(2)}',
          bold: true,
          large: true,
        ),
        const SizedBox(height: 28),
        _buildCheckoutButton(),
        const SizedBox(height: 16),
        Text(
          'SECURE ENCRYPTED CHECKOUT',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 9,
            color: _onSurfaceVariant,
            letterSpacing: 2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool bold = false,
    bool large = false,
    bool small = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: large
              ? GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _onSurface,
                )
              : GoogleFonts.inter(
                  fontSize: small ? 13 : 15,
                  color: _onSurfaceVariant,
                ),
        ),
        Text(
          value,
          style: large
              ? GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                )
              : GoogleFonts.inter(
                  fontSize: small ? 13 : 15,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                  color: _onSurface,
                ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primary, _primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/checkout'),
          icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          label: Text(
            'Proceed to Checkout',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: const Color(0xFFdec0b5),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add items from your wishlist or browse the collection.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/products'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: Text(
              'SHOP NOW',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/products');
        break;
      case 3:
        Navigator.pushNamed(context, '/wishlist');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }
}
