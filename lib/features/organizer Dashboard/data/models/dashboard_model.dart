int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String _readString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString();
}

class DashboardStatsModel {
  const DashboardStatsModel({
    required this.trips,
    required this.pendingRequests,
    required this.acceptedOffers,
    required this.completedBookings,
    this.acceptedRequests = 0,
    this.newOffers = 0,
  });

  final int trips;
  final int pendingRequests;
  final int acceptedOffers;
  final int completedBookings;
  final int acceptedRequests;
  final int newOffers;

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      trips: _readInt(json['trips']),
      pendingRequests: _readInt(json['pendingRequests']),
      acceptedOffers: _readInt(json['acceptedOffers']),
      completedBookings: _readInt(json['completedBookings']),
      acceptedRequests: _readInt(json['acceptedRequests']),
      newOffers: _readInt(json['newOffers']),
    );
  }
}

class DashboardTripModel {
  const DashboardTripModel({
    required this.id,
    required this.title,
    required this.location,
    required this.status,
    this.image,
    this.startDate,
    this.needTypes = const [],
  });

  final String id;
  final String title;
  final String location;
  final String status;
  final String? image;
  final String? startDate;
  final List<String> needTypes;

  factory DashboardTripModel.fromJson(Map<String, dynamic> json) {
    return DashboardTripModel(
      id: _readString(json['_id'] ?? json['id']),
      title: _readString(json['title']),
      location: _readString(json['location']),
      status: _readString(json['status']),
      image: json['image'] as String?,
      startDate: json['startDate'] as String?,
      needTypes: (json['needTypes'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
    );
  }
}

class DashboardResponseModel {
  const DashboardResponseModel({
    required this.success,
    required this.role,
    required this.unreadCount,
    required this.stats,
    required this.recentTrips,
  });

  final bool success;
  final String role;
  final int unreadCount;
  final DashboardStatsModel stats;
  final List<DashboardTripModel> recentTrips;

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) {
    final recent = json['recent'];
    final trips = recent is Map<String, dynamic>
        ? recent['trips'] as List<dynamic>? ?? const []
        : const [];

    return DashboardResponseModel(
      success: json['success'] == true,
      role: _readString(json['role']),
      unreadCount: _readInt(json['unreadCount']),
      stats: DashboardStatsModel.fromJson(
        json['stats'] is Map<String, dynamic>
            ? json['stats'] as Map<String, dynamic>
            : {},
      ),
      recentTrips: trips
          .whereType<Map>()
          .map((trip) => DashboardTripModel.fromJson(
                Map<String, dynamic>.from(trip),
              ))
          .toList(),
    );
  }
}
