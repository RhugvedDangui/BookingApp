import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _userEmail;
  String? _userType;

  String? get userEmail => _userEmail;
  String? get userType => _userType;

  void setUser(String email) {
    _userEmail = email;
    _userType = 'User'; // Set dynamically if you have user type logic
    notifyListeners();
  }

  void clearUser() {
    _userEmail = null;
    _userType = null;
    notifyListeners();
  }
}
