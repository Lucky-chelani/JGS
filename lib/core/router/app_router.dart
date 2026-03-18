import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/category_page.dart';
import '../../features/home/presentation/bride_to_be_screen.dart';
import '../../features/home/presentation/salon_owners_screen.dart';
import '../../features/home/presentation/about_us_screen.dart';
import '../../features/home/presentation/privacy_policy_screen.dart';
import '../../features/home/presentation/terms_screen.dart';
import '../../features/home/presentation/footer_info_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/announcements/presentation/announcements_screen.dart';
import '../../features/admin/presentation/admin_screen.dart';
import '../../features/admin/presentation/admin_login_screen.dart';
import '../../features/product/presentation/product_detail_page.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/orders/presentation/order_details_screen.dart';
import '../../shared/models/product_model.dart';
import '../../shared/models/order_model.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  observers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)],
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
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return OtpScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/product',
      builder: (context, state) {
        final product = state.extra as CatalogProduct;
        return ProductDetailPage(product: product);
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
      path: '/bride-to-be',
      builder: (context, state) => const BrideToBeScreen(),
    ),
    GoRoute(
      path: '/salon-owners',
      builder: (context, state) => const SalonOwnersScreen(),
    ),
    GoRoute(
      path: '/about-us',
      builder: (context, state) => const AboutUsScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(path: '/terms', builder: (context, state) => const TermsScreen()),
    GoRoute(
      path: '/careers',
      builder: (context, state) => const FooterInfoScreen(
        pageTitle: 'Careers',
        subtitle: 'Build your career with JGS in beauty, retail, and tech.',
        icon: Icons.work_outline_rounded,
        sections: [
          FooterInfoSection(
            title: 'Open Roles',
            points: [
              'Store Associate (Chhindwara) - Customer support and beauty guidance.',
              'Inventory Executive - Warehouse and stock management.',
              'Delivery Partner Coordinator - Last-mile operations.',
              'Content & Catalog Executive - Product listing and quality checks.',
            ],
          ),
          FooterInfoSection(
            title: 'How To Apply',
            points: [
              'Send your resume to careers@jagdishgeneralstore.com.',
              'Mention your role of interest in the email subject line.',
              'Include your city, notice period, and expected salary.',
            ],
          ),
        ],
      ),
    ),
    GoRoute(
      path: '/returns',
      builder: (context, state) => const FooterInfoScreen(
        pageTitle: 'Returns & Refunds',
        subtitle: 'Simple and transparent return process for eligible orders.',
        icon: Icons.assignment_return_rounded,
        sections: [
          FooterInfoSection(
            title: 'Return Window',
            points: [
              'Raise return requests within 7 days from delivery date.',
              'Product must be unused, sealed, and in original packaging.',
              'Damaged or wrong item returns are prioritized for quick resolution.',
            ],
          ),
          FooterInfoSection(
            title: 'Refund Timeline',
            points: [
              'Prepaid orders: 5-7 business days to original payment method.',
              'COD orders: refunded via bank transfer after verification.',
              'Return pickup availability depends on pincode serviceability.',
            ],
          ),
        ],
      ),
    ),
    GoRoute(
      path: '/shipping-info',
      builder: (context, state) => const FooterInfoScreen(
        pageTitle: 'Shipping Info',
        subtitle: 'Fast and reliable shipping across India.',
        icon: Icons.local_shipping_outlined,
        sections: [
          FooterInfoSection(
            title: 'Delivery Timelines',
            points: [
              'Standard delivery: 2-5 business days in most cities.',
              'Remote locations may take additional transit time.',
              'You get order confirmation and shipment updates by SMS/email.',
            ],
          ),
          FooterInfoSection(
            title: 'Charges & Coverage',
            points: [
              'Free shipping on orders above INR 499.',
              'A shipping fee applies to orders below the threshold.',
              'We ship PAN India through trusted courier partners.',
            ],
          ),
        ],
      ),
    ),
    GoRoute(
      path: '/faqs',
      builder: (context, state) => const FooterInfoScreen(
        pageTitle: 'FAQs',
        subtitle: 'Answers to the most common questions from customers.',
        icon: Icons.help_outline_rounded,
        sections: [
          FooterInfoSection(
            title: 'Orders',
            points: [
              'You can track orders from the Orders page after login.',
              'Order cancellation is possible before dispatch only.',
              'COD availability depends on your pincode and order value.',
            ],
          ),
          FooterInfoSection(
            title: 'Products & Support',
            points: [
              'All listed products are sourced from authorized channels.',
              'For shade/usage help, contact support before placing order.',
              'For urgent issues, use the Contact Us page in footer.',
            ],
          ),
        ],
      ),
    ),
    GoRoute(
      path: '/contact-us',
      builder: (context, state) => const FooterInfoScreen(
        pageTitle: 'Contact Us',
        subtitle: 'We are here to help you every day.',
        icon: Icons.support_agent_rounded,
        sections: [
          FooterInfoSection(
            title: 'Customer Support',
            points: [
              'Phone/WhatsApp: +91 8770132554',
              'Email: support@jagdishgeneralstore.com',
              'Support Hours: 9:00 AM to 9:00 PM, all days.',
            ],
          ),
          FooterInfoSection(
            title: 'Store Address',
            points: [
              'Jagdish General Store, Chhindwara, Madhya Pradesh.',
              'In-store pickup available for select products.',
              'For bridal and salon partnerships, use dedicated forms in app.',
            ],
          ),
        ],
      ),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin/panel',
      builder: (context, state) => const AdminScreen(),
    ),
    GoRoute(
      path: '/order-details',
      builder: (context, state) {
        final order = state.extra as Order;
        return OrderDetailsScreen(order: order);
      },
    ),
  ],
);
