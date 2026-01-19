import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import '../models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isLoading = false;

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );
      return user;
    } catch (e) {
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();
    try {
      await _authService.logout();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
