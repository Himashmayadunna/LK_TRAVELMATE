import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    print('Firebase initialized');
    
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "test@example.com",
        password: "password123"
    );
    print('User created');
  } catch (e) {
    print('Error: $e');
  }
}
