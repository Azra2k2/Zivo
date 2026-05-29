import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../data/app_data.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4;

  static const _primary = Color(0xFFa03c01);
  static const _primaryContainer = Color(0xFFc0541c);
  static const _surface = Color(0xFFfef9f1);
  static const _surfaceContainerLowest = Color(0xFFffffff);
  static const _surfaceContainerHigh = Color(0xFFece8e0);
  static const _onSurface = Color(0xFF1d1c17);
  static const _onSurfaceVariant = Color(0xFF57423a);
  static const _outlineVariant = Color(0xFFdec0b5);
  static const _error = Color(0xFFba1a1a);
  static const _errorContainer = Color(0xFFffdad6);

  static const _avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuD0-cZw9EQJPQTl4UMtE9QbBR8B-tJu26TBAzZ5s2dnK6rqjmPBcllBmjj1mR6j7iYD2O6OSj7wcBQIjtjFx7IWA7oOcMYP48PaoVNleMbdabd3MYE0yXewNLgCr8jE_qW3aPHUN31xUstvHM_5qUfdyW1xYud0KJds1RuiyI_pFzrSOEMkIBRUVMGhtMs2EmtLShnfzvHLi-T4LPLQ1ce6THYj6eIQ3PO9k_G73GP1Y1aa4rnuPaMaZng17wctmIrdgtWW0GG8TxM';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      extendBody: true,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
        child: Column(
          children: [
            _buildHeroSection(),
            const SizedBox(height: 40),
            _buildMenuList(),
            const SizedBox(height: 40),
            _buildLoyaltyCard(),
            const SizedBox(height: 32),
          ],
        ),
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

  Widget _buildHeroSection() {
    final appData = context.watch<AppData>();
    return StreamBuilder<UserModel?>(
      stream: appData.getUserProfileStream(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _surfaceContainerHigh, width: 4),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      _avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: _surfaceContainerHigh,
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              user?.name ?? 'Guest',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: _onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuList() {
    final items = [
      _MenuItem(
        icon: Icons.person_outline,
        title: 'Edit Profile',
        subtitle: 'Account details',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.history,
        title: 'Order History',
        subtitle: '12 completed orders',
        onTap: () => Navigator.pushNamed(context, '/orders'),
      ),
      _MenuItem(
        icon: Icons.location_on_outlined,
        title: 'Shipping Addresses',
        subtitle: '2 saved locations',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.credit_card_outlined,
        title: 'Payments',
        subtitle: 'Visa ending in 4242',
        onTap: () {},
      ),
    ];

    return Column(
      children: [
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildMenuRow(item),
          ),
        ),
        const SizedBox(height: 8),
        _buildLogoutRow(),
      ],
    );
  }

  Widget _buildMenuRow(_MenuItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: _primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: _onSurfaceVariant,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _outlineVariant, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutRow() {
    return GestureDetector(
      onTap: () async {
        final authService = context.read<AuthService>();
        final appData = context.read<AppData>();
        await authService.signOut();
        appData.logout();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: _error, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logout',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _error,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'END CURRENT SESSION',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: _error.withValues(alpha: 0.6),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: _error.withValues(alpha: 0.4), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.35),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background blob
          Positioned(
            top: -48,
            right: -48,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primaryContainer.withValues(alpha: 0.5),
              ),
            ),
          ),
          // Content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ZIVO ELITE MEMBER',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '2,450 Points',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildLoyaltyPill('View Perks'),
                        const SizedBox(width: 8),
                        _buildLoyaltyPill('Redeem'),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.diamond_outlined,
                size: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyPill(String label) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1,
          ),
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
      case 3:
        Navigator.pushNamed(context, '/wishlist');
        break;
    }
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}
