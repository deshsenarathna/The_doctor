import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import '../models/user_model.dart';

class SignupViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isLoading = false;

  Future<UserModel?> signup({
    required String email,
    required String password,
    required String role,
    required String phone,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signup(
        email: email,
        password: password,
        role: role,
        isDoctor: role == 'doctor',
        phone: phone,
      );
      return user;
    } catch (e) {
      print('Signup error: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
