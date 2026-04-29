import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? currentUser;

  String _displayName = 'Traveler';
  String _email = 'traveler@example.com';
  String? _photoUrl;
  bool _isLoggedIn = false;
  bool _isUploadingPhoto = false;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      currentUser = user;
      _isLoggedIn = user != null;
      if (user != null) {
        _displayName = user.displayName ?? 'Traveler';
        _email = user.email ?? 'traveler@example.com';
        _photoUrl = user.photoURL;
      } else {
        _displayName = '';
        _email = '';
        _photoUrl = null;
      }
      notifyListeners();
    });
  }

  String get displayName => _displayName;
  String get email => _email;
  String? get photoUrl => _photoUrl;
  bool get isLoggedIn => _isLoggedIn;
  bool get isUploadingPhoto => _isUploadingPhoto;

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
