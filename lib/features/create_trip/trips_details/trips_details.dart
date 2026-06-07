import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flunexia_app/features/create_trip/data/models/create_trip_response_model.dart';
import 'package:flunexia_app/features/create_trip/data/models/offer_model.dart';
import 'package:flunexia_app/features/create_trip/data/offer_repository.dart';
import 'package:flunexia_app/features/create_trip/data/trip_repository.dart';
import 'package:flunexia_app/features/organizer Dashboard/screens/organizer_dashboard.dart';
import 'package:flunexia_app/features/create_trip/screens/create_trip.dart';
import 'package:flunexia_app/features/create_trip/screens/my_trips.dart';
import 'package:flunexia_app/features/requests/screens/requests_screen.dart';
import 'package:flunexia_app/features/profile/screens/profile_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({
    super.key,
    required this.tripId,
  });

  static const String routeName = '/trip-details';

  final String tripId;

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final _tripRepository = TripRepository();
  final _offerRepository = OfferRepository();
  int _navIndex = 2;
  bool _isDuplicating = false;
  bool _isLoading = true;
  bool _isLoadingOffers = false;
  CreatedTripModel? _trip;
  String? _loadError;
  List<OfferModel> _offers = const [];
  final Set<String> _updatingOfferIds = {};

  static const _fallbackImage =
      'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1000&q=80';

  @override
  void initState() {
    super.initState();
    _loadTripDetails();
  }

  Future<void> _loadTripDetails() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final response = await _tripRepository.fetchTripById(widget.tripId);
      if (!mounted) return;
      setState(() {
        _trip = response.trip;
        _isLoading = false;
      });
      await _loadOffers();
    } on TripException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Failed to load trip details. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOffers() async {
    setState(() => _isLoadingOffers = true);

    try {
      final offers = await _offerRepository.fetchOffersForTrip(widget.tripId);
      if (!mounted) return;
      setState(() {
        _offers = offers;
        _isLoadingOffers = false;
      });
    } on TripException catch (error) {
      if (!mounted) return;
      setState(() => _isLoadingOffers = false);
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingOffers = false);
    }
  }

  String _formatOfferPrice(OfferModel offer) {
    final symbol = switch (offer.currency.toUpperCase()) {
      'EUR' => '€',
      'USD' => '\$',
      'GBP' => '£',
      _ => '${offer.currency} ',
    };
    final amount = offer.price;
    final formatted = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toString();
    return '$symbol$formatted';
  }

  _ProviderTag _tagFromOffer(OfferModel offer) {
    if (offer.isRejected) return _ProviderTag.rejected;
    switch (offer.tier.toLowerCase()) {
      case 'recommended':
        return _ProviderTag.recommended;
      default:
        return _ProviderTag.standard;
    }
  }

  int get _pendingOfferCount =>
      _offers.where((offer) => offer.isPending).length;

  Future<void> _acceptOffer(OfferModel offer) async {
    await _updateOfferStatus(offer.id, 'accepted');
  }

  Future<void> _rejectOffer(OfferModel offer) async {
    final feedback = await showDialog<String>(
      context: context,
      builder: (context) => _RejectOfferDialog(
        providerName: offer.provider.name,
      ),
    );
    if (feedback == null || !mounted) return;
    await _updateOfferStatus(offer.id, 'rejected', feedback: feedback);
  }

  Future<void> _updateOfferStatus(
    String offerId,
    String status, {
    String? feedback,
  }) async {
    if (_updatingOfferIds.contains(offerId)) return;

    setState(() => _updatingOfferIds.add(offerId));

    try {
      final response = await _offerRepository.updateOfferStatus(
        offerId: offerId,
        status: status,
        feedback: feedback,
      );
      if (!mounted) return;

      setState(() {
        final index = _offers.indexWhere((offer) => offer.id == offerId);
        if (index != -1) {
          _offers = List<OfferModel>.from(_offers)
            ..[index] = response.offer;
        }
      });

      final label = status == 'accepted' ? 'accepted' : 'rejected';
      _showMessage('Offer $label successfully.');
    } on TripException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Failed to update offer. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _updatingOfferIds.remove(offerId));
      }
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '—';
    try {
      final date = DateTime.parse(isoDate);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  String _formatDateRange(CreatedTripModel trip) {
    final start = _formatDate(trip.startDate);
    final end = _formatDate(trip.endDate);
    if (trip.endDate == null ||
        trip.endDate!.isEmpty ||
        trip.endDate == trip.startDate) {
      return start;
    }
    return '$start - $end';
  }

  String _formatBudget(CreatedTripModel trip) {
    if (trip.budgetEstimate == null) return '—';
    final symbol = switch (trip.budgetCurrency?.toUpperCase()) {
      'EUR' => '€',
      'USD' => '\$',
      'GBP' => '£',
      _ => '${trip.budgetCurrency ?? ''} ',
    };
    final amount = trip.budgetEstimate!;
    final formatted = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toString();
    return '$symbol$formatted';
  }

  String _formatParticipants(CreatedTripModel trip) {
    if (trip.participants == null) return '—';
    final count = trip.participants!;
    return '$count ${count == 1 ? 'Person' : 'People'}';
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'published':
      case 'active':
        return 'Active';
      case 'draft':
        return 'Draft';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      default:
        if (status.isEmpty) return 'Active';
        return status[0].toUpperCase() + status.substring(1);
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _duplicateTrip() async {
    if (_isDuplicating) return;

    setState(() => _isDuplicating = true);

    try {
      final response = await _tripRepository.duplicateTrip(widget.tripId);
      if (!mounted) return;

      _showMessage('Trip "${response.trip.title}" duplicated successfully.');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TripDetailsScreen(tripId: response.trip.id),
        ),
      );
    } on TripException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Failed to duplicate trip. Please try again.');
    } finally {
      if (mounted) setState(() => _isDuplicating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _TDDesign.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TripDetailsTopBar(
              onDuplicate: _duplicateTrip,
              isDuplicating: _isDuplicating,
            ),
            Expanded(child: _buildBody()),
            _TDBottomNav(
              selectedIndex: _navIndex,
              onSelected: _onNavSelected,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _TDDesign.primary),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: _TDDesign.body,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTripDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _TDDesign.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final trip = _trip!;
    final imageUrl = (trip.image != null && trip.image!.isNotEmpty)
        ? trip.image!
        : _fallbackImage;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroImage(
            imageUrl: imageUrl,
            statusLabel: _statusLabel(trip.status),
          ),
          const SizedBox(height: 18),
          Text(trip.title, style: _TDDesign.heading),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: _TDDesign.textGrey),
              const SizedBox(width: 6),
              Text(_formatDateRange(trip), style: _TDDesign.metaText),
              const SizedBox(width: 14),
              const Icon(Icons.location_on_outlined,
                  size: 14, color: _TDDesign.textGrey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  trip.location.isNotEmpty ? trip.location : '—',
                  style: _TDDesign.metaText,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.groups_outlined,
                  label: 'Participants',
                  value: _formatParticipants(trip),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Total Budget',
                  value: _formatBudget(trip),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text('Description', style: _TDDesign.sectionTitle),
          const SizedBox(height: 8),
          Text(
            (trip.description != null && trip.description!.isNotEmpty)
                ? trip.description!
                : 'No description provided.',
            style: _TDDesign.body,
          ),
          const SizedBox(height: 22),
          const _RecommendedProvidersCard(),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Provider Responses', style: _TDDesign.sectionTitle),
              const Spacer(),
              if (_pendingOfferCount > 0)
                _NewBadge(count: _pendingOfferCount),
            ],
          ),
          const SizedBox(height: 14),
          if (_isLoadingOffers)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: _TDDesign.primary),
              ),
            )
          else if (_offers.isEmpty)
            Text(
              'No provider responses yet.',
              style: _TDDesign.body,
            )
          else
            ..._offers.map(
              (offer) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProviderCard(
                  offer: offer,
                  priceLabel: _formatOfferPrice(offer),
                  tag: _tagFromOffer(offer),
                  isUpdating: _updatingOfferIds.contains(offer.id),
                  onAccept: () => _acceptOffer(offer),
                  onReject: () => _rejectOffer(offer),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Design tokens scoped to this screen only.
class _TDDesign {
  _TDDesign._();

  static const Color background = Color(0xFFF8F9FE);
  static const Color primary = Color(0xFF0052CC);
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color textGrey = Color(0xFF667085);
  static const Color textMuted = Color(0xFF98A2B3);
  static const Color border = Color(0xFFE4E7EC);
  static const Color cardBorder = Color(0xFFEAECF0);
  static const Color card = Color(0xFFFFFFFF);
  static const Color innerCard = Color(0xFFF4F6FB);

  static const Color badgeActive = Color(0xFF0052CC);
  static const Color badgeTop = Color(0xFF12B76A);
  static const Color tagRecommendedBg = Color(0xFFD1FADF);
  static const Color tagRecommendedText = Color(0xFF027A48);
  static const Color tagStandardBg = Color(0xFFEAECF0);
  static const Color tagStandardText = Color(0xFF475467);
  static const Color tagRejectedBg = Color(0xFFFEE4E2);
  static const Color tagRejectedText = Color(0xFFB42318);

  static const Color navInactive = Color(0xFF98A2B3);
  static const Color notificationDot = Color(0xFFF04438);

  static const double cardRadius = 16;
  static const double innerCardRadius = 14;
  static const double heroRadius = 18;

  static TextStyle get appBarTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.2,
      );

  static TextStyle get heading => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.2,
        letterSpacing: -0.3,
      );

  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.25,
      );

  static TextStyle get metaText => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.3,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.55,
      );

  static TextStyle get statLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textGrey,
        height: 1.3,
      );

  static TextStyle get statValue => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.25,
      );

  static TextStyle get providerName => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.25,
      );

  static TextStyle get providerService => GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.3,
      );

  static TextStyle get providerPrice => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.25,
      );

  static TextStyle tagLabel(Color color) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.2,
      );

  static TextStyle get acceptLabel => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get rejectLabel => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textDark,
        height: 1.2,
      );

  static TextStyle get recommendedTitle => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.25,
      );

  static TextStyle get recommendedSubtitle => GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: textGrey,
        height: 1.35,
      );

  static TextStyle get providerCardName => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.25,
      );

  static TextStyle get reviewText => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textGrey,
        height: 1.3,
      );

  static TextStyle get viewServicesLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.2,
      );

  static TextStyle get newBadge => GoogleFonts.inter(
        fontSize: 11,
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

class _TripDetailsTopBar extends StatelessWidget {
  const _TripDetailsTopBar({
    required this.onDuplicate,
    required this.isDuplicating,
  });

  final VoidCallback onDuplicate;
  final bool isDuplicating;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.arrow_back),
                color: _TDDesign.primary,
                iconSize: 22,
              ),
              Text('Trip Details', style: _TDDesign.appBarTitle),
              const Spacer(),
              IconButton(
                onPressed: isDuplicating ? null : onDuplicate,
                icon: isDuplicating
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _TDDesign.primary,
                        ),
                      )
                    : const Icon(Icons.content_copy_outlined),
                color: _TDDesign.primary,
                iconSize: 20,
                tooltip: 'Duplicate trip',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
                color: _TDDesign.primary,
                iconSize: 22,
              ),
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(left: 4),
                decoration: const BoxDecoration(
                  color: _TDDesign.textDark,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'O',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: _TDDesign.border),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({
    required this.imageUrl,
    required this.statusLabel,
  });

  final String imageUrl;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_TDDesign.heroRadius),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFD0D5DD),
                child: const Icon(Icons.landscape_outlined,
                    size: 48, color: Colors.white54),
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _TDDesign.badgeActive,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusLabel,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _TDDesign.card,
        borderRadius: BorderRadius.circular(_TDDesign.cardRadius),
        border: Border.all(color: _TDDesign.cardBorder),
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
          Icon(icon, size: 20, color: _TDDesign.primary),
          const SizedBox(height: 10),
          Text(label, style: _TDDesign.statLabel),
          const SizedBox(height: 4),
          Text(value, style: _TDDesign.statValue),
        ],
      ),
    );
  }
}

class _RecommendedProvidersCard extends StatelessWidget {
  const _RecommendedProvidersCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _TDDesign.card,
        borderRadius: BorderRadius.circular(_TDDesign.cardRadius),
        border: Border.all(color: _TDDesign.cardBorder),
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
          Text('Recommended Providers',
              style: _TDDesign.recommendedTitle),
          const SizedBox(height: 4),
          Text(
            'Expert services tailored to your trip details',
            style: _TDDesign.recommendedSubtitle,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: _TDDesign.innerCard,
              borderRadius: BorderRadius.circular(_TDDesign.innerCardRadius),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFFE4E7EC),
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Luxury Linens',
                        style: _TDDesign.providerCardName),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star,
                            size: 14, color: _TDDesign.textDark),
                        const SizedBox(width: 4),
                        Text('4.9 ', style: _TDDesign.reviewText),
                        Text('Ltd reviews',
                            style: _TDDesign.reviewText.copyWith(
                                color: _TDDesign.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: _TDDesign.primary, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Text('View Services',
                            style: _TDDesign.viewServicesLabel),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _TDDesign.badgeTop,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'TOP',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
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

class _NewBadge extends StatelessWidget {
  const _NewBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _TDDesign.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$count New', style: _TDDesign.newBadge),
    );
  }
}

enum _ProviderTag { recommended, standard, rejected }

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.offer,
    required this.priceLabel,
    required this.tag,
    required this.isUpdating,
    required this.onAccept,
    required this.onReject,
  });

  final OfferModel offer;
  final String priceLabel;
  final _ProviderTag tag;
  final bool isUpdating;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  String get _serviceLabel {
    if (offer.description.isNotEmpty) return offer.description;
    return offer.provider.providerType ?? 'Provider service';
  }

  String get _initials {
    final name = offer.provider.name.trim();
    if (name.isEmpty) return 'P';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _TDDesign.card,
        borderRadius: BorderRadius.circular(_TDDesign.cardRadius),
        border: Border.all(color: _TDDesign.cardBorder),
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
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE4E7EC),
                child: Text(
                  _initials,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _TDDesign.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer.provider.name, style: _TDDesign.providerName),
                    const SizedBox(height: 2),
                    Text(_serviceLabel, style: _TDDesign.providerService),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(priceLabel, style: _TDDesign.providerPrice),
                  const SizedBox(height: 6),
                  _ProviderTagChip(tag: tag),
                ],
              ),
            ],
          ),
          if (offer.isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: isUpdating ? null : onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _TDDesign.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: const StadiumBorder(),
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
                          : Text('Accept Offer', style: _TDDesign.acceptLabel),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: isUpdating ? null : onReject,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _TDDesign.border),
                        shape: const StadiumBorder(),
                        backgroundColor: Colors.white,
                      ),
                      child: Text('Reject Offer', style: _TDDesign.rejectLabel),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
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

class _ProviderTagChip extends StatelessWidget {
  const _ProviderTagChip({required this.tag});

  final _ProviderTag tag;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String label;
    switch (tag) {
      case _ProviderTag.recommended:
        bg = _TDDesign.tagRecommendedBg;
        fg = _TDDesign.tagRecommendedText;
        label = 'Recommended';
      case _ProviderTag.standard:
        bg = _TDDesign.tagStandardBg;
        fg = _TDDesign.tagStandardText;
        label = 'Standard';
      case _ProviderTag.rejected:
        bg = _TDDesign.tagRejectedBg;
        fg = _TDDesign.tagRejectedText;
        label = 'Rejected';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: _TDDesign.tagLabel(fg)),
    );
  }
}

class _TDBottomNav extends StatelessWidget {
  const _TDBottomNav({
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
        color: _TDDesign.card,
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
                        style: _TDDesign.navLabel(
                          active ? _TDDesign.primary : _TDDesign.navInactive,
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
      color: active ? _TDDesign.primary : _TDDesign.navInactive,
    );

    Widget child = active
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _TDDesign.primary.withValues(alpha: 0.12),
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
                color: _TDDesign.notificationDot,
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
