import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/app_data.dart';
import '../../models/product_model.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  int _currentIndex = 1;

  static const _primary = Color(0xFFa03c01);
  static const _surface = Color(0xFFfef9f1);
  static const _surfaceContainerLowest = Color(0xFFffffff);
  static const _surfaceContainerLow = Color(0xFFf8f3eb);
  static const _onSurface = Color(0xFF1d1c17);
  static const _onSurfaceVariant = Color(0xFF57423a);

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();

    return Scaffold(
      backgroundColor: _surface,
      extendBody: true,
      appBar: _buildAppBar(),
      body: StreamBuilder<List<ProductModel>>(
        stream: appData.getProductsStream(),
        builder: (context, snapshot) {
          final products = snapshot.data ?? AppData.products;
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildEditorialHero(),
                const SizedBox(height: 40),
                _buildProductGrid(products, appData),
                const SizedBox(height: 56),
                _buildDiscoverMore(),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _navigateToScreen(index);
        },
      ),
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
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined, color: _onSurface),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ],
    );
  }

  Widget _buildEditorialHero() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUMMER 2024',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: _primary,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The New\nStandard.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 52,
              fontWeight: FontWeight.w600,
              color: _onSurface,
              height: 1.0,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Refined textures and organic silhouettes\nfor the modern minimalist.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<ProductModel> products, AppData appData) {
    if (products.length < 4) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildProductCard(products[0], appData),
                const SizedBox(height: 24),
                _buildProductCard(products[2], appData),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 32),
                _buildProductCard(products[1], appData),
                const SizedBox(height: 24),
                _buildProductCard(products[3], appData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, AppData appData) {
    final isWishlisted = appData.isInWishlist(product.id);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/product-detail',
        arguments: product.id,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: _surfaceContainerLowest),
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Container(color: _surfaceContainerLow),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        if (isWishlisted) {
                          appData.removeFromWishlist(product.id);
                        } else {
                          appData.addToWishlist(product);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _surface.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isWishlisted ? _primary : _onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverMore() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'DISCOVER MORE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _onSurface,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 8),
          Container(height: 1, width: 48, color: _onSurface),
        ],
      ),
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
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
