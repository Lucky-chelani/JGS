import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/category_page.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/announcements/presentation/announcements_screen.dart';
import '../../features/admin/presentation/admin_screen.dart';
import '../../features/admin/presentation/admin_login_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/category',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return CategoryPage(
          initialCategory: extra['category'] as String?,
          initialBrand: extra['brand'] as String?,
          initialConcern: extra['concern'] as String?,
          initialSort: extra['sort'] as String?,
          pageTitle: extra['title'] as String?,
          initialCollection: extra['collection'] as String?,
          initialSearchQuery: extra['search'] as String?,
          autoFocusSearch: extra['autoFocusSearch'] == true,
        );
      },
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return OtpScreen(phoneNumber: phone);
      },
    ),
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
    GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/announcements',
      builder: (context, state) => const AnnouncementsScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin/panel',
      builder: (context, state) => const AdminScreen(),
    ),
  ],
);
