import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flunexia_app/features/provider_dashbord/screens/provider_dashbord_screen.dart';
import 'package:flunexia_app/features/provider_dashbord/screens/provider_trips_screen.dart';
import 'package:flunexia_app/features/provider_dashbord/screens/provider_profile_screen.dart';

class ProviderRequestsScreen extends StatefulWidget {
  const ProviderRequestsScreen({super.key});

  static const String routeName = '/provider-requests';

  @override
  State<ProviderRequestsScreen> createState() => _ProviderRequestsScreenState();
}

class _ProviderRequestsScreenState extends State<ProviderRequestsScreen> {
  int _navIndex = 2;

  void _onNavSelected(int index) {
    if (index == _navIndex) return;
    if (index == 0) {
      _replaceWith(const ProviderDashboardScreen());
      return;
    }
    if (index == 1) {
      _replaceWith(const ProviderTripsScreen());
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
      backgroundColor: _PRDesign.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _ProviderRequestsTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeroRequestCard(),
                    const SizedBox(height: 16),
                    const _OrganizerBar(),
                    const SizedBox(height: 16),
                    const _TripDetailsGrid(),
                    const SizedBox(height: 24),
                    Text('Trip Description', style: _PRDesign.sectionHeading),
                    const SizedBox(height: 10),
                    Text(
                      'Looking for an experienced outdoor guide to lead a '
                      'medium-sized group through the hidden trails of Lake '
                      'Como. The expedition includes a sunset peak climb '
                      'followed by a catered alpine dinner.',
                      style: _PRDesign.bodyText,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Requirements: Professional certification, knowledge of '
                      'local historical landmarks, and the ability to '
                      'coordinate transport for the participants from the '
                      'base camp.',
                      style: _PRDesign.bodyText,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _PRDesign.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(_PRDesign.buttonRadius),
                          ),
                        ),
                        child:
                            Text('Submit Proposal', style: _PRDesign.primaryBtn),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _PRBottomNav(
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
class _PRDesign {
  _PRDesign._();

  static const Color background = Color(0xFFF8F9FE);
  static const Color primary = Color(0xFF0052CC);
  static const Color textDark = Color(0xFF09101D);
  static const Color textGrey = Color(0xFF858EA9);
  static const Color border = Color(0xFFE4E7EC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color navInactive = Color(0xFF98A2B3);
  static const Color infoCardBg = Color(0xFFF0F7FF);
  static const Color chatBtnBg = Color(0xFFE8F1FF);

  static const double cardRadius = 24;
  static const double buttonRadius = 30;
  static const double infoCardRadius = 16;

  static TextStyle get brandName => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.2,
      );

  static TextStyle get activeBadge => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.8,
        height: 1.2,
      );

  static TextStyle get heroTitle => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.25,
        letterSpacing: -0.2,
      );

  static TextStyle get organizerLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.2,
      );

  static TextStyle get organizerName => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.2,
      );

  static TextStyle get infoLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.2,
      );

  static TextStyle get infoValue => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.25,
      );

  static TextStyle get sectionHeading => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.3,
      );

  static TextStyle get bodyText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.55,
      );

  static TextStyle get primaryBtn => GoogleFonts.inter(
        fontSize: 16,
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

class _ProviderRequestsTopBar extends StatelessWidget {
  const _ProviderRequestsTopBar();

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
              Text('Flunexia', style: _PRDesign.brandName),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
                color: _PRDesign.primary,
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: _PRDesign.border),
      ],
    );
  }
}

class _HeroRequestCard extends StatelessWidget {
  const _HeroRequestCard();

  static const _imageUrl =
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_PRDesign.cardRadius),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFE4E7EC),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  stops: const [0.35, 0.65, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('ACTIVE REQUEST', style: _PRDesign.activeBadge),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Sunset Alpine Expedition', style: _PRDesign.heroTitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganizerBar extends StatelessWidget {
  const _OrganizerBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _PRDesign.card,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: _PRDesign.border),
      ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Organizer', style: _PRDesign.organizerLabel),
                const SizedBox(height: 2),
                Text('Sarah Jenkins', style: _PRDesign.organizerName),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _PRDesign.chatBtnBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline),
              color: _PRDesign.primary,
              iconSize: 20,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripDetailsGrid extends StatelessWidget {
  const _TripDetailsGrid();

  static const _items = [
    _InfoItem(
      icon: Icons.calendar_today_outlined,
      label: 'Date',
      value: 'Oct 24 - 26, 2024',
    ),
    _InfoItem(
      icon: Icons.location_on_outlined,
      label: 'Location',
      value: 'Lake Como, Italy',
    ),
    _InfoItem(
      icon: Icons.groups_outlined,
      label: 'Participants',
      value: '12 People',
    ),
    _InfoItem(
      icon: Icons.category_outlined,
      label: 'Need Type',
      value: 'Guided Hiking',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) => _InfoCard(item: _items[index]),
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.item});

  final _InfoItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _PRDesign.infoCardBg,
        borderRadius: BorderRadius.circular(_PRDesign.infoCardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 20, color: _PRDesign.primary),
          const Spacer(),
          Text(item.label, style: _PRDesign.infoLabel),
          const SizedBox(height: 4),
          Text(item.value, style: _PRDesign.infoValue),
        ],
      ),
    );
  }
}

class _PRBottomNav extends StatelessWidget {
  const _PRBottomNav({
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
        color: _PRDesign.card,
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
                      _PRNavIcon(icon: item.icon, active: active),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: _PRDesign.navLabel(
                          active ? _PRDesign.primary : _PRDesign.navInactive,
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

class _PRNavIcon extends StatelessWidget {
  const _PRNavIcon({required this.icon, required this.active});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: _PRDesign.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 22, color: Colors.white),
      );
    }

    return SizedBox(
      height: 38,
      child: Center(
        child: Icon(icon, size: 22, color: _PRDesign.navInactive),
      ),
    );
  }
}
