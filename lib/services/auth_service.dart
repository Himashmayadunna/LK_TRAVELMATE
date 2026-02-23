import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SIGN UP
  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // 1) Create user in Firebase Auth (throws FirebaseAuthException on failure)
    UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;

    // 2) Update display name — fire-and-forget so it doesn't block navigation
    user?.updateDisplayName(name).catchError((e) {
      print("updateDisplayName failed (non-fatal): $e");
    });

    // 3) Save to Firestore — fire-and-forget so it doesn't block navigation
    //    Data will sync to the server in the background via Firestore persistence.
    if (user != null) {
      _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'createdAt': Timestamp.now(),
      }).catchError((e) {
        print("Firestore write failed (non-fatal): $e");
      });
    }

    return user;
  }

  // SIGN IN
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    // Throws FirebaseAuthException on failure — let it propagate
    UserCredential userCredential =
        await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential.user;
  }

  // LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // GET CURRENT USER
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Convert FirebaseAuthException codes to user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      // Check if the error message contains CONFIGURATION_NOT_FOUND
      // (Firebase returns this as code "unknown" with the real info in the message)
      final message = error.message ?? '';
      if (message.contains('CONFIGURATION_NOT_FOUND')) {
        return 'Firebase Authentication is not configured.\n'
            '1. Go to Firebase Console → Authentication → Sign-in method\n'
            '2. Enable Email/Password provider\n'
            '3. Add SHA-1 fingerprint in Project Settings';
      }

      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already registered. Please sign in instead.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'weak-password':
          return 'The password is too weak. Use at least 6 characters.';
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-credential':
          return 'Invalid email or password. Please try again.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait and try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'operation-not-allowed':
          return 'Email/password sign-in is not enabled in Firebase Console.';
        case 'internal-error':
          return 'Firebase Auth is not properly configured. Please enable Email/Password authentication in Firebase Console.';
        case 'configuration-not-found':
          return 'Firebase project configuration error. Check Firebase Console setup.';
        case 'app-not-authorized':
          return 'This app is not authorized. Add SHA-1 fingerprint in Firebase Console.';
        case 'channel-error':
          return 'Communication error. Please try again.';
        case 'unknown':
          // "unknown" code often wraps CONFIGURATION_NOT_FOUND or other backend errors
          if (message.contains('CONFIGURATION_NOT_FOUND') ||
              message.contains('internal error')) {
            return 'Firebase Authentication is not configured. '
                'Enable Email/Password in Firebase Console → Authentication → Sign-in method.';
          }
          return 'An unexpected error occurred. Please try again. (${error.message})';
        default:
          // Show error code for debugging unhandled cases
          return '${error.message ?? 'Authentication failed'} (code: ${error.code})';
      }
    }
    return 'Something went wrong: ${error.toString()}';
  }
}