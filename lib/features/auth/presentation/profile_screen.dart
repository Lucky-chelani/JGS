import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../../shared/services/email_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  bool _editing = false;
  bool _saving = false;
  bool _fetchingCity = false;
  String _lastProfileSnapshot = '';

  static const _bg = Color(0xFFFDF8F5);
  static const _textPrimary = Color(0xFF2D1B20);
  static const _textSecondary = Color(0xFF5A3A40);
  static const _border = Color(0xFFE8D5D0);
  static const _accent = Color(0xFFB76E79);
  static const _accentLight = Color(0xFFE8B4B8);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    _populateFields(auth.profile);
    // If profile is incomplete, start in edit mode
    if (!auth.isProfileComplete) {
      _editing = true;
    }
    _pincodeController.addListener(_onPincodeChanged);
  }

  void _populateFields(UserProfile profile) {
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _pincodeController.text = profile.pincode;
    _cityController.text = profile.city;
    _addressController.text = profile.address;
  }

  @override
  void dispose() {
    _pincodeController.removeListener(_onPincodeChanged);
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _pincodeController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onPincodeChanged() {
    final pin = _pincodeController.text.trim();
    if (pin.length == 6) {
      _fetchCityFromPincode(pin);
    }
  }

  Future<void> _fetchCityFromPincode(String pincode) async {
    setState(() => _fetchingCity = true);
    try {
      final uri = Uri.parse('https://api.postalpincode.in/pincode/$pincode');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        if (data.isNotEmpty && data[0]['Status'] == 'Success') {
          final postOffices = data[0]['PostOffice'] as List;
          if (postOffices.isNotEmpty) {
            final district = postOffices[0]['District'] as String? ?? '';
            final state = postOffices[0]['State'] as String? ?? '';
            if (district.isNotEmpty) {
              _cityController.text = state.isNotEmpty
                  ? '$district, $state'
                  : district;
            }
          }
        }
      }
    } catch (_) {
      // Silently fail — user can type city manually
    }
    if (mounted) setState(() => _fetchingCity = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final profile = UserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      pincode: _pincodeController.text.trim(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
    );

    final success = await auth.saveProfile(profile);

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile saved successfully!'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Failed to save profile'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profileSnapshot =
        '${auth.profile.name}|${auth.profile.email}|${auth.profile.pincode}|${auth.profile.city}|${auth.profile.address}';
    if (profileSnapshot != _lastProfileSnapshot) {
      _lastProfileSnapshot = profileSnapshot;
      _populateFields(auth.profile);
    }
    final phone = auth.user?.phoneNumber ?? '';
    final screenW = MediaQuery.sizeOf(context).width;
    final contentW = screenW > 600 ? 500.0 : screenW;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(
          'My Profile',
          style: TextStyle(
            fontFamily: AppTheme.playfairFamily,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_editing && auth.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: _accent, size: 22),
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: auth.profileLoading
            ? const Center(child: CircularProgressIndicator(color: _accent))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Center(
                  child: SizedBox(
                    width: contentW,
                    child: Column(
                      children: [
                        // ── Avatar & Phone ──
                        const SizedBox(height: 8),
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: _accentLight.withValues(alpha: 0.3),
                          child: Text(
                            auth.profile.name.isNotEmpty
                                ? auth.profile.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontFamily: AppTheme.playfairFamily,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: _accent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          phone,
                          style: TextStyle(
                            fontFamily: AppTheme.dmSansFamily,
                            fontSize: 15,
                            color: _textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Profile Card ──
                        if (!_editing) _buildViewCard(auth.profile),
                        if (_editing) _buildEditForm(),

                        const SizedBox(height: 24),

                        // ── Logout ──
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final cart = context.read<CartProvider>();
                              if (cart.items.isNotEmpty) {
                                EmailService.sendAbandonedCartEmail(
                                  profile: auth.profile,
                                  items: cart.items.values.toList(),
                                );
                              }
                              auth.signOut();
                              context.go('/');
                            },
                            icon: const Icon(Icons.logout_rounded, size: 20),
                            label: Text(
                              'Logout',
                              style: TextStyle(
                                fontFamily: AppTheme.dmSansFamily,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _accent,
                              side: const BorderSide(color: _accent),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildViewCard(UserProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: _accentLight.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMembershipStatus(context, profile),
          if (profile.name.isEmpty && profile.pincode.isEmpty) ...[
            Icon(
              Icons.info_outline_rounded,
              color: _textSecondary.withValues(alpha: 0.4),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Complete your profile to continue',
              style: TextStyle(
                fontFamily: AppTheme.dmSansFamily,
                fontSize: 14,
                color: _textSecondary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() => _editing = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Add Details',
                style: TextStyle(
                  fontFamily: AppTheme.dmSansFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else ...[
            _infoRow(Icons.person_outline_rounded, 'Name', profile.name),
            _divider(),
            _infoRow(Icons.email_outlined, 'Email', profile.email),
            _divider(),
            _infoRow(Icons.pin_drop_outlined, 'Pincode', profile.pincode),
            if (profile.city.isNotEmpty) ...[
              _divider(),
              _infoRow(Icons.location_city_rounded, 'City', profile.city),
            ],
            if (profile.address.isNotEmpty) ...[
              _divider(),
              _infoRow(Icons.home_outlined, 'Address', profile.address),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMembershipStatus(BuildContext context, UserProfile profile) {
    if (profile.isMember) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8B4B8), Color(0xFFB76E79)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JGS Premium Member',
                    style: TextStyle(
                      fontFamily: AppTheme.playfairFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Enjoying 10% off all orders',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard_rounded, color: _accent, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Unlock 10% Off Every Order',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Become a JGS Premium Member today and save on all your favorite products.',
            style: TextStyle(
              fontSize: 13,
              color: _textSecondary.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: auth.loading
                  ? null
                  : () async {
                      final success = await auth.joinMembership();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Welcome to JGS Premium!'),
                            backgroundColor: Color(0xFF4CAF50),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: auth.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Join Membership',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: _accent, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTheme.dmSansFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _textSecondary.withValues(alpha: 0.5),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '—',
                  style: TextStyle(
                    fontFamily: AppTheme.dmSansFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(color: _border.withValues(alpha: 0.4), height: 1);

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: _accentLight.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Details',
              style: TextStyle(
                fontFamily: AppTheme.playfairFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Fill in your details to continue shopping',
              style: TextStyle(
                fontFamily: AppTheme.dmSansFamily,
                fontSize: 13,
                color: _textSecondary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            _buildField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline_rounded,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Please enter your name'
                  : null,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your email';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _pincodeController,
              label: 'Pincode',
              icon: Icons.pin_drop_outlined,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => v == null || v.trim().length < 6
                  ? 'Enter valid 6-digit pincode'
                  : null,
            ),
            const SizedBox(height: 14),
            Stack(
              children: [
                _buildField(
                  controller: _cityController,
                  label: _fetchingCity ? 'Fetching city...' : 'City',
                  icon: Icons.location_city_rounded,
                  readOnly: _fetchingCity,
                ),
                if (_fetchingCity)
                  Positioned(
                    right: 12,
                    top: 14,
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _accent,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.home_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Cancel button (only show if profile already has data)
                if (Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).isProfileComplete)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _populateFields(
                          Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          ).profile,
                        );
                        setState(() => _editing = false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textSecondary,
                        side: BorderSide(color: _border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: AppTheme.dmSansFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).isProfileComplete)
                  const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _accentLight,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save & Continue',
                            style: TextStyle(
                              fontFamily: AppTheme.dmSansFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(
        fontFamily: AppTheme.dmSansFamily,
        fontSize: 15,
        color: _textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        prefixIcon: Icon(icon, color: _accent, size: 20),
        labelStyle: TextStyle(
          fontFamily: AppTheme.dmSansFamily,
          color: _textSecondary.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        filled: true,
        fillColor: _bg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _border),
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
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
