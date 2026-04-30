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
  bool _isUploadingPhoto = false;
  bool _isLoggedIn = false;
  bool _isAuthReady = true; // Always ready since no Firebase init needed
  DateTime _memberSince = DateTime.now();
  final List<Map<String, dynamic>> _registeredUsers = [];

  AuthProvider() {
    // Auto-login for demo purposes
    _currentUserId = 'demo_user_123';
    _displayName = 'Traveler';
    _email = 'traveler@example.com';
    _isLoggedIn = true;
    // demo member since and demo users
    _memberSince = DateTime(2023, 6, 1);
    _registeredUsers.addAll([
      {
        'id': _currentUserId,
        'name': _displayName,
        'email': _email,
        'memberSince': _memberSince,
        'photoUrl': _photoUrl,
      },
      {
        'id': 'jane_001',
        'name': 'Jane Doe',
        'email': 'jane@example.com',
        'memberSince': DateTime(2024, 1, 12),
        'photoUrl': null,
      },
    ]);
    notifyListeners();
  }

  String? get currentUser => _currentUserId;
  String get displayName => _displayName;
  String get email => _email;
  String? get photoUrl => _photoUrl;
  bool get isUploadingPhoto => _isUploadingPhoto;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAuthReady => _isAuthReady;
  DateTime get memberSince => _memberSince;
  List<Map<String, dynamic>> get registeredUsers => List.unmodifiable(_registeredUsers);

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

      final localPath = imageFile.path;
      _photoUrl = localPath.startsWith('file://') ? localPath : 'file://$localPath';
      final userIndex = _registeredUsers.indexWhere((user) => user['id'] == _currentUserId);
      if (userIndex != -1) {
        _registeredUsers[userIndex]['photoUrl'] = _photoUrl;
      }

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
    // Mock signup - just store locally and register the user in-memory
    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _currentUserId = id;
    _displayName = name;
    _email = email;
    _isLoggedIn = true;
    _memberSince = DateTime.now();
    _registeredUsers.insert(0, {
      'id': id,
      'name': name,
      'email': email,
      'memberSince': _memberSince,
      'photoUrl': _photoUrl,
    });
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    // Validate inputs
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    if (password.isEmpty) {
      throw Exception('Password cannot be empty');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Mock signin - accept any valid credentials for demo
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));
    
    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _currentUserId = id;
    _displayName = email.split('@').first;
    _email = email;
    _isLoggedIn = true;
    _memberSince = DateTime.now();
    _registeredUsers.insert(0, {
      'id': id,
      'name': _displayName,
      'email': email,
      'memberSince': _memberSince,
      'photoUrl': _photoUrl,
    });
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
