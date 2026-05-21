import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/stats.dart';

class StatsProvider extends ChangeNotifier {
  ProductivityStats? _stats;
  bool _isLoading = false;

  ProductivityStats? get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> fetchStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.get('/statistics');
      if (response.statusCode == 200) {
        _stats = ProductivityStats.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (_) {}
    
    _isLoading = false;
    notifyListeners();
  }
}
