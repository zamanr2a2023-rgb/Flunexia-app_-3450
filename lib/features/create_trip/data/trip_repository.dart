import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flunexia_app/core/constants/api_constants.dart';
import 'package:flunexia_app/core/services/api_service.dart';
import 'package:flunexia_app/core/services/storage_service.dart';
import 'package:flunexia_app/features/create_trip/data/models/create_trip_response_model.dart';

class TripException implements Exception {
  TripException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CreateTripRequest {
  const CreateTripRequest({
    required this.title,
    required this.description,
    required this.location,
    required this.startDate,
    required this.participants,
    required this.needTypes,
    required this.status,
    this.budgetEstimate,
    this.budgetCurrency = 'EUR',
    this.imageBytes,
    this.imageName,
  });

  final String title;
  final String description;
  final String location;
  final String startDate;
  final String participants;
  final List<String> needTypes;
  final String status;
  final String? budgetEstimate;
  final String budgetCurrency;
  final List<int>? imageBytes;
  final String? imageName;
}

class TripRepository {
  TripRepository({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? ApiService(),
        _storageService = storageService ?? StorageService();

  final ApiService _apiService;
  final StorageService _storageService;

  Future<CreateTripResponseModel> createTrip(CreateTripRequest request) async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      throw TripException('You are not logged in. Please sign in again.');
    }

    final fields = <String, String>{
      'title': request.title.trim(),
      'description': request.description.trim(),
      'location': request.location.trim(),
      'startDate': request.startDate,
      'participants': request.participants.trim(),
      'needTypes': jsonEncode(request.needTypes),
      'status': request.status,
      'budgetCurrency': request.budgetCurrency,
    };

    if (request.budgetEstimate != null && request.budgetEstimate!.isNotEmpty) {
      fields['budgetEstimate'] = request.budgetEstimate!;
    }

    http.MultipartFile? imageFile;
    if (request.imageBytes != null && request.imageBytes!.isNotEmpty) {
      imageFile = http.MultipartFile.fromBytes(
        'image',
        request.imageBytes!,
        filename: request.imageName ?? 'cover.jpg',
      );
    }

    http.Response response;
    try {
      response = await _apiService.postMultipart(
        ApiConstants.trips,
        fields: fields,
        file: imageFile,
        token: token,
      );
    } on http.ClientException {
      throw TripException(
        'Unable to connect. Please check your internet connection.',
      );
    }

    if (response.body.trim().isEmpty) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw TripException('Session expired. Please sign in again.');
      }
      throw TripException('Empty server response. Please try again.');
    }

    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw TripException('Invalid server response. Please try again.');
      }
      data = decoded;
    } catch (error) {
      if (error is TripException) rethrow;
      throw TripException('Invalid server response. Please try again.');
    }

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data['success'] == true) {
      try {
        return CreateTripResponseModel.fromJson(data);
      } catch (_) {
        throw TripException('Failed to parse trip response.');
      }
    }

    throw TripException(_extractErrorMessage(data, response.statusCode));
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

    return 'Failed to create trip. Please try again.';
  }
}
