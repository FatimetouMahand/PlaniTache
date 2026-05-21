import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // 10.0.2.2 est l'adresse IP de la machine hôte pour l'émulateur Android.
  // Pour le web, iOS ou appareil physique, utilisez 'localhost' ou l'IP de votre machine.
  static const String _baseUrl = 'http://localhost:8080/api';
  // Modifiez à true si vous testez sur l'émulateur Android officiel
  static const bool useAndroidEmulator = false;
  
  static String get baseUrl => useAndroidEmulator ? 'http://10.0.2.2:8080/api' : _baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  static Future<http.Response> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    return await http.get(url, headers: headers);
  }

  static Future<http.Response> post(String path, dynamic body) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    final encodedBody = body != null ? jsonEncode(body) : null;
    return await http.post(url, headers: headers, body: encodedBody);
  }

  static Future<http.Response> put(String path, dynamic body) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    final encodedBody = body != null ? jsonEncode(body) : null;
    return await http.put(url, headers: headers, body: encodedBody);
  }

  static Future<http.Response> delete(String path) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    return await http.delete(url, headers: headers);
  }
}
