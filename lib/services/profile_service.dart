import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class ProfileService {
  ProfileService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> _profile(String uid) =>
      _db.collection('users').doc(uid);

  Stream<UserModel?> watchProfile(String uid) =>
      _profile(uid).snapshots().map((snapshot) {
        final data = snapshot.data();
        return data == null ? null : UserModel.fromMap(uid, data);
      });

  Future<UserModel?> getProfile(String uid) async {
    final snapshot = await _profile(uid).get();
    final data = snapshot.data();
    return data == null ? null : UserModel.fromMap(uid, data);
  }

  Future<void> updateProfile(UserModel profile) async {
    await _profile(profile.uid).set(profile.toMap(), SetOptions(merge: true));
    await _auth.currentUser?.updateDisplayName(profile.fullName);
    await _auth.currentUser?.updatePhotoURL(profile.photoUrl);
  }
}
