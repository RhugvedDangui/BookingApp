import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String? _userEmail;
  bool _isAdmin = false;
  String? _name;

  // Keys for SharedPreferences
  static const String _emailKey = 'user_email';
  static const String _isAdminKey = 'is_admin';
  static const String _nameKey = 'user_name';

  UserProvider() {
    // Load saved data when provider is initialized
    _loadFromPrefs();
  }

  String? get userEmail => _userEmail;
  bool get isAdmin => _isAdmin;
  String? get name => _name;

  // Load user data from SharedPreferences
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userEmail = prefs.getString(_emailKey);
      _isAdmin = prefs.getBool(_isAdminKey) ?? false;
      _name = prefs.getString(_nameKey);
      
      debugPrint(
        'UserProvider - Loaded from prefs: email=$_userEmail, isAdmin=$_isAdmin, name=$_name',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading from SharedPreferences: $e');
    }
  }

  // Save user data to SharedPreferences
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_userEmail != null) {
        await prefs.setString(_emailKey, _userEmail!);
      } else {
        await prefs.remove(_emailKey);
      }
      
      await prefs.setBool(_isAdminKey, _isAdmin);
      
      if (_name != null) {
        await prefs.setString(_nameKey, _name!);
      } else {
        await prefs.remove(_nameKey);
      }
      
      debugPrint('UserProvider - Saved to prefs: email=$_userEmail, isAdmin=$_isAdmin, name=$_name');
    } catch (e) {
      debugPrint('Error saving to SharedPreferences: $e');
    }
  }

  void setUser(String email, {bool isAdmin = false, String? name}) {
    _userEmail = email;
    _isAdmin = isAdmin;
    _name = name;
    debugPrint(
      'UserProvider - Set: email=$email, isAdmin=$isAdmin, name=$name',
    );
    
    // Save to SharedPreferences
    _saveToPrefs();
    
    try {
      notifyListeners();
    } catch (e) {
      debugPrint('Error in notifyListeners: $e');
      // Continue execution even if notifyListeners fails
    }
  }

  void clearUser() {
    _userEmail = null;
    _isAdmin = false;
    _name = null;
    
    // Clear from SharedPreferences
    _saveToPrefs();
    
    try {
      notifyListeners();
    } catch (e) {
      debugPrint('Error in notifyListeners: $e');
      // Continue execution even if notifyListeners fails
    }
  }
}
