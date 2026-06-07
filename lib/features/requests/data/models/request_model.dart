class RequestTripModel {
  const RequestTripModel({
    required this.id,
    required this.title,
    this.startDate,
    this.location,
  });

  final String id;
  final String title;
  final String? startDate;
  final String? location;

  factory RequestTripModel.fromJson(Map<String, dynamic> json) {
    return RequestTripModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      startDate: json['startDate'] as String?,
      location: json['location']?.toString(),
    );
  }
}

class RequestProviderModel {
  const RequestProviderModel({
    required this.id,
    required this.name,
    this.providerType,
  });

  final String id;
  final String name;
  final String? providerType;

  factory RequestProviderModel.fromJson(Map<String, dynamic> json) {
    return RequestProviderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      providerType: json['providerType']?.toString(),
    );
  }
}

class RequestOfferSummaryModel {
  const RequestOfferSummaryModel({
    required this.id,
    required this.status,
    this.rejectionReason,
  });

  final String id;
  final String status;
  final String? rejectionReason;

  factory RequestOfferSummaryModel.fromJson(Map<String, dynamic> json) {
    return RequestOfferSummaryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      rejectionReason: json['rejectionReason']?.toString(),
    );
  }
}

class BookingRequestModel {
  const BookingRequestModel({
    required this.id,
    required this.needType,
    required this.message,
    required this.status,
    this.trip,
    this.provider,
    this.acceptedOffer,
  });

  final String id;
  final String needType;
  final String message;
  final String status;
  final RequestTripModel? trip;
  final RequestProviderModel? provider;
  final RequestOfferSummaryModel? acceptedOffer;

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    final tripJson = json['trip'];
    final providerJson = json['provider'];
    final offerJson = json['acceptedOffer'];

    return BookingRequestModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      needType: json['needType']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      trip: tripJson is Map<String, dynamic>
          ? RequestTripModel.fromJson(tripJson)
          : null,
      provider: providerJson is Map<String, dynamic>
          ? RequestProviderModel.fromJson(providerJson)
          : null,
      acceptedOffer: offerJson is Map<String, dynamic>
          ? RequestOfferSummaryModel.fromJson(offerJson)
          : null,
    );
  }
}

class RequestsListResponse {
  const RequestsListResponse({
    required this.success,
    required this.count,
    required this.requests,
  });

  final bool success;
  final int count;
  final List<BookingRequestModel> requests;

  factory RequestsListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['requests'] ?? json['data'];
    return RequestsListResponse(
      success: json['success'] == true,
      count: _readInt(json['count']),
      requests: raw is List
          ? raw
              .whereType<Map>()
              .map(
                (item) => BookingRequestModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
