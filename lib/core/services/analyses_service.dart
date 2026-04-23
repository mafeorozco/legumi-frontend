import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_client.dart';

class AnalysesService {
  final _client = ApiClient();
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String get _baseUrl => dotenv.env['API_URL'] ?? '';

  // SUBIR IMAGEN (multipart — no JSON)

  Future<Map<String, dynamic>> createAnalysis({
    // required int  greenhouseId,
    required File imageFile,
  }) async {
    final token = await _storage.read(key: 'access_token');

    final request =
        http.MultipartRequest('POST', Uri.parse('$_baseUrl/detections/predict'))
          ..headers['Authorization'] = 'Bearer $token'
          // ..fields['greenhouse_id']  = greenhouseId.toString()
          ..files.add(
            await http.MultipartFile.fromPath(
              'image',
              imageFile.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(data);
    }
    throw Exception(data['detail'] ?? 'Error al crear análisis');
  }

  // GUARDAR CELDAS AFECTADAS

  Future<List<dynamic>> addPlantLocations(
    int resultId,
    List<Map<String, int>> locations,
    int greenhouseId,
  ) async {
    final token = await _storage.read(key: 'access_token');
    final bodyMap = {
  'greenhouse_id': greenhouseId,
  'locations': locations,
};

print('Body enviado: ${jsonEncode(bodyMap)}'); // ← verifica en consola

final response = await http.post(
  Uri.parse('$_baseUrl/analyses/results/$resultId/locations'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
  body: jsonEncode(bodyMap),
);

print('Status: ${response.statusCode}');
print('Response: ${response.body}');

    final data      = jsonDecode(utf8.decode(response.bodyBytes));

    return List<Map<String, dynamic>>.from(data);

    // final data = await _client.post(
    //   '/analyses/results/$resultId/locations',
    //   body: {
    //     'locations': locations, 
    //     'greenhouse_id':greenhouseId
    //   },
    // );
    // return List.from(data);
  }

  // HISTORIAL — mis análisis

  Future<List<Map<String, dynamic>>> fetchMyAnalyses() async {
    final data = await _client.get('/analyses/my');
    return List<Map<String, dynamic>>.from(data);
  }

  // HISTORIAL — por invernadero

  Future<List<Map<String, dynamic>>> fetchAnalysesByGreenhouse(
    int greenhouseId,
  ) async {
    final data = await _client.get('/analyses/greenhouse/$greenhouseId');
    return List<Map<String, dynamic>>.from(data);
  }

  // DETALLE DE UN ANÁLISIS

  Future<Map<String, dynamic>> fetchAnalysis(int analysisId) async {
    final data = await _client.get('/analyses/$analysisId');
    return Map<String, dynamic>.from(data);
  }
}
