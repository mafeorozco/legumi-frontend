import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UsersServices {
  final baseUrl = dotenv.env['API_URL'];

  // Future<Map<String, dynamic>> fetchUsers() async {
  //   try{
  //     final response = await http
  //   }
  // }

  //Aqui estoy ingresando un nuevo usuario
  Future<Map<String, dynamic>> insertUser(Map<String, dynamic> data) async {
    try {
      debugPrint("Llego hasta aqui");
      final response = await http.post(
        Uri.parse('$baseUrl/users/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al registrar usuario: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al registrar usuario: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
