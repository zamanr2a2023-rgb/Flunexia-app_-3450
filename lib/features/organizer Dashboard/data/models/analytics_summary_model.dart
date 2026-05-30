import 'package:flunexia_app/data/models/base_model.dart';

class AnalyticsSummaryModel implements BaseModel {
  const AnalyticsSummaryModel({required this.label, required this.value});

  final String label;
  final num value;

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummaryModel(
      label: json['label'] as String? ?? '',
      value: json['value'] as num? ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'label': label, 'value': value};
}
