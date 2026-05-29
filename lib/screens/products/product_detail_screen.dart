import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/app_data.dart';
import '../../models/product_model.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = '';
  bool _materialExpanded = false;
  bool _shippingExpanded = false;
  int _currentNav = 1;

  static const _primary = Color(0xFFa03c01);
  static const _primaryContainer = Color(0xFFc0541c);
  static const _surface = Color(0xFFfef9f1);
  static const _surfaceContainerLowest = Color(0xFFffffff);
  static const _surfaceContainerLow = Color(0xFFf8f3eb);
  static const _surfaceContainerHighest = Color(0xFFe7e2da);
  static const _onSurface = Color(0xFF1d1c17);
  static const _onSurfaceVariant = Color(0xFF57423a);
  static const _outline = Color(0xFF8b7268);
  static const _outlineVariant = Color(0xFFdec0b5);
  static const _secondary = Color(0xFF74584e);

  ProductModel get _product => AppData.products.firstWhere(
    (p) => p.id == widget.productId,
    orElse: () => AppData.products.first,
  );

  @override
  void initState() {
    super.initState();
    final product = _product;
    _selectedSize = product.sizes.isNotEmpty ? product.sizes.first : '';
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();

    return StreamBuilder<List<ProductModel>>(
      stream: appData.getProductsStream(),
      builder: (context, snapshot) {
        final products = snapshot.data ?? AppData.products;
        final product = products.firstWhere(
          (p) => p.id == widget.productId,
          orElse: () => products.isNotEmpty ? products.first : _product,
        );
        final isWishlisted = appData.isInWishlist(widget.productId);

        return Scaffold(
          backgroundColor: _surface,
          extendBody: true,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                _buildHeroImage(product.imageUrl),
                _buildProductCard(product, isWishlisted, appData),
                const SizedBox(height: 40),
                _buildGallery(product.imageUrl),
                const SizedBox(height: 48),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentNav,
            onTap: (i) {
              setState(() => _currentNav = i);
              _navigateToScreen(i);
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
        icon: const Icon(Icons.arrow_back, color: _primary),
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
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ],
    );
  }

  Widget _buildHeroImage(String imageUrl) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: _surfaceContainerLow),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, _surface.withValues(alpha: 0.2)],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    ProductModel product,
    bool isWishlisted,
    AppData appData,
  ) {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1d1c17).withValues(alpha: 0.06),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductHeader(product),
              const SizedBox(height: 28),
              _buildDescription(product.description),
              const SizedBox(height: 24),
              _buildAccordion(),
              const SizedBox(height: 32),
              _buildSizeSelector(product.sizes),
              const SizedBox(height: 32),
              _buildActionButtons(product, isWishlisted, appData),
              const SizedBox(height: 28),
              _buildValueProps(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductHeader(ProductModel product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.category.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: _secondary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: _onSurface,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              if (product.brand.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  product.brand,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: _onSurface,
              ),
            ),
            Text(
              'TAX INCLUDED',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: _outline,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: _onSurfaceVariant,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _buildAccordion() {
    return Column(
      children: [
        _AccordionRow(
          title: 'Material & Care',
          expanded: _materialExpanded,
          onTap: () => setState(() => _materialExpanded = !_materialExpanded),
          content:
              '80% Wool, 20% Polyamide. Dry clean only. Do not bleach. Iron on low heat.',
        ),
        _AccordionRow(
          title: 'Shipping & Returns',
          expanded: _shippingExpanded,
          onTap: () => setState(() => _shippingExpanded = !_shippingExpanded),
          content:
              'Free express delivery worldwide. Returns accepted within 14 days in original condition.',
        ),
      ],
    );
  }

  Widget _buildSizeSelector(List<String> sizes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SELECT SIZE',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _onSurface,
                letterSpacing: 1.5,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Size Guide',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: _outline,
                  decoration: TextDecoration.underline,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: sizes.map((size) {
            final selected = size == _selectedSize;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: selected
                      ? _surfaceContainerHighest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? _onSurface : _outlineVariant,
                    width: selected ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  size,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: _onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    ProductModel product,
    bool isWishlisted,
    AppData appData,
  ) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 64,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primary, _primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_selectedSize.isEmpty) return;
                  appData.addToCart(product, _selectedSize, 1);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${product.name} added to cart',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                      backgroundColor: _primary,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'VIEW',
                        textColor: Colors.white,
                        onPressed: () => Navigator.pushNamed(context, '/cart'),
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  'Add to Cart',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            if (isWishlisted) {
              appData.removeFromWishlist(product.id);
            } else {
              appData.addToWishlist(product);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? _primary : _onSurface,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueProps() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  color: _primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'FREE EXPRESS\nDELIVERY',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _onSurface,
                      letterSpacing: 0.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_outlined, color: _primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AUTHENTICITY\nGUARANTEED',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _onSurface,
                      letterSpacing: 0.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGallery(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Container(color: _surfaceContainerLow),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 48),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.grey,
                      BlendMode.saturation,
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Container(color: _surfaceContainerLow),
                    ),
                  ),
                ),
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
      case 2:
        Navigator.pushNamed(context, '/cart');
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

class _AccordionRow extends StatelessWidget {
  const _AccordionRow({
    required this.title,
    required this.expanded,
    required this.onTap,
    required this.content,
  });

  final String title;
  final bool expanded;
  final VoidCallback onTap;
  final String content;

  static const _surfaceContainerHigh = Color(0xFFece8e0);
  static const _onSurface = Color(0xFF1d1c17);
  static const _onSurfaceVariant = Color(0xFF57423a);
  static const _outline = Color(0xFF8b7268);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _onSurface,
                  ),
                ),
                Icon(
                  expanded ? Icons.remove : Icons.add,
                  color: _outline,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              content,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ),
        const Divider(color: _surfaceContainerHigh, thickness: 1, height: 1),
      ],
    );
  }
}
