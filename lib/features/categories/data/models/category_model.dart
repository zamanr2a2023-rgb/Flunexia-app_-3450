import 'package:flunexia_app/data/models/base_model.dart';

class CategoryModel implements BaseModel {
  const CategoryModel({required this.id, required this.name});

  final String id;
  final String name;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
