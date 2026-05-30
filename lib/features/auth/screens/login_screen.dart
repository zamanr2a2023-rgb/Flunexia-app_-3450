import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flunexia_app/features/auth/screens/register_screen.dart';
import 'package:flunexia_app/features/organizer Dashboard/screens/organizer_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OrganizerDashboard()),
    );
  }

  void _goToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _LoginDesign.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      const _FlunexiaBrandHeader(),
                      const SizedBox(height: 32),
                      _LoginCard(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        onLogin: () => _handleLogin(context),
                        onSignUpTap: _goToRegister,
                      ),
                      const Spacer(),
                      const _SecureConnectionFooter(),
                      const SizedBox(height: 24),
                      _SignUpPrompt(onSignUpTap: _goToRegister),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Design tokens from the Flunexia login mockup (scoped to this screen only).
class _LoginDesign {
  _LoginDesign._();

  static const Color background = Color(0xFFF8F9FB);
  static const Color primary = Color(0xFF0052CC);
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color textGrey = Color(0xFF667085);
  static const Color border = Color(0xFFD0D5DD);
  static const Color card = Color(0xFFFFFFFF);
  static const Color placeholder = Color(0xFF98A2B3);
  static const Color tabInactiveBg = Color(0xFFF2F4F7);

  static const double cardRadius = 32;
  static const double buttonRadius = 6;
  static const double inputRadius = 6;
  static const double tabRadius = 999;

  static TextStyle brandTitle(Color color) => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle tabLabel(Color color, {bool active = false}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        color: color,
        height: 1.2,
      );

  static TextStyle welcomeTitle(Color color) => GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.25,
        letterSpacing: -0.3,
      );

  static TextStyle subtitle(Color color) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle fieldLabel(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      );

  static TextStyle inputText(Color color) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  static TextStyle inputHint(Color color) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  static TextStyle link(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle buttonLabel(Color color) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.2,
      );

  static TextStyle footer(Color color) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  static TextStyle signUpMuted(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  static TextStyle signUpLink(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );
}

class _FlunexiaBrandHeader extends StatelessWidget {
  const _FlunexiaBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Flunexia', style: _LoginDesign.brandTitle(_LoginDesign.primary)),
        const SizedBox(height: 8),
        Container(
          width: 56,
          height: 4,
          decoration: BoxDecoration(
            color: _LoginDesign.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _LoginCard extends StatefulWidget {
  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.onSignUpTap,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final VoidCallback onSignUpTap;

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
      decoration: BoxDecoration(
        color: _LoginDesign.card,
        borderRadius: BorderRadius.circular(_LoginDesign.cardRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101828).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
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
          _AuthTabBar(onSignUpTap: widget.onSignUpTap),
          const SizedBox(height: 24),
          Text('Welcome back',
              style: _LoginDesign.welcomeTitle(_LoginDesign.textDark)),
          const SizedBox(height: 10),
          Text(
            'Access your space to organize outings or respond to requests.',
            style: _LoginDesign.subtitle(_LoginDesign.textGrey),
          ),
          const SizedBox(height: 28),
          Text('Email address',
              style: _LoginDesign.fieldLabel(_LoginDesign.textGrey)),
          const SizedBox(height: 8),
          _LoginTextField(
            controller: widget.emailController,
            hintText: 'name@company.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Password',
                  style: _LoginDesign.fieldLabel(_LoginDesign.textGrey)),
              GestureDetector(
                onTap: () {},
                child: Text('Forgot password?',
                    style: _LoginDesign.link(_LoginDesign.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _LoginTextField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: _LoginDesign.textGrey,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 28),
          _LoginButton(onPressed: widget.onLogin),
        ],
      ),
    );
  }
}

class _AuthTabBar extends StatelessWidget {
  const _AuthTabBar({required this.onSignUpTap});

  final VoidCallback onSignUpTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _LoginDesign.tabInactiveBg,
        borderRadius: BorderRadius.circular(_LoginDesign.tabRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _LoginDesign.primary,
                borderRadius: BorderRadius.circular(_LoginDesign.tabRadius),
              ),
              alignment: Alignment.center,
              child: Text(
                'Log In',
                style: _LoginDesign.tabLabel(Colors.white, active: true),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onSignUpTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                child: Text(
                  'Sign Up',
                  style: _LoginDesign.tabLabel(_LoginDesign.textGrey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      style: _LoginDesign.inputText(_LoginDesign.textDark),
      cursorColor: _LoginDesign.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: _LoginDesign.inputHint(_LoginDesign.placeholder),
        filled: true,
        fillColor: _LoginDesign.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_LoginDesign.inputRadius),
          borderSide: const BorderSide(color: _LoginDesign.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_LoginDesign.inputRadius),
          borderSide:
              const BorderSide(color: _LoginDesign.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _LoginDesign.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_LoginDesign.buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Log In', style: _LoginDesign.buttonLabel(Colors.white)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _SecureConnectionFooter extends StatelessWidget {
  const _SecureConnectionFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 16, color: _LoginDesign.textGrey),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Secure connection – your data is protected',
              style: _LoginDesign.footer(_LoginDesign.textGrey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt({required this.onSignUpTap});

  final VoidCallback onSignUpTap;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: _LoginDesign.signUpMuted(_LoginDesign.textGrey),
        children: [
          const TextSpan(text: "Don't have an account? "),
          TextSpan(
            text: 'Sign up for free',
            style: _LoginDesign.signUpLink(_LoginDesign.primary),
            recognizer: TapGestureRecognizer()..onTap = onSignUpTap,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
