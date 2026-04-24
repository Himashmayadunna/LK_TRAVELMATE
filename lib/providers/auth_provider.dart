import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;

  String _displayName = 'Traveler';
  String _email = 'traveler@example.com';
  bool _isLoggedIn = false;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      currentUser = user;
      _isLoggedIn = user != null;
      if (user != null) {
        _displayName = user.displayName ?? 'Traveler';
        _email = user.email ?? 'traveler@example.com';
      } else {
        _displayName = '';
        _email = '';
      }
      notifyListeners();
    });
  }

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

  Future<void> signUp({required String name, required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name immediately
      await userCredential.user?.updateDisplayName(name);
      
      _displayName = name;
      _email = email;
      _isLoggedIn = true;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      debugPrint('SignUp Failed: ${e.message}');
      throw Exception(e.message ?? 'Unknown error occurred.');
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('SignIn Failed: ${e.message}');
      throw Exception(e.message ?? 'Unknown error occurred.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
