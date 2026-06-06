import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flunexia_app/core/constants/api_constants.dart';
import 'package:flunexia_app/core/services/api_service.dart';
import 'package:flunexia_app/core/services/storage_service.dart';
import 'package:flunexia_app/features/organizer Dashboard/data/models/dashboard_model.dart';

class DashboardException implements Exception {
  DashboardException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AnalyticsRepository {
  AnalyticsRepository({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? ApiService(),
        _storageService = storageService ?? StorageService();

  final ApiService _apiService;
  final StorageService _storageService;

  Future<DashboardResponseModel> fetchMobileDashboard() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      throw DashboardException('You are not logged in. Please sign in again.');
    }

    http.Response response;
    try {
      response = await _apiService.get(
        ApiConstants.mobileDashboard,
        token: token,
      );
    } on http.ClientException {
      throw DashboardException(
        'Unable to connect. Please check your internet connection.',
      );
    }

    if (response.body.trim().isEmpty) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw DashboardException('Session expired. Please sign in again.');
      }
      throw DashboardException('Empty server response. Please try again.');
    }

    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw DashboardException('Invalid server response. Please try again.');
      }
      data = decoded;
    } catch (error) {
      if (error is DashboardException) rethrow;
      throw DashboardException(
        response.statusCode == 401
            ? 'Session expired. Please sign in again.'
            : 'Invalid server response. Please try again.',
      );
    }

    if (response.statusCode == 200 && data['success'] == true) {
      try {
        return DashboardResponseModel.fromJson(data);
      } catch (_) {
        throw DashboardException('Failed to parse dashboard data.');
      }
    }

    throw DashboardException(_extractErrorMessage(data, response.statusCode));
  }

  String _extractErrorMessage(Map<String, dynamic> data, int statusCode) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;

    final error = data['error'];
    if (error is String && error.isNotEmpty) return error;
    if (error is Map) {
      final nested = error['message'];
      if (nested is String && nested.isNotEmpty) return nested;
    }

    if (statusCode == 401 || statusCode == 403) {
      return 'Session expired. Please sign in again.';
    }

    return 'Failed to load dashboard data.';
  }
}
