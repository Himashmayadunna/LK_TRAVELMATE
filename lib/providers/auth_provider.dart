import 'dart:io';
import 'package:flutter/foundation.dart';

/// Mock Auth Provider - replaces Firebase Auth
/// To enable Firebase Auth later, add google-services.json and restore the original file
class AuthProvider extends ChangeNotifier {
  // Mock user state - no Firebase required
  String? _currentUserId;
  String _displayName = 'Traveler';
  String _email = 'traveler@example.com';
  String? _photoUrl;
  bool _isLoggedIn = false;
  bool _isAuthReady = true; // Always ready since no Firebase init needed

  AuthProvider() {
    // Auto-login for demo purposes
    _currentUserId = 'demo_user_123';
    _displayName = 'Traveler';
    _email = 'traveler@example.com';
    _isLoggedIn = true;
    notifyListeners();
  }

  String? get currentUser => _currentUserId;
  String get displayName => _displayName;
  String get email => _email;
  String? get photoUrl => _photoUrl;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAuthReady => _isAuthReady;

  String get initials {
    if (_displayName.isEmpty) return 'T';
    final names = _displayName.split(' ');
    if (names.length >= 2 && names[0].isNotEmpty && names[1].isNotEmpty) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'T';
  }

  Future<void> uploadProfilePhoto(File imageFile) async {
    if (currentUser == null) return;
    
    try {
      _isUploadingPhoto = true;
      notifyListeners();

      final ref = _storage.ref().child('profile_photos').child('${currentUser!.uid}.jpg');
      await ref.putFile(imageFile);
      
      final downloadUrl = await ref.getDownloadURL();
      
      await currentUser!.updatePhotoURL(downloadUrl);
      _photoUrl = downloadUrl;
      
    } catch (e) {
      debugPrint('Profile photo upload failed: $e');
      rethrow;
    } finally {
      _isUploadingPhoto = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // Mock signup - just store locally
    _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _displayName = name;
    _email = email;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    // Mock signin - accept any credentials for demo
    _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _displayName = email.split('@').first;
    _email = email;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    _currentUserId = null;
    _displayName = '';
    _email = '';
    _isLoggedIn = false;
    notifyListeners();
  }
}
