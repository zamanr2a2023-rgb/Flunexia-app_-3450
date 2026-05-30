import 'package:flunexia_app/data/models/base_model.dart';

class VehicleModel implements BaseModel {
  const VehicleModel({required this.id, required this.plateNumber});

  final String id;
  final String plateNumber;

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String? ?? '',
      plateNumber: json['plate_number'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {'id': id, 'plate_number': plateNumber};
}
