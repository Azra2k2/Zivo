import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/app_data.dart';
import '../../models/product_model.dart';
import '../../widgets/bottom_nav_bar.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  int _currentIndex = 3;

  static const _primary = Color(0xFFa03c01);
  static const _surface = Color(0xFFfef9f1);
  static const _surfaceContainerLow = Color(0xFFf8f3eb);
  static const _onSurface = Color(0xFF1d1c17);
  static const _onSurfaceVariant = Color(0xFF57423a);
  static const _outline = Color(0xFF8b7268);
  static const _outlineVariant = Color(0xFFdec0b5);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, _) {
        final items = appData.wishlist;
        return Scaffold(
          backgroundColor: _surface,
          extendBody: true,
          appBar: _buildAppBar(),
          body: items.isEmpty
              ? _buildEmptyState()
              : _buildWishlist(items, appData),
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
        icon: const Icon(Icons.menu, color: _primary),
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
          icon: const Icon(Icons.shopping_bag_outlined, color: _primary),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ],
    );
  }

  Widget _buildWishlist(List<ProductModel> items, AppData appData) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      children: [
        _buildHeader(items.length),
        const SizedBox(height: 40),
        ...items.map(
          (product) => Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: _buildWishlistCard(product, appData),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SAVED COLLECTIONS',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: _primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'The Wishlist',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 52,
            fontWeight: FontWeight.w600,
            color: _onSurface,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$count ${count == 1 ? 'piece' : 'pieces'} awaiting their place in your archive.',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: _onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistCard(ProductModel product, AppData appData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: _surfaceContainerLow),
                Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Container(color: _surfaceContainerLow),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => appData.removeFromWishlist(product.id),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _surface.withValues(alpha: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: _onSurface,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      appData.addToCart(product, product.sizes.first, 1);
                      Navigator.pushNamed(context, '/cart');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _primary,
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: _outline,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: _onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '\$${product.price.toStringAsFixed(0)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.heart_broken_outlined, size: 64, color: _outlineVariant),
            const SizedBox(height: 24),
            Text(
              'Your wishlist is empty',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: _onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Curate your collection by exploring our latest seasonal arrivals.',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 18,
                ),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: Text(
                'START EXPLORING',
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
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }
}
