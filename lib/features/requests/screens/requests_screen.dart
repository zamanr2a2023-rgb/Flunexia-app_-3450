import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flunexia_app/features/organizer Dashboard/screens/organizer_dashboard.dart';
import 'package:flunexia_app/features/create_trip/screens/create_trip.dart';
import 'package:flunexia_app/features/create_trip/screens/my_trips.dart';
import 'package:flunexia_app/features/profile/screens/profile_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  static const String routeName = '/requests';

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  int _navIndex = 3;
  int _activeFilter = 0;

  static const _filters = [
    'All',
    'Pending',
    'Accepted',
    'Rejected',
    'Completed',
  ];

  static const _requests = [
    _RequestItem(
      title: 'Amalfi Coast Summer Escape',
      status: _RequestStatus.pending,
      provider: 'Luxury Linens Ltd.',
      type: 'Catering',
      serviceDate: 'August 12, 2024',
      providerIcon: Icons.person_outline,
      typeIcon: Icons.restaurant_outlined,
    ),
    _RequestItem(
      title: 'Swiss Alps Hiking Retreat',
      status: _RequestStatus.accepted,
      provider: 'Peak Guides Co.',
      type: 'Adventure',
      serviceDate: 'Sept 05, 2024',
      providerIcon: Icons.hiking_outlined,
      typeIcon: Icons.terrain_outlined,
    ),
    _RequestItem(
      title: 'Kyoto Cherry Blossom Tour',
      status: _RequestStatus.completed,
      provider: 'Nippon Travel Experts',
      type: 'City Tour',
      serviceDate: 'April 14, 2024',
      providerIcon: Icons.person_outline,
      typeIcon: Icons.location_city_outlined,
    ),
    _RequestItem(
      title: 'Berlin Underground Art Trip',
      status: _RequestStatus.rejected,
      provider: 'Urban Art Tours',
      type: 'Culture',
      serviceDate: 'June 20, 2024',
      providerIcon: Icons.person_outline,
      typeIcon: Icons.palette_outlined,
      errorMessage:
          'Service unavailable for selected dates. Tap to refresh.',
    ),
  ];

  void _onNavSelected(int index) {
    if (index == _navIndex) return;
    if (index == 0) {
      _replaceWith(const OrganizerDashboard());
      return;
    }
    if (index == 1) {
      _replaceWith(const CreateTripScreen());
      return;
    }
    if (index == 2) {
      _replaceWith(const MyTripsScreen());
      return;
    }
    if (index == 4) {
      _replaceWith(const ProfileScreen());
      return;
    }
    setState(() => _navIndex = index);
  }

  void _replaceWith(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  List<_RequestItem> get _filteredRequests {
    if (_activeFilter == 0) return _requests;
    final status = switch (_activeFilter) {
      1 => _RequestStatus.pending,
      2 => _RequestStatus.accepted,
      3 => _RequestStatus.rejected,
      4 => _RequestStatus.completed,
      _ => null,
    };
    return _requests.where((r) => r.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ReqDesign.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _RequestsTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Requests / Bookings', style: _ReqDesign.heading),
                    const SizedBox(height: 6),
                    Text(
                      'Manage your upcoming trip logistics.',
                      style: _ReqDesign.subtitle,
                    ),
                    const SizedBox(height: 20),
                    _FilterTabBar(
                      filters: _filters,
                      activeIndex: _activeFilter,
                      onTap: (i) => setState(() => _activeFilter = i),
                    ),
                    const SizedBox(height: 20),
                    ..._filteredRequests.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _RequestCard(item: item),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _ReqBottomNav(
              selectedIndex: _navIndex,
              onSelected: _onNavSelected,
            ),
          ],
        ),
      ),
    );
  }
}

/// Design tokens scoped to this screen only.
class _ReqDesign {
  _ReqDesign._();

  static const Color background = Color(0xFFF8F9FE);
  static const Color primary = Color(0xFF0052CC);
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color textGrey = Color(0xFF667085);
  static const Color border = Color(0xFFE4E7EC);
  static const Color cardBorder = Color(0xFFEAECF0);
  static const Color card = Color(0xFFFFFFFF);
  static const Color navInactive = Color(0xFF98A2B3);
  static const Color notificationDot = Color(0xFFF04438);

  static const Color pendingBg = Color(0xFFFFF6ED);
  static const Color pendingText = Color(0xFFB54708);
  static const Color acceptedBg = Color(0xFFECFDF3);
  static const Color acceptedText = Color(0xFF027A48);
  static const Color completedBg = Color(0xFFE9E5F5);
  static const Color completedText = Color(0xFF6F5DA8);
  static const Color rejectedBg = Color(0xFFFEE4E2);
  static const Color rejectedText = Color(0xFFB42318);
  static const Color completedCardText = Color(0xFF98A2B3);
  static const Color markCompleted = Color(0xFF039855);
  static const Color errorBoxBg = Color(0xFFFEF3F2);
  static const Color errorBoxText = Color(0xFFB42318);

  static const double cardRadius = 20;

  static TextStyle get eyebrow => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textGrey,
        letterSpacing: 1.0,
        height: 1.2,
      );

  static TextStyle get brandTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.2,
      );

  static TextStyle get heading => GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.2,
        letterSpacing: -0.3,
      );

  static TextStyle get subtitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.45,
      );

  static TextStyle tabLabel(Color color, {bool active = false}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        color: color,
        height: 1.2,
      );

  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.3,
      );

  static TextStyle get cardTitleMuted => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: completedCardText,
        height: 1.3,
      );

  static TextStyle get metaLabel => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: textGrey,
        letterSpacing: 0.5,
        height: 1.2,
      );

  static TextStyle get metaValue => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textDark,
        height: 1.3,
      );

  static TextStyle get metaValueMuted => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: completedCardText,
        height: 1.3,
      );

  static TextStyle badgeLabel(Color color) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.6,
        height: 1.2,
      );

  static TextStyle get acceptLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get rejectLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textDark,
        height: 1.2,
      );

  static TextStyle get markCompletedLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get errorText => GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: errorBoxText,
        height: 1.35,
      );

  static TextStyle navLabel(Color color, {bool active = false}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        color: color,
        height: 1.2,
      );
}

enum _RequestStatus { pending, accepted, completed, rejected }

class _RequestItem {
  const _RequestItem({
    required this.title,
    required this.status,
    required this.provider,
    required this.type,
    required this.serviceDate,
    required this.providerIcon,
    required this.typeIcon,
    this.errorMessage,
  });

  final String title;
  final _RequestStatus status;
  final String provider;
  final String type;
  final String serviceDate;
  final IconData providerIcon;
  final IconData typeIcon;
  final String? errorMessage;
}

class _RequestsTopBar extends StatelessWidget {
  const _RequestsTopBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          child: Center(child: Text('ORGANIZERS', style: _ReqDesign.eyebrow)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFE4E7EC),
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
                ),
              ),
              const SizedBox(width: 12),
              Text('Flunexia', style: _ReqDesign.brandTitle),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.tune, size: 22),
                color: _ReqDesign.textDark,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined, size: 24),
                    color: _ReqDesign.primary,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: _ReqDesign.notificationDot,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: _ReqDesign.border),
      ],
    );
  }
}

class _FilterTabBar extends StatelessWidget {
  const _FilterTabBar({
    required this.filters,
    required this.activeIndex,
    required this.onTap,
  });

  final List<String> filters;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (i) {
          final active = i == activeIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(right: i == filters.length - 1 ? 0 : 20),
              child: Column(
                children: [
                  Text(
                    filters[i],
                    style: _ReqDesign.tabLabel(
                      active ? _ReqDesign.primary : _ReqDesign.textGrey,
                      active: active,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 2,
                    width: active ? 28 : 0,
                    decoration: BoxDecoration(
                      color: _ReqDesign.primary,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.item});

  final _RequestItem item;

  bool get _isMuted => item.status == _RequestStatus.completed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isMuted ? 0.72 : 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _ReqDesign.card,
          borderRadius: BorderRadius.circular(_ReqDesign.cardRadius),
          border: Border.all(color: _ReqDesign.cardBorder),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF101828).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: _isMuted
                        ? _ReqDesign.cardTitleMuted
                        : _ReqDesign.cardTitle,
                  ),
                ),
                _StatusBadge(status: item.status),
              ],
            ),
            const SizedBox(height: 16),
            if (item.status == _RequestStatus.pending) ...[
              _MetaRow(
                label: 'PROVIDER',
                value: item.provider,
                icon: item.providerIcon,
              ),
              const SizedBox(height: 10),
              _MetaRow(
                label: 'TYPE',
                value: item.type,
                icon: item.typeIcon,
              ),
              const SizedBox(height: 10),
              _MetaRow(
                label: 'SERVICE DATE',
                value: item.serviceDate,
                icon: Icons.calendar_today_outlined,
              ),
            ] else ...[
              _MetaRow(
                label: 'PROVIDER',
                value: item.provider,
                icon: item.providerIcon,
                muted: _isMuted,
              ),
              const SizedBox(height: 10),
              _MetaRow(
                label: 'DATE',
                value: item.serviceDate,
                icon: Icons.calendar_today_outlined,
                muted: _isMuted,
              ),
            ],
            if (item.status == _RequestStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _ReqDesign.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Accept', style: _ReqDesign.acceptLabel),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _ReqDesign.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Text('Reject', style: _ReqDesign.rejectLabel),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: _ReqDesign.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Icon(Icons.visibility_outlined,
                          size: 18, color: _ReqDesign.textGrey),
                    ),
                  ),
                ],
              ),
            ],
            if (item.status == _RequestStatus.accepted) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check, size: 18, color: Colors.white),
                  label: Text('Mark Completed',
                      style: _ReqDesign.markCompletedLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ReqDesign.markCompleted,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
            if (item.errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _ReqDesign.errorBoxBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 16, color: _ReqDesign.errorBoxText),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.errorMessage!,
                          style: _ReqDesign.errorText),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final _RequestStatus status;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String label;

    switch (status) {
      case _RequestStatus.pending:
        bg = _ReqDesign.pendingBg;
        fg = _ReqDesign.pendingText;
        label = 'PENDING';
      case _RequestStatus.accepted:
        bg = _ReqDesign.acceptedBg;
        fg = _ReqDesign.acceptedText;
        label = 'ACCEPTED';
      case _RequestStatus.completed:
        bg = _ReqDesign.completedBg;
        fg = _ReqDesign.completedText;
        label = 'COMPLETED';
      case _RequestStatus.rejected:
        bg = _ReqDesign.rejectedBg;
        fg = _ReqDesign.rejectedText;
        label = 'REJECTED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: _ReqDesign.badgeLabel(fg)),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    required this.icon,
    this.muted = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final iconColor = muted ? _ReqDesign.completedCardText : _ReqDesign.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: _ReqDesign.metaLabel),
              const SizedBox(height: 2),
              Text(
                value,
                style: muted ? _ReqDesign.metaValueMuted : _ReqDesign.metaValue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReqBottomNav extends StatelessWidget {
  const _ReqBottomNav({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = <_NavBarItem>[
    _NavBarItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
    _NavBarItem(icon: Icons.add_circle_outline, label: 'Create'),
    _NavBarItem(icon: Icons.calendar_month_outlined, label: 'Trips'),
    _NavBarItem(icon: Icons.inbox, label: 'Requests'),
    _NavBarItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _ReqDesign.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101828).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final active = selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NavIcon(icon: item.icon, active: active),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: _ReqDesign.navLabel(
                          active ? _ReqDesign.primary : _ReqDesign.navInactive,
                          active: active,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem {
  const _NavBarItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.active});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: 22,
      color: active ? _ReqDesign.primary : _ReqDesign.navInactive,
    );

    if (active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: _ReqDesign.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: iconWidget,
      );
    }

    return SizedBox(height: 34, child: Center(child: iconWidget));
  }
}
