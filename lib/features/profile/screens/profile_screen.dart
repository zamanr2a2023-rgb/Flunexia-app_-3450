import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flunexia_app/features/auth/screens/login_screen.dart';
import 'package:flunexia_app/features/organizer Dashboard/screens/organizer_dashboard.dart';
import 'package:flunexia_app/features/create_trip/screens/create_trip.dart';
import 'package:flunexia_app/features/create_trip/screens/my_trips.dart';
import 'package:flunexia_app/features/requests/screens/requests_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: 'Marc Dupont');
  final _emailController =
      TextEditingController(text: 'm.dupont@flunexia.app');
  final _otherOrgTypeController = TextEditingController();

  int _navIndex = 4;
  int _orgType = 0;

  static const _otherOrgTypeIndex = 5;

  static const _orgTypes = [
    (icon: Icons.account_balance_outlined, label: 'Municipality'),
    (icon: Icons.groups_outlined, label: 'Association'),
    (icon: Icons.school_outlined, label: 'School'),
    (icon: Icons.business_outlined, label: 'Company'),
    (icon: Icons.person_outline, label: 'Individual'),
    (icon: Icons.more_horiz, label: 'Other'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _otherOrgTypeController.dispose();
    super.dispose();
  }

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
    if (index == 3) {
      _replaceWith(const RequestsScreen());
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

  void _deleteAccount() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ProfDesign.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _ProfileTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  children: [
                    const _ProfileAvatarSection(),
                    const SizedBox(height: 28),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Full Name', style: _ProfDesign.fieldLabel),
                    ),
                    const SizedBox(height: 8),
                    _ProfileTextField(controller: _nameController),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child:
                          Text('Email Address', style: _ProfDesign.fieldLabel),
                    ),
                    const SizedBox(height: 8),
                    _ProfileTextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Organization type',
                        style: _ProfDesign.fieldLabel,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_orgTypes.length, (i) {
                      final type = _orgTypes[i];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: i == _orgTypes.length - 1 ? 0 : 10,
                        ),
                        child: _OrgTypeOption(
                          icon: type.icon,
                          label: type.label,
                          selected: _orgType == i,
                          onTap: () => setState(() => _orgType = i),
                        ),
                      );
                    }),
                    if (_orgType == _otherOrgTypeIndex) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Specify organization type',
                          style: _ProfDesign.fieldLabel,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _ProfileTextField(
                        controller: _otherOrgTypeController,
                        hintText: 'Enter your organization type',
                      ),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _ProfDesign.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          'Save Changes',
                          style: _ProfDesign.saveLabel,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _deleteAccount,
                      child: Text(
                        'Delete Account',
                        style: _ProfDesign.deleteLabel,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _ProfBottomNav(
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
class _ProfDesign {
  _ProfDesign._();

  static const Color background = Color(0xFFF8F9FE);
  static const Color primary = Color(0xFF0052CC);
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color textGrey = Color(0xFF667085);
  static const Color border = Color(0xFFE4E7EC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color selectedBg = Color(0xFFEFF4FF);
  static const Color badgeBg = Color(0xFFECFDF3);
  static const Color badgeText = Color(0xFF027A48);
  static const Color deleteRed = Color(0xFFB42318);
  static const Color navInactive = Color(0xFF98A2B3);

  static TextStyle get appBarTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.2,
      );

  static TextStyle get userName => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.2,
        letterSpacing: -0.3,
      );

  static TextStyle get badgeLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: badgeText,
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
        height: 1.3,
      );

  static TextStyle get orgLabel => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: textDark,
        height: 1.3,
      );

  static TextStyle get orgLabelSelected => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.3,
      );

  static TextStyle get saveLabel => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get deleteLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: deleteRed,
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

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar();

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
              const SizedBox(width: 12),
              Text('Profile', style: _ProfDesign.appBarTitle),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
                color: _ProfDesign.primary,
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: _ProfDesign.border),
      ],
    );
  }
}

class _ProfileAvatarSection extends StatelessWidget {
  const _ProfileAvatarSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFB8C5CE),
                border: Border.all(color: Colors.white, width: 4),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: _ProfDesign.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Marc Dupont', style: _ProfDesign.userName),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _ProfDesign.badgeBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, size: 14, color: _ProfDesign.badgeText),
              const SizedBox(width: 6),
              Text('Organizer', style: _ProfDesign.badgeLabel),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    this.keyboardType,
    this.hintText,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: _ProfDesign.inputText,
      cursorColor: _ProfDesign.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: _ProfDesign.inputText.copyWith(
          color: _ProfDesign.textGrey.withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: _ProfDesign.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: _ProfDesign.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: _ProfDesign.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _OrgTypeOption extends StatelessWidget {
  const _OrgTypeOption({
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _ProfDesign.selectedBg : _ProfDesign.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _ProfDesign.primary : _ProfDesign.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? _ProfDesign.primary : _ProfDesign.textGrey,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: selected
                    ? _ProfDesign.orgLabelSelected
                    : _ProfDesign.orgLabel.copyWith(color: _ProfDesign.textGrey),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _ProfDesign.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? _ProfDesign.primary : _ProfDesign.border,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfBottomNav extends StatelessWidget {
  const _ProfBottomNav({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

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
        color: _ProfDesign.card,
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
                      _ProfNavIcon(icon: item.icon, active: active),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: _ProfDesign.navLabel(
                          active ? _ProfDesign.primary : _ProfDesign.navInactive,
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

class _ProfNavIcon extends StatelessWidget {
  const _ProfNavIcon({required this.icon, required this.active});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: _ProfDesign.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 22, color: Colors.white),
      );
    }

    return SizedBox(
      height: 34,
      child: Center(
        child: Icon(icon, size: 22, color: _ProfDesign.navInactive),
      ),
    );
  }
}
