import 'package:flunexia_app/data/models/base_model.dart';

class UserModel implements BaseModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.organizationType,
    this.providerType,
    this.companyDescription,
    this.contactPerson,
    this.status,
    this.reviewCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? organizationType;
  final String? providerType;
  final String? companyDescription;
  final String? contactPerson;
  final String? status;
  final int reviewCount;
  final String? createdAt;
  final String? updatedAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      organizationType: json['organizationType'] as String?,
      providerType: json['providerType'] as String?,
      companyDescription: json['companyDescription'] as String?,
      contactPerson: json['contactPerson'] as String?,
      status: json['status'] as String?,
      reviewCount: json['reviewCount'] as int? ?? 0,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        if (organizationType != null) 'organizationType': organizationType,
        if (providerType != null) 'providerType': providerType,
        if (companyDescription != null) 'companyDescription': companyDescription,
        if (contactPerson != null) 'contactPerson': contactPerson,
        if (status != null) 'status': status,
        'reviewCount': reviewCount,
        if (createdAt != null) 'createdAt': createdAt,
        if (updatedAt != null) 'updatedAt': updatedAt,
      };
}
