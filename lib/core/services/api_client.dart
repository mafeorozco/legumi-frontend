import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

typedef OnSessionExpired = void Function();

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _auth = AuthService();
  OnSessionExpired? onSessionExpired;

  String get _baseUrl => dotenv.env['API_URL'] ?? '';

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getAccessToken();
    return {
      'Content-Type' : 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Maneja el 401 → renueva token → reintenta
  Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    var response = await request();

    if (response.statusCode == 401) {
      debugPrint('Token expirado, renovando...');
      final renewed = await _auth.refreshAccessToken();

      if (renewed) {
        debugPrint('Token renovado, reintentando...');
        response = await request();
      } else {
        debugPrint('Sesión expirada');
        onSessionExpired?.call();
      }
    }

    return response;
  }

  Future<dynamic> get(String path) async {
    final response = await _send(() async {
      return http.get(
        Uri.parse('$_baseUrl/api/v1$path'),
        headers: await _headers(),
      );
    });
    return _parse(response);
  }

  Future<dynamic> post(String path, {dynamic body}) async {
    final response = await _send(() async {
      return http.post(
        Uri.parse('$_baseUrl/api/v1$path'),
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
    });
    return _parse(response);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final response = await _send(() async {
      return http.put(
        Uri.parse('$_baseUrl/api/v1$path'),
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
    });
    return _parse(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await _send(() async {
      return http.delete(
        Uri.parse('$_baseUrl/api/v1$path'),
        headers: await _headers(),
      );
    });
    return _parse(response);
  }

  dynamic _parse(http.Response response) {
    final body = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final detail = body['detail'] ?? 'Error desconocido';
    throw ApiException(
      statusCode: response.statusCode,
      message   : detail is String ? detail : detail.toString(),
    );
  }
}

class ApiException implements Exception {
  final int    statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}