import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flunexia_app/core/constants/api_constants.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    return _client.post(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> get(
    String endpoint, {
    String? token,
  }) {
    final headers = <String, String>{
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    return _client.get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
    );
  }

  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    return _client.patch(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    http.MultipartFile? file,
    String fileFieldName = 'image',
    String? token,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
    );

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';
    request.fields.addAll(fields);
    if (file != null) {
      request.files.add(file);
    }

    final streamedResponse = await _client.send(request);
    return http.Response.fromStream(streamedResponse);
  }
}
