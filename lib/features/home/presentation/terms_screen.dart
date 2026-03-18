import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'Terms & Conditions',
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
                _banner(),
                const SizedBox(height: 20),

                _introText(
                  'Welcome to Jagdish General Store ("JGS"). By accessing or using our mobile application and website, you agree to be bound by these Terms and Conditions. Please read them carefully before placing any order.',
                ),
                const SizedBox(height: 16),

                _section('1. Acceptance of Terms', [
                  _item(
                    'Agreement',
                    'By creating an account or placing an order, you confirm that you have read, understood, and agree to these Terms and Conditions and our Privacy Policy.',
                  ),
                  _item(
                    'Eligibility',
                    'You must be at least 18 years old, or have the consent of a parent or guardian, to use our services.',
                  ),
                  _item(
                    'Modifications',
                    'JGS reserves the right to update these terms at any time. Continued use of the platform constitutes acceptance of the revised terms.',
                  ),
                ]),
                const SizedBox(height: 16),

                _section('2. Products & Pricing', [
                  _item(
                    'Authenticity',
                    'All products listed on JGS are 100% genuine and sourced from authorised distributors or brand principals.',
                  ),
                  _item(
                    'Pricing',
                    'Prices are displayed in Indian Rupees (₹) inclusive of applicable taxes unless stated otherwise. Prices may change without prior notice.',
                  ),
                  _item(
                    'Availability',
                    'Product availability is not guaranteed. If an item becomes unavailable after you place an order, we will notify you and offer a full refund or substitute.',
                  ),
                  _item(
                    'Images',
                    'Product images are for illustrative purposes only. Actual product packaging and colour may vary slightly.',
                  ),
                ]),
                const SizedBox(height: 16),

                _section('3. Orders & Payments', [
                  _item(
                    'Order Confirmation',
                    'An order is confirmed only after successful payment or COD selection and a confirmation notification is sent to you.',
                  ),
                  _item(
                    'Payment Methods',
                    'We accept UPI, credit/debit cards, net banking, and Cash on Delivery (COD) where available.',
                  ),
                  _item(
                    'Cancellations',
                    'Orders can be cancelled before dispatch. Once dispatched, cancellations are not accepted; you may initiate a return after delivery.',
                  ),
                  _item(
                    'Failed Payments',
                    'If a payment fails but your account is debited, the amount will be refunded within 5–7 business days.',
                  ),
                ]),
                const SizedBox(height: 16),

                _section('4. Delivery', [
                  _item(
                    'Shipping Timeline',
                    'Standard delivery: 2–5 business days across India. Delivery times are estimates and not guaranteed.',
                  ),
                  _item(
                    'Free Delivery',
                    'Free delivery applies to orders above ₹499. Orders below this threshold are subject to a shipping fee displayed at checkout.',
                  ),
                  _item(
                    'Delays',
                    'JGS is not liable for delivery delays caused by courier partners, natural disasters, or government restrictions.',
                  ),
                  _item(
                    'Undeliverable Orders',
                    'If an order is returned due to an incorrect address or failed delivery attempts, re-delivery charges may apply.',
                  ),
                ]),
                const SizedBox(height: 16),

                _section('5. Returns & Refunds', [
                  _item(
                    'Return Window',
                    'Returns are accepted within 7 days of delivery for defective, damaged, or incorrect products.',
                  ),
                  _item(
                    'Non-Returnable Items',
                    'Opened cosmetics, intimate care products, and items marked as non-returnable on the product page cannot be returned.',
                  ),
                  _item(
                    'Refund Processing',
                    'Approved refunds are credited to the original payment method within 5–7 business days after we receive the returned item.',
                  ),
                  _item(
                    'COD Orders',
                    'Refunds for COD orders are processed via bank transfer. Please provide your bank details when raising a return request.',
                  ),
                ]),
                const SizedBox(height: 16),

                _section('6. Coupons & Promotions', [
                  _item(
                    'Single Use',
                    'Coupon codes are typically single-use per account and cannot be combined with other offers unless stated.',
                  ),
                  _item(
                    'Validity',
                    'Coupons are subject to validity dates and minimum order values as displayed.',
                  ),
                  _item(
                    'Misuse',
                    'JGS reserves the right to cancel orders or suspend accounts where coupon misuse or fraud is suspected.',
                  ),
                ]),
                const SizedBox(height: 16),

                _section('7. User Account', [
                  _item(
                    'Account Security',
                    'You are responsible for maintaining the confidentiality of your OTP and account access. Do not share your OTP with anyone.',
                  ),
                  _item(
                    'Accurate Information',
                    'You agree to provide accurate, current, and complete information during registration and checkout.',
                  ),
                  _item(
                    'Suspension',
                    'JGS may suspend or terminate accounts that violate these terms, engage in fraudulent activity, or misuse our platform.',
                  ),
                ]),
                const SizedBox(height: 16),

                _section('8. Intellectual Property', [
                  _item(
                    'Ownership',
                    'All content on the JGS platform — including logos, product descriptions, images, and software — is the property of Jagdish General Store or its licensors.',
                  ),
                  _item(
                    'Prohibited Use',
                    'You may not copy, reproduce, distribute, or create derivative works from any JGS content without express written permission.',
                  ),
                ]),
                const SizedBox(height: 16),

                _section('9. Limitation of Liability', [
                  _item(
                    'No Warranty',
                    'JGS provides the platform "as is" and does not warrant uninterrupted, error-free access.',
                  ),
                  _item(
                    'Indirect Damages',
                    'JGS shall not be liable for any indirect, incidental, or consequential loss arising from use of the platform.',
                  ),
                  _item(
                    'Maximum Liability',
                    'In any event, JGS\'s maximum liability is limited to the value of the specific order in dispute.',
                  ),
                ]),
                const SizedBox(height: 16),

                _section('10. Governing Law & Disputes', [
                  _item(
                    'Jurisdiction',
                    'These terms are governed by the laws of India. Any disputes shall be subject to the exclusive jurisdiction of courts in Chhindwara, Madhya Pradesh.',
                  ),
                  _item(
                    'Resolution',
                    'We encourage you to contact our support team before initiating any legal proceedings. Most disputes can be resolved amicably.',
                  ),
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

  static Widget _banner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFB76E79).withValues(alpha: 0.08),
            const Color(0xFFB76E79).withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFB76E79).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.gavel_rounded, color: _accent, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Effective Date: 18 March 2026\nLast Updated: 18 March 2026',
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
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
            child: Column(children: items),
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
            margin: const EdgeInsets.only(top: 5),
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
                  'Questions about these Terms?',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Email us: support@jagdishgeneralstore.com',
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
