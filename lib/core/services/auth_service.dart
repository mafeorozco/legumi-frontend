import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String get _baseUrl => dotenv.env['API_URL'] ?? '';

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyUserId = 'user_id';

  // REGISTRO

  Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) return data;
      throw Exception(data['detail'] ?? 'Error al registrarse');
    } catch (e) {
      debugPrint('Error registro: $e');
      rethrow;
    }
  }

  // LOGIN

  Future<bool> login(String email, String password) async {
    try {
      // OAuth2 requiere form-encoded, no JSON
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Guardar tokens en almacenamiento cifrado
        await _storage.write(key: _keyAccessToken, value: data['access_token']);
        await _storage.write(
          key: _keyRefreshToken,
          value: data['refresh_token'],
        );

        // Guardar datos básicos del usuario para mostrar en UI
        final user = data['user'];
        await _storage.write(key: _keyUserId, value: user['id'].toString());
        await _storage.write(key: _keyUserName, value: user['name']);
        await _storage.write(key: _keyUserEmail, value: user['email']);

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error login: $e');
      return false;
    }
  }

  // LOGOUT

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(key: _keyRefreshToken);
      final accessToken = await _storage.read(key: _keyAccessToken);

      if (refreshToken != null && accessToken != null) {
        // Revocar en backend → logout real, no solo local
        await http.post(
          Uri.parse('$_baseUrl/api/v1/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({'refresh_token': refreshToken}),
        );
      }
    } catch (e) {
      debugPrint('Error al revocar token: $e');
    } finally {
      // Siempre limpiar storage local aunque falle el servidor
      await _storage.deleteAll();
    }
  }

  // REFRESH — renovar access token

  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await _storage.read(key: _keyRefreshToken);
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: _keyAccessToken, value: data['access_token']);
        return true;
      }

      // Refresh expirado → limpiar todo, forzar login
      await _storage.deleteAll();
      return false;
    } catch (e) {
      debugPrint('Error refresh: $e');
      return false;
    }
  }

  // USUARIO ACTUAL

  Future<Map<String, dynamic>?> getLoggedUser() async {
    try {
      final token = await _storage.read(key: _keyAccessToken);
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        // Actualizar datos locales por si cambiaron
        await _storage.write(key: _keyUserId, value: user['id'].toString());
        await _storage.write(key: _keyUserName, value: user['name']);
        await _storage.write(key: _keyUserEmail, value: user['email']);
        return user;
      }
      return null;
    } catch (e) {
      debugPrint('Error getLoggedUser: $e');
      return null;
    }
  }

  // CAMBIAR CONTRASEÑA

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _storage.read(key: _keyAccessToken);
    if (token == null) throw Exception('Sesión no válida');

    final response = await http.put(
      Uri.parse('$_baseUrl/api/v1/users/me/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    // Si no es 200, lanzar el error que mandó el servidor
    if (response.statusCode != 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(data['detail'] ?? 'Error al cambiar contraseña');
    }
  }

  // GETTERS

  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);
  Future<String?> getUserName() => _storage.read(key: _keyUserName);
  Future<String?> getUserEmail() => _storage.read(key: _keyUserEmail);

  Future<int?> getUserId() async {
    final id = await _storage.read(key: _keyUserId);
    return id != null ? int.tryParse(id) : null;
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _keyAccessToken);
    return token != null;
  }
}
