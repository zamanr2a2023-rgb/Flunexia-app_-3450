import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flunexia_app/features/auth/screens/login_screen.dart';
import 'package:flunexia_app/features/organizer Dashboard/screens/organizer_dashboard.dart';
import 'package:flunexia_app/features/provider_dashbord/screens/provider_dashbord_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  int _accountType = 0; // 0 = Organizer, 1 = Provider

  @override
  void dispose() {
    _nameController.dispose();
    _organizationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _handleSignUp() {
    final Widget destination = _accountType == 0
        ? const OrganizerDashboard()
        : const ProviderDashboardScreen();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RegDesign.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const _RegisterTopBar(),
              const SizedBox(height: 28),
              Center(
                child: Text(
                  'Create your account',
                  style: _RegDesign.heading,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Join the leading network for professional group travel.',
                  style: _RegDesign.subtitle,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),
              Text('CHOOSE ACCOUNT TYPE', style: _RegDesign.sectionLabel),
              const SizedBox(height: 12),
              _AccountTypeCard(
                title: 'Organizer',
                description:
                    'Create trips, send requests, and coordinate group logistics seamlessly.',
                icon: Icons.explore_outlined,
                iconBg: _RegDesign.primary,
                titleColor: _RegDesign.primary,
                selected: _accountType == 0,
                onTap: () => setState(() => _accountType = 0),
              ),
              const SizedBox(height: 12),
              _AccountTypeCard(
                title: 'Provider',
                description:
                    'Receive requests, offer professional services, and grow your business.',
                icon: Icons.handyman_outlined,
                iconBg: _RegDesign.providerGreen,
                titleColor: _RegDesign.providerGreen,
                selected: _accountType == 1,
                onTap: () => setState(() => _accountType = 1),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                decoration: BoxDecoration(
                  color: _RegDesign.card,
                  borderRadius: BorderRadius.circular(_RegDesign.cardRadius),
                  border: Border.all(color: _RegDesign.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF101828).withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Full name', style: _RegDesign.fieldLabel),
                    const SizedBox(height: 8),
                    _RegTextField(
                      controller: _nameController,
                      hintText: 'John Doe',
                    ),
                    const SizedBox(height: 16),
                    Text('Organization', style: _RegDesign.fieldLabel),
                    const SizedBox(height: 8),
                    _RegTextField(
                      controller: _organizationController,
                      hintText: 'Company Name',
                    ),
                    const SizedBox(height: 16),
                    Text('Email address', style: _RegDesign.fieldLabel),
                    const SizedBox(height: 8),
                    _RegTextField(
                      controller: _emailController,
                      hintText: 'john@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    Text('Password', style: _RegDesign.fieldLabel),
                    const SizedBox(height: 8),
                    _RegTextField(
                      controller: _passwordController,
                      hintText: '••••••••',
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: _RegDesign.textGrey,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _RegDesign.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: const StadiumBorder(),
                        ),
                        child: Text('Sign Up', style: _RegDesign.buttonLabel),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text.rich(
                  TextSpan(
                    style: _RegDesign.footerMuted,
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Log In',
                        style: _RegDesign.footerLink,
                        recognizer: TapGestureRecognizer()..onTap = _goToLogin,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Design tokens scoped to this screen only.
class _RegDesign {
  _RegDesign._();

  static const Color background = Color(0xFFF8F9FE);
  static const Color primary = Color(0xFF0052CC);
  static const Color providerGreen = Color(0xFF12B76A);
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color textGrey = Color(0xFF667085);
  static const Color border = Color(0xFFD0D5DD);
  static const Color cardBorder = Color(0xFFEAECF0);
  static const Color card = Color(0xFFFFFFFF);
  static const Color placeholder = Color(0xFF98A2B3);
  static const Color selectedBg = Color(0xFFEFF4FF);

  static const double cardRadius = 16;
  static const double inputRadius = 8;
  static const double typeCardRadius = 14;

  static TextStyle get brandTitle => GoogleFonts.inter(
        fontSize: 22,
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
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.45,
      );

  static TextStyle get sectionLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textGrey,
        letterSpacing: 0.8,
        height: 1.2,
      );

  static TextStyle get fieldLabel => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textDark,
        height: 1.3,
      );

  static TextStyle get inputText => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textDark,
        height: 1.3,
      );

  static TextStyle get inputHint => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: placeholder,
        height: 1.3,
      );

  static TextStyle get buttonLabel => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get typeTitle => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  static TextStyle get typeDescription => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.4,
      );

  static TextStyle get footerMuted => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.4,
      );

  static TextStyle get footerLink => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.4,
      );
}

class _RegisterTopBar extends StatelessWidget {
  const _RegisterTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Flunexia', style: _RegDesign.brandTitle),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _RegDesign.border),
          ),
          child: const Icon(
            Icons.help_outline,
            size: 18,
            color: _RegDesign.textGrey,
          ),
        ),
      ],
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBg,
    required this.titleColor,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color iconBg;
  final Color titleColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _RegDesign.selectedBg : _RegDesign.card,
          borderRadius: BorderRadius.circular(_RegDesign.typeCardRadius),
          border: Border.all(
            color: selected ? _RegDesign.primary : _RegDesign.cardBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: _RegDesign.typeTitle.copyWith(color: titleColor),
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: _RegDesign.typeDescription),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegTextField extends StatelessWidget {
  const _RegTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: _RegDesign.inputText,
      cursorColor: _RegDesign.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: _RegDesign.inputHint,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_RegDesign.inputRadius),
          borderSide: const BorderSide(color: _RegDesign.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_RegDesign.inputRadius),
          borderSide: const BorderSide(color: _RegDesign.primary, width: 1.5),
        ),
      ),
    );
  }
}
