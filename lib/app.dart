import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'data/app_data.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/products/product_list_screen.dart';
import 'screens/products/product_detail_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/orders/order_history_screen.dart';
import 'screens/wishlist/wishlist_screen.dart';
import 'screens/profile/profile_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<AppData>(
          create: (_) => AppData(),
        ),
      ],
      child: MaterialApp(
        title: 'ZIVO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFa03c01),
          ),
          scaffoldBackgroundColor: const Color(0xFFfef9f1),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFfef9f1),
            foregroundColor: Color(0xFF1d1c17),
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
        ),
        home: const _AuthGate(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
          '/products': (_) => const ProductListScreen(),
          '/cart': (_) => const CartScreen(),
          '/checkout': (_) => const CheckoutScreen(),
          '/orders': (_) => const OrderHistoryScreen(),
          '/wishlist': (_) => const WishlistScreen(),
          '/profile': (_) => const ProfileScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product-detail') {
            final productId = settings.arguments as String? ?? '1';
            return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: productId),
            );
          }
          return null;
        },
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          if (!_initialized) {
            _initialized = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<AppData>().initFirestore();
              }
            });
          }
          return const HomeScreen();
        }
        _initialized = false;
        return const LoginScreen();
      },
    );
  }
}
