import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
  static const _onSecondaryFixedVariant = Color(0xFF5a4137);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }

    try {
      final authService = context.read<AuthService>();
      await authService.signInWithEmail(email, password);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      _showError(_getAuthErrorMessage(e.code));
    } on Exception catch (_) {
      _showError('Login failed. Please try again.');
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
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Invalid email or password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          _BackgroundBlobs(),
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 64),
                  _buildCard(),
                  const SizedBox(height: 48),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'ZIVO',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 60,
            fontWeight: FontWeight.w800,
            color: _onSurface,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'EDITORIAL FASHION EXCELLENCE',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: _onSecondaryFixedVariant,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1d1c17).withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please enter your credentials to access your curated collection.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _buildEmailField(),
          const SizedBox(height: 24),
          _buildPasswordField(),
          const SizedBox(height: 32),
          _buildSignInButton(),
          const SizedBox(height: 32),
          _buildDivider(),
          const SizedBox(height: 24),
          _buildSocialButtons(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EMAIL ADDRESS',
          style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _onSurface,
              letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(color: _onSurface),
            decoration: InputDecoration(
              hintText: 'curator@zivo.com',
              hintStyle: GoogleFonts.inter(
                  color: _outline.withValues(alpha: 0.6)),
              prefixIcon: const Icon(Icons.mail_outline, color: _outline),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 18),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PASSWORD',
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _onSurface,
                  letterSpacing: 1.2),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Forgot?',
                style: GoogleFonts.inter(
                    fontSize: 10, color: _primary, letterSpacing: 0.5),
              ),
            ),
          ],
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
              hintStyle: GoogleFonts.inter(
                  color: _outline.withValues(alpha: 0.6)),
              prefixIcon: const Icon(Icons.lock_outline, color: _outline),
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
                  horizontal: 16, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
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
              color: _primary.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _signIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign In',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward,
                  color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
            child: Divider(color: _surfaceContainerHigh, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR CONTINUE WITH',
            style: GoogleFonts.inter(
                fontSize: 9, letterSpacing: 2, color: _outline),
          ),
        ),
        const Expanded(
            child: Divider(color: _surfaceContainerHigh, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'Google',
            icon: const Icon(Icons.g_mobiledata, color: _outline, size: 22),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SocialButton(
            label: 'Apple',
            icon: const Icon(Icons.apple, color: _outline, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(fontSize: 14, color: _onSurfaceVariant),
        children: [
          const TextSpan(text: 'New to Zivo? '),
          WidgetSpan(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/register'),
              child: Text(
                'Create an account',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _onSurface,
                  decoration: TextDecoration.underline,
                  decorationColor: _primary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon});
  final String label;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFf2ede5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF8b7268).withValues(alpha: 0.1)),
      ),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1d1c17),
                  letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundBlobs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
          top: -size.height * 0.1,
          left: -size.width * 0.1,
          child: Container(
            width: size.width * 0.7,
            height: size.width * 0.7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x33ffdbcd),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.4,
          right: -size.width * 0.1,
          child: Container(
            width: size.width * 0.6,
            height: size.width * 0.6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x33fed8ca),
            ),
          ),
        ),
      ],
    );
  }
}
