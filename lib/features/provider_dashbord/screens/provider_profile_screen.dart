import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flunexia_app/features/auth/screens/login_screen.dart';
import 'package:flunexia_app/features/provider_dashbord/screens/provider_dashbord_screen.dart';
import 'package:flunexia_app/features/provider_dashbord/screens/provider_trips_screen.dart';
import 'package:flunexia_app/features/provider_dashbord/screens/provider_requests_screen.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  static const String routeName = '/provider-profile';

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final _nameController = TextEditingController(text: 'Alexander Sterling');
  final _emailController =
      TextEditingController(text: 'alexander@lumina-services.com');
  final _descriptionController = TextEditingController(
    text:
        'Premium boutique accommodation provider specializing in sustainable '
        'luxury experiences across Western Europe...',
  );

  int _navIndex = 3;
  int _providerType = 0;

  static const _providerTypes = [
    (icon: Icons.bed_outlined, label: 'Hotel'),
    (icon: Icons.restaurant_outlined, label: 'Restaurant'),
    (icon: Icons.directions_bus_outlined, label: 'Transport'),
    (icon: Icons.local_activity_outlined, label: 'Activity'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
    if (index == 2) {
      _replaceWith(const ProviderRequestsScreen());
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

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _PPDesign.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _ProviderProfileTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  children: [
                    const _ProfileHeaderSection(),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _PPDesign.card,
                        borderRadius: BorderRadius.circular(_PPDesign.cardRadius),
                        border: Border.all(color: _PPDesign.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Full Name / Contact Person',
                            style: _PPDesign.fieldLabel,
                          ),
                          const SizedBox(height: 8),
                          _ProfileTextField(
                            controller: _nameController,
                            trailingIcon: Icons.person_outline,
                          ),
                          const SizedBox(height: 18),
                          Text('Email Address', style: _PPDesign.fieldLabel),
                          const SizedBox(height: 8),
                          _ProfileTextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            trailingIcon: Icons.mail_outline,
                          ),
                          const SizedBox(height: 18),
                          Text('Provider Type', style: _PPDesign.fieldLabel),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 2.4,
                            ),
                            itemCount: _providerTypes.length,
                            itemBuilder: (context, index) {
                              final type = _providerTypes[index];
                              return _ProviderTypeTile(
                                icon: type.icon,
                                label: type.label,
                                selected: _providerType == index,
                                onTap: () =>
                                    setState(() => _providerType = index),
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Company Description',
                            style: _PPDesign.fieldLabel,
                          ),
                          const SizedBox(height: 8),
                          _ProfileTextField(
                            controller: _descriptionController,
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.save_outlined, size: 20),
                        label: Text('Save Changes', style: _PPDesign.saveLabel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _PPDesign.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(_PPDesign.buttonRadius),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, size: 20),
                      label: Text('Logout Account', style: _PPDesign.logoutLabel),
                      style: TextButton.styleFrom(
                        foregroundColor: _PPDesign.logoutRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _PPBottomNav(
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
class _PPDesign {
  _PPDesign._();

  static const Color background = Color(0xFFF8F9FE);
  static const Color primary = Color(0xFF0052CC);
  static const Color textDark = Color(0xFF09101D);
  static const Color textGrey = Color(0xFF667085);
  static const Color border = Color(0xFFE4E7EC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color selectedBg = Color(0xFFEFF4FF);
  static const Color badgeBg = Color(0xFF12B76A);
  static const Color logoutRed = Color(0xFFB42318);
  static const Color navInactive = Color(0xFF98A2B3);

  static const double cardRadius = 24;
  static const double buttonRadius = 30;
  static const double inputRadius = 12;

  static TextStyle get brandName => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.2,
      );

  static TextStyle get companyName => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.25,
        letterSpacing: -0.2,
      );

  static TextStyle get badgeLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get fieldLabel => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textGrey,
        height: 1.3,
      );

  static TextStyle get inputText => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textDark,
        height: 1.35,
      );

  static TextStyle typeLabel(Color color, {bool selected = false}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: color,
        height: 1.2,
      );

  static TextStyle get saveLabel => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get logoutLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: logoutRed,
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

class _ProviderProfileTopBar extends StatelessWidget {
  const _ProviderProfileTopBar();

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
              Text('Flunexia', style: _PPDesign.brandName),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
                color: _PPDesign.primary,
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: _PPDesign.border),
      ],
    );
  }
}

class _ProfileHeaderSection extends StatelessWidget {
  const _ProfileHeaderSection();

  static const _avatarUrl =
      'https://images.unsplash.com/photo-1497366216548-37526070297c?w=400&q=80';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFB8C5CE),
                border: Border.all(color: Colors.white, width: 4),
                image: const DecorationImage(
                  image: NetworkImage(_avatarUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _PPDesign.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Lumina Services Ltd.', style: _PPDesign.companyName),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _PPDesign.badgeBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('Provider', style: _PPDesign.badgeLabel),
        ),
      ],
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    this.keyboardType,
    this.trailingIcon,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final IconData? trailingIcon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: _PPDesign.inputText,
      decoration: InputDecoration(
        filled: true,
        fillColor: _PPDesign.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: trailingIcon != null
            ? Icon(trailingIcon, size: 20, color: _PPDesign.textGrey)
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_PPDesign.inputRadius),
          borderSide: const BorderSide(color: _PPDesign.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_PPDesign.inputRadius),
          borderSide: const BorderSide(color: _PPDesign.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _ProviderTypeTile extends StatelessWidget {
  const _ProviderTypeTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _PPDesign.primary : _PPDesign.textGrey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _PPDesign.selectedBg : _PPDesign.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _PPDesign.primary : _PPDesign.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: _PPDesign.typeLabel(color, selected: selected),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PPBottomNav extends StatelessWidget {
  const _PPBottomNav({
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
        color: _PPDesign.card,
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
                      _PPNavIcon(icon: item.icon, active: active),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: _PPDesign.navLabel(
                          active ? _PPDesign.primary : _PPDesign.navInactive,
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

class _PPNavIcon extends StatelessWidget {
  const _PPNavIcon({required this.icon, required this.active});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: _PPDesign.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 22, color: Colors.white),
      );
    }

    return SizedBox(
      height: 38,
      child: Center(
        child: Icon(icon, size: 22, color: _PPDesign.navInactive),
      ),
    );
  }
}
