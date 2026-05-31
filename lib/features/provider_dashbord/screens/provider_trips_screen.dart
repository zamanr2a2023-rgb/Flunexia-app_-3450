import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flunexia_app/features/provider_dashbord/screens/provider_dashbord_screen.dart';
import 'package:flunexia_app/features/provider_dashbord/screens/provider_requests_screen.dart';
import 'package:flunexia_app/features/provider_dashbord/screens/provider_profile_screen.dart';

class ProviderTripsScreen extends StatefulWidget {
  const ProviderTripsScreen({super.key});

  static const String routeName = '/provider-trips';

  @override
  State<ProviderTripsScreen> createState() => _ProviderTripsScreenState();
}

class _ProviderTripsScreenState extends State<ProviderTripsScreen> {
  int _navIndex = 1;
  int _activeChip = 0;

  static const _trips = [
    _AvailableTrip(
      title: 'Summer Retreat 2024',
      price: r'$4,200 Est.',
      organizer: 'Sarah Jenkins (Organizer)',
      dates: 'Aug 12 - Aug 18, 2024',
      location: 'Santorini, Greece',
      groupSize: '12 pax',
      serviceType: 'Full Service',
      badge: 'Urgent',
      badgeStyle: _TripBadgeStyle.urgent,
      imageUrl:
          'https://images.unsplash.com/photo-1613395877344-13d4a8e0d49e?w=800&q=80',
    ),
    _AvailableTrip(
      title: 'Corporate Wellness Weekend',
      price: r'$1,850 Est.',
      organizer: 'David Chen (Organizer)',
      dates: 'Oct 24 - Oct 26, 2024',
      location: 'Aspen, Colorado',
      groupSize: '45 pax',
      serviceType: 'Transport',
      badge: 'Flexible',
      badgeStyle: _TripBadgeStyle.flexible,
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
    ),
    _AvailableTrip(
      title: 'Autumn Adventure',
      price: r'$980 Est.',
      organizer: 'Emily Blunt (Organizer)',
      dates: 'Nov 02 - Nov 05, 2024',
      location: 'Kyoto, Japan',
      groupSize: '8 pax',
      serviceType: 'Transport',
      badge: 'New',
      badgeStyle: _TripBadgeStyle.newTrip,
      imageUrl:
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800&q=80',
    ),
  ];

  void _onNavSelected(int index) {
    if (index == _navIndex) return;
    if (index == 0) {
      _replaceWith(const ProviderDashboardScreen());
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
      backgroundColor: _PTDesign.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _ProviderTripsTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available Trips', style: _PTDesign.heading),
                    const SizedBox(height: 6),
                    Text(
                      'Browse outing requests and submit your offer.',
                      style: _PTDesign.subtitle,
                    ),
                    const SizedBox(height: 20),
                    const _SearchBar(),
                    const SizedBox(height: 14),
                    _FilterChipsRow(
                      activeIndex: _activeChip,
                      onTap: (i) => setState(() => _activeChip = i),
                    ),
                    const SizedBox(height: 20),
                    ..._trips.map(
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
            _PTBottomNav(
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
class _PTDesign {
  _PTDesign._();

  static const Color background = Color(0xFFF8F9FE);
  static const Color primary = Color(0xFF2D60FF);
  static const Color textDark = Color(0xFF09101D);
  static const Color textGrey = Color(0xFF858EA9);
  static const Color border = Color(0xFFE4E7EC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color navInactive = Color(0xFF98A2B3);
  static const Color tagBg = Color(0xFFF0F3FA);
  static const Color tagText = Color(0xFF667085);

  static const Color urgentBg = Color(0xFFECFDF3);
  static const Color urgentText = Color(0xFF027A48);
  static const Color flexibleBg = Color(0xFFFFF6ED);
  static const Color flexibleText = Color(0xFFB54708);

  static const double cardRadius = 24;
  static const double buttonRadius = 30;
  static const double searchRadius = 15;

  static TextStyle get brandName => GoogleFonts.inter(
        fontSize: 16,
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

  static TextStyle get searchHint => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.2,
      );

  static TextStyle chipLabel(Color color, {bool active = false}) =>
      GoogleFonts.inter(
        fontSize: 13,
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

  static TextStyle get cardPrice => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.2,
      );

  static TextStyle get detailText => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.35,
      );

  static TextStyle get tagLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: tagText,
        height: 1.2,
      );

  static TextStyle badgeLabel(Color color) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.2,
      );

  static TextStyle get primaryBtn => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
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

enum _TripBadgeStyle { urgent, flexible, newTrip }

class _AvailableTrip {
  const _AvailableTrip({
    required this.title,
    required this.price,
    required this.organizer,
    required this.dates,
    required this.location,
    required this.groupSize,
    required this.serviceType,
    required this.badge,
    required this.badgeStyle,
    required this.imageUrl,
  });

  final String title;
  final String price;
  final String organizer;
  final String dates;
  final String location;
  final String groupSize;
  final String serviceType;
  final String badge;
  final _TripBadgeStyle badgeStyle;
  final String imageUrl;
}

class _ProviderTripsTopBar extends StatelessWidget {
  const _ProviderTripsTopBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFE4E7EC),
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
                ),
              ),
              const SizedBox(width: 10),
              Text('Flunexia', style: _PTDesign.brandName),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
                color: _PTDesign.textDark,
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: _PTDesign.border),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _PTDesign.card,
        borderRadius: BorderRadius.circular(_PTDesign.searchRadius),
        border: Border.all(color: _PTDesign.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search, size: 20, color: _PTDesign.textGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search destinations or types...',
              style: _PTDesign.searchHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({
    required this.activeIndex,
    required this.onTap,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;

  static const _chips = [
    _ChipData(label: 'Any Date', icon: Icons.calendar_today_outlined),
    _ChipData(label: 'Need Type', icon: Icons.category_outlined),
    _ChipData(label: 'Group Size', icon: Icons.groups_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_chips.length, (i) {
                final chip = _chips[i];
                final active = i == activeIndex;
                return Padding(
                  padding: EdgeInsets.only(right: i == _chips.length - 1 ? 0 : 8),
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: active ? _PTDesign.primary : _PTDesign.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: active ? _PTDesign.primary : _PTDesign.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            chip.icon,
                            size: 16,
                            color: active ? Colors.white : _PTDesign.textGrey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            chip.label,
                            style: _PTDesign.chipLabel(
                              active ? Colors.white : _PTDesign.textDark,
                              active: active,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _PTDesign.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _PTDesign.border),
          ),
          child: Icon(Icons.tune, size: 20, color: _PTDesign.textGrey),
        ),
      ],
    );
  }
}

class _ChipData {
  const _ChipData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final _AvailableTrip trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _PTDesign.card,
        borderRadius: BorderRadius.circular(_PTDesign.cardRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101828).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
                    color: const Color(0xFFE4E7EC),
                    child: const Icon(Icons.image_outlined, size: 48),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _TripBadge(
                  label: trip.badge,
                  style: trip.badgeStyle,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(trip.title, style: _PTDesign.cardTitle),
                    ),
                    const SizedBox(width: 8),
                    Text(trip.price, style: _PTDesign.cardPrice),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.person_outline,
                  text: trip.organizer,
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  text: trip.dates,
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  text: trip.location,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _TagChip(
                      icon: Icons.groups_outlined,
                      label: trip.groupSize,
                    ),
                    const SizedBox(width: 8),
                    _TagChip(
                      icon: trip.serviceType == 'Transport'
                          ? Icons.directions_bus_outlined
                          : Icons.work_outline,
                      label: trip.serviceType,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _PTDesign.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(_PTDesign.buttonRadius),
                      ),
                    ),
                    child: Text('View Details', style: _PTDesign.primaryBtn),
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

class _TripBadge extends StatelessWidget {
  const _TripBadge({required this.label, required this.style});

  final String label;
  final _TripBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final Border? border;

    switch (style) {
      case _TripBadgeStyle.urgent:
        bg = _PTDesign.urgentBg;
        fg = _PTDesign.urgentText;
        border = null;
      case _TripBadgeStyle.flexible:
        bg = _PTDesign.flexibleBg;
        fg = _PTDesign.flexibleText;
        border = null;
      case _TripBadgeStyle.newTrip:
        bg = Colors.white;
        fg = _PTDesign.textDark;
        border = Border.all(color: _PTDesign.border);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: border,
      ),
      child: Text(label, style: _PTDesign.badgeLabel(fg)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _PTDesign.textGrey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: _PTDesign.detailText)),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _PTDesign.tagBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _PTDesign.tagText),
          const SizedBox(width: 5),
          Text(label, style: _PTDesign.tagLabel),
        ],
      ),
    );
  }
}

class _PTBottomNav extends StatelessWidget {
  const _PTBottomNav({
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
        color: _PTDesign.card,
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
                      _PTNavIcon(icon: item.icon, active: active),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: _PTDesign.navLabel(
                          active ? _PTDesign.primary : _PTDesign.navInactive,
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

class _PTNavIcon extends StatelessWidget {
  const _PTNavIcon({required this.icon, required this.active});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: _PTDesign.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 22, color: Colors.white),
      );
    }

    return SizedBox(
      height: 38,
      child: Center(
        child: Icon(icon, size: 22, color: _PTDesign.navInactive),
      ),
    );
  }
}
