import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  String _displayName = 'Traveler';
  String _email = 'traveler@example.com';
  bool _isLoggedIn = true;

  String get displayName => _displayName;
  String get email => _email;
  bool get isLoggedIn => _isLoggedIn;

  String get initials {
    if (_displayName.isEmpty) return 'T';
    final names = _displayName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return _displayName[0].toUpperCase();
  }

  void setUser({required String name, required String email}) {
    _displayName = name;
    _email = email;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    // Simulate sign out delay
    await Future.delayed(const Duration(milliseconds: 300));
    _displayName = '';
    _email = '';
    _isLoggedIn = false;
    notifyListeners();
  }
}
