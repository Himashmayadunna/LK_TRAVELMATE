import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? user;
  String? errorMessage;
  String? _overrideName; // Cached name from signup (since updateDisplayName is async)

  /// Initialize with the currently signed-in user (if any)
  AuthProvider() {
    user = _authService.getCurrentUser();
  }

  /// Whether a user is currently signed in
  bool get isLoggedIn => user != null;

  /// Display name from Firebase Auth (falls back to email prefix or 'Traveler')
  String get displayName {
    if (user == null) return 'Traveler';
    // Use cached override name if displayName hasn't synced yet
    if (_overrideName != null && _overrideName!.isNotEmpty) {
      return _overrideName!;
    }
    if (user!.displayName != null && user!.displayName!.isNotEmpty) {
      return user!.displayName!;
    }
    // Fallback: use part before @ in email
    final email = user!.email ?? '';
    if (email.contains('@')) return email.split('@').first;
    return 'Traveler';
  }

  /// User email
  String get email => user?.email ?? '';

  /// Initials derived from display name (e.g. "John Doe" -> "JD")
  String get initials {
    final name = displayName;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Future<void> signUp(String name, String email, String password) async {
    errorMessage = null;
    try {
      user = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );
      // Cache name locally since updateDisplayName is fire-and-forget
      if (user != null) _overrideName = name;
    } catch (e) {
      user = null;
      _overrideName = null;
      errorMessage = AuthService.getErrorMessage(e);
      debugPrint('SignUp error: $e');
      debugPrint('SignUp error type: ${e.runtimeType}');
      if (e is FirebaseAuthException) {
        debugPrint('SignUp error code: ${e.code}');
        debugPrint('SignUp error message: ${e.message}');
      }
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    errorMessage = null;
    _overrideName = null; // Use Firebase displayName for sign-in
    try {
      user = await _authService.signIn(
        email: email,
        password: password,
      );
    } catch (e) {
      user = null;
      errorMessage = AuthService.getErrorMessage(e);
      debugPrint('SignIn error: $e');
      debugPrint('SignIn error type: ${e.runtimeType}');
      if (e is FirebaseAuthException) {
        debugPrint('SignIn error code: ${e.code}');
        debugPrint('SignIn error message: ${e.message}');
      }
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    user = null;
    _overrideName = null;
    errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}