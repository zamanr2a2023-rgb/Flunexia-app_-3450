import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flunexia_app/core/constants/api_constants.dart';
import 'package:flunexia_app/core/services/api_service.dart';
import 'package:flunexia_app/core/services/storage_service.dart';
import 'package:flunexia_app/features/create_trip/data/trip_repository.dart';
import 'package:flunexia_app/features/requests/data/models/request_model.dart';

class RequestRepository {
  RequestRepository({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? ApiService(),
        _storageService = storageService ?? StorageService();

  final ApiService _apiService;
  final StorageService _storageService;

  Future<List<BookingRequestModel>> fetchRequests({String? status}) async {
    final token = await _requireToken();

    http.Response response;
    try {
      response = await _apiService.get(
        ApiConstants.requestsList(status: status),
        token: token,
      );
    } on http.ClientException {
      throw TripException(
        'Unable to connect. Please check your internet connection.',
      );
    }

    final data = _decodeMap(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return RequestsListResponse.fromJson(data).requests;
    }

    throw TripException(_extractErrorMessage(data, response.statusCode));
  }

  Future<String> _requireToken() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      throw TripException('You are not logged in. Please sign in again.');
    }
    return token;
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    if (response.body.trim().isEmpty) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw TripException('Session expired. Please sign in again.');
      }
      throw TripException('Empty server response. Please try again.');
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw TripException('Invalid server response. Please try again.');
      }
      if (response.statusCode >= 400) {
        throw TripException(_extractErrorMessage(decoded, response.statusCode));
      }
      return decoded;
    } catch (error) {
      if (error is TripException) rethrow;
      throw TripException('Invalid server response. Please try again.');
    }
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

    return 'Failed to load requests. Please try again.';
  }
}
