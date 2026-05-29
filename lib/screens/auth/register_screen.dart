import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  static const _primary = Color(0xFFa03c01);
  static const _primaryContainer = Color(0xFFc0541c);
  static const _surface = Color(0xFFfef9f1);
  static const _surfaceContainerLowest = Color(0xFFffffff);
  static const _surfaceContainerLow = Color(0xFFf8f3eb);
  static const _surfaceContainerHigh = Color(0xFFece8e0);
  static const _onSurface = Color(0xFF1d1c17);
  static const _onSurfaceVariant = Color(0xFF57423a);
  static const _outline = Color(0xFF8b7268);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }

    try {
      final authService = context.read<AuthService>();
      final user = await authService.signUpWithEmail(email, password, name);
      if (user != null) {
        final firestore = FirestoreService();
        await firestore.saveUserProfile(UserModel(
          id: user.uid,
          name: name,
          email: email,
        ));
      }
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      _showError(_getAuthErrorMessage(e.code));
    } on Exception catch (_) {
      _showError('Registration failed. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      default:
        return 'Registration failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
        child: Column(
          children: [
            _buildHeading(),
            const SizedBox(height: 48),
            _buildCard(),
            const SizedBox(height: 48),
            _buildEditorialImages(),
            const SizedBox(height: 48),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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

  Widget _buildHeading() {
    return Column(
      children: [
        Text(
          'Create Account',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 52,
            fontWeight: FontWeight.w600,
            color: _onSurface,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Join the Zivo editorial experience today.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 14, color: _onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1d1c17).withValues(alpha: 0.04),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField(
            label: 'FULL NAME',
            controller: _nameController,
            hint: 'Evelyn Thorne',
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 24),
          _buildField(
            label: 'EMAIL ADDRESS',
            controller: _emailController,
            hint: 'evelyn@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          _buildPasswordField(),
          const SizedBox(height: 32),
          _buildRegisterButton(),
          const SizedBox(height: 32),
          const Divider(color: _surfaceContainerHigh, thickness: 2),
          const SizedBox(height: 24),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(color: _onSurface),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: _outline),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PASSWORD',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: GoogleFonts.inter(color: _onSurface),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: GoogleFonts.inter(color: _outline),
              suffixIcon: GestureDetector(
                onTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                child: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _outline,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
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
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _register,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Register Account',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(fontSize: 14, color: _onSurfaceVariant),
          children: [
            const TextSpan(text: 'Already have an account? '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Login',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                    decoration: TextDecoration.underline,
                    decorationColor: _primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorialImages() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.saturation,
                ),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBO3F6tYCoFk4ZBEbE11L56Kqgre7yb4AoTJ-9VU-tFGrzP7yutJhpJnEVKlNG8dP_kXu5lV7wdKfMys5eY5z_rJa3LVOG9Ml0kE5fbEiSgxEIE1YwRU-G_LTrNkuk4mXXoxPq6BygDgeNcA4H82S4zMUTYHjva4dN4LQw1-Z5p0ftA-utmI5NMEkjjrnfGbn4JWF49vPMq4aIRs1bY6e0MaVbgeL6r_Bry946NW_i0Sh-PNzBUcljRzqHZx19t00lMzapsF1jGBew',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Container(color: _surfaceContainerLow),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 32),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.saturation,
                  ),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAXCZJU5gPcpIpIqoJgthZq04xmRTQesaalCPWt4BG4Qee3z8yopV3g5lHnjbP_-DZXksfzpZKlg6ucjJSLKqSSR4f2fhA554MWCoeqmlGwXDLeCB8djWOR8wOrgXcfXiaRPCXhMO3cWNoQ8A60bF-1p75B9w-3ImJz5BoVtLSclogbtdDx26PLkrUnp6BJ9JwEQ7DlCP5jNdToUmDu2tJJ4LcJoVO77yZA6fKdzgVyXaSHwgcRrNzWcR8olXFlYjudNuSALkgAsWk',
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
    );
  }

  Widget _buildFooter() {
    return Text(
      '© 2024 ZIVO Collective. All Rights Reserved.',
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 11,
        color: _outline,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
