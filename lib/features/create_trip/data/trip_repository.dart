import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
      final bytes = request.imageBytes!;
      final contentType = _resolveImageContentType(bytes, request.imageName);
      imageFile = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: _resolveImageFilename(request.imageName, contentType),
        contentType: contentType,
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

    return _parseTripResponse(response);
  }

  Future<CreateTripResponseModel> duplicateTrip(String tripId) async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      throw TripException('You are not logged in. Please sign in again.');
    }
    if (tripId.trim().isEmpty) {
      throw TripException('Trip not found.');
    }

    http.Response response;
    try {
      response = await _apiService.post(
        ApiConstants.tripDuplicate(tripId.trim()),
        token: token,
      );
    } on http.ClientException {
      throw TripException(
        'Unable to connect. Please check your internet connection.',
      );
    }

    return _parseTripResponse(response);
  }

  Future<CreateTripResponseModel> fetchTripById(String tripId) async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      throw TripException('You are not logged in. Please sign in again.');
    }
    if (tripId.trim().isEmpty) {
      throw TripException('Trip not found.');
    }

    http.Response response;
    try {
      response = await _apiService.get(
        ApiConstants.tripById(tripId.trim()),
        token: token,
      );
    } on http.ClientException {
      throw TripException(
        'Unable to connect. Please check your internet connection.',
      );
    }

    return _parseTripResponse(response);
  }

  CreateTripResponseModel _parseTripResponse(http.Response response) {
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

    if (response.statusCode == 200 && data['trip'] is Map<String, dynamic>) {
      try {
        return CreateTripResponseModel(
          success: true,
          trip: CreatedTripModel.fromJson(
            data['trip'] as Map<String, dynamic>,
          ),
        );
      } catch (_) {
        throw TripException('Failed to parse trip response.');
      }
    }

    if (response.statusCode == 200 &&
        (data['_id'] != null || data['id'] != null)) {
      try {
        return CreateTripResponseModel(
          success: true,
          trip: CreatedTripModel.fromJson(data),
        );
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

  MediaType _resolveImageContentType(List<int> bytes, String? filename) {
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return MediaType('image', 'png');
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return MediaType('image', 'jpeg');
    }
    if (bytes.length >= 6 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46) {
      return MediaType('image', 'gif');
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46) {
      return MediaType('image', 'webp');
    }

    final name = filename?.toLowerCase() ?? '';
    if (name.endsWith('.png')) return MediaType('image', 'png');
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (name.endsWith('.gif')) return MediaType('image', 'gif');
    if (name.endsWith('.webp')) return MediaType('image', 'webp');

    return MediaType('image', 'jpeg');
  }

  String _resolveImageFilename(String? name, MediaType contentType) {
    final base = (name != null && name.isNotEmpty) ? name : 'cover';
    final lower = base.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp')) {
      return base;
    }

    final ext = contentType.subtype == 'jpeg' ? 'jpg' : contentType.subtype;
    return '$base.$ext';
  }
}
