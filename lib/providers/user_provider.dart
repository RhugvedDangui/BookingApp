import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _userEmail;
  bool _isAdmin = false;
  String? _name;

  String? get userEmail => _userEmail;
  bool get isAdmin => _isAdmin;
  String? get name => _name;

  void setUser(String email, {bool isAdmin = false, String? name}) {
    _userEmail = email;
    _isAdmin = isAdmin;
    _name = name;
    debugPrint(
      'UserProvider - Set: email=$email, isAdmin=$isAdmin, name=$name',
    );
    notifyListeners();
  }

  void clearUser() {
    _userEmail = null;
    _isAdmin = false;
    _name = null;
    notifyListeners();
  }
}
