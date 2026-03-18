import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/models/announcement_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../../../shared/models/coupon_model.dart';
import '../../../shared/models/alert_model.dart';

// ═════════════════════════════════════════════════════════════════════════════
//  ADMIN SCREEN — Main Shell
// ═════════════════════════════════════════════════════════════════════════════

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tab = 0;

  static const _bg = Color(0xFFFDF8F5);
  static const _textSecondary = Color(0xFF5A3A40);
  static const _border = Color(0xFFE8D5D0);
  static const _accent = Color(0xFFB76E79);

  static const _tabs = [
    _TabDef(Icons.dashboard_rounded, 'Dashboard'),
    _TabDef(Icons.inventory_2_outlined, 'Products'),
    _TabDef(Icons.campaign_outlined, 'Announce'),
    _TabDef(Icons.shopping_bag_outlined, 'Orders'),
    _TabDef(Icons.confirmation_number_outlined, 'Coupons'),
    _TabDef(Icons.reviews_outlined, 'Reviews'),
    _TabDef(Icons.people_outline_rounded, 'Users'),
    _TabDef(Icons.sms_outlined, 'Alerts'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isLoggedIn || !auth.isAdmin) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 44,
                  color: _accent,
                ),
                const SizedBox(height: 12),
                Text(
                  'Admin Access Required',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D1B20),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login with OTP and use an account present in admins/{uid}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textSecondary.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 720;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // ── Top bar ──
          Container(
            padding: EdgeInsets.fromLTRB(20, top + 10, 20, 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2D1B20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'JGS Admin',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Admin',
                    style: TextStyle(
                      color: Color(0xFFE8B4B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──
          Expanded(child: compact ? _buildCompactLayout() : _buildWideLayout()),
        ],
      ),
      bottomNavigationBar: compact
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: _border.withValues(alpha: 0.5)),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_tabs.length, (i) {
                      final selected = _tab == i;
                      return GestureDetector(
                        onTap: () => setState(() => _tab = i),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _tabs[i].icon,
                              size: 22,
                              color: selected
                                  ? _accent
                                  : _textSecondary.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _tabs[i].label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? _accent
                                    : _textSecondary.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCompactLayout() {
    return IndexedStack(
      index: _tab,
      children: const [
        _DashboardTab(),
        _ProductsTab(),
        _AnnouncementsTab(),
        _OrdersTab(),
        _CouponsTab(),
        _ReviewsTab(),
        _UsersTab(),
        _AlertsTab(),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Side rail
        Container(
          width: 200,
          color: Colors.white,
          child: Column(
            children: List.generate(_tabs.length, (i) {
              final selected = _tab == i;
              return GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _accent.withValues(alpha: 0.08) : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _tabs[i].icon,
                        size: 20,
                        color: selected
                            ? _accent
                            : _textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _tabs[i].label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? _accent
                              : _textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        VerticalDivider(width: 1, color: _border.withValues(alpha: 0.5)),
        Expanded(
          child: IndexedStack(
            index: _tab,
            children: const [
              _DashboardTab(),
              _ProductsTab(),
              _AnnouncementsTab(),
              _OrdersTab(),
              _CouponsTab(),
              _ReviewsTab(),
              _UsersTab(),
              _AlertsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabDef {
  final IconData icon;
  final String label;
  const _TabDef(this.icon, this.label);
}

// ═════════════════════════════════════════════════════════════════════════════
//  REVIEWS TAB — Moderation
// ═════════════════════════════════════════════════════════════════════════════

class _ReviewsTab extends StatefulWidget {
  const _ReviewsTab();

  @override
  State<_ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<_ReviewsTab> {
  static const _textPrimary = Color(0xFF2D1B20);
  static const _textSecondary = Color(0xFF5A3A40);
  static const _border = Color(0xFFE8D5D0);
  static const _accent = Color(0xFFB76E79);

  Future<void> _setApproval(String reviewId, bool approved) async {
    await FirebaseFirestore.instance.collection('reviews').doc(reviewId).update(
      {'approved': approved, 'moderatedAt': FieldValue.serverTimestamp()},
    );
  }

  Future<void> _deleteReview(String reviewId) async {
    await FirebaseFirestore.instance
        .collection('reviews')
        .doc(reviewId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? const [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reviews Moderation',
                    style: TextStyle(
                      fontFamily: AppTheme.playfairFamily,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${docs.length} review${docs.length == 1 ? '' : 's'} total',
                    style: TextStyle(
                      color: _textSecondary.withValues(alpha: 0.62),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const LinearProgressIndicator(minHeight: 2),
                  if (docs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _border.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        'No reviews yet.',
                        style: TextStyle(
                          color: _textSecondary.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    ...docs.map((d) {
                      final data = d.data();
                      final approved = data['approved'] == true;
                      final rating = (data['rating'] as num?)?.round() ?? 0;
                      final userName = (data['userName'] as String? ?? 'User')
                          .trim();
                      final productName =
                          (data['productName'] as String? ?? 'Product').trim();
                      final comment = (data['comment'] as String? ?? '').trim();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _border.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '$userName · $productName',
                                    style: const TextStyle(
                                      color: _textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: approved
                                        ? const Color(
                                            0xFF4CAF50,
                                          ).withValues(alpha: 0.14)
                                        : const Color(
                                            0xFFFF9800,
                                          ).withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    approved ? 'Approved' : 'Pending',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: approved
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFEF6C00),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < rating
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              comment,
                              style: TextStyle(
                                color: _textSecondary.withValues(alpha: 0.78),
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (!approved)
                                  OutlinedButton.icon(
                                    onPressed: () => _setApproval(d.id, true),
                                    icon: const Icon(
                                      Icons.check_circle_outline,
                                      size: 16,
                                    ),
                                    label: const Text('Approve'),
                                  )
                                else
                                  OutlinedButton.icon(
                                    onPressed: () => _setApproval(d.id, false),
                                    icon: const Icon(
                                      Icons.visibility_off_outlined,
                                      size: 16,
                                    ),
                                    label: const Text('Hide'),
                                  ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _deleteReview(d.id),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                  ),
                                  label: const Text('Delete'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  USERS TAB — All Registered Users from Firestore
// ═════════════════════════════════════════════════════════════════════════════

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  static const _textPrimary = Color(0xFF2D1B20);
  static const _textSecondary = Color(0xFF5A3A40);
  static const _border = Color(0xFFE8D5D0);
  static const _accent = Color(0xFFB76E79);
  static const _accentLight = Color(0xFFE8B4B8);

  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('updatedAt', descending: true)
          .get();
      if (!mounted) return;
      setState(() {
        _users = snapshot.docs.map((doc) {
          final data = doc.data();
          data['uid'] = doc.id;
          return data;
        }).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load users: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _accent,
      onRefresh: _fetchUsers,
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: _accent, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.dmSansFamily,
                        color: _textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchUsers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _users.isEmpty
          ? Center(
              child: Text(
                'No registered users yet',
                style: TextStyle(
                  fontFamily: AppTheme.dmSansFamily,
                  color: _textSecondary.withValues(alpha: 0.6),
                  fontSize: 15,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Registered Users',
                                  style: TextStyle(
                                    fontFamily: AppTheme.playfairFamily,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_users.length} user${_users.length == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    fontFamily: AppTheme.dmSansFamily,
                                    color: _textSecondary.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _fetchUsers,
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: _accent,
                            ),
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(_users.length, (i) {
                        final u = _users[i];
                        final name = u['name'] as String? ?? 'Unnamed';
                        final phone = u['phone'] as String? ?? '—';
                        final city = u['city'] as String? ?? '';
                        final pincode = u['pincode'] as String? ?? '';
                        final address = u['address'] as String? ?? '';
                        final initial = name.isNotEmpty
                            ? name[0].toUpperCase()
                            : '?';
                        final isMember = u['isMember'] as bool? ?? false;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _border.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: _accentLight.withValues(
                                  alpha: 0.3,
                                ),
                                child: Text(
                                  initial,
                                  style: TextStyle(
                                    fontFamily: AppTheme.playfairFamily,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _accent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontFamily: AppTheme.dmSansFamily,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: _textPrimary,
                                      ),
                                    ),
                                    if (isMember)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFFD4AF37,
                                            ).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: const Color(
                                                0xFFD4AF37,
                                              ).withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: const Text(
                                            'JGS PREMIUM',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFFD4AF37),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 2),
                                    Text(
                                      phone,
                                      style: TextStyle(
                                        fontFamily: AppTheme.dmSansFamily,
                                        fontSize: 13,
                                        color: _textSecondary.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                    if (city.isNotEmpty || pincode.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          [
                                            if (city.isNotEmpty) city,
                                            if (pincode.isNotEmpty) pincode,
                                          ].join(' · '),
                                          style: TextStyle(
                                            fontFamily: AppTheme.dmSansFamily,
                                            fontSize: 12,
                                            color: _textSecondary.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (address.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          address,
                                          style: TextStyle(
                                            fontFamily: AppTheme.dmSansFamily,
                                            fontSize: 12,
                                            color: _textSecondary.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Switch(
                                      value: isMember,
                                      activeColor: const Color(0xFFD4AF37),
                                      onChanged: (val) async {
                                        final admin =
                                            Provider.of<AdminProvider>(
                                              context,
                                              listen: false,
                                            );
                                        await admin.toggleMembership(
                                          u['uid'],
                                          val,
                                        );
                                        _fetchUsers();
                                      },
                                    ),
                                  ),
                                  Text(
                                    'Member',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isMember
                                          ? const Color(0xFFD4AF37)
                                          : _textSecondary.withValues(
                                              alpha: 0.4,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  1. DASHBOARD TAB
// ═════════════════════════════════════════════════════════════════════════════

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  int _userCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserCount();
  }

  Future<void> _fetchUserCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .count()
          .get();
      if (mounted) setState(() => _userCount = snapshot.count ?? 0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final pending = admin.orders.where((o) => o.status == 'Pending').length;
    final confirmed = admin.orders.where((o) => o.status == 'Confirmed').length;
    final revenue = admin.orders.fold<double>(0, (sum, o) => sum + o.total);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  fontFamily: AppTheme.playfairFamily,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D1B20),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Overview of your store',
                style: TextStyle(
                  color: const Color(0xFF5A3A40).withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _StatCard(
                    'Products',
                    '${admin.products.length}',
                    Icons.inventory_2_outlined,
                    const Color(0xFF4CAF50),
                  ),
                  _StatCard(
                    'Announcements',
                    '${admin.announcements.length}',
                    Icons.campaign_outlined,
                    const Color(0xFF2196F3),
                  ),
                  _StatCard(
                    'Total Orders',
                    '${admin.orders.length}',
                    Icons.shopping_bag_outlined,
                    const Color(0xFFFF9800),
                  ),
                  _StatCard(
                    'Pending',
                    '$pending',
                    Icons.hourglass_empty_rounded,
                    const Color(0xFFFF5722),
                  ),
                  _StatCard(
                    'Confirmed',
                    '$confirmed',
                    Icons.check_circle_outline,
                    const Color(0xFF9C27B0),
                  ),
                  _StatCard(
                    'Revenue',
                    '₹${revenue.toStringAsFixed(0)}',
                    Icons.currency_rupee_rounded,
                    const Color(0xFFB76E79),
                  ),
                  _StatCard(
                    'SMS Sent',
                    '${admin.sentAlerts.length}',
                    Icons.sms_outlined,
                    const Color(0xFF607D8B),
                  ),
                  _StatCard(
                    'Users',
                    '$_userCount',
                    Icons.people_outline_rounded,
                    const Color(0xFF795548),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Recent Orders',
                style: TextStyle(
                  fontFamily: AppTheme.playfairFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D1B20),
                ),
              ),
              const SizedBox(height: 14),
              ...admin.orders
                  .take(5)
                  .map(
                    (o) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE8D5D0).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  o.id,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${o.customerName} · ${o.date}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(
                                      0xFF5A3A40,
                                    ).withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _StatusBadge(o.status),
                          const SizedBox(width: 12),
                          Text(
                            '₹${o.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8D5D0).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B4B8).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTheme.playfairFamily,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2D1B20),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF5A3A40).withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  Color get _color {
    switch (status) {
      case 'Delivered':
        return const Color(0xFF4CAF50);
      case 'Shipped':
        return const Color(0xFF2196F3);
      case 'Confirmed':
        return const Color(0xFF9C27B0);
      case 'Cancelled':
        return const Color(0xFFFF5722);
      default:
        return const Color(0xFFFF9800);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  2. PRODUCTS TAB
// ═════════════════════════════════════════════════════════════════════════════

class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final products = admin.products;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Products (${products.length})',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D1B20),
                  ),
                ),
              ),
              _AdminButton(
                icon: Icons.add_rounded,
                label: 'Add Product',
                onTap: () => _showProductDialog(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: products.isEmpty
              ? const Center(
                  child: Text('No products yet. Add your first product!'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final p = products[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE8D5D0).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: p.image.startsWith('http')
                                ? Image.network(
                                    p.image,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildPlaceholder(),
                                  )
                                : Image.asset(
                                    p.image,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildPlaceholder(),
                                  ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.brand ?? 'No brand'} · ${p.category ?? 'Uncategorized'} · ₹${p.effectivePrice.toStringAsFixed(0)} · ${p.variants.length} size(s)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(
                                      0xFF5A3A40,
                                    ).withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: const Color(
                              0xFF5A3A40,
                            ).withValues(alpha: 0.5),
                            onPressed: () =>
                                _showProductDialog(context, product: p),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                            ),
                            color: const Color(
                              0xFFFF5722,
                            ).withValues(alpha: 0.6),
                            onPressed: () {
                              admin.deleteProduct(p.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showProductDialog(BuildContext context, {CatalogProduct? product}) {
    final isEdit = product != null;
    StateSetter? dialogSetter;

    final nameC = TextEditingController(text: product?.name ?? '');
    final priceC = TextEditingController(
      text: (product?.price ?? 0) > 0 ? product!.price.toStringAsFixed(0) : '',
    );
    final origPriceC = TextEditingController(
      text: (product?.originalPrice ?? 0) > 0
          ? product!.originalPrice!.toStringAsFixed(0)
          : '',
    );
    final brandC = TextEditingController(text: product?.brand ?? '');
    final subtitleC = TextEditingController(text: product?.subtitle ?? '');
    final descriptionC = TextEditingController(
      text: product?.description ?? '',
    );
    final imageUrlC = TextEditingController(
      text: (product?.image.startsWith('http') ?? false) ? product!.image : '',
    );

    // Structured variant management
    final List<Map<String, TextEditingController>> variantRows = [];

    void addVariantRow({String size = '', String mrp = '', String sp = ''}) {
      final sC = TextEditingController(text: size);
      final mC = TextEditingController(text: mrp);
      final spC = TextEditingController(text: sp);
      // Re-trigger dialog build for preview
      sC.addListener(() => dialogSetter?.call(() {}));
      mC.addListener(() => dialogSetter?.call(() {}));
      spC.addListener(() => dialogSetter?.call(() {}));

      variantRows.add({'size': sC, 'mrp': mC, 'sp': spC});
    }

    if (product != null && product.variants.isNotEmpty) {
      for (var v in product.variants) {
        addVariantRow(
          size: v.sizeLabel,
          mrp: v.mrp.toStringAsFixed(0),
          sp: v.sellingPrice.toStringAsFixed(0),
        );
      }
    } else {
      // Default empty row
      addVariantRow(size: '50 ml', mrp: '799', sp: '499');
    }

    String category = product?.category ?? 'Makeup';
    String? concern = product?.concern;
    bool aiLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          dialogSetter = setDialogState;
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFFFDF8F5),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Product' : 'Add Product',
                      style: TextStyle(
                        fontFamily: AppTheme.playfairFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D1B20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _DialogField(controller: nameC, label: 'Product Name'),
                    const SizedBox(height: 12),
                    _DialogField(controller: brandC, label: 'Brand'),
                    const SizedBox(height: 12),
                    _DialogField(controller: subtitleC, label: 'Subtitle'),
                    const SizedBox(height: 12),
                    _DialogField(
                      controller: descriptionC,
                      label: 'Product Description',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: aiLoading
                            ? null
                            : () async {
                                if (nameC.text.trim().isEmpty) return;
                                setDialogState(() => aiLoading = true);
                                final admin = Provider.of<AdminProvider>(
                                  ctx,
                                  listen: false,
                                );
                                final suggestion = await admin
                                    .suggestDescriptionAi(
                                      name: nameC.text,
                                      category: category,
                                      concern: concern,
                                    );
                                if (!ctx.mounted) return;
                                descriptionC.text = suggestion;
                                setDialogState(() => aiLoading = false);
                                setDialogState(() {});
                              },
                        icon: aiLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome_rounded, size: 16),
                        label: Text(
                          aiLoading
                              ? 'Generating...'
                              : 'AI Suggest Description',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DialogField(
                      controller: imageUrlC,
                      label: 'Image URL (paste link)',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final file = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 75,
                                maxWidth: 1400,
                              );
                              if (file == null) return;
                              final bytes = await file.readAsBytes();
                              final ref = FirebaseStorage.instance.ref().child(
                                'products/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
                              );
                              await ref.putData(
                                bytes,
                                SettableMetadata(
                                  contentType: file.mimeType ?? 'image/jpeg',
                                ),
                              );
                              imageUrlC.text = await ref.getDownloadURL();
                              setDialogState(() {});
                            },
                            icon: const Icon(
                              Icons.photo_library_outlined,
                              size: 18,
                            ),
                            label: const Text('Gallery'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final file = await picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 75,
                                maxWidth: 1400,
                              );
                              if (file == null) return;
                              final bytes = await file.readAsBytes();
                              final ref = FirebaseStorage.instance.ref().child(
                                'products/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
                              );
                              await ref.putData(
                                bytes,
                                SettableMetadata(
                                  contentType: file.mimeType ?? 'image/jpeg',
                                ),
                              );
                              imageUrlC.text = await ref.getDownloadURL();
                              setDialogState(() {});
                            },
                            icon: const Icon(
                              Icons.photo_camera_outlined,
                              size: 18,
                            ),
                            label: const Text('Camera'),
                          ),
                        ),
                      ],
                    ),
                    // Update preview when URL changes
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => setDialogState(() {}),
                        child: const Text(
                          'Load Preview',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB76E79),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (imageUrlC.text.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child:
                              (imageUrlC.text.trim().startsWith('http') ||
                                  imageUrlC.text.trim().startsWith('https'))
                              ? Image.network(
                                  imageUrlC.text.trim(),
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDF8F5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Invalid image URL',
                                        style: TextStyle(
                                          color: Color(0xFFFF5722),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  imageUrlC.text.trim(),
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDF8F5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Asset not found',
                                        style: TextStyle(
                                          color: Color(0xFFFF5722),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      'Product Sizes & Variants',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D1B20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...variantRows.asMap().entries.map((entry) {
                      final i = entry.key;
                      final row = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _DialogField(
                                controller: row['size']!,
                                label: 'Size (e.g. 50ml)',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: _DialogField(
                                controller: row['mrp']!,
                                label: 'MRP',
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: _DialogField(
                                controller: row['sp']!,
                                label: 'Price',
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: variantRows.length > 1
                                  ? () => setDialogState(
                                      () => variantRows.removeAt(i),
                                    )
                                  : null,
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    GestureDetector(
                      onTap: () => setDialogState(() => addVariantRow()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFB76E79)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: Color(0xFFB76E79),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Add Another Size',
                              style: TextStyle(
                                color: Color(0xFFB76E79),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFE8D5D0)),
                    const SizedBox(height: 12),
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5A3A40).withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                                'Makeup',
                                'Skincare',
                                'Haircare',
                                'Fragrance',
                                'Bath & Body',
                              ]
                              .map(
                                (c) => GestureDetector(
                                  onTap: () =>
                                      setDialogState(() => category = c),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: category == c
                                          ? const Color(0xFFB76E79)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: category == c
                                            ? const Color(0xFFB76E79)
                                            : const Color(0xFFE8D5D0),
                                      ),
                                    ),
                                    child: Text(
                                      c,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: category == c
                                            ? Colors.white
                                            : const Color(0xFF5A3A40),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Concern (optional)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5A3A40).withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        GestureDetector(
                          onTap: () => setDialogState(() => concern = null),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: concern == null
                                  ? const Color(0xFFB76E79)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: concern == null
                                    ? const Color(0xFFB76E79)
                                    : const Color(0xFFE8D5D0),
                              ),
                            ),
                            child: Text(
                              'None',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: concern == null
                                    ? Colors.white
                                    : const Color(0xFF5A3A40),
                              ),
                            ),
                          ),
                        ),
                        ...[
                          'Acne & Blemishes',
                          'Dry Skin',
                          'Anti-Aging',
                          'Sun Protection',
                          'Hair Fall',
                          'Dark Circles',
                        ].map(
                          (c) => GestureDetector(
                            onTap: () => setDialogState(() => concern = c),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: concern == c
                                    ? const Color(0xFFB76E79)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: concern == c
                                      ? const Color(0xFFB76E79)
                                      : const Color(0xFFE8D5D0),
                                ),
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: concern == c
                                      ? Colors.white
                                      : const Color(0xFF5A3A40),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE8D5D0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Color(0xFF5A3A40)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (nameC.text.trim().isEmpty) return;
                              final admin = Provider.of<AdminProvider>(
                                ctx,
                                listen: false,
                              );

                              // Collect variants from rows
                              final List<ProductVariant> variants = [];
                              for (int i = 0; i < variantRows.length; i++) {
                                final row = variantRows[i];
                                final size = row['size']!.text.trim();
                                if (size.isEmpty) continue;

                                final mrp =
                                    double.tryParse(row['mrp']!.text) ?? 0;
                                final sp =
                                    double.tryParse(row['sp']!.text) ?? 0;

                                variants.add(
                                  ProductVariant(
                                    id: '${DateTime.now().millisecondsSinceEpoch}_$i',
                                    sizeLabel: size,
                                    mrp: mrp,
                                    sellingPrice: sp,
                                  ),
                                );
                              }

                              final defaultVariant = variants.isNotEmpty
                                  ? variants.first
                                  : null;

                              final newProduct = CatalogProduct(
                                id: isEdit
                                    ? product!.id
                                    : 'prod_${DateTime.now().millisecondsSinceEpoch}',
                                name: nameC.text.trim(),
                                price:
                                    defaultVariant?.sellingPrice ??
                                    (double.tryParse(priceC.text) ?? 0),
                                originalPrice:
                                    defaultVariant?.mrp ??
                                    (origPriceC.text.isNotEmpty
                                        ? double.tryParse(origPriceC.text)
                                        : null),
                                rating: product?.rating ?? 4.5,
                                image: imageUrlC.text.trim().isNotEmpty
                                    ? imageUrlC.text.trim()
                                    : (product?.image ??
                                          'assets/images/products/foundation.png'),
                                subtitle: subtitleC.text.trim().isEmpty
                                    ? null
                                    : subtitleC.text.trim(),
                                brand: brandC.text.trim().isEmpty
                                    ? null
                                    : brandC.text.trim(),
                                category: category,
                                concern: concern,
                                description: descriptionC.text.trim().isEmpty
                                    ? null
                                    : descriptionC.text.trim(),
                                variants: variants,
                              );

                              if (isEdit) {
                                await admin.updateProduct(
                                  product!.id,
                                  newProduct,
                                );
                              } else {
                                await admin.addProduct(newProduct);
                              }
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB76E79),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(isEdit ? 'Update' : 'Add Product'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  3. ANNOUNCEMENTS TAB
// ═════════════════════════════════════════════════════════════════════════════

class _AnnouncementsTab extends StatelessWidget {
  const _AnnouncementsTab();

  static const _tagOptions = [
    (
      'NEW ARRIVALS',
      Color(0xFF4CAF50),
      Icons.new_releases_outlined,
      'New Arrivals',
    ),
    (
      'EXCLUSIVE',
      Color(0xFFB76E79),
      Icons.auto_awesome_outlined,
      'New Arrivals',
    ),
    ('OFFER', Color(0xFFFF9800), Icons.local_offer_outlined, 'Offers'),
    ('UPDATE', Color(0xFF2196F3), Icons.local_shipping_outlined, 'Updates'),
    ('NEWS', Color(0xFF9C27B0), Icons.storefront_outlined, 'News'),
  ];

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final items = admin.announcements;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Announcements (${items.length})',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D1B20),
                  ),
                ),
              ),
              _AdminButton(
                icon: Icons.add_rounded,
                label: 'New Post',
                onTap: () => _showAnnouncementDialog(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('No announcements. Create one!'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final a = items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE8D5D0).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (a.imageUrl != null && a.imageUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(13),
                              ),
                              child: Image.network(
                                a.imageUrl!,
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    height: 140,
                                    color: const Color(0xFFFDF8F5),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFB76E79),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Container(
                                  height: 80,
                                  color: const Color(0xFFFDF8F5),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      color: Color(0xFFE8D5D0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: a.tagColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    a.tag,
                                    style: TextStyle(
                                      color: a.tagColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    a.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  color: const Color(
                                    0xFF5A3A40,
                                  ).withValues(alpha: 0.5),
                                  onPressed: () => _showAnnouncementDialog(
                                    context,
                                    existing: a,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                  ),
                                  color: const Color(
                                    0xFFFF5722,
                                  ).withValues(alpha: 0.6),
                                  onPressed: () =>
                                      admin.deleteAnnouncement(a.id),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAnnouncementDialog(BuildContext context, {Announcement? existing}) {
    final isEdit = existing != null;
    final titleC = TextEditingController(text: existing?.title ?? '');
    final subtitleC = TextEditingController(text: existing?.subtitle ?? '');
    final bodyC = TextEditingController(text: existing?.body ?? '');
    final imageC = TextEditingController(text: existing?.imageUrl ?? '');
    int tagIdx = 0;
    if (isEdit) {
      tagIdx = _tagOptions.indexWhere((t) => t.$1 == existing!.tag);
      if (tagIdx < 0) tagIdx = 0;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFDF8F5),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Edit Announcement' : 'New Announcement',
                    style: TextStyle(
                      fontFamily: AppTheme.playfairFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D1B20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DialogField(controller: titleC, label: 'Title'),
                  const SizedBox(height: 12),
                  _DialogField(controller: subtitleC, label: 'Subtitle'),
                  const SizedBox(height: 12),
                  _DialogField(
                    controller: bodyC,
                    label: 'Body / Details',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  _DialogField(
                    controller: imageC,
                    label: 'Image (Picker or URL)',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _AdminButton(
                          onTap: () async {
                            final picker = ImagePicker();
                            final file = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 70,
                            );
                            if (file == null) return;

                            final bytes = await file.readAsBytes();
                            final ref = FirebaseStorage.instance.ref().child(
                              'announcements/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
                            );
                            await ref.putData(
                              bytes,
                              SettableMetadata(
                                contentType: file.mimeType ?? 'image/jpeg',
                              ),
                            );
                            imageC.text = await ref.getDownloadURL();
                            setDialogState(() {});
                          },
                          icon: Icons.image_outlined,
                          label: 'Gallery',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _AdminButton(
                          onTap: () async {
                            final picker = ImagePicker();
                            final file = await picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 70,
                            );
                            if (file == null) return;

                            final bytes = await file.readAsBytes();
                            final ref = FirebaseStorage.instance.ref().child(
                              'announcements/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
                            );
                            await ref.putData(
                              bytes,
                              SettableMetadata(
                                contentType: file.mimeType ?? 'image/jpeg',
                              ),
                            );
                            imageC.text = await ref.getDownloadURL();
                            setDialogState(() {});
                          },
                          icon: Icons.photo_camera_outlined,
                          label: 'Camera',
                        ),
                      ),
                    ],
                  ),
                  if (imageC.text.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageC.text.trim().startsWith('http')
                            ? Image.network(
                                imageC.text.trim(),
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildPlaceholder(),
                              )
                            : Image.asset(
                                imageC.text.trim(),
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildPlaceholder(),
                              ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    'Category / Tag',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5A3A40).withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_tagOptions.length, (i) {
                      final t = _tagOptions[i];
                      final selected = tagIdx == i;
                      return GestureDetector(
                        onTap: () => setDialogState(() => tagIdx = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? t.$2.withValues(alpha: 0.15)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? t.$2 : const Color(0xFFE8D5D0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(t.$3, size: 16, color: t.$2),
                              const SizedBox(width: 6),
                              Text(
                                t.$1,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? t.$2
                                      : const Color(0xFF5A3A40),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE8D5D0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF5A3A40)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (titleC.text.trim().isEmpty) return;
                            final admin = Provider.of<AdminProvider>(
                              context,
                              listen: false,
                            );
                            final tag = _tagOptions[tagIdx];
                            final now = DateTime.now();
                            final months = [
                              '',
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun',
                              'Jul',
                              'Aug',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dec',
                            ];
                            final dateStr =
                                '${months[now.month]} ${now.day}, ${now.year}';

                            final ann = Announcement(
                              id: isEdit
                                  ? existing.id
                                  : 'ann_${DateTime.now().millisecondsSinceEpoch}',
                              title: titleC.text.trim(),
                              subtitle: subtitleC.text.trim(),
                              body: bodyC.text.trim(),
                              date: isEdit ? existing.date : dateStr,
                              tag: tag.$1,
                              category: tag.$4,
                              tagColor: tag.$2,
                              icon: tag.$3,
                              imageUrl: imageC.text.trim().isEmpty
                                  ? null
                                  : imageC.text.trim(),
                            );
                            if (isEdit) {
                              admin.updateAnnouncement(existing.id, ann);
                            } else {
                              admin.addAnnouncement(ann);
                            }
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB76E79),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(isEdit ? 'Update' : 'Publish'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  4. ORDERS TAB
// ═════════════════════════════════════════════════════════════════════════════

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  static const _statuses = [
    'Pending',
    'Confirmed',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final orders = admin.orders;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Orders (${orders.length})',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D1B20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: orders.isEmpty
              ? const Center(child: Text('No orders yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: orders.length,
                  itemBuilder: (_, i) {
                    final o = orders[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE8D5D0).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            16,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      o.id,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${o.customerName} · ₹${o.total.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: const Color(
                                          0xFF5A3A40,
                                        ).withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _StatusBadge(o.status),
                            ],
                          ),
                          children: [
                            // Customer info
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF8F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _InfoRow(
                                    Icons.person_outline,
                                    o.customerName,
                                  ),
                                  _InfoRow(
                                    Icons.phone_outlined,
                                    '+91 ${o.phone}',
                                  ),
                                  _InfoRow(
                                    Icons.location_on_outlined,
                                    '${o.address}, ${o.city} - ${o.pincode}',
                                  ),
                                  _InfoRow(
                                    Icons.calendar_today_outlined,
                                    o.date,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Items
                            ...o.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.name} × ${item.qty}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    Text(
                                      '₹${(item.price * item.qty).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Status update
                            Row(
                              children: [
                                const Text(
                                  'Update Status:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: _statuses.map((s) {
                                        final active = o.status == s;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 6,
                                          ),
                                          child: GestureDetector(
                                            onTap: () => admin
                                                .updateOrderStatus(o.id, s),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: active
                                                    ? const Color(0xFFB76E79)
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: active
                                                      ? const Color(0xFFB76E79)
                                                      : const Color(0xFFE8D5D0),
                                                ),
                                              ),
                                              child: Text(
                                                s,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: active
                                                      ? Colors.white
                                                      : const Color(0xFF5A3A40),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF5A3A40).withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF5A3A40).withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  5. SMS / ALERTS TAB
// ═════════════════════════════════════════════════════════════════════════════

class _AlertsTab extends StatelessWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final alerts = admin.sentAlerts;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'SMS & Alerts (${alerts.length})',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D1B20),
                  ),
                ),
              ),
              _AdminButton(
                icon: Icons.send_rounded,
                label: 'Send Alert',
                onTap: () => _showAlertDialog(context),
              ),
            ],
          ),
        ),
        // Quick action chips
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickChip(
                '📢 New Arrival Alert',
                () => _showAlertDialog(
                  context,
                  prefillTitle: 'New Arrivals!',
                  prefillMsg:
                      'New beauty products just arrived at JGS! Visit us or browse online.',
                ),
              ),
              _QuickChip(
                '🎁 Offer Alert',
                () => _showAlertDialog(
                  context,
                  prefillTitle: 'Special Offer!',
                  prefillMsg:
                      'Exciting offers at JGS! Get up to 50% off on select products.',
                ),
              ),
              _QuickChip(
                '🚚 Delivery Update',
                () => _showAlertDialog(
                  context,
                  prefillTitle: 'Delivery Update',
                  prefillMsg:
                      'Your order has been shipped and will arrive soon!',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: alerts.isEmpty
              ? const Center(child: Text('No alerts sent yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: alerts.length,
                  itemBuilder: (_, i) {
                    final a = alerts[i];
                    final typeColor = a.type == 'Promotional'
                        ? const Color(0xFFFF9800)
                        : a.type == 'Offer'
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF2196F3);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE8D5D0).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.sms_outlined,
                                size: 18,
                                color: typeColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  a.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: typeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  a.type,
                                  style: TextStyle(
                                    color: typeColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            a.message,
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(
                                0xFF5A3A40,
                              ).withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                color: const Color(
                                  0xFF5A3A40,
                                ).withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                a.sentTo,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: const Color(
                                    0xFF5A3A40,
                                  ).withValues(alpha: 0.5),
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: const Color(
                                  0xFF5A3A40,
                                ).withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                a.sentAt,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: const Color(
                                    0xFF5A3A40,
                                  ).withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAlertDialog(
    BuildContext context, {
    String? prefillTitle,
    String? prefillMsg,
  }) {
    final titleC = TextEditingController(text: prefillTitle ?? '');
    final msgC = TextEditingController(text: prefillMsg ?? '');
    String alertSendTo = 'All Customers';
    String alertType = 'Promotional';
    bool alertIsSending = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFDF8F5),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Send SMS / Alert',
                    style: TextStyle(
                      fontFamily: AppTheme.playfairFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D1B20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DialogField(controller: titleC, label: 'Alert Title'),
                  const SizedBox(height: 12),
                  _DialogField(controller: msgC, label: 'Message', maxLines: 4),
                  const SizedBox(height: 12),
                  Text(
                    'Send To',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5A3A40).withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        ['All Customers', 'Recent Buyers', 'Custom Number']
                            .map(
                              (s) => GestureDetector(
                                onTap: alertIsSending
                                    ? null
                                    : () =>
                                          setDialogState(() => alertSendTo = s),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: alertSendTo == s
                                        ? const Color(0xFFB76E79)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: alertSendTo == s
                                          ? const Color(0xFFB76E79)
                                          : const Color(0xFFE8D5D0),
                                    ),
                                  ),
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: alertSendTo == s
                                          ? Colors.white
                                          : const Color(0xFF5A3A40),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Type',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5A3A40).withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: ['Promotional', 'Transactional', 'Offer'].map((
                      t,
                    ) {
                      return GestureDetector(
                        onTap: alertIsSending
                            ? null
                            : () => setDialogState(() => alertType = t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: alertType == t
                                ? const Color(0xFFB76E79)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: alertType == t
                                  ? const Color(0xFFB76E79)
                                  : const Color(0xFFE8D5D0),
                            ),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: alertType == t
                                  ? Colors.white
                                  : const Color(0xFF5A3A40),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: alertIsSending
                              ? null
                              : () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE8D5D0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF5A3A40)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: alertIsSending
                              ? null
                              : () async {
                                  if (titleC.text.trim().isEmpty ||
                                      msgC.text.trim().isEmpty) {
                                    return;
                                  }

                                  setDialogState(() => alertIsSending = true);

                                  try {
                                    final admin = Provider.of<AdminProvider>(
                                      ctx,
                                      listen: false,
                                    );
                                    final now = DateTime.now();
                                    final months = [
                                      '',
                                      'Jan',
                                      'Feb',
                                      'Mar',
                                      'Apr',
                                      'May',
                                      'Jun',
                                      'Jul',
                                      'Aug',
                                      'Sep',
                                      'Oct',
                                      'Nov',
                                      'Dec',
                                    ];
                                    final h = now.hour > 12
                                        ? now.hour - 12
                                        : now.hour;
                                    final ampm = now.hour >= 12 ? 'PM' : 'AM';
                                    final timeStr =
                                        '${months[now.month]} ${now.day}, ${now.year} - $h:${now.minute.toString().padLeft(2, '0')} $ampm';

                                    await admin.sendAlert(
                                      SmsAlert(
                                        id: 'sms_${DateTime.now().millisecondsSinceEpoch}',
                                        title: titleC.text.trim(),
                                        message: msgC.text.trim(),
                                        sentTo: alertSendTo,
                                        sentAt: timeStr,
                                        type: alertType,
                                      ),
                                    );

                                    if (!ctx.mounted) return;
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context)
                                      ..clearSnackBars()
                                      ..showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 4),
                                          content: Text(
                                            'Bulk alert sent to $alertSendTo successfully!',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: const Color(
                                            0xFF4CAF50,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                  } catch (e) {
                                    if (!ctx.mounted) return;
                                    setDialogState(
                                      () => alertIsSending = false,
                                    );
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to send alert: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB76E79),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: alertIsSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded, size: 18),
                          label: Text(alertIsSending ? 'Sending...' : 'Send'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE8D5D0).withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A3A40),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

class _AdminButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AdminButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFB76E79),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  5. COUPONS TAB
// ═════════════════════════════════════════════════════════════════════════════

class _CouponsTab extends StatelessWidget {
  const _CouponsTab();

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final coupons = admin.coupons;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Coupons (${coupons.length})',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D1B20),
                  ),
                ),
              ),
              _AdminButton(
                icon: Icons.add_rounded,
                label: 'Add Coupon',
                onTap: () => _showCouponDialog(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: coupons.isEmpty
              ? const Center(
                  child: Text('No coupons yet. Create your first offer!'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: coupons.length,
                  itemBuilder: (_, i) {
                    final c = coupons[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE8D5D0).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF8F5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.confirmation_number_outlined,
                              color: c.isActive
                                  ? const Color(0xFFB76E79)
                                  : Colors.grey,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      c.code,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (!c.isActive)
                                      const _StatusLabel(
                                        label: 'Inactive',
                                        color: Colors.grey,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${c.isPercentage ? '${c.discountAmount.toStringAsFixed(0)}%' : '₹${c.discountAmount.toStringAsFixed(0)}'} discount · Min ₹${c.minOrderAmount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(
                                      0xFF5A3A40,
                                    ).withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: const Color(
                              0xFF5A3A40,
                            ).withValues(alpha: 0.5),
                            onPressed: () =>
                                _showCouponDialog(context, coupon: c),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                            ),
                            color: const Color(
                              0xFFFF5722,
                            ).withValues(alpha: 0.6),
                            onPressed: () => admin.deleteCoupon(c.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

void _showCouponDialog(BuildContext context, {Coupon? coupon}) {
  final isEdit = coupon != null;
  final codeC = TextEditingController(text: coupon?.code ?? '');
  final amountC = TextEditingController(
    text: coupon?.discountAmount.toString() ?? '',
  );
  final minAmountC = TextEditingController(
    text: coupon?.minOrderAmount.toString() ?? '',
  );
  final maxDiscountC = TextEditingController(
    text: coupon?.maxDiscountAmount?.toString() ?? '',
  );
  bool isPercentage = coupon?.isPercentage ?? true;
  bool isActive = coupon?.isActive ?? true;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Edit Coupon' : 'New Coupon',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D1B20),
                  ),
                ),
                const SizedBox(height: 20),
                _DialogField(
                  controller: codeC,
                  label: 'Coupon Code (e.g. SAVE20)',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DialogField(
                        controller: amountC,
                        label: 'Discount Amount',
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        const Text('Type', style: TextStyle(fontSize: 12)),
                        Switch(
                          value: isPercentage,
                          activeThumbColor: const Color(0xFFB76E79),
                          onChanged: (v) =>
                              setDialogState(() => isPercentage = v),
                        ),
                        Text(
                          isPercentage ? '%' : 'Fixed',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DialogField(
                  controller: minAmountC,
                  label: 'Min Order Amount',
                  isNumber: true,
                ),
                const SizedBox(height: 12),
                _DialogField(
                  controller: maxDiscountC,
                  label: 'Max Discount (Optional)',
                  isNumber: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Is Active'),
                    const Spacer(),
                    Switch(
                      value: isActive,
                      activeThumbColor: const Color(0xFFB76E79),
                      onChanged: (v) => setDialogState(() => isActive = v),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB76E79),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (codeC.text.isEmpty || amountC.text.isEmpty)
                            return;
                          final admin = Provider.of<AdminProvider>(
                            context,
                            listen: false,
                          );
                          final newCoupon = Coupon(
                            id:
                                coupon?.id ??
                                'cpn_${DateTime.now().millisecondsSinceEpoch}',
                            code: codeC.text.trim().toUpperCase(),
                            discountAmount: double.tryParse(amountC.text) ?? 0,
                            isPercentage: isPercentage,
                            minOrderAmount:
                                double.tryParse(minAmountC.text) ?? 0,
                            maxDiscountAmount: double.tryParse(
                              maxDiscountC.text,
                            ),
                            isActive: isActive,
                          );

                          if (isEdit) {
                            admin.updateCoupon(coupon.id, newCoupon);
                          } else {
                            admin.addCoupon(newCoupon);
                          }
                          Navigator.pop(ctx);
                        },
                        child: Text(isEdit ? 'Update' : 'Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _StatusLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final bool isNumber;

  const _DialogField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))]
          : null,
      style: const TextStyle(
        color: Color(0xFF2D1B20),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: const Color(0xFF5A3A40).withValues(alpha: 0.5),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFE8D5D0).withValues(alpha: 0.6),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFE8D5D0).withValues(alpha: 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB76E79), width: 1.5),
        ),
      ),
    );
  }
}

Widget _buildPlaceholder() {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFFDF8F5),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Center(
      child: Icon(
        Icons.shopping_bag_outlined,
        color: Color(0xFFB76E79),
        size: 22,
      ),
    ),
  );
}
