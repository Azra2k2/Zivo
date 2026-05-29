import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  static const _surface = Color(0xFFfef9f1);

  static const _icons = [
    Icons.home,
    Icons.grid_view,
    Icons.shopping_cart_outlined,
    Icons.favorite_border,
    Icons.person_outline,
  ];

  static const _filledIcons = [
    Icons.home,
    Icons.grid_view,
    Icons.shopping_cart,
    Icons.favorite,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: _surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1d1c17).withValues(alpha: 0.06),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              5,
              (i) => _NavItem(
                icon: i == currentIndex ? _filledIcons[i] : _icons[i],
                isSelected: i == currentIndex,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  static const _primary = Color(0xFFa03c01);
  static const _surface = Color(0xFFfef9f1);
  static const _onSurface = Color(0xFF1d1c17);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? _primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: isSelected ? _surface : _onSurface),
      ),
    );
  }
}
