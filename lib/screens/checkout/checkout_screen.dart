import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/app_data.dart';
import '../../models/cart_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();

  static const _primary = Color(0xFFa03c01);
  static const _primaryContainer = Color(0xFFc0541c);
  static const _surface = Color(0xFFfef9f1);
  static const _surfaceContainerLowest = Color(0xFFffffff);
  static const _surfaceContainerLow = Color(0xFFf8f3eb);
  static const _surfaceContainer = Color(0xFFf2ede5);
  static const _surfaceContainerHigh = Color(0xFFece8e0);
  static const _onSurface = Color(0xFF1d1c17);
  static const _onSurfaceVariant = Color(0xFF57423a);

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _placeOrder(AppData appData) {
    final name = _nameController.text.trim();
    final street = _addressController.text.trim();
    final city = _cityController.text.trim();
    final zip = _zipController.text.trim();
    final hasAddress = name.isNotEmpty || street.isNotEmpty || city.isNotEmpty;
    final address = hasAddress
        ? [
            name,
            street,
            '$city $zip'.trim(),
          ].where((s) => s.isNotEmpty).join(', ')
        : '242 Editorial Avenue, New York';
    appData.placeOrder(address);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _surfaceContainerLowest,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: _primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Order Confirmed',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your order has been placed successfully. Track it anytime in your order history.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/orders',
                      (r) => r.settings.name == '/home',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'View My Order',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, _) {
        final cartItems = appData.cart;
        final subtotal = appData.getCartTotal();
        final tax = subtotal * 0.085;
        final total = subtotal + tax;

        return Scaffold(
          backgroundColor: _surface,
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildDeliverySection(),
                const SizedBox(height: 40),
                _buildPaymentSection(),
                const SizedBox(height: 32),
                _buildOrderSummaryCard(
                  cartItems,
                  subtotal,
                  tax,
                  total,
                  appData,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: _primary),
        onPressed: () => Navigator.pop(context),
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
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined, color: _primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SECURE TRANSACTION',
          style: GoogleFonts.inter(
            fontSize: 10,
            color: _onSurfaceVariant,
            letterSpacing: 2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Finalizing your\nselection.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 42,
            fontWeight: FontWeight.w600,
            color: _onSurface,
            height: 1.15,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepLabel('1', 'Delivery Address', active: true),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _nameController,
          label: 'FULL NAME',
          hint: 'Julianne Moore',
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: 'STREET ADDRESS',
          hint: '242 Editorial Avenue, Apt 4B',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cityController,
                label: 'CITY',
                hint: 'New York',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _zipController,
                label: 'ZIP CODE',
                hint: '10012',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepLabel('2', 'Payment Method', active: false),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.credit_card, color: _primary, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visa ending in 4429',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Expires 12/26',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: _onSurfaceVariant,
                size: 22,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummaryCard(
    List<CartModel> cartItems,
    double subtotal,
    double tax,
    double total,
    AppData appData,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1d1c17).withValues(alpha: 0.04),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 24),
          ...cartItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildOrderItem(item),
            ),
          ),
          const Divider(color: _surfaceContainerHigh, thickness: 2, height: 32),
          _buildPriceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _onSurfaceVariant,
                ),
              ),
              Text(
                'COMPLIMENTARY',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: _primary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Taxes (8.5%)', '\$${tax.toStringAsFixed(2)}'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _onSurface,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildPlaceOrderButton(appData),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 14,
                color: _onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'ENCRYPTED TRANSACTION',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: _onSurfaceVariant.withValues(alpha: 0.6),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 72,
            height: 88,
            child: Image.network(
              item.product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: _surfaceContainer),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                item.product.name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.product.brand.isNotEmpty ? '${item.product.brand.toUpperCase()} • ' : ''}SIZE ${item.selectedSize} • QTY ${item.quantity}',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: _onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, color: _onSurfaceVariant),
        ),
        Text(value, style: GoogleFonts.inter(fontSize: 14, color: _onSurface)),
      ],
    );
  }

  Widget _buildPlaceOrderButton(AppData appData) {
    return SizedBox(
      width: double.infinity,
      height: 60,
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
              color: _primary.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () => _placeOrder(appData),
          icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
          label: Text(
            'Place Order',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.5,
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

  Widget _buildStepLabel(String number, String title, {required bool active}) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? _primary : _surfaceContainerHigh,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : _onSurface,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: _onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: _surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(fontSize: 15, color: _onSurface),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                color: _onSurface.withValues(alpha: 0.3),
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 16,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: _onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
