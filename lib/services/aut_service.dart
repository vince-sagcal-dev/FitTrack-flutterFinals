import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  static Future<void>? _googleSignInInitialization;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();
    final credential = await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Your account could not be created. Please try again.',
      );
    }

    await user.updateDisplayName(cleanName);
    await _db.collection('users').doc(user.uid).set({
      'fullName': cleanName,
      'email': cleanEmail,
      'dailyCalorieGoal': 2000,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return credential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<UserCredential> signInWithGoogle() async {
    final UserCredential credential;
    if (kIsWeb) {
      credential = await _auth.signInWithPopup(GoogleAuthProvider());
    } else {
      final googleSignIn = GoogleSignIn.instance;
      final initialization = _googleSignInInitialization ??= googleSignIn
          .initialize();
      try {
        await initialization;
      } catch (_) {
        _googleSignInInitialization = null;
        rethrow;
      }
      final googleUser = await googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-google-id-token',
          message: 'Google did not provide an authentication token.',
        );
      }
      credential = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    }

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'google-user-missing',
        message: 'Google sign-in succeeded without an account. Please retry.',
      );
    }

    final profile = _db.collection('users').doc(user.uid);
    final existingProfile = await profile.get();
    if (existingProfile.exists) {
      await profile.set({
        'fullName': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await profile.set({
        'fullName': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL,
        'dailyCalorieGoal': 2000,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    return credential;
  }

  Future<void> logout() => _auth.signOut();

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw FirebaseAuthException(
        code: 'requires-recent-login',
        message: 'Sign in again before changing your password.',
      );
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}
