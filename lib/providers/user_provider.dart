// user_provider.dart
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _email;

  String? get userEmail => _email; // Add this getter

  void setUser(String email) {
    _email = email;
    notifyListeners();
  }
}
