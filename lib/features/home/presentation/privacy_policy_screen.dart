import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _bg = Color(0xFFFDF8F5);
  static const _textPrimary = Color(0xFF2D1B20);
  static const _textSecondary = Color(0xFF5A3A40);
  static const _accent = Color(0xFFB76E79);
  static const _border = Color(0xFFE8D5D0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            fontFamily: AppTheme.playfairFamily,
            color: _textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner
                _banner(
                  icon: Icons.lock_outline_rounded,
                  title: 'Privacy Policy',
                  subtitle:
                      'Effective Date: 18 March 2026\nLast Updated: 18 March 2026',
                  accentColor: const Color(0xFF6BA3FF),
                ),
                const SizedBox(height: 20),

                _introText(
                  'Jagdish General Store ("JGS", "we", "our", or "us") is committed to protecting your personal information. This Privacy Policy describes what data we collect, how we use it, and your rights regarding that data when you use our mobile application and website.',
                ),
                const SizedBox(height: 16),

                _section('1. Information We Collect', [
                  _item('Phone Number', 'Used for OTP-based authentication and delivery coordination.'),
                  _item('Name & Address', 'Collected during checkout to process and deliver your orders.'),
                  _item('Order History', 'Stored to allow you to track and manage past purchases.'),
                  _item('Device & Usage Data', 'Anonymised analytics data (screen views, crash reports) collected via Firebase to improve app performance.'),
                  _item('Location (optional)', 'Only if you use the "Use My Location" feature for pincode auto-fill. We do not store your GPS coordinates.'),
                ]),
                const SizedBox(height: 16),

                _section('2. How We Use Your Information', [
                  _item('Order Fulfilment', 'To process, dispatch, and deliver your orders.'),
                  _item('Communication', 'Order confirmations, shipping updates, and promotional messages (only with your consent).'),
                  _item('Personalisation', 'Product recommendations based on browsing and purchase history.'),
                  _item('Customer Support', 'To resolve queries, refunds, and complaints.'),
                  _item('Analytics', 'To understand app usage patterns and improve our services.'),
                ]),
                const SizedBox(height: 16),

                _section('3. Data Sharing', [
                  _item('Delivery Partners', 'We share your name, address, and phone number with logistics partners solely for delivery purposes.'),
                  _item('Payment Processors', 'We do not store card details. Payments are processed by PCI-compliant third-party gateways.'),
                  _item('No Sale of Data', 'We never sell, rent, or trade your personal information to any third party.'),
                ]),
                const SizedBox(height: 16),

                _section('4. Data Retention', [
                  _item('Account Data', 'Retained as long as your account is active or as needed to provide services.'),
                  _item('Order Data', 'Retained for 7 years for legal and accounting obligations.'),
                  _item('Deletion Requests', 'You may request deletion of your account and data by contacting us at support@jagdishgeneralstore.com.'),
                ]),
                const SizedBox(height: 16),

                _section('5. Security', [
                  _item('Encryption', 'All data is transmitted over HTTPS with TLS 1.2+.'),
                  _item('Firebase Security', 'Your data is stored on Google Firebase with strict Firestore security rules.'),
                  _item('OTP Authentication', 'We use Firebase Phone Auth to ensure only you can access your account.'),
                ]),
                const SizedBox(height: 16),

                _section('6. Your Rights', [
                  _item('Access', 'Request a copy of the personal data we hold about you.'),
                  _item('Correction', 'Update incorrect or outdated information via the Profile screen.'),
                  _item('Deletion', 'Request erasure of your account and associated data.'),
                  _item('Opt-Out', 'Unsubscribe from promotional communications at any time.'),
                ]),
                const SizedBox(height: 16),

                _section('7. Cookies & Tracking', [
                  _item('Firebase Analytics', 'We use Firebase Analytics for anonymised usage statistics. No personal identifiers are shared with Google for advertising purposes.'),
                  _item('No Third-Party Ads', 'We do not use ad networks, tracking pixels, or retargeting cookies.'),
                ]),
                const SizedBox(height: 16),

                _section('8. Children\'s Privacy', [
                  _item('Age Restriction', 'Our services are not directed at children under 13. We do not knowingly collect data from minors.'),
                ]),
                const SizedBox(height: 16),

                _section('9. Changes to This Policy', [
                  _item('Notification', 'We may update this policy from time to time. Significant changes will be communicated via in-app notification.'),
                  _item('Continued Use', 'By continuing to use our services after changes, you agree to the updated policy.'),
                ]),
                const SizedBox(height: 16),

                _contactCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _banner({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.08),
            accentColor.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accentColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _textSecondary.withValues(alpha: 0.65),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _introText(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border.withValues(alpha: 0.6)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _textSecondary.withValues(alpha: 0.85),
          fontSize: 14,
          height: 1.65,
        ),
      ),
    );
  }

  static Widget _section(String heading, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            width: double.infinity,
            child: Text(
              heading,
              style: TextStyle(
                fontFamily: AppTheme.playfairFamily,
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _item(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: _accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                  TextSpan(
                    text: text,
                    style: TextStyle(
                      color: _textSecondary.withValues(alpha: 0.80),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _contactCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.mail_outline_rounded, color: _accent, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Questions about your privacy?',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Contact us: support@jagdishgeneralstore.com',
                  style: TextStyle(
                    color: _textSecondary.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
