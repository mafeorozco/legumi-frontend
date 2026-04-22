import 'api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GreenhousesService {
  final _client = ApiClient();
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String get _baseUrl => dotenv.env['API_URL'] ?? '';

  // Mis invernaderos (admin + operario)
  Future<List<Map<String, dynamic>>> fetchMyGreenhouses() async {
    final token = await _storage.read(key: 'access_token');

    final request = http.MultipartRequest(
      'GET',
      Uri.parse('$_baseUrl/greenhouses/my'),
    )..headers['Authorization'] = 'Bearer $token';

  final streamed  = await request.send();
    final response  = await http.Response.fromStream(streamed);
    final data      = jsonDecode(utf8.decode(response.bodyBytes));

    return List<Map<String, dynamic>>.from(data);
  }

  // Ver detalle de un invernadero
  Future<Map<String, dynamic>> fetchGreenhouse(int id) async {
    final data = await _client.get('/greenhouses/$id');
    return Map<String, dynamic>.from(data);
  }

  // Crear invernadero — solo admin
  Future<Map<String, dynamic>> createGreenhouse({
    required String name,
    required int rows,
    required int columns,
  }) async {
    final data = await _client.post(
      '/greenhouses/',
      body: {'name': name, 'rows': rows, 'columns': columns},
    );
    return Map<String, dynamic>.from(data);
  }

  // Editar invernadero — solo admin
  Future<Map<String, dynamic>> updateGreenhouse(
    int id, {
    String? name,
    int? rows,
    int? columns,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (rows != null) body['rows'] = rows;
    if (columns != null) body['columns'] = columns;

    final data = await _client.put('/greenhouses/$id', body: body);
    return Map<String, dynamic>.from(data);
  }

  // Eliminar — solo admin
  Future<void> deleteGreenhouse(int id) async {
    await _client.delete('/greenhouses/$id');
  }

  // Escanear QR → vincularse como operario
  Future<Map<String, dynamic>> scanQR(String qrCode) async {
    final data = await _client.post(
      '/greenhouses/scan-qr',
      body: {'qr_code': qrCode},
    );
    return Map<String, dynamic>.from(data);
  }
}
