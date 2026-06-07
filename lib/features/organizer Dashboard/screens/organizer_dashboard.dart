import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flunexia_app/features/organizer Dashboard/data/analytics_repository.dart';
import 'package:flunexia_app/features/organizer Dashboard/data/models/dashboard_model.dart';
import 'package:flunexia_app/features/create_trip/screens/create_trip.dart';
import 'package:flunexia_app/features/create_trip/screens/my_trips.dart';
import 'package:flunexia_app/features/create_trip/trips_details/trips_details.dart';
import 'package:flunexia_app/features/requests/screens/requests_screen.dart';
import 'package:flunexia_app/features/profile/screens/profile_screen.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  final _analyticsRepository = AnalyticsRepository();
  int _navIndex = 0;
  bool _isLoading = true;
  DashboardStatsModel _stats = const DashboardStatsModel(
    trips: 0,
    pendingRequests: 0,
    acceptedOffers: 0,
    completedBookings: 0,
  );
  List<_TripItem> _recentTrips = const [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);

    try {
      final dashboard = await _analyticsRepository.fetchMobileDashboard();
      if (!mounted) return;

      setState(() {
        _stats = dashboard.stats;
        _unreadCount = dashboard.unreadCount;
        _recentTrips = dashboard.recentTrips.map(_mapTrip).toList();
      });
    } on DashboardException catch (error) {
      if (!mounted) return;
      _showMessage(context, error.message);
    } catch (error) {
      if (!mounted) return;
      _showMessage(context, 'Failed to load dashboard. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  _TripItem _mapTrip(DashboardTripModel trip) {
    return _TripItem(
      id: trip.id,
      title: trip.title,
      date: _formatDate(trip.startDate),
      category: trip.location.isNotEmpty
          ? trip.location
          : (trip.needTypes.isNotEmpty ? trip.needTypes.first : 'Trip'),
      status: _mapTripStatus(trip.status),
      imageUrl: trip.image ??
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  _TripStatus _mapTripStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _TripStatus.pending;
      case 'completed':
        return _TripStatus.completed;
      default:
        return _TripStatus.active;
    }
  }

  void _onNavSelected(int index) {
    if (index == _navIndex) return;
    if (index == 1) {
      _replaceWith(const CreateTripScreen());
      return;
    }
    if (index == 2) {
      _replaceWith(const MyTripsScreen());
      return;
    }
    if (index == 3) {
      _replaceWith(const RequestsScreen());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DashboardDesign.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _DashboardTopBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello, Organizer.',
                              style: _DashboardDesign.greeting),
                          const SizedBox(height: 6),
                          Text(
                            'Manage your group outings in one place.',
                            style: _DashboardDesign.greetingSubtitle,
                          ),
                          const SizedBox(height: 24),
                          _StatsGrid(stats: _stats),
                          const SizedBox(height: 20),
                          _CreateTripButton(
                            onPressed: () => _replaceWith(const CreateTripScreen()),
                          ),
                          const SizedBox(height: 28),
                          const _RecentTripsHeader(),
                          const SizedBox(height: 16),
                          if (_recentTrips.isEmpty)
                            Text(
                              'No recent trips yet.',
                              style: _DashboardDesign.tripMeta,
                            )
                          else
                            ..._recentTrips.map(
                              (trip) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _TripCard(trip: trip),
                              ),
                            ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
            ),
            _DashboardBottomNav(
              selectedIndex: _navIndex,
              onSelected: _onNavSelected,
              showRequestsDot: _unreadCount > 0,
            ),
          ],
        ),
      ),
    );
  }
}

/// Design tokens scoped to this screen only.
class _DashboardDesign {
  _DashboardDesign._();

  static const Color background = Color(0xFFF8F9FE);
  static const Color primary = Color(0xFF0052CC);
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color textGrey = Color(0xFF667085);
  static const Color border = Color(0xFFE4E7EC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color statOrange = Color(0xFFB54708);
  static const Color statGreen = Color(0xFF039855);
  static const Color badgeActive = Color(0xFF12B76A);
  static const Color badgePending = Color(0xFFF79009);
  static const Color badgeCompletedBg = Color(0xFFE4E7EC);
  static const Color badgeCompletedText = Color(0xFF344054);
  static const Color navInactive = Color(0xFF98A2B3);
  static const Color notificationDot = Color(0xFFF04438);

  static const double statCardRadius = 12;
  static const double tripCardRadius = 16;
  static const double navBarTopRadius = 24;

  static TextStyle get greeting => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.2,
        letterSpacing: -0.3,
      );

  static TextStyle get greetingSubtitle => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.45,
      );

  static TextStyle statLabel(Color color) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.6,
        height: 1.3,
      );

  static TextStyle statValue(Color color) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.1,
      );

  static TextStyle get brandTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.2,
      );

  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.2,
      );

  static TextStyle get viewAll => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.2,
      );

  static TextStyle get createTripLabel => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get tripTitle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.3,
      );

  static TextStyle get tripMeta => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.3,
      );

  static TextStyle get viewDetails => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.2,
      );

  static TextStyle badgeLabel(Color color) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.4,
        height: 1.2,
      );

  static TextStyle navLabel(Color color, {bool active = false}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        color: color,
        height: 1.2,
      );
}

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFE4E7EC),
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
                ),
              ),
              const SizedBox(width: 12),
              Text('Flunexia', style: _DashboardDesign.brandTitle),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
                color: _DashboardDesign.primary,
                iconSize: 26,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: _DashboardDesign.border),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final DashboardStatsModel stats;

  String _formatCount(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _StatCard(
          label: 'CREATED TRIPS',
          value: stats.trips.toString(),
          valueColor: _DashboardDesign.primary,
        ),
        _StatCard(
          label: 'PENDING REQUESTS',
          value: _formatCount(stats.pendingRequests),
          valueColor: _DashboardDesign.statOrange,
        ),
        _StatCard(
          label: 'ACCEPTED OFFERS',
          value: _formatCount(stats.acceptedOffers),
          valueColor: _DashboardDesign.statGreen,
        ),
        _StatCard(
          label: 'COMPLETED BOOKINGS',
          value: stats.completedBookings.toString(),
          valueColor: _DashboardDesign.textDark,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DashboardDesign.card,
        borderRadius: BorderRadius.circular(_DashboardDesign.statCardRadius),
        border: Border.all(color: _DashboardDesign.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: _DashboardDesign.statLabel(_DashboardDesign.textGrey)),
          const SizedBox(height: 8),
          Text(value, style: _DashboardDesign.statValue(valueColor)),
        ],
      ),
    );
  }
}

class _CreateTripButton extends StatelessWidget {
  const _CreateTripButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _DashboardDesign.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(Icons.add, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text('Create a Trip', style: _DashboardDesign.createTripLabel),
          ],
        ),
      ),
    );
  }
}

class _RecentTripsHeader extends StatelessWidget {
  const _RecentTripsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Recent Trips', style: _DashboardDesign.sectionTitle),
        GestureDetector(
          onTap: () {},
          child: Text('View All', style: _DashboardDesign.viewAll),
        ),
      ],
    );
  }
}

enum _TripStatus { active, pending, completed }

class _TripItem {
  const _TripItem({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.status,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String date;
  final String category;
  final _TripStatus status;
  final String imageUrl;
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final _TripItem trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DashboardDesign.card,
        borderRadius: BorderRadius.circular(_DashboardDesign.tripCardRadius),
        border: Border.all(color: _DashboardDesign.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101828).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  trip.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFD0D5DD),
                    child: const Icon(Icons.landscape_outlined, size: 48, color: Colors.white54),
                  ),
                ),
              ),
              Positioned(top: 12, right: 12, child: _StatusBadge(status: trip.status)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.title, style: _DashboardDesign.tripTitle),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: _DashboardDesign.textGrey),
                    const SizedBox(width: 6),
                    Text(trip.date, style: _DashboardDesign.tripMeta),
                    const SizedBox(width: 16),
                    Icon(Icons.explore_outlined, size: 14, color: _DashboardDesign.textGrey),
                    const SizedBox(width: 6),
                    Expanded(child: Text(trip.category, style: _DashboardDesign.tripMeta)),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: _DashboardDesign.border),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    if (trip.id.isEmpty) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TripDetailsScreen(tripId: trip.id),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('View Details', style: _DashboardDesign.viewDetails),
                      Icon(Icons.chevron_right, size: 20, color: _DashboardDesign.primary),
                    ],
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final _TripStatus status;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String label;

    switch (status) {
      case _TripStatus.active:
        bg = _DashboardDesign.badgeActive;
        fg = Colors.white;
        label = 'ACTIVE';
      case _TripStatus.pending:
        bg = _DashboardDesign.badgePending;
        fg = Colors.white;
        label = 'PENDING';
      case _TripStatus.completed:
        bg = _DashboardDesign.badgeCompletedBg;
        fg = _DashboardDesign.badgeCompletedText;
        label = 'COMPLETED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: _DashboardDesign.badgeLabel(fg)),
    );
  }
}

class _NavBarItem {
  const _NavBarItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class _DashboardBottomNav extends StatelessWidget {
  const _DashboardBottomNav({
    required this.selectedIndex,
    required this.onSelected,
    required this.showRequestsDot,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool showRequestsDot;

  static const _items = <_NavBarItem>[
    _NavBarItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
    _NavBarItem(icon: Icons.add_circle_outline, label: 'Create'),
    _NavBarItem(icon: Icons.calendar_month_outlined, label: 'Trips'),
    _NavBarItem(icon: Icons.mail_outline, label: 'Requests'),
    _NavBarItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DashboardDesign.card,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(_DashboardDesign.navBarTopRadius),
        ),
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
                      _NavIcon(
                        icon: item.icon,
                        active: active,
                        showDot: item.label == 'Requests' && showRequestsDot,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: _DashboardDesign.navLabel(
                          active ? _DashboardDesign.primary : _DashboardDesign.navInactive,
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

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.active,
    required this.showDot,
  });

  final IconData icon;
  final bool active;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: 22,
      color: active ? _DashboardDesign.primary : _DashboardDesign.navInactive,
    );

    Widget child = active
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _DashboardDesign.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: iconWidget,
          )
        : SizedBox(height: 34, child: Center(child: iconWidget));

    if (showDot) {
      child = Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned(
            top: active ? 4 : 2,
            right: active ? 10 : 14,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: _DashboardDesign.notificationDot,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      );
    }

    return child;
  }
}
