import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  // Private setter for loading state
  set _loading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Initialize auth state listener
  void initAuthStateListener() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  /// Improved login with better error handling and validation
  Future<bool> login({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _setError('Email and password cannot be empty');
      return false;
    }

    _loading = true;
    clearError();

    try {
      // First authenticate with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        _setError('Authentication failed');
        return false;
      }

      // Then verify user role from Firestore
      final bool roleVerified = await _verifyUserRole(
          userCredential.user!.uid,
          expectedRole
      );

      if (!roleVerified) {
        // Sign out if role doesn't match
        await _auth.signOut();
        _setError('This account is not registered as a $expectedRole');
        return false;
      }

      _currentUser = userCredential.user;
      return true;

    } on FirebaseAuthException catch (e) {
      await _handleAuthException(e);
      return false;
    } catch (e) {
      _setError('Unexpected error occurred. Please try again.');
      debugPrint('Login error: $e');
      return false;
    } finally {
      _loading = false;
    }
  }

  /// Verify user role from Firestore
  Future<bool> _verifyUserRole(String uid, String expectedRole) async {
    try {
      // Check in Job_Seeker collection
      DocumentSnapshot jobSeekerDoc = await _firestore
          .collection('Job_Seeker')
          .doc(uid)
          .get();

      if (jobSeekerDoc.exists) {
        final data = jobSeekerDoc.data() as Map<String, dynamic>?;
        return data?['role'] == expectedRole;
      }

      // Check in other role collections if needed (e.g., Employers)
      DocumentSnapshot employerDoc = await _firestore
          .collection('Employers')
          .doc(uid)
          .get();

      if (employerDoc.exists) {
        final data = employerDoc.data() as Map<String, dynamic>?;
        return data?['role'] == expectedRole;
      }

      return false;
    } catch (e) {
      debugPrint('Role verification error: $e');
      return false;
    }
  }

  /// Handle Firebase Auth exceptions
  Future<void> _handleAuthException(FirebaseAuthException e) async {
    switch (e.code) {
      case 'user-not-found':
        _setError('No account found with this email. Please register first.');
        break;
      case 'wrong-password':
        _setError('Incorrect password. Please try again.');
        break;
      case 'invalid-email':
        _setError('Invalid email format.');
        break;
      case 'user-disabled':
        _setError('This account has been disabled.');
        break;
      case 'too-many-requests':
        _setError('Too many failed attempts. Please try again later.');
        break;
      case 'network-request-failed':
        _setError('Network error. Please check your connection.');
        break;
      default:
        _setError(e.message ?? 'Authentication failed. Please try again.');
    }
  }

  /// Improved Google Sign-In with proper error handling
  Future<bool> signInWithGoogle() async {
    _loading = true;
    clearError();

    try {
      // Sign out from previous Google sessions
      await _googleSignIn.signOut();

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return false;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        _setError('Google sign-in failed. Please try again.');
        return false;
      }

      // Check if this is a new user and create Firestore document
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _createUserDocument(user);
      }

      _currentUser = user;
      return true;

    } on FirebaseAuthException catch (e) {
      await _handleAuthException(e);
      return false;
    } catch (e) {
      _setError('Google sign-in failed. Please try again.');
      debugPrint('Google sign-in error: $e');
      return false;
    } finally {
      _loading = false;
    }
  }

  /// Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    try {
      await _firestore.collection('Job_Seeker').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoURL': user.photoURL ?? '',
        'role': 'Job_Seeker',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'loginMethod': 'google',
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error creating user document: $e');
      // Don't throw error here as user is already authenticated
    }
  }

  /// Update last login timestamp
  Future<void> updateLastLogin() async {
    if (_currentUser != null) {
      try {
        await _firestore.collection('Job_Seeker').doc(_currentUser!.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Error updating last login: $e');
      }
    }
  }

  /// Sign out from all services
  Future<void> signOut() async {
    _loading = true;
    clearError();

    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      _currentUser = null;
    } catch (e) {
      _setError('Error signing out. Please try again.');
      debugPrint('Sign out error: $e');
    } finally {
      _loading = false;
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      _setError('Please enter your email address');
      return false;
    }

    _loading = true;
    clearError();

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _setError('No account found with this email');
          break;
        case 'invalid-email':
          _setError('Invalid email format');
          break;
        default:
          _setError(e.message ?? 'Error sending reset email');
      }
      return false;
    } catch (e) {
      _setError('Unexpected error occurred');
      debugPrint('Password reset error: $e');
      return false;
    } finally {
      _loading = false;
    }
  }

  /// Check if user is already signed in
  Future<void> checkCurrentUser() async {
    _currentUser = _auth.currentUser;
    notifyListeners();
  }

  /// Dispose method to clean up resources
  @override
  void dispose() {
    // Clean up any streams or resources if needed
    super.dispose();
  }
}