import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/announcement_model.dart';
import '../../admin/providers/admin_provider.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  static const _bg = Color(0xFFFDF8F5);
  static const _textPrimary = Color(0xFF2D1B20);
  static const _textSecondary = Color(0xFF5A3A40);
  static const _border = Color(0xFFE8D5D0);
  static const _accent = Color(0xFFB76E79);
  static const _accentLight = Color(0xFFE8B4B8);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final announcements = context.select<AdminProvider, List<Announcement>>(
      (a) => a.announcements,
    );

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
                  onTap: () =>
                      context.canPop() ? context.pop() : context.go('/'),
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
                    'What\'s New',
                    style: TextStyle(
                      fontFamily: AppTheme.playfairFamily,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.campaign_outlined, size: 16, color: _accent),
                      const SizedBox(width: 4),
                      Text(
                        '${announcements.length}',
                        style: TextStyle(
                          color: _accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──
          Expanded(
            child: announcements.isEmpty
                ? _buildEmptyState(context)
                : SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Hero banner ──
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _accent.withValues(alpha: 0.12),
                                      _accentLight.withValues(alpha: 0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _accent.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: _accentLight.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 20,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.campaign_rounded,
                                        color: _accent,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Store Announcements',
                                      style: TextStyle(
                                        fontFamily: AppTheme.playfairFamily,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: _textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Stay updated with new arrivals, offers\n& special events at Jagdish General Store',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _textSecondary.withValues(
                                          alpha: 0.6,
                                        ),
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ── Announcement cards ──
                              ...announcements.map(
                                (a) => _AnnouncementCard(announcement: a),
                              ),
                            ],
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accent.withValues(alpha: 0.08),
            ),
            child: Icon(
              Icons.campaign_outlined,
              size: 56,
              color: _accent.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No announcements yet',
            style: TextStyle(
              fontFamily: AppTheme.playfairFamily,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon for updates on\nnew arrivals and special offers',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textSecondary.withValues(alpha: 0.6),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Announcement Card Widget — large image card then text ──

class _AnnouncementCard extends StatefulWidget {
  final Announcement announcement;

  const _AnnouncementCard({required this.announcement});

  @override
  State<_AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<_AnnouncementCard> {
  bool _expanded = false;

  static const _textPrimary = Color(0xFF2D1B20);
  static const _textSecondary = Color(0xFF5A3A40);
  static const _border = Color(0xFFE8D5D0);
  static const _accent = Color(0xFFB76E79);
  static const _accentLight = Color(0xFFE8B4B8);

  @override
  Widget build(BuildContext context) {
    final a = widget.announcement;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Large image at top ──
          if (a.imageUrl != null && a.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
              child: Image.network(
                a.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 200,
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
                  height: 120,
                  color: const Color(0xFFFDF8F5),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Color(0xFFE8D5D0),
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),

          // ── Tag + date row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: a.tagColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(a.icon, color: a.tagColor, size: 18),
                ),
                const SizedBox(width: 10),
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
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  a.date,
                  style: TextStyle(
                    color: _textSecondary.withValues(alpha: 0.45),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── Title & subtitle ──
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: Text(
              a.title,
              style: TextStyle(
                fontFamily: AppTheme.playfairFamily,
                color: _textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
          if (a.subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
              child: Text(
                a.subtitle,
                style: TextStyle(
                  color: _textSecondary.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // ── Expandable body ──
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Text(
                a.body,
                style: TextStyle(
                  color: _textSecondary.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),

          // ── Read More / Less ──
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              child: Row(
                children: [
                  Text(
                    _expanded ? 'Show Less' : 'Read More',
                    style: const TextStyle(
                      color: _accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: _accent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
