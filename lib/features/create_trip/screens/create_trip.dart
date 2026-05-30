import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flunexia_app/features/organizer Dashboard/screens/organizer_dashboard.dart';
import 'package:flunexia_app/features/create_trip/screens/my_trips.dart';
import 'package:flunexia_app/features/requests/screens/requests_screen.dart';
import 'package:flunexia_app/features/profile/screens/profile_screen.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  static const String routeName = '/create-trip';

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _budgetController = TextEditingController();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _participantsController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _needType = 'Transport';
  static const List<String> _needTypeOptions = [
    'Transport',
    'Accommodation',
    'Food & Catering',
    'Guide & Tour',
    'Equipment',
  ];

  int _navIndex = 1;

  void _onNavSelected(int index) {
    if (index == _navIndex) return;
    if (index == 0) {
      _replaceWith(const OrganizerDashboard());
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
  void dispose() {
    _budgetController.dispose();
    _titleController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _participantsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      _dateController.text =
          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CTDesign.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _CreateTripTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _StepIndicator(currentStep: 1),
                    const SizedBox(height: 24),
                    Text('ORGANIZERS', style: _CTDesign.eyebrow),
                    const SizedBox(height: 6),
                    Text('Create a Trip', style: _CTDesign.heading),
                    const SizedBox(height: 8),
                    Text(
                      'Design your perfect outing and let local providers handle the details.',
                      style: _CTDesign.subtitle,
                    ),
                    const SizedBox(height: 20),
                    _FieldCard(
                      label: 'Cover Image',
                      child: _CoverImagePicker(onTap: () {}),
                    ),
                    const SizedBox(height: 14),
                    _FieldCard(
                      label: 'Budget Estimate',
                      helper: 'Enter an estimated amount in USD',
                      child: _CTTextField(
                        controller: _budgetController,
                        hintText: 'e.g. 500',
                        prefixIcon: Icons.calculate_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FieldCard(
                      label: 'Trip Title',
                      helper: 'Give your trip a catchy name',
                      child: _CTTextField(
                        controller: _titleController,
                        hintText: 'e.g. Summer Weekend in Amalfi',
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FieldCard(
                      label: 'Departure Date',
                      child: _CTTextField(
                        controller: _dateController,
                        hintText: 'dd----yyyy',
                        prefixIcon: Icons.calendar_today_outlined,
                        readOnly: true,
                        onTap: _pickDate,
                        suffixIcon: Icons.calendar_month_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FieldCard(
                      label: 'Location',
                      helper: 'Where is this adventure happening?',
                      child: _CTTextField(
                        controller: _locationController,
                        hintText: 'e.g. Santorini, Greece',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FieldCard(
                      label: 'Participants',
                      helper: 'Number of people attending',
                      child: _CTTextField(
                        controller: _participantsController,
                        hintText: 'e.g. 12',
                        prefixIcon: Icons.groups_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FieldCard(
                      label: 'Need Type',
                      child: _NeedTypeDropdown(
                        value: _needType,
                        options: _needTypeOptions,
                        onChanged: (value) => setState(() => _needType = value),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FieldCard(
                      label: 'Description',
                      helper:
                          'Be as detailed as possible to get better results from providers',
                      child: _CTTextField(
                        controller: _descriptionController,
                        hintText:
                            'Tell us about your trip goals, preferences, or specific requests...',
                        maxLines: 4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _PublishRequestButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _CTBottomNav(
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
class _CTDesign {
  _CTDesign._();

  static const Color background = Color(0xFFF8F9FE);
  static const Color primary = Color(0xFF0052CC);
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color textGrey = Color(0xFF667085);
  static const Color helper = Color(0xFF98A2B3);
  static const Color border = Color(0xFFE4E7EC);
  static const Color cardBorder = Color(0xFFEAECF0);
  static const Color card = Color(0xFFFFFFFF);
  static const Color placeholder = Color(0xFF98A2B3);
  static const Color stepInactive = Color(0xFFE4E7EC);
  static const Color stepInactiveText = Color(0xFF98A2B3);
  static const Color stepConnector = Color(0xFFD0D5DD);
  static const Color navInactive = Color(0xFF98A2B3);
  static const Color notificationDot = Color(0xFFF04438);

  static const double cardRadius = 16;
  static const double inputRadius = 8;

  static TextStyle get brandTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.2,
      );

  static TextStyle get stepLabelActive => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: 0.8,
        height: 1.2,
      );

  static TextStyle get stepLabelInactive => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: stepInactiveText,
        letterSpacing: 0.8,
        height: 1.2,
      );

  static TextStyle get stepNumber => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.1,
      );

  static TextStyle get stepNumberInactive => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: stepInactiveText,
        height: 1.1,
      );

  static TextStyle get eyebrow => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: 1.0,
        height: 1.2,
      );

  static TextStyle get heading => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.2,
        letterSpacing: -0.3,
      );

  static TextStyle get subtitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.5,
      );

  static TextStyle get fieldLabel => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textDark,
        height: 1.3,
      );

  static TextStyle get fieldHelper => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: helper,
        height: 1.3,
        fontStyle: FontStyle.italic,
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

  static TextStyle get coverHint => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textGrey,
        height: 1.3,
      );

  static TextStyle get publishLabel => GoogleFonts.inter(
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

class _CreateTripTopBar extends StatelessWidget {
  const _CreateTripTopBar();

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
              Text('Flunexia', style: _CTDesign.brandTitle),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
                color: _CTDesign.primary,
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: _CTDesign.border),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  static const _steps = [
    (number: 1, label: 'BASIC INFO'),
    (number: 2, label: 'DETAILS'),
    (number: 3, label: 'PUBLISH'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            return const Expanded(child: _DashedConnector());
          }
          final stepIndex = i ~/ 2;
          final step = _steps[stepIndex];
          final active = step.number == currentStep;
          return _StepNode(
            number: step.number,
            label: step.label,
            active: active,
          );
        }),
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.number,
    required this.label,
    required this.active,
  });

  final int number;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? _CTDesign.primary : _CTDesign.stepInactive,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: active
                ? _CTDesign.stepNumber
                : _CTDesign.stepNumberInactive,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: active
              ? _CTDesign.stepLabelActive
              : _CTDesign.stepLabelInactive,
        ),
      ],
    );
  }
}

class _DashedConnector extends StatelessWidget {
  const _DashedConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 6, right: 6),
      child: CustomPaint(
        size: const Size.fromHeight(2),
        painter: _DashedLinePainter(),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 4.0;
    const dashGap = 4.0;
    final paint = Paint()
      ..color = _CTDesign.stepConnector
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.label,
    required this.child,
    this.helper,
  });

  final String label;
  final Widget child;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _CTDesign.card,
        borderRadius: BorderRadius.circular(_CTDesign.cardRadius),
        border: Border.all(color: _CTDesign.cardBorder),
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
          Text(label, style: _CTDesign.fieldLabel),
          const SizedBox(height: 10),
          child,
          if (helper != null) ...[
            const SizedBox(height: 8),
            Text(helper!, style: _CTDesign.fieldHelper),
          ],
        ],
      ),
    );
  }
}

class _CTTextField extends StatelessWidget {
  const _CTTextField({
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: _CTDesign.inputText,
      cursorColor: _CTDesign.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: _CTDesign.inputHint,
        isDense: true,
        filled: true,
        fillColor: _CTDesign.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        prefixIcon: prefixIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(prefixIcon, size: 18, color: _CTDesign.textGrey),
              ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 12, left: 8),
                child: Icon(suffixIcon, size: 18, color: _CTDesign.textGrey),
              ),
        suffixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_CTDesign.inputRadius),
          borderSide: const BorderSide(color: _CTDesign.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_CTDesign.inputRadius),
          borderSide: const BorderSide(color: _CTDesign.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _CoverImagePicker extends StatelessWidget {
  const _CoverImagePicker({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorderBox(
        child: Container(
          height: 100,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _CTDesign.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  size: 24,
                  color: _CTDesign.textGrey,
                ),
              ),
              const SizedBox(height: 8),
              Text('Add a cover photo', style: _CTDesign.coverHint),
            ],
          ),
        ),
      ),
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_CTDesign.inputRadius),
        child: child,
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _CTDesign.stepConnector
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(_CTDesign.inputRadius),
    );
    final path = Path()..addRRect(rrect);
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 5.0;
    const dashGap = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NeedTypeDropdown extends StatelessWidget {
  const _NeedTypeDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: _CTDesign.card,
        borderRadius: BorderRadius.circular(_CTDesign.inputRadius),
        border: Border.all(color: _CTDesign.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.pedal_bike_outlined,
              size: 18, color: _CTDesign.textGrey),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: _CTDesign.textGrey),
                style: _CTDesign.inputText,
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
                items: options
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(option, style: _CTDesign.inputText),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishRequestButton extends StatelessWidget {
  const _PublishRequestButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: _CTDesign.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.send_rounded, size: 18, color: Colors.white),
            const SizedBox(width: 10),
            Text('Publish Request', style: _CTDesign.publishLabel),
          ],
        ),
      ),
    );
  }
}

class _CTBottomNav extends StatelessWidget {
  const _CTBottomNav({
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
        color: _CTDesign.card,
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
                        style: _CTDesign.navLabel(
                          active ? _CTDesign.primary : _CTDesign.navInactive,
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
      color: active ? _CTDesign.primary : _CTDesign.navInactive,
    );

    Widget child = active
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _CTDesign.primary.withValues(alpha: 0.12),
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
                color: _CTDesign.notificationDot,
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
