import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flunexia_app/features/organizer Dashboard/screens/organizer_dashboard.dart';
import 'package:flunexia_app/features/create_trip/screens/create_trip.dart';
import 'package:flunexia_app/features/create_trip/trips_details/trips_details.dart';
import 'package:flunexia_app/features/requests/screens/requests_screen.dart';
import 'package:flunexia_app/features/profile/screens/profile_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  static const String routeName = '/my-trips';

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  final _searchController = TextEditingController();
  int _navIndex = 2;
  int _activeFilter = 0;

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

  static const _filters = ['Date', 'Need Type', 'Status'];

  static const _trips = [
    _TripItem(
      title: 'Sunset Ridge Trail',
      category: 'Hiking',
      price: '\$15 entry',
      date: 'Oct 24, 2023',
      location: 'Blue Mountains',
      joined: '8/12 Joined',
      extraIcon: Icons.handyman_outlined,
      extra: 'Bring Water',
      status: _TripStatus.confirmed,
      action: _TripAction.viewDetails,
      imageUrl:
          'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400&q=80',
    ),
    _TripItem(
      title: 'Weekly Supper Club',
      category: 'Social',
      price: 'No Fee',
      date: 'Oct 28, 2023',
      location: 'Downtown Hub',
      joined: '4/6 Joined',
      extraIcon: Icons.restaurant_outlined,
      extra: 'Appetizers',
      status: _TripStatus.pending,
      action: _TripAction.viewDetails,
      imageUrl:
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
    ),
    _TripItem(
      title: 'UI Design Sync',
      category: 'Workshop',
      price: 'Free',
      date: 'Oct 15, 2023',
      location: 'Studio 4B',
      joined: '10 Joined',
      extraIcon: Icons.laptop_mac_outlined,
      extra: 'Bring Laptop',
      status: _TripStatus.completed,
      action: _TripAction.viewRecap,
      imageUrl:
          'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=400&q=80',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _MTDesign.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _MyTripsTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Trips', style: _MTDesign.heading),
                    const SizedBox(height: 16),
                    _SearchField(controller: _searchController),
                    const SizedBox(height: 16),
                    _FilterChipsRow(
                      filters: _filters,
                      activeIndex: _activeFilter,
                      onTap: (i) => setState(() => _activeFilter = i),
                    ),
                    const SizedBox(height: 18),
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
            _MTBottomNav(
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
class _MTDesign {
  _MTDesign._();

  static const Color background = Color(0xFFF8F9FE);
  static const Color primary = Color(0xFF0052CC);
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color textGrey = Color(0xFF667085);
  static const Color border = Color(0xFFE4E7EC);
  static const Color cardBorder = Color(0xFFEAECF0);
  static const Color card = Color(0xFFFFFFFF);
  static const Color placeholder = Color(0xFF98A2B3);

  static const Color badgeConfirmedBg = Color(0xFF12B76A);
  static const Color badgePendingBg = Color(0xFFF79009);
  static const Color badgeCompletedBg = Color(0xFFE9E5F5);
  static const Color badgeCompletedText = Color(0xFF6F5DA8);

  static const Color actionBg = Color(0xFFEFF4FF);
  static const Color navInactive = Color(0xFF98A2B3);
  static const Color notificationDot = Color(0xFFF04438);

  static const double cardRadius = 16;
  static const double inputRadius = 12;
  static const double chipRadius = 999;

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

  static TextStyle get searchHint => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: placeholder,
        height: 1.3,
      );

  static TextStyle get searchText => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textDark,
        height: 1.3,
      );

  static TextStyle chipLabel(Color color, {bool active = false}) =>
      GoogleFonts.inter(
        fontSize: 13,
        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        color: color,
        height: 1.2,
      );

  static TextStyle badgeLabel(Color color) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.2,
        height: 1.2,
      );

  static TextStyle get tripTitle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.25,
      );

  static TextStyle get tripSubtitle => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.3,
      );

  static TextStyle get tripMeta => GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.3,
      );

  static TextStyle get actionLabel => GoogleFonts.inter(
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

class _MyTripsTopBar extends StatelessWidget {
  const _MyTripsTopBar();

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
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
                ),
              ),
              const SizedBox(width: 12),
              Text('Flunexia', style: _MTDesign.brandTitle),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
                color: _MTDesign.primary,
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: _MTDesign.border),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: _MTDesign.searchText,
      cursorColor: _MTDesign.primary,
      decoration: InputDecoration(
        hintText: 'Search your trips...',
        hintStyle: _MTDesign.searchHint,
        isDense: true,
        filled: true,
        fillColor: _MTDesign.card,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 14, right: 8),
          child: Icon(Icons.search, size: 20, color: _MTDesign.textGrey),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_MTDesign.inputRadius),
          borderSide: const BorderSide(color: _MTDesign.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_MTDesign.inputRadius),
          borderSide: const BorderSide(color: _MTDesign.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({
    required this.filters,
    required this.activeIndex,
    required this.onTap,
  });

  final List<String> filters;
  final int activeIndex;
  final ValueChanged<int> onTap;

  static const _icons = [
    Icons.calendar_today_outlined,
    Icons.link_outlined,
    Icons.tune,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (i) {
          final active = i == activeIndex;
          return Padding(
            padding: EdgeInsets.only(right: i == filters.length - 1 ? 0 : 10),
            child: _FilterChip(
              label: filters[i],
              icon: _icons[i],
              active: active,
              onTap: () => onTap(i),
            ),
          );
        }),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _MTDesign.primary : _MTDesign.card,
          borderRadius: BorderRadius.circular(_MTDesign.chipRadius),
          border: Border.all(
            color: active ? _MTDesign.primary : _MTDesign.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? Colors.white : _MTDesign.textDark,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: _MTDesign.chipLabel(
                active ? Colors.white : _MTDesign.textDark,
                active: active,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TripStatus { confirmed, pending, completed }

enum _TripAction { viewDetails, viewRecap }

class _TripItem {
  const _TripItem({
    required this.title,
    required this.category,
    required this.price,
    required this.date,
    required this.location,
    required this.joined,
    required this.extraIcon,
    required this.extra,
    required this.status,
    required this.action,
    required this.imageUrl,
  });

  final String title;
  final String category;
  final String price;
  final String date;
  final String location;
  final String joined;
  final IconData extraIcon;
  final String extra;
  final _TripStatus status;
  final _TripAction action;
  final String imageUrl;
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final _TripItem trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _MTDesign.card,
        borderRadius: BorderRadius.circular(_MTDesign.cardRadius),
        border: Border.all(color: _MTDesign.cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101828).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: Image.network(
                    trip.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFD0D5DD),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _StatusBadge(status: trip.status),
                        const Spacer(),
                        const Icon(Icons.content_copy_outlined,
                            size: 16, color: _MTDesign.textGrey),
                        const SizedBox(width: 12),
                        const Icon(Icons.more_vert,
                            size: 18, color: _MTDesign.textGrey),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(trip.title, style: _MTDesign.tripTitle),
                    const SizedBox(height: 4),
                    Text(
                      '${trip.category} • ${trip.price}',
                      style: _MTDesign.tripSubtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MetaGrid(
            items: [
              _MetaItem(icon: Icons.calendar_today_outlined, text: trip.date),
              _MetaItem(icon: Icons.location_on_outlined, text: trip.location),
              _MetaItem(icon: Icons.groups_outlined, text: trip.joined),
              _MetaItem(icon: trip.extraIcon, text: trip.extra),
            ],
          ),
          const SizedBox(height: 14),
          _ActionButton(
            action: trip.action,
            onPressed: trip.action == _TripAction.viewDetails
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TripDetailsScreen(),
                      ),
                    )
                : () {},
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
      case _TripStatus.confirmed:
        bg = _MTDesign.badgeConfirmedBg;
        fg = Colors.white;
        label = 'Confirmed';
      case _TripStatus.pending:
        bg = _MTDesign.badgePendingBg;
        fg = Colors.white;
        label = 'Pending';
      case _TripStatus.completed:
        bg = _MTDesign.badgeCompletedBg;
        fg = _MTDesign.badgeCompletedText;
        label = 'Completed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: _MTDesign.badgeLabel(fg)),
    );
  }
}

class _MetaItem {
  const _MetaItem({required this.icon, required this.text});
  final IconData icon;
  final String text;
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.items});

  final List<_MetaItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _MetaCell(item: items[0])),
            Expanded(child: _MetaCell(item: items[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _MetaCell(item: items[2])),
            Expanded(child: _MetaCell(item: items[3])),
          ],
        ),
      ],
    );
  }
}

class _MetaCell extends StatelessWidget {
  const _MetaCell({required this.item});

  final _MetaItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(item.icon, size: 14, color: _MTDesign.textGrey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            item.text,
            style: _MTDesign.tripMeta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action, required this.onPressed});

  final _TripAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label =
        action == _TripAction.viewDetails ? 'View Details' : 'View Recap';
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: _MTDesign.actionBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label, style: _MTDesign.actionLabel),
      ),
    );
  }
}

class _MTBottomNav extends StatelessWidget {
  const _MTBottomNav({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = <_NavBarItem>[
    _NavBarItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
    _NavBarItem(icon: Icons.add_circle_outline, label: 'Create'),
    _NavBarItem(icon: Icons.calendar_month_outlined, label: 'Trips'),
    _NavBarItem(icon: Icons.mail_outline, label: 'Requests', showDot: true),
    _NavBarItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _MTDesign.card,
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
                      _NavIcon(
                        icon: item.icon,
                        active: active,
                        showDot: item.showDot,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: _MTDesign.navLabel(
                          active ? _MTDesign.primary : _MTDesign.navInactive,
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
  const _NavBarItem({
    required this.icon,
    required this.label,
    this.showDot = false,
  });

  final IconData icon;
  final String label;
  final bool showDot;
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
      color: active ? _MTDesign.primary : _MTDesign.navInactive,
    );

    Widget child = active
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _MTDesign.primary.withValues(alpha: 0.12),
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
                color: _MTDesign.notificationDot,
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
