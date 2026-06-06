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
  });

  final String id;
  final String title;
  final String location;
  final String status;
  final String? image;
  final String? startDate;

  factory CreatedTripModel.fromJson(Map<String, dynamic> json) {
    return CreatedTripModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      image: json['image'] as String?,
      startDate: json['startDate'] as String?,
    );
  }
}
