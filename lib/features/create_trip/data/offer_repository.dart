import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flunexia_app/core/constants/api_constants.dart';
import 'package:flunexia_app/core/services/api_service.dart';
import 'package:flunexia_app/core/services/storage_service.dart';
import 'package:flunexia_app/features/create_trip/data/models/offer_model.dart';
import 'package:flunexia_app/features/create_trip/data/trip_repository.dart';

class OfferRepository {
  OfferRepository({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? ApiService(),
        _storageService = storageService ?? StorageService();

  final ApiService _apiService;
  final StorageService _storageService;

  Future<List<OfferModel>> fetchOffersForTrip(String tripId) async {
    final token = await _requireToken();
    if (tripId.trim().isEmpty) return const [];

    final requestsResponse = await _get(
      ApiConstants.requestsByTrip(tripId.trim()),
      token,
    );
    final requestsData = _decodeMap(requestsResponse);
    final requestIds = TripRequestsResponse.fromJson(requestsData).requestIds;

    final offers = <OfferModel>[];
    for (final requestId in requestIds) {
      if (requestId.isEmpty) continue;
      try {
        final offersResponse = await _get(
          ApiConstants.requestOffers(requestId),
          token,
        );
        final offersData = _decodeMap(offersResponse);
        offers.addAll(OffersListResponse.fromJson(offersData).offers);
      } catch (_) {
        continue;
      }
    }

    return offers;
  }

  Future<List<OfferModel>> fetchOffersForRequest(String requestId) async {
    final token = await _requireToken();
    if (requestId.trim().isEmpty) return const [];

    final offersResponse = await _get(
      ApiConstants.requestOffers(requestId.trim()),
      token,
    );
    final offersData = _decodeMap(offersResponse);
    return OffersListResponse.fromJson(offersData).offers;
  }

  Future<UpdateOfferStatusResponse> updateOfferStatus({
    required String offerId,
    required String status,
    String? feedback,
  }) async {
    final token = await _requireToken();
    if (offerId.trim().isEmpty) {
      throw TripException('Offer not found.');
    }

    final body = <String, dynamic>{'status': status};
    if (feedback != null && feedback.trim().isNotEmpty) {
      body['feedback'] = feedback.trim();
    }

    http.Response response;
    try {
      response = await _apiService.patch(
        ApiConstants.offerStatus(offerId.trim()),
        body: body,
        token: token,
      );
    } on http.ClientException {
      throw TripException(
        'Unable to connect. Please check your internet connection.',
      );
    }

    return _parseStatusResponse(response);
  }

  Future<String> _requireToken() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      throw TripException('You are not logged in. Please sign in again.');
    }
    return token;
  }

  Future<http.Response> _get(String endpoint, String token) async {
    try {
      return await _apiService.get(endpoint, token: token);
    } on http.ClientException {
      throw TripException(
        'Unable to connect. Please check your internet connection.',
      );
    }
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

  UpdateOfferStatusResponse _parseStatusResponse(http.Response response) {
    final data = _decodeMap(response);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data['success'] == true) {
      try {
        return UpdateOfferStatusResponse.fromJson(data);
      } catch (_) {
        throw TripException('Failed to parse offer response.');
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

    return 'Failed to update offer. Please try again.';
  }
}
