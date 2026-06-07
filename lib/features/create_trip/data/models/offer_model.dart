class OfferProviderModel {
  const OfferProviderModel({
    required this.id,
    required this.name,
    this.providerType,
    this.email,
  });

  final String id;
  final String name;
  final String? providerType;
  final String? email;

  factory OfferProviderModel.fromJson(Map<String, dynamic> json) {
    return OfferProviderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      providerType: json['providerType']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

class OfferModel {
  const OfferModel({
    required this.id,
    required this.provider,
    required this.description,
    required this.price,
    required this.currency,
    required this.status,
    required this.tier,
  });

  final String id;
  final OfferProviderModel provider;
  final String description;
  final num price;
  final String currency;
  final String status;
  final String tier;

  bool get isPending {
    final value = status.toLowerCase();
    return value == 'pending' || value == 'submitted' || value == 'new';
  }

  bool get isAccepted => status.toLowerCase() == 'accepted';

  bool get isRejected => status.toLowerCase() == 'rejected';

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final providerJson = json['provider'];
    return OfferModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      provider: providerJson is Map<String, dynamic>
          ? OfferProviderModel.fromJson(providerJson)
          : const OfferProviderModel(id: '', name: 'Provider'),
      description: json['description']?.toString() ?? '',
      price: _readNum(json['price']) ?? 0,
      currency: json['currency']?.toString() ?? 'EUR',
      status: json['status']?.toString() ?? '',
      tier: json['tier']?.toString() ?? 'standard',
    );
  }

  OfferModel copyWith({
    String? status,
    String? tier,
  }) {
    return OfferModel(
      id: id,
      provider: provider,
      description: description,
      price: price,
      currency: currency,
      status: status ?? this.status,
      tier: tier ?? this.tier,
    );
  }

  static num? _readNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}

class UpdateOfferStatusResponse {
  const UpdateOfferStatusResponse({
    required this.success,
    required this.offer,
  });

  final bool success;
  final OfferModel offer;

  factory UpdateOfferStatusResponse.fromJson(Map<String, dynamic> json) {
    return UpdateOfferStatusResponse(
      success: json['success'] == true,
      offer: OfferModel.fromJson(
        json['offer'] is Map<String, dynamic>
            ? json['offer'] as Map<String, dynamic>
            : {},
      ),
    );
  }
}

class OffersListResponse {
  const OffersListResponse({
    required this.success,
    required this.offers,
  });

  final bool success;
  final List<OfferModel> offers;

  factory OffersListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['offers'] ?? json['data'];
    return OffersListResponse(
      success: json['success'] == true,
      offers: raw is List
          ? raw
              .whereType<Map>()
              .map((item) => OfferModel.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
    );
  }
}

class TripRequestsResponse {
  const TripRequestsResponse({
    required this.success,
    required this.requestIds,
  });

  final bool success;
  final List<String> requestIds;

  factory TripRequestsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['requests'] ?? json['data'];
    final ids = <String>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final id = item['_id'] ?? item['id'];
          if (id != null) ids.add(id.toString());
        }
      }
    }
    return TripRequestsResponse(
      success: json['success'] == true,
      requestIds: ids,
    );
  }
}
