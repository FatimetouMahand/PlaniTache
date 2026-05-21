import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _loadSession();
  }

  // Charger la session stockée localement
  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userJson = prefs.getString('user_profile');

    if (token != null && userJson != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(userJson));
        notifyListeners();
        // Vérifier/Rafraîchir le profil depuis le serveur en arrière-plan
        refreshProfile();
      } catch (_) {
        logout();
      }
    }
  }

  Future<void> refreshProfile() async {
    try {
      final response = await ApiClient.get('/auth/profile');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        
        _currentUser = User(
          id: data['id'],
          username: data['username'],
          email: data['email'],
          roles: List<String>.from(data['roles']),
          token: token,
        );
        
        await prefs.setString('user_profile', jsonEncode(_currentUser!.toJson()));
        notifyListeners();
      }
    } catch (_) {
      // Ignorer les erreurs réseau pour le rafraîchissement d'arrière-plan
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.post('/auth/register', {
        'username': username,
        'email': email,
        'password': password,
      });

      _isLoading = false;
      if (response.statusCode == 201) {
        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(utf8.decode(response.bodyBytes));
        _errorMessage = errorData['message'] ?? 'Erreur lors de l\'inscription';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur réseau. Impossible de contacter le serveur.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String usernameOrEmail, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.post('/auth/login', {
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      });

      _isLoading = false;
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        _currentUser = User.fromJson(data);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _currentUser!.token ?? '');
        await prefs.setString('user_profile', jsonEncode(_currentUser!.toJson()));

        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(utf8.decode(response.bodyBytes));
        _errorMessage = errorData['message'] ?? 'Identifiants incorrects';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur de connexion réseau.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_profile');
    notifyListeners();
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await ApiClient.post('/auth/forgot-password', {'email': email});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
