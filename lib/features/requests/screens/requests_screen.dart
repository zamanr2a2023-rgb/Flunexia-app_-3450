import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flunexia_app/features/create_trip/data/offer_repository.dart';
import 'package:flunexia_app/features/create_trip/data/trip_repository.dart';
import 'package:flunexia_app/features/requests/data/models/request_model.dart';
import 'package:flunexia_app/features/requests/data/request_repository.dart';
import 'package:flunexia_app/features/organizer Dashboard/screens/organizer_dashboard.dart';
import 'package:flunexia_app/features/create_trip/screens/create_trip.dart';
import 'package:flunexia_app/features/create_trip/screens/my_trips.dart';
import 'package:flunexia_app/features/profile/screens/profile_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  static const String routeName = '/requests';

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final _requestRepository = RequestRepository();
  final _offerRepository = OfferRepository();
  int _navIndex = 3;
  int _activeFilter = 0;
  bool _isLoading = true;
  List<_RequestItem> _requests = const [];
  final Set<String> _updatingOfferIds = {};

  static const _filters = [
    'All',
    'Pending',
    'Accepted',
    'Rejected',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  String? _statusForFilter(int index) {
    return switch (index) {
      1 => 'pending',
      2 => 'accepted',
      3 => 'rejected',
      4 => 'completed',
      _ => null,
    };
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    try {
      final apiRequests = await _requestRepository.fetchRequests(
        status: _statusForFilter(_activeFilter),
      );
      final items = <_RequestItem>[];
      for (final request in apiRequests) {
        items.add(await _mapRequest(request));
      }
      if (!mounted) return;
      setState(() {
        _requests = items;
        _isLoading = false;
      });
    } on TripException catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Failed to load requests. Please try again.');
    }
  }

  Future<_RequestItem> _mapRequest(BookingRequestModel request) async {
    var providerName = request.provider?.name ?? '—';
    String? offerId;

    if (request.status.toLowerCase() == 'pending') {
      final offers = await _offerRepository.fetchOffersForRequest(request.id);
      final pendingOffers = offers.where((offer) => offer.isPending).toList();
      final selected = pendingOffers.isNotEmpty
          ? pendingOffers.first
          : (offers.isNotEmpty ? offers.first : null);
      if (selected != null) {
        offerId = selected.id;
        providerName = selected.provider.name;
      }
    } else if (request.provider != null && request.provider!.name.isNotEmpty) {
      providerName = request.provider!.name;
    }

    final needType = request.needType.isNotEmpty ? request.needType : 'Service';
    String? errorMessage;
    if (request.status.toLowerCase() == 'rejected') {
      errorMessage = request.acceptedOffer?.rejectionReason ??
          'This request was rejected.';
    }

    return _RequestItem(
      requestId: request.id,
      offerId: offerId,
      title: request.trip?.title ?? 'Trip request',
      status: _mapStatus(request.status),
      provider: providerName,
      type: needType,
      serviceDate: _formatDate(request.trip?.startDate),
      providerIcon: Icons.person_outline,
      typeIcon: _iconForNeedType(needType),
      errorMessage: errorMessage,
    );
  }

  _RequestStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _RequestStatus.pending;
      case 'accepted':
        return _RequestStatus.accepted;
      case 'completed':
        return _RequestStatus.completed;
      case 'rejected':
        return _RequestStatus.rejected;
      default:
        return _RequestStatus.pending;
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '—';
    try {
      final date = DateTime.parse(isoDate);
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  IconData _iconForNeedType(String type) {
    switch (type.toLowerCase()) {
      case 'transport':
        return Icons.directions_bus_outlined;
      case 'restaurant':
      case 'food & catering':
        return Icons.restaurant_outlined;
      case 'accommodation':
        return Icons.hotel_outlined;
      case 'activity':
      case 'guide & tour':
        return Icons.terrain_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _acceptOffer(_RequestItem item) async {
    await _updateOfferStatus(item, 'accepted');
  }

  Future<void> _rejectOffer(_RequestItem item) async {
    final feedback = await showDialog<String>(
      context: context,
      builder: (context) => _RejectOfferDialog(providerName: item.provider),
    );
    if (feedback == null || !mounted) return;
    await _updateOfferStatus(item, 'rejected', feedback: feedback);
  }

  Future<void> _updateOfferStatus(
    _RequestItem item,
    String status, {
    String? feedback,
  }) async {
    final offerId = item.offerId;
    if (offerId == null || offerId.isEmpty) {
      _showMessage('No offer available for this request.');
      return;
    }
    if (_updatingOfferIds.contains(offerId)) return;

    setState(() => _updatingOfferIds.add(offerId));

    try {
      await _offerRepository.updateOfferStatus(
        offerId: offerId,
        status: status,
        feedback: feedback,
      );
      if (!mounted) return;
      _showMessage(
        status == 'accepted'
            ? 'Offer accepted successfully.'
            : 'Offer rejected successfully.',
      );
      await _loadRequests();
    } on TripException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Failed to update offer. Please try again.');
    } finally {
      if (mounted) setState(() => _updatingOfferIds.remove(offerId));
    }
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

  List<_RequestItem> get _filteredRequests => _requests;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ReqDesign.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _RequestsTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Requests / Bookings', style: _ReqDesign.heading),
                    const SizedBox(height: 6),
                    Text(
                      'Manage your upcoming trip logistics.',
                      style: _ReqDesign.subtitle,
                    ),
                    const SizedBox(height: 20),
                    _FilterTabBar(
                      filters: _filters,
                      activeIndex: _activeFilter,
                      onTap: (i) {
                        if (i == _activeFilter) return;
                        setState(() => _activeFilter = i);
                        _loadRequests();
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _ReqDesign.primary,
                          ),
                        ),
                      )
                    else if (_filteredRequests.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'No requests found.',
                          style: _ReqDesign.subtitle,
                        ),
                      )
                    else
                      ..._filteredRequests.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _RequestCard(
                            item: item,
                            isUpdating: item.offerId != null &&
                                _updatingOfferIds.contains(item.offerId),
                            onAccept: () => _acceptOffer(item),
                            onReject: () => _rejectOffer(item),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _ReqBottomNav(
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
class _ReqDesign {
  _ReqDesign._();

  static const Color background = Color(0xFFF8F9FE);
  static const Color primary = Color(0xFF0052CC);
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color textGrey = Color(0xFF667085);
  static const Color border = Color(0xFFE4E7EC);
  static const Color cardBorder = Color(0xFFEAECF0);
  static const Color card = Color(0xFFFFFFFF);
  static const Color navInactive = Color(0xFF98A2B3);
  static const Color notificationDot = Color(0xFFF04438);

  static const Color pendingBg = Color(0xFFFFF6ED);
  static const Color pendingText = Color(0xFFB54708);
  static const Color acceptedBg = Color(0xFFECFDF3);
  static const Color acceptedText = Color(0xFF027A48);
  static const Color completedBg = Color(0xFFE9E5F5);
  static const Color completedText = Color(0xFF6F5DA8);
  static const Color rejectedBg = Color(0xFFFEE4E2);
  static const Color rejectedText = Color(0xFFB42318);
  static const Color completedCardText = Color(0xFF98A2B3);
  static const Color markCompleted = Color(0xFF039855);
  static const Color errorBoxBg = Color(0xFFFEF3F2);
  static const Color errorBoxText = Color(0xFFB42318);

  static const double cardRadius = 20;

  static TextStyle get eyebrow => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textGrey,
        letterSpacing: 1.0,
        height: 1.2,
      );

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

  static TextStyle get subtitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.45,
      );

  static TextStyle tabLabel(Color color, {bool active = false}) =>
      GoogleFonts.inter(
        fontSize: 14,
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

  static TextStyle get cardTitleMuted => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: completedCardText,
        height: 1.3,
      );

  static TextStyle get metaLabel => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: textGrey,
        letterSpacing: 0.5,
        height: 1.2,
      );

  static TextStyle get metaValue => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textDark,
        height: 1.3,
      );

  static TextStyle get metaValueMuted => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: completedCardText,
        height: 1.3,
      );

  static TextStyle badgeLabel(Color color) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.6,
        height: 1.2,
      );

  static TextStyle get acceptLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get rejectLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textDark,
        height: 1.2,
      );

  static TextStyle get markCompletedLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get errorText => GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: errorBoxText,
        height: 1.35,
      );

  static TextStyle navLabel(Color color, {bool active = false}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        color: color,
        height: 1.2,
      );
}

enum _RequestStatus { pending, accepted, completed, rejected }

class _RequestItem {
  const _RequestItem({
    required this.requestId,
    required this.title,
    required this.status,
    required this.provider,
    required this.type,
    required this.serviceDate,
    required this.providerIcon,
    required this.typeIcon,
    this.offerId,
    this.errorMessage,
  });

  final String requestId;
  final String? offerId;
  final String title;
  final _RequestStatus status;
  final String provider;
  final String type;
  final String serviceDate;
  final IconData providerIcon;
  final IconData typeIcon;
  final String? errorMessage;
}

class _RequestsTopBar extends StatelessWidget {
  const _RequestsTopBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          child: Center(child: Text('ORGANIZERS', style: _ReqDesign.eyebrow)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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
              Text('Flunexia', style: _ReqDesign.brandTitle),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.tune, size: 22),
                color: _ReqDesign.textDark,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined, size: 24),
                    color: _ReqDesign.primary,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: _ReqDesign.notificationDot,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: _ReqDesign.border),
      ],
    );
  }
}

class _FilterTabBar extends StatelessWidget {
  const _FilterTabBar({
    required this.filters,
    required this.activeIndex,
    required this.onTap,
  });

  final List<String> filters;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (i) {
          final active = i == activeIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(right: i == filters.length - 1 ? 0 : 20),
              child: Column(
                children: [
                  Text(
                    filters[i],
                    style: _ReqDesign.tabLabel(
                      active ? _ReqDesign.primary : _ReqDesign.textGrey,
                      active: active,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 2,
                    width: active ? 28 : 0,
                    decoration: BoxDecoration(
                      color: _ReqDesign.primary,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.item,
    required this.onAccept,
    required this.onReject,
    required this.isUpdating,
  });

  final _RequestItem item;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isUpdating;

  bool get _isMuted => item.status == _RequestStatus.completed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isMuted ? 0.72 : 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _ReqDesign.card,
          borderRadius: BorderRadius.circular(_ReqDesign.cardRadius),
          border: Border.all(color: _ReqDesign.cardBorder),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF101828).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: _isMuted
                        ? _ReqDesign.cardTitleMuted
                        : _ReqDesign.cardTitle,
                  ),
                ),
                _StatusBadge(status: item.status),
              ],
            ),
            const SizedBox(height: 16),
            if (item.status == _RequestStatus.pending) ...[
              _MetaRow(
                label: 'PROVIDER',
                value: item.provider,
                icon: item.providerIcon,
              ),
              const SizedBox(height: 10),
              _MetaRow(
                label: 'TYPE',
                value: item.type,
                icon: item.typeIcon,
              ),
              const SizedBox(height: 10),
              _MetaRow(
                label: 'SERVICE DATE',
                value: item.serviceDate,
                icon: Icons.calendar_today_outlined,
              ),
            ] else ...[
              _MetaRow(
                label: 'PROVIDER',
                value: item.provider,
                icon: item.providerIcon,
                muted: _isMuted,
              ),
              const SizedBox(height: 10),
              _MetaRow(
                label: 'DATE',
                value: item.serviceDate,
                icon: Icons.calendar_today_outlined,
                muted: _isMuted,
              ),
            ],
            if (item.status == _RequestStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: isUpdating ? null : onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _ReqDesign.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isUpdating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text('Accept', style: _ReqDesign.acceptLabel),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        onPressed: isUpdating ? null : onReject,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _ReqDesign.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Text('Reject', style: _ReqDesign.rejectLabel),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: _ReqDesign.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Icon(Icons.visibility_outlined,
                          size: 18, color: _ReqDesign.textGrey),
                    ),
                  ),
                ],
              ),
            ],
            if (item.status == _RequestStatus.accepted) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check, size: 18, color: Colors.white),
                  label: Text('Mark Completed',
                      style: _ReqDesign.markCompletedLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ReqDesign.markCompleted,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
            if (item.errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _ReqDesign.errorBoxBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 16, color: _ReqDesign.errorBoxText),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.errorMessage!,
                          style: _ReqDesign.errorText),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final _RequestStatus status;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String label;

    switch (status) {
      case _RequestStatus.pending:
        bg = _ReqDesign.pendingBg;
        fg = _ReqDesign.pendingText;
        label = 'PENDING';
      case _RequestStatus.accepted:
        bg = _ReqDesign.acceptedBg;
        fg = _ReqDesign.acceptedText;
        label = 'ACCEPTED';
      case _RequestStatus.completed:
        bg = _ReqDesign.completedBg;
        fg = _ReqDesign.completedText;
        label = 'COMPLETED';
      case _RequestStatus.rejected:
        bg = _ReqDesign.rejectedBg;
        fg = _ReqDesign.rejectedText;
        label = 'REJECTED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: _ReqDesign.badgeLabel(fg)),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    required this.icon,
    this.muted = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final iconColor = muted ? _ReqDesign.completedCardText : _ReqDesign.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: _ReqDesign.metaLabel),
              const SizedBox(height: 2),
              Text(
                value,
                style: muted ? _ReqDesign.metaValueMuted : _ReqDesign.metaValue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReqBottomNav extends StatelessWidget {
  const _ReqBottomNav({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = <_NavBarItem>[
    _NavBarItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
    _NavBarItem(icon: Icons.add_circle_outline, label: 'Create'),
    _NavBarItem(icon: Icons.calendar_month_outlined, label: 'Trips'),
    _NavBarItem(icon: Icons.inbox, label: 'Requests'),
    _NavBarItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _ReqDesign.card,
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
                      _NavIcon(icon: item.icon, active: active),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: _ReqDesign.navLabel(
                          active ? _ReqDesign.primary : _ReqDesign.navInactive,
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

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.active});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: 22,
      color: active ? _ReqDesign.primary : _ReqDesign.navInactive,
    );

    if (active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: _ReqDesign.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: iconWidget,
      );
    }

    return SizedBox(height: 34, child: Center(child: iconWidget));
  }
}

class _RejectOfferDialog extends StatefulWidget {
  const _RejectOfferDialog({required this.providerName});

  final String providerName;

  @override
  State<_RejectOfferDialog> createState() => _RejectOfferDialogState();
}

class _RejectOfferDialogState extends State<_RejectOfferDialog> {
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reject offer from ${widget.providerName}?'),
      content: TextField(
        controller: _feedbackController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Optional feedback for the provider',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_feedbackController.text),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}
