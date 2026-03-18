import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/cart/providers/cart_provider.dart';

class EmailService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // JGS Theme Colors (Website Brand)
  static const String _primaryColor = '#B76E79';
  static const String _primaryDark = '#8B4A52';
  static const String _accentColor = '#E8D5D0';
  static const String _bgColor = '#FDF8F5';
  static const String _surfaceColor = '#FFFFFF';
  static const String _textPrimary = '#2D1B20';
  static const String _textSecondary = '#5A3A40';
  static const String _borderLight = '#E8D5D0';
  static const String _contactPhone = '8770132554';

  static String _getHtmlTemplate({
    required String title,
    required String preheader,
    required String content,
  }) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700;800&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
  <title>${title}</title>
  <style>
    * { margin: 0; padding: 0; }
    body {
      background-color: ${_bgColor};
      font-family: 'DM Sans', sans-serif;
      color: ${_textPrimary};
      -webkit-font-smoothing: antialiased;
    }
    .wrapper {
      width: 100%;
      background-color: ${_bgColor};
      padding: 40px 20px;
    }
    .main {
      background-color: ${_surfaceColor};
      margin: 0 auto;
      width: 100%;
      max-width: 600px;
      border-radius: 20px;
      overflow: hidden;
      box-shadow: 0 8px 32px rgba(183, 110, 121, 0.12);
    }
    .preheader {
      display: none;
      visibility: hidden;
      font-size: 1px;
      opacity: 0;
    }
    .header {
      background: linear-gradient(135deg, #FDF8F5 0%, #FCF3F0 100%);
      padding: 40px;
      text-align: center;
      border-bottom: 2px solid ${_accentColor};
    }
    .logo {
      font-family: 'Playfair Display', serif;
      font-size: 36px;
      font-weight: 800;
      color: ${_primaryColor};
      margin-bottom: 8px;
      letter-spacing: -0.5px;
    }
    .tagline {
      font-size: 12px;
      color: ${_textSecondary};
      font-weight: 600;
      letter-spacing: 1.5px;
      text-transform: uppercase;
    }
    .content {
      padding: 40px;
    }
    h1 {
      font-family: 'Playfair Display', serif;
      font-size: 28px;
      font-weight: 700;
      color: ${_textPrimary};
      margin-bottom: 16px;
      line-height: 1.3;
    }
    h2 {
      font-family: 'Playfair Display', serif;
      font-size: 20px;
      font-weight: 700;
      color: ${_primaryColor};
      margin: 28px 0 16px 0;
    }
    p {
      font-size: 15px;
      line-height: 1.7;
      color: ${_textSecondary};
      margin-bottom: 16px;
    }
    .button {
      display: inline-block;
      padding: 14px 32px;
      background-color: ${_primaryColor};
      color: #ffffff;
      text-decoration: none;
      font-weight: 600;
      font-size: 15px;
      border-radius: 14px;
      transition: all 0.3s;
      text-align: center;
      margin: 16px 0;
    }
    .button:hover {
      background-color: ${_primaryDark};
      transform: translateY(-2px);
    }
    .footer {
      background-color: ${_bgColor};
      padding: 32px 40px;
      text-align: center;
      border-top: 2px solid ${_accentColor};
    }
    .footer-brand {
      font-family: 'Playfair Display', serif;
      font-size: 20px;
      font-weight: 700;
      color: ${_primaryColor};
      margin-bottom: 12px;
    }
    .footer-contact {
      font-size: 13px;
      color: ${_textSecondary};
      margin: 8px 0;
    }
    .footer-contact a {
      color: ${_primaryColor};
      text-decoration: none;
      font-weight: 600;
    }
    .footer-links {
      margin: 16px 0;
      font-size: 12px;
    }
    .footer-links a {
      color: ${_primaryColor};
      text-decoration: none;
      margin: 0 12px;
      font-weight: 500;
    }
    .footer-copyright {
      font-size: 11px;
      color: #999999;
      margin-top: 16px;
      border-top: 1px solid ${_accentColor};
      padding-top: 16px;
    }
    .order-table {
      width: 100%;
      border-collapse: collapse;
      margin: 20px 0;
    }
    .order-table th {
      text-align: left;
      padding: 12px;
      border-bottom: 2px solid ${_accentColor};
      color: ${_textPrimary};
      font-weight: 600;
      font-size: 13px;
      background-color: ${_bgColor};
    }
    .order-table td {
      padding: 14px 12px;
      border-bottom: 1px solid ${_borderLight};
      color: ${_textSecondary};
      font-size: 14px;
    }
    .item-name {
      color: ${_textPrimary};
      font-weight: 600;
      margin-bottom: 4px;
    }
    .item-qty {
      font-size: 12px;
      color: ${_textSecondary};
    }
    .price {
      text-align: right;
      font-weight: 700;
      color: ${_primaryColor};
    }
    .summary-box {
      background: linear-gradient(135deg, #FDF8F5 0%, #FCF3F0 100%);
      border-radius: 14px;
      padding: 24px;
      margin: 24px 0;
      border: 1px solid ${_accentColor};
    }
    .summary-row {
      display: flex;
      justify-content: space-between;
      margin-bottom: 12px;
      font-size: 14px;
      color: ${_textSecondary};
    }
    .summary-row.total {
      margin-top: 14px;
      padding-top: 14px;
      border-top: 2px solid ${_accentColor};
      font-size: 16px;
      font-weight: 700;
      color: ${_primaryColor};
    }
    .divider {
      height: 1px;
      background-color: ${_accentColor};
      margin: 20px 0;
    }
    @media screen and (max-width: 600px) {
      .main { border-radius: 0; }
      .wrapper { padding: 0; }
      .content { padding: 24px; }
      .header { padding: 24px; }
      .footer { padding: 20px 24px; }
      h1 { font-size: 24px; }
      h2 { font-size: 18px; }
    }
  </style>
</head>
<body>
  <span class="preheader">${preheader}</span>
  <div class="wrapper">
    <table class="main" width="100%" cellpadding="0" cellspacing="0" role="presentation">
      <tr>
        <td class="header">
          <div class="logo">JGS</div>
          <div class="tagline">Beauty & Care</div>
        </td>
      </tr>
      <tr>
        <td class="content">
          ${content}
        </td>
      </tr>
      <tr>
        <td class="footer">
          <div class="footer-brand">JGS Store</div>
          <div class="footer-contact">
            <a href="tel:${_contactPhone}">📞 ${_contactPhone}</a>
          </div>
          <div class="footer-contact">
            Premium Beauty & Wellness for Every Skin
          </div>
          <div class="footer-links">
            <a href="#">Help Center</a>
            <a href="#">Track Order</a>
            <a href="#">Returns</a>
          </div>
          <div class="footer-copyright">
            © ${DateTime.now().year} JGS Store. All rights reserved.<br>
            Beauty & Wellness Delivered to Your Door
          </div>
        </td>
      </tr>
    </table>
  </div>
</body>
</html>
''';
  }

  static Future<void> sendOrderConfirmation({
    required UserProfile profile,
    required List<CartItem> items,
    required double total,
    required String orderId,
  }) async {
    debugPrint('EmailService: Attempting to send order confirmation to ${profile.email} for order #$orderId');
    if (profile.email.isEmpty) {
      debugPrint('EmailService: Profile email is empty, skipping.');
      return;
    }

    final subtotal = items.fold<double>(0, (sum, item) => sum + (item.price * item.quantity));
    final discount = subtotal > total ? subtotal - total : 0.0;

    String itemsHtml = items.map((item) => '''
      <tr>
        <td>
          <div class="item-name">${item.title}</div>
          <div class="item-qty">Qty: ${item.quantity} ${item.variantLabel != null ? '• ${item.variantLabel}' : ''}</div>
        </td>
        <td class="price">₹${(item.price * item.quantity).toStringAsFixed(2)}</td>
      </tr>
    ''').join('');

    String discountRow = discount > 0 ? '''
          <tr>
            <td style="padding-bottom: 12px; color: ${_textSecondary};">Discount</td>
            <td style="padding-bottom: 12px; text-align: right; color: #00A699; font-weight: 500;">-₹${discount.toStringAsFixed(2)}</td>
          </tr>
    ''' : '';

    String summaryHtml = '''
      <div class="summary-box">
        <table width="100%" cellpadding="0" cellspacing="0" role="presentation">
          <tr>
            <td style="padding-bottom: 12px; color: ${_textSecondary};">Subtotal</td>
            <td style="padding-bottom: 12px; text-align: right; color: ${_textPrimary}; font-weight: 500;">₹${subtotal.toStringAsFixed(2)}</td>
          </tr>
          ${discountRow}
          <tr>
            <td style="padding-bottom: 12px; color: ${_textSecondary};">Shipping</td>
            <td style="padding-bottom: 12px; text-align: right; color: #00A699; font-weight: 500;">FREE</td>
          </tr>
          <tr>
            <td style="padding-top: 16px; border-top: 1px solid ${_borderLight}; font-size: 18px; font-weight: 700; color: ${_textPrimary};">Total</td>
            <td style="padding-top: 16px; border-top: 1px solid ${_borderLight}; text-align: right; font-size: 18px; font-weight: 700; color: ${_primaryColor};">₹${total.toStringAsFixed(2)}</td>
          </tr>
        </table>
      </div>
    ''';

    final html = _getHtmlTemplate(
      title: 'Order Confirmed - JGS Store',
      preheader: 'Your order #$orderId has been placed successfully.',
      content: '''
        <h1>Thank you for your order, ${profile.name}!</h1>
        <p>We've received your order <strong>#$orderId</strong> and it is now being processed.</p>
        
        <h2>Order Summary</h2>
        <table class="order-table" role="presentation">
          <thead>
            <tr>
              <th>Item</th>
              <th style="text-align: right;">Price</th>
            </tr>
          </thead>
          <tbody>
            ${itemsHtml}
          </tbody>
        </table>
        
        ${summaryHtml}
        
        <div style="text-align: center; margin-top: 40px; margin-bottom: 16px;">
          <a href="#" class="button" style="color: #ffffff;">Track Your Order</a>
        </div>
      ''',
    );

    try {
      final docRef = await _firestore.collection('mail').add({
        'to': [profile.email],
        'message': {
          'subject': 'Order Confirmed! - JGS Store (#$orderId)',
          'html': html,
        },
      });
      debugPrint('EmailService: Order confirmation added to mail collection: ${docRef.id}');
    } catch (e) {
      debugPrint('Failed to send order confirmation email: $e');
    }
  }

  static Future<void> sendWelcomeEmail(UserProfile profile) async {
    debugPrint('EmailService: Attempting to send welcome email to ${profile.email}');
    if (profile.email.isEmpty) {
      debugPrint('EmailService: Profile email is empty, skipping.');
      return;
    }

    final html = _getHtmlTemplate(
      title: 'Welcome to JGS Store!',
      preheader: "We're thrilled to have you onboard. Let's start shopping!",
      content: '''
        <h1>Welcome to JGS, ${profile.name}! 🎉</h1>
        <p>We're absolutely thrilled to have you join our community. Your account has been successfully created and you're all set to start exploring.</p>
        
        <div style="background-color: ${_bgColor}; border-radius: 12px; padding: 24px; margin: 32px 0;">
          <h3 style="margin-top: 0; color: ${_textPrimary}; font-size: 18px;">Why you'll love shopping with us:</h3>
          <ul style="color: ${_textSecondary}; line-height: 1.8; margin-bottom: 0; padding-left: 20px;">
            <li>Curated premium products</li>
            <li>Fast and free shipping on all orders</li>
            <li>Exclusive member-only discounts</li>
            <li>Hassle-free 30-day returns</li>
          </ul>
        </div>
        
        <p><strong>Pro Tip:</strong> Click the button below to browse our latest collection and discover your new favorites.</p>
        
        <div style="text-align: center; margin-top: 40px; margin-bottom: 16px;">
          <a href="#" class="button" style="color: #ffffff;">Start Shopping Now</a>
        </div>
      ''',
    );

    try {
      final docRef = await _firestore.collection('mail').add({
        'to': [profile.email],
        'message': {
          'subject': 'Welcome to JGS Store! 🎉',
          'html': html,
        },
      });
      debugPrint('EmailService: Welcome email added to mail collection: ${docRef.id}');
    } catch (e) {
      debugPrint('Failed to send welcome email: $e');
    }
  }

  static Future<void> sendAbandonedCartEmail({
    required UserProfile profile,
    required List<CartItem> items,
  }) async {
    if (profile.email.isEmpty || items.isEmpty) return;

    final firstFewItems = items.take(3).toList();
    final hasMore = items.length > 3;

    String itemsHtml = firstFewItems.map((item) => '''
      <table width="100%" cellpadding="0" cellspacing="0" role="presentation" style="margin-bottom: 16px; border: 1px solid ${_borderLight}; border-radius: 12px; padding: 12px;">
        <tr>
          <td width="80" style="padding-right: 16px;">
            <img src="${item.imageUrl}" alt="${item.title}" style="width: 80px; height: 80px; border-radius: 8px; object-fit: cover; background-color: ${_bgColor}; display: block;">
          </td>
          <td valign="middle">
            <h4 style="margin: 0 0 4px 0; font-size: 16px; color: ${_textPrimary}; font-weight: 600;">${item.title}</h4>
            <p style="margin: 0 0 4px 0; font-size: 14px; color: ${_textSecondary};">Qty: ${item.quantity}</p>
            <p style="margin: 0; font-size: 15px; color: ${_primaryColor}; font-weight: 600;">₹${(item.price * item.quantity).toStringAsFixed(2)}</p>
          </td>
        </tr>
      </table>
    ''').join('');

    if (hasMore) {
      itemsHtml += '''
        <p style="text-align: center; color: ${_textSecondary}; font-size: 14px; margin-top: 16px;">
          <em>+ ${items.length - 3} more item${items.length - 3 > 1 ? 's' : ''} in your cart</em>
        </p>
      ''';
    }

    final html = _getHtmlTemplate(
      title: "You left something behind!",
      preheader: "Your cart is waiting for you. Come back and complete your purchase.",
      content: '''
        <h1>Did you forget something, ${profile.name}?</h1>
        <p>We noticed you left some great items in your cart. They're waiting for you, but they might sell out soon! Come back and complete your purchase before they're gone.</p>
        
        <h2 style="margin-top: 32px;">Items in your cart:</h2>
        ${itemsHtml}
        
        <p style="text-align: center; margin-top: 32px;">Ready to make them yours?</p>
        
        <div style="text-align: center; margin-top: 24px; margin-bottom: 16px;">
          <a href="#" class="button" style="color: #ffffff;">Return to Checkout</a>
        </div>
      ''',
    );

    try {
      await _firestore.collection('mail').add({
        'to': [profile.email],
        'message': {
          'subject': "You left something behind! 🛒",
          'html': html,
        },
      });
    } catch (e) {
      debugPrint('Failed to send abandoned cart email: $e');
    }
  }
}
