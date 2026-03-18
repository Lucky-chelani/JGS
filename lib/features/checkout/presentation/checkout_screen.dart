import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/services/email_service.dart';
import '../../../shared/services/location_service.dart';
import '../../orders/providers/orders_provider.dart';
import '../../admin/providers/admin_provider.dart';
import '../../../shared/models/order_model.dart';
import '../../../shared/models/coupon_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _couponController = TextEditingController();

  String? _couponError;
  bool _isLoading = false;
  bool _isLocating = false;
  String? _locationError;

  static const _bg = Color(0xFFFDF8F5);
  static const _textPrimary = Color(0xFF2D1B20);
  static const _textSecondary = Color(0xFF5A3A40);
  static const _border = Color(0xFFE8D5D0);
  static const _accent = Color(0xFFB76E79);
  static const _accentLight = Color(0xFFE8B4B8);

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isLoggedIn) {
      final profile = auth.profile;
      final phone = auth.user?.phoneNumber ?? '';
      if (profile.name.isNotEmpty) _nameController.text = profile.name;
      if (profile.email.isNotEmpty) _emailController.text = profile.email;
      if (phone.length > 3) {
        _phoneController.text = phone.replaceFirst('+91', '');
      }
      if (profile.pincode.isNotEmpty) _pincodeController.text = profile.pincode;
      if (profile.city.isNotEmpty) _cityController.text = profile.city;
      if (profile.address.isNotEmpty) _addressController.text = profile.address;
    }
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });
    try {
      final result = await LocationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        if (result.pincode.isNotEmpty) _pincodeController.text = result.pincode;
        if (result.city.isNotEmpty) _cityController.text = result.city;
        if (result.state.isNotEmpty) _stateController.text = result.state;
        _isLocating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.city.isNotEmpty
                      ? 'Location detected: ${result.city}'
                      : 'Location detected! Fields auto-filled.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = e.toString();
        _isLocating = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isLoading = false);

    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    
    // Sync membership status
    cart.setPremiumMember(auth.profile.isMember);

    // Get order ID
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    final profile = auth.profile.email.isEmpty
        ? UserProfile(
            uid: auth.user!.uid,
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            address: _addressController.text.trim(),
            pincode: _pincodeController.text.trim(),
            city: _cityController.text.trim(),
          )
        : auth.profile;

    // Update profile if email was missing
    if (auth.profile.email.isEmpty) {
      await auth.saveProfile(profile);
    }

    final now = DateTime.now();
    final newOrder = Order(
      id: orderId,
      userId: auth.user!.uid,
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      pincode: _pincodeController.text.trim(),
      city: _cityController.text.trim(),
      total: cart.finalAmount,
      date: '${now.day} ${_getMonthMap()[now.month]} ${now.year}',
      status: 'Pending',
      items: cart.items.values
          .map((i) => OrderLineItem(
                name: i.title,
                qty: i.quantity,
                price: i.price,
              ))
          .toList(),
    );

    final success = await ordersProvider.saveOrder(newOrder);

    if (!success) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ordersProvider.error ?? 'Failed to place order.')),
        );
      }
      return;
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    // Trigger email (Background)
    EmailService.sendOrderConfirmation(
      profile: profile, 
      items: cart.items.values.toList(), 
      total: cart.finalAmount, 
      orderId: orderId,
    );

    cart.clear();

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF4CAF50),
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Order Placed!',
                style: TextStyle(
                  fontFamily: AppTheme.playfairFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your order has been placed successfully via Cash on Delivery. You\'ll receive an SMS confirmation shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSecondary.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.go('/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final cart = Provider.of<CartProvider>(context, listen: false);
    final admin = Provider.of<AdminProvider>(context, listen: false);

    final coupon = admin.coupons.firstWhere(
      (c) => c.code.toUpperCase() == code && c.isActive,
      orElse: () => const Coupon(id: '', code: '', discountAmount: 0),
    );

    if (coupon.id.isNotEmpty) {
      if (!coupon.isValid(cart.totalAmount)) {
        setState(() {
          _couponError = cart.totalAmount < coupon.minOrderAmount
              ? 'Min order for this coupon is ₹${coupon.minOrderAmount.toStringAsFixed(0)}'
              : 'Coupon is expired or inactive';
        });
        return;
      }
      cart.applyCoupon(coupon);
      _couponController.clear();
      setState(() {
        _couponError = null;
      });
    } else {
      setState(() {
        _couponError = 'Invalid or inactive coupon';
      });
    }
  }

  void _removeCoupon() {
    Provider.of<CartProvider>(context, listen: false).removeCoupon();
    setState(() {
      _couponError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final top = MediaQuery.of(context).padding.top;

    if (cart.items.isEmpty && !_isLoading) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 56,
                color: _accent.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Your cart is empty',
                style: TextStyle(
                  color: _textSecondary.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // ── App bar ──
          Container(
            padding: EdgeInsets.fromLTRB(20, top + 12, 20, 12),
            decoration: BoxDecoration(
              color: _bg,
              border: Border(
                bottom: BorderSide(color: _border.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _textSecondary.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border.withValues(alpha: 0.5)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: _textPrimary,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Checkout',
                    style: TextStyle(
                      fontFamily: AppTheme.playfairFamily,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Delivery Details ──
                          _buildSectionTitle('Delivery Details'),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: _cardDecoration(),
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  icon: Icons.person_outline_rounded,
                                  validator: (v) =>
                                      v!.isEmpty ? 'Enter your name' : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Enter email';
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _phoneController,
                                  label: 'Phone Number',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (v) => v!.length < 10
                                      ? 'Enter valid 10-digit number'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _addressController,
                                  label: 'Complete Address',
                                  icon: Icons.location_on_outlined,
                                  maxLines: 3,
                                  validator: (v) =>
                                      v!.isEmpty ? 'Enter address' : null,
                                ),
                                const SizedBox(height: 16),

                                // ── Use Location button ──
                                _buildLocationButton(),
                                if (_locationError != null) ...[  
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B6B)
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFFF6B6B)
                                            .withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline,
                                            color: Color(0xFFFF6B6B), size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _locationError!,
                                            style: const TextStyle(
                                              color: Color(0xFFFF6B6B),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),

                                // ── Pincode + City ──
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _pincodeController,
                                        label: 'Pincode',
                                        icon: Icons.pin_drop_outlined,
                                        keyboardType: TextInputType.number,
                                        maxLength: 6,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        validator: (v) => v!.length != 6
                                            ? 'Enter 6-digit pincode'
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _cityController,
                                        label: 'City',
                                        icon: Icons.location_city_outlined,
                                        validator: (v) =>
                                            v!.isEmpty ? 'Enter city' : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // ── State ──
                                _buildTextField(
                                  controller: _stateController,
                                  label: 'State',
                                  icon: Icons.map_outlined,
                                  validator: (v) =>
                                      v!.isEmpty ? 'Enter state' : null,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ── Payment Method ──
                          _buildSectionTitle('Payment Method'),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _accent.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _accent.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.payments_outlined,
                                    color: _accent,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cash on Delivery',
                                        style: TextStyle(
                                          color: _textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Pay when your order arrives',
                                        style: TextStyle(
                                          color: _textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _accent,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ── Coupon section ──
                          _buildSectionTitle('Apply Coupon'),
                          const SizedBox(height: 16),
                          if (cart.appliedCoupon != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 18,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF4CAF50).withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.local_offer_rounded,
                                    color: Color(0xFF4CAF50),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cart.appliedCoupon!.code,
                                          style: const TextStyle(
                                            color: Color(0xFF4CAF50),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '₹${cart.couponDiscountAmount.toStringAsFixed(0)} off applied',
                                          style: TextStyle(
                                            color: const Color(
                                              0xFF4CAF50,
                                            ).withValues(alpha: 0.7),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _removeCoupon,
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Color(0xFF4CAF50),
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _couponError != null
                                      ? const Color(0xFFFF6B6B)
                                      : _border.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.local_offer_outlined,
                                    size: 20,
                                    color: _textSecondary.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _couponController,
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      style: const TextStyle(
                                        color: _textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Enter coupon code',
                                        hintStyle: TextStyle(
                                          color: _textSecondary.withValues(
                                            alpha: 0.35,
                                          ),
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                      ),
                                      onChanged: (_) {
                                        if (_couponError != null) {
                                          setState(() => _couponError = null);
                                        }
                                      },
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _applyCoupon,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _accent,
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(15),
                                          bottomRight: Radius.circular(15),
                                        ),
                                      ),
                                      child: const Text(
                                        'Apply',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_couponError != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _couponError!,
                              style: const TextStyle(
                                color: Color(0xFFFF6B6B),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],

                          const SizedBox(height: 28),

                          // ── Order Summary ──
                          _buildSectionTitle('Order Summary'),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: _cardDecoration(),
                            child: Column(
                              children: [
                                ...cart.items.entries.map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: _bg,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: _border.withValues(
                                                alpha: 0.4,
                                              ),
                                            ),
                                          ),
                                          child: entry.value.imageUrl.isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(11),
                                                  child: Image.network(
                                                    entry.value.imageUrl,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder:
                                                        (
                                                          context,
                                                          child,
                                                          progress,
                                                        ) {
                                                          if (progress == null)
                                                            return child;
                                                          return const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color: Color(
                                                                    0xFFB76E79,
                                                                  ),
                                                                ),
                                                          );
                                                        },
                                                    errorBuilder:
                                                        (_, __, ___) => Icon(
                                                          Icons
                                                              .shopping_bag_outlined,
                                                          size: 20,
                                                          color: _accent
                                                              .withValues(
                                                                alpha: 0.4,
                                                              ),
                                                        ),
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.shopping_bag_outlined,
                                                  size: 20,
                                                  color: _accent.withValues(
                                                    alpha: 0.4,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.value.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: _textPrimary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Qty: ${entry.value.quantity}',
                                                style: TextStyle(
                                                  color: _textSecondary
                                                      .withValues(alpha: 0.6),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '₹${(entry.value.price * entry.value.quantity).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: _textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: _border.withValues(alpha: 0.5),
                                  height: 1,
                                ),
                                const SizedBox(height: 14),
                                _buildPriceRow(
                                  'Subtotal',
                                  '₹${cart.totalAmount.toStringAsFixed(2)}',
                                ),
                                const SizedBox(height: 10),
                                _buildPriceRow(
                                  'Delivery',
                                  'FREE',
                                  valueColor: const Color(0xFF4CAF50),
                                ),
                                if (cart.memberDiscountAmount > 0) ...[
                                  const SizedBox(height: 10),
                                  _buildPriceRow(
                                    'Member Discount (10%)',
                                    '-₹${cart.memberDiscountAmount.toStringAsFixed(2)}',
                                    valueColor: const Color(0xFF4CAF50),
                                  ),
                                ],
                                if (cart.couponDiscountAmount > 0) ...[
                                  const SizedBox(height: 10),
                                  _buildPriceRow(
                                    'Coupon (${cart.appliedCoupon?.code})',
                                    '-₹${cart.couponDiscountAmount.toStringAsFixed(2)}',
                                    valueColor: const Color(0xFF4CAF50),
                                  ),
                                ],
                                const SizedBox(height: 14),
                                Divider(
                                  color: _border.withValues(alpha: 0.5),
                                  height: 1,
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                        fontFamily: AppTheme.playfairFamily,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: _textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '₹${cart.finalAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontFamily: AppTheme.playfairFamily,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: _accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: _border.withValues(alpha: 0.5)),
              ),
              boxShadow: [
                BoxShadow(
                  color: _accentLight.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _accent.withValues(alpha: 0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Place Order  •  ₹${cart.finalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton() {
    return GestureDetector(
      onTap: _isLocating ? null : _fetchCurrentLocation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _accent.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLocating)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _accent,
                ),
              )
            else
              const Icon(
                Icons.my_location_rounded,
                color: _accent,
                size: 18,
              ),
            const SizedBox(width: 10),
            Text(
              _isLocating
                  ? 'Detecting your location…'
                  : 'Use my current location',
              style: const TextStyle(
                color: _accent,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!_isLocating) ...[
              const SizedBox(width: 6),
              Text(
                '(auto-fill pincode, city & state)',
                style: TextStyle(
                  color: _accent.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {

    return Text(
      title,
      style: TextStyle(
        fontFamily: AppTheme.playfairFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _border.withValues(alpha: 0.5)),
      boxShadow: [
        BoxShadow(
          color: _accentLight.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        color: _textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        labelStyle: TextStyle(
          color: _textSecondary.withValues(alpha: 0.5),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          size: 20,
          color: _textSecondary.withValues(alpha: 0.4),
        ),
        filled: true,
        fillColor: _bg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _border.withValues(alpha: 0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _border.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _textSecondary.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? _textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Map<int, String> _getMonthMap() {
    return {
      1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr',
      5: 'May', 6: 'Jun', 7: 'Jul', 8: 'Aug',
      9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec',
    };
  }
}
