import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flunexia_app/core/constants/api_constants.dart';
import 'package:flunexia_app/core/services/api_service.dart';
import 'package:flunexia_app/core/services/storage_service.dart';
import 'package:flunexia_app/features/auth/data/models/user_model.dart';

class ProfileException implements Exception {
  ProfileException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProfileRepository {
  ProfileRepository({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? ApiService(),
        _storageService = storageService ?? StorageService();

  final ApiService _apiService;
  final StorageService _storageService;

  Future<UserModel> fetchProfile() async {
    final token = await _requireToken();

    http.Response response;
    try {
      response = await _apiService.get(ApiConstants.usersMe, token: token);
    } on http.ClientException {
      throw ProfileException(
        'Unable to connect. Please check your internet connection.',
      );
    }

    return _parseUserResponse(response);
  }

  Future<UserModel> updateProfile({
    required String name,
    required String organizationType,
  }) async {
    final token = await _requireToken();

    http.Response response;
    try {
      response = await _apiService.patch(
        ApiConstants.usersMe,
        body: {
          'name': name.trim(),
          'organizationType': organizationType.trim(),
        },
        token: token,
      );
    } on http.ClientException {
      throw ProfileException(
        'Unable to connect. Please check your internet connection.',
      );
    }

    final user = _parseUserResponse(response);
    await _storageService.saveUser(user);
    return user;
  }

  Future<String> _requireToken() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      throw ProfileException('You are not logged in. Please sign in again.');
    }
    return token;
  }

  UserModel _parseUserResponse(http.Response response) {
    if (response.body.trim().isEmpty) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw ProfileException('Session expired. Please sign in again.');
      }
      throw ProfileException('Empty server response. Please try again.');
    }

    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ProfileException('Invalid server response. Please try again.');
      }
      data = decoded;
    } catch (error) {
      if (error is ProfileException) rethrow;
      throw ProfileException('Invalid server response. Please try again.');
    }

    if (response.statusCode == 200 && data['success'] == true) {
      final userJson = data['user'];
      if (userJson is Map<String, dynamic>) {
        return UserModel.fromJson(userJson);
      }
    }

    if (response.statusCode == 200 && data['_id'] != null) {
      return UserModel.fromJson(data);
    }

    throw ProfileException(_extractErrorMessage(data, response.statusCode));
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

    return 'Failed to update profile. Please try again.';
  }
}
