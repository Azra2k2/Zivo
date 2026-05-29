import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/app_data.dart';
import '../../models/product_model.dart';
import '../../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _selectedCategory = 0;

  static const _primary = Color(0xFFa03c01);
  static const _surface = Color(0xFFfef9f1);
  static const _surfaceContainerLow = Color(0xFFf8f3eb);
  static const _surfaceContainerHigh = Color(0xFFece8e0);
  static const _surfaceContainerHighest = Color(0xFFe7e2da);
  static const _surfaceContainerLowest = Color(0xFFffffff);
  static const _onSurface = Color(0xFF1d1c17);
  static const _onSurfaceVariant = Color(0xFF57423a);
  static const _secondaryContainer = Color(0xFFfed8ca);
  static const _onSecondaryFixed = Color(0xFF2a170f);

  final _categories = [
    'All',
    'New',
    'Summer',
    'Accessories',
    "Editors' Choice",
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, _) {
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
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    _buildCategoryChips(),
                    const SizedBox(height: 32),
                    _buildHeroBanner(),
                    const SizedBox(height: 48),
                    _buildFeaturedProducts(products),
                    const SizedBox(height: 80),
                    _buildEditorialQuote(),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: _surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          style: GoogleFonts.inter(color: _onSurface, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search curated collections...',
            hintStyle: GoogleFonts.inter(
              color: _onSurface.withValues(alpha: 0.3),
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.search, color: _onSurface.withValues(alpha: 0.4)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final selected = i == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _secondaryContainer : _surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _categories[i].toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: selected ? _onSecondaryFixed : _onSurface,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAS4i1dXoRo8oI9enQmYr1hGW2H3PwEkPVuQqo3aUA2PL4U2IWDaTay71QmyNUW2l8xz16_Q0OsG5hhtWMiU3W-PX8_kpdHCgU1jYE-q0e5K1EENSIFGFbGniAf_wP54G_zgykhyWJIGfxAelHsT31KsJlkdnVsBRkE6DQMe0CClmIIJ-y3bAvSWsP-S2KN7Whs6iWrYQ9Cga2LM9wuX_VuYImri5WhBI02w9ek8scDhMaBeZ3f6pX2w4LI7Nkx8J4ADt-V9MHhNnQ',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Container(color: _surfaceContainerLow),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF1d1c17).withValues(alpha: 0.6),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 32,
                    left: 32,
                    right: 32,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXCLUSIVE DROP',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.8),
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The Summer\nSolstice Series',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/products'),
                          icon: const Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Shop Now',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 4,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 4,
                decoration: BoxDecoration(
                  color: _surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 4,
                decoration: BoxDecoration(
                  color: _surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProducts(List<ProductModel> products) {
    if (products.length < 4) return const SizedBox.shrink();
    final featured = products.take(4).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURATED',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                      letterSpacing: 3,
                    ),
                  ),
                  Text(
                    'Featured Products',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: _onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/products'),
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _onSurface.withValues(alpha: 0.6),
                    letterSpacing: 1.5,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildProductCard(featured[0]),
                    const SizedBox(height: 24),
                    _buildProductCard(featured[2]),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    _buildProductCard(featured[1]),
                    const SizedBox(height: 24),
                    _buildProductCard(featured[3]),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
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
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _surfaceContainerLowest.withValues(alpha: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: _onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.brand.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              letterSpacing: 2,
              color: _onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.name,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${product.price.toStringAsFixed(0)}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorialQuote() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: _surfaceContainerHigh, width: 2),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.format_quote, size: 36, color: _primary.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          Text(
            '"Style is a way to say who you are without having to speak."',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: _onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '— RACHEL ZOE',
            style: GoogleFonts.inter(
              fontSize: 9,
              letterSpacing: 4,
              color: _onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
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
