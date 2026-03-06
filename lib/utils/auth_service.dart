import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current Firebase user (null if not logged in)
  static User? get currentUser => _auth.currentUser;

  /// Whether a user is logged in
  static bool get isLoggedIn => _auth.currentUser != null;

  /// Stream of auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get display name or fallback
  static String get displayName =>
      _auth.currentUser?.displayName ?? 'Traveler';

  /// Get email
  static String get email => _auth.currentUser?.email ?? '';

  /// Get user initials for avatar
  static String get initials {
    final name = displayName;
    if (name.isEmpty || name == 'Traveler') return 'T';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  /// Sign in with email and password
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
