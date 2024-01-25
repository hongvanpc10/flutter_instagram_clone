import 'package:flutter/material.dart';
import 'package:instagram/models/user.dart' as model;
import 'package:instagram/services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  model.User? user;
  final _authService = AuthService();

  Future<void> refreshUser() async {
    user = await _authService.getUserDetails();
    notifyListeners();
  }
}
