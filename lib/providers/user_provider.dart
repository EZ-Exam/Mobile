
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _apiService.getUserProfile();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
