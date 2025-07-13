import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  set _loading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Email/password sign up
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String role = 'Job_Seeker',
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      _setError('All fields are required');
      return false;
    }

    _loading = true;
    clearError();

    try {
      final UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCred.user;
      if (user == null) {
        _setError('Sign-up failed. Please try again.');
        return false;
      }

      await _firestore.collection(role).doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'loginMethod': 'email',
      });

      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Sign-up failed. Please try again.');
      return false;
    } catch (e) {
      _setError('Unexpected error occurred. Please try again.');
      debugPrint('Sign-up error: $e');
      return false;
    } finally {
      _loading = false;
    }
  }

  /// Google Sign-Up (or Sign-In if already registered)
  Future<bool> signUpWithGoogle({String role = 'Job_Seeker'}) async {
    _loading = true;
    clearError();

    try {
      await _googleSignIn.signOut(); // clean session
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        _setError('Google sign-up failed. Please try again.');
        return false;
      }

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection(role).doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': user.photoURL ?? '',
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'loginMethod': 'google',
        });
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Google sign-up failed.');
      return false;
    } catch (e) {
      _setError('Unexpected error occurred.');
      debugPrint('Google sign-up error: $e');
      return false;
    } finally {
      _loading = false;
    }
  }
}
