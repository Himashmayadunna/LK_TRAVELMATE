import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? _user;
  bool _isUploadingPhoto = false;
  bool _isAuthReady = false;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isAuthReady = true;
      notifyListeners();
    });
  }

  User? get user => _user;
  String? get currentUser => _user?.uid;
  String get displayName => _user?.displayName ?? 'User';
  String get email => _user?.email ?? '';
  String? get photoUrl => _user?.photoURL;
  bool get isUploadingPhoto => _isUploadingPhoto;
  bool get isLoggedIn => _user != null;
  bool get isAuthReady => _isAuthReady;

  DateTime get memberSince => _user?.metadata.creationTime ?? DateTime.now();

  String get initials {
    if (displayName.isEmpty) return 'T';
    final names = displayName.split(' ');
    if (names.length >= 2 && names[0].isNotEmpty && names[1].isNotEmpty) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : 'T';
  }

  Future<void> uploadProfilePhoto(File imageFile) async {
    if (_user == null) return;
    try {
      _isUploadingPhoto = true;
      notifyListeners();
      final ref = _storage
          .ref()
          .child('user_profiles')
          .child('${_user!.uid}.jpg');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      await _user!.updatePhotoURL(url);
      await _user!.reload();
      _user = _auth.currentUser;
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
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.reload();
        _user = _auth.currentUser;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign up failed');
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign in failed');
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
