class CreateTripResponseModel {
  const CreateTripResponseModel({
    required this.success,
    required this.trip,
  });

  final bool success;
  final CreatedTripModel trip;

  factory CreateTripResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateTripResponseModel(
      success: json['success'] == true,
      trip: CreatedTripModel.fromJson(
        json['trip'] is Map<String, dynamic>
            ? json['trip'] as Map<String, dynamic>
            : {},
      ),
    );
  }
}

class CreatedTripModel {
  const CreatedTripModel({
    required this.id,
    required this.title,
    required this.location,
    required this.status,
    this.image,
    this.startDate,
    this.endDate,
    this.description,
    this.participants,
    this.budgetEstimate,
    this.budgetCurrency,
  });

  final String id;
  final String title;
  final String location;
  final String status;
  final String? image;
  final String? startDate;
  final String? endDate;
  final String? description;
  final int? participants;
  final num? budgetEstimate;
  final String? budgetCurrency;

  factory CreatedTripModel.fromJson(Map<String, dynamic> json) {
    return CreatedTripModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      image: json['image'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      description: json['description']?.toString(),
      participants: _readInt(json['participants']),
      budgetEstimate: _readNum(json['budgetEstimate']),
      budgetCurrency: json['budgetCurrency']?.toString(),
    );
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static num? _readNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}
