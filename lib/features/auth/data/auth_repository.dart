import 'dart:convert';

import 'package:flunexia_app/core/constants/api_constants.dart';
import 'package:flunexia_app/core/services/api_service.dart';
import 'package:flunexia_app/core/services/storage_service.dart';
import 'package:flunexia_app/features/auth/data/models/login_response_model.dart';

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? ApiService(),
        _storageService = storageService ?? StorageService();

  final ApiService _apiService;
  final StorageService _storageService;

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConstants.login,
      body: {
        'email': email.trim(),
        'password': password,
      },
    );

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthException('Invalid server response. Please try again.');
    }

    if (response.statusCode == 200 && data['success'] == true) {
      final loginResponse = LoginResponseModel.fromJson(data);
      if (loginResponse.token.isEmpty) {
        throw AuthException('Login failed. No authentication token received.');
      }
      await _storageService.saveToken(loginResponse.token);
      await _storageService.saveUser(loginResponse.user);
      return loginResponse;
    }

    final message = data['message'] as String? ??
        data['error'] as String? ??
        'Login failed. Please check your email and password.';
    throw AuthException(message);
  }

  Future<void> clearSession() => _storageService.clearSession();
}
