import 'package:flunexia_app/data/models/base_model.dart';

class UserModel implements BaseModel {
  const UserModel({required this.id, required this.email});

  final String id;
  final String email;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {'id': id, 'email': email};
}
