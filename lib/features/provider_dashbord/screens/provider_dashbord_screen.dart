import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flunexia_app/features/provider_dashbord/screens/provider_trips_screen.dart';
import 'package:flunexia_app/features/provider_dashbord/screens/provider_requests_screen.dart';
import 'package:flunexia_app/features/provider_dashbord/screens/provider_profile_screen.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  static const String routeName = '/provider-dashboard';

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  int _navIndex = 0;

  static const _trips = [
    _AvailableTrip(
      title: 'Alpine Retreat',
      client: 'Elena R.',
      dateRange: 'Dec 12 - 15',
      people: '4 People',
      badge: 'New',
      badgeStyle: _TripBadgeStyle.newRequest,
      iconUrl:
          'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=200&q=80',
    ),
    _AvailableTrip(
      title: 'Coastal Serenity',
      client: 'Marcus K.',
      dateRange: 'Jan 05 - 12',
      people: '2 People',
      badge: '2 hours ago',
      badgeStyle: _TripBadgeStyle.timeAgo,
      iconUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=200&q=80',
    ),
  ];

  void _onNavSelected(int index) {
    if (index == _navIndex) return;
    if (index == 1) {
      _replaceWith(const ProviderTripsScreen());
      return;
    }
    if (index == 2) {
      _replaceWith(const ProviderRequestsScreen());
      return;
    }
    if (index == 3) {
      _replaceWith(const ProviderProfileScreen());
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
      backgroundColor: _PDDesign.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _ProviderTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, Provider.', style: _PDDesign.greeting),
                    const SizedBox(height: 6),
                    Text(
                      'Receive trip requests and propose your services to '
                      'potential clients instantly.',
                      style: _PDDesign.greetingSubtitle,
                    ),
                    const SizedBox(height: 24),
                    const _ProviderStatsGrid(),
                    const SizedBox(height: 20),
                    const _ServiceModelReminder(),
                    const SizedBox(height: 28),
                    const _RecentTripsHeader(),
                    const SizedBox(height: 16),
                    ..._trips.map(
                      (trip) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _AvailableTripCard(trip: trip),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _ProviderBottomNav(
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
class _PDDesign {
  _PDDesign._();

  static const Color background = Color(0xFFF8F9FE);
  static const Color primary = Color(0xFF0052CC);
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color textGrey = Color(0xFF667085);
  static const Color border = Color(0xFFE4E7EC);
  static const Color cardBorder = Color(0xFFEAECF0);
  static const Color card = Color(0xFFFFFFFF);
  static const Color reminderBg = Color(0xFFEFF4FF);
  static const Color actionBg = Color(0xFFEFF4FF);
  static const Color navInactive = Color(0xFF98A2B3);

  static const Color statBlue = Color(0xFF0052CC);
  static const Color statGreen = Color(0xFF039855);
  static const Color statOrange = Color(0xFFB54708);
  static const Color statLightBlue = Color(0xFF1570EF);

  static const Color badgeNewBg = Color(0xFF12B76A);
  static const Color badgeTimeBg = Color(0xFFF2F4F7);
  static const Color badgeTimeText = Color(0xFF475467);

  static const double cardRadius = 16;
  static const double statCardRadius = 14;

  static TextStyle get brandTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.2,
      );

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
        fontSize: 10,
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

  static TextStyle get reminderTitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.3,
      );

  static TextStyle get reminderBody => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: primary,
        height: 1.45,
      );

  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.2,
      );

  static TextStyle get seeAll => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.2,
      );

  static TextStyle get tripTitle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.25,
      );

  static TextStyle get tripClient => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.3,
      );

  static TextStyle get tripMeta => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.3,
      );

  static TextStyle badgeLabel(Color color) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.2,
      );

  static TextStyle get proposeLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.2,
      );

  static TextStyle navLabel(Color color, {bool active = false}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        color: color,
        height: 1.2,
      );
}

class _ProviderTopBar extends StatelessWidget {
  const _ProviderTopBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
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
              Text('Flunexia', style: _PDDesign.brandTitle),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
                color: _PDDesign.primary,
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: _PDDesign.border),
      ],
    );
  }
}

class _ProviderStatsGrid extends StatelessWidget {
  const _ProviderStatsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.92,
      children: const [
        _StatCard(
          icon: Icons.send_outlined,
          iconColor: _PDDesign.statBlue,
          iconBg: Color(0xFFEFF4FF),
          value: '12',
          label: 'AVAILABLE REQUESTS',
        ),
        _StatCard(
          icon: Icons.pending_actions_outlined,
          iconColor: _PDDesign.statGreen,
          iconBg: Color(0xFFECFDF3),
          value: '4',
          label: 'PENDING RESPONSES',
        ),
        _StatCard(
          icon: Icons.check_circle_outline,
          iconColor: _PDDesign.statOrange,
          iconBg: Color(0xFFFFF6ED),
          value: '8',
          label: 'ACCEPTED OFFERS',
        ),
        _StatCard(
          icon: Icons.history,
          iconColor: _PDDesign.statLightBlue,
          iconBg: Color(0xFFEFF8FF),
          value: '42',
          label: 'COMPLETED BOOKINGS',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _PDDesign.card,
        borderRadius: BorderRadius.circular(_PDDesign.statCardRadius),
        border: Border.all(color: _PDDesign.cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101828).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(value, style: _PDDesign.statValue(_PDDesign.textDark)),
          const SizedBox(height: 4),
          Text(
            label,
            style: _PDDesign.statLabel(_PDDesign.textGrey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ServiceModelReminder extends StatelessWidget {
  const _ServiceModelReminder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _PDDesign.reminderBg,
        borderRadius: BorderRadius.circular(_PDDesign.cardRadius),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 0,
            top: -4,
            child: Icon(
              Icons.info_outline,
              size: 64,
              color: _PDDesign.primary.withValues(alpha: 0.12),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: _PDDesign.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lightbulb_outline,
                    size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Service Model Reminder',
                        style: _PDDesign.reminderTitle),
                    const SizedBox(height: 4),
                    Text(
                      'You do not create trips... you review details and '
                      'submit proposals based on client needs.',
                      style: _PDDesign.reminderBody,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
        Text('Recent Available Trips', style: _PDDesign.sectionTitle),
        GestureDetector(
          onTap: () {},
          child: Text('See All', style: _PDDesign.seeAll),
        ),
      ],
    );
  }
}

enum _TripBadgeStyle { newRequest, timeAgo }

class _AvailableTrip {
  const _AvailableTrip({
    required this.title,
    required this.client,
    required this.dateRange,
    required this.people,
    required this.badge,
    required this.badgeStyle,
    required this.iconUrl,
  });

  final String title;
  final String client;
  final String dateRange;
  final String people;
  final String badge;
  final _TripBadgeStyle badgeStyle;
  final String iconUrl;
}

class _AvailableTripCard extends StatelessWidget {
  const _AvailableTripCard({required this.trip});

  final _AvailableTrip trip;

  @override
  Widget build(BuildContext context) {
    final isNew = trip.badgeStyle == _TripBadgeStyle.newRequest;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _PDDesign.card,
        borderRadius: BorderRadius.circular(_PDDesign.cardRadius),
        border: Border.all(color: _PDDesign.cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101828).withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Image.network(
                  trip.iconUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 40,
                    height: 40,
                    color: const Color(0xFFD0D5DD),
                    child: const Icon(Icons.landscape_outlined,
                        size: 20, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.title, style: _PDDesign.tripTitle),
                    const SizedBox(height: 2),
                    Text('Client: ${trip.client}', style: _PDDesign.tripClient),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isNew ? _PDDesign.badgeNewBg : _PDDesign.badgeTimeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  trip.badge,
                  style: _PDDesign.badgeLabel(
                    isNew ? Colors.white : _PDDesign.badgeTimeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: _PDDesign.textGrey),
              const SizedBox(width: 6),
              Text(trip.dateRange, style: _PDDesign.tripMeta),
              const SizedBox(width: 20),
              const Icon(Icons.groups_outlined,
                  size: 14, color: _PDDesign.textGrey),
              const SizedBox(width: 6),
              Text(trip.people, style: _PDDesign.tripMeta),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: _PDDesign.actionBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Review Details & Propose',
                  style: _PDDesign.proposeLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderBottomNav extends StatelessWidget {
  const _ProviderBottomNav({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = <_NavBarItem>[
    _NavBarItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
    _NavBarItem(icon: Icons.explore_outlined, label: 'Trips'),
    _NavBarItem(icon: Icons.inbox_outlined, label: 'Requests'),
    _NavBarItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _PDDesign.card,
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
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
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
                      _ProviderNavIcon(icon: item.icon, active: active),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: _PDDesign.navLabel(
                          active ? _PDDesign.primary : _PDDesign.navInactive,
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

class _ProviderNavIcon extends StatelessWidget {
  const _ProviderNavIcon({required this.icon, required this.active});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: _PDDesign.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 22, color: Colors.white),
      );
    }

    return SizedBox(
      height: 38,
      child: Center(
        child: Icon(icon, size: 22, color: _PDDesign.navInactive),
      ),
    );
  }
}
