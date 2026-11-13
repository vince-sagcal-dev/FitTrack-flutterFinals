import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadFoodImage(
    String uid,
    String foodId,
    Uint8List bytes, {
    String mimeType = 'image/jpeg',
  }) async {
    final extension = switch (mimeType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => 'jpg',
    };
    final ref = _storage.ref('users/$uid/foods/$foodId.$extension');
    final snapshot = await ref.putData(
      bytes,
      SettableMetadata(contentType: mimeType),
    );
    return snapshot.ref.getDownloadURL();
  }

  Future<String> uploadProfileImage(String uid, Uint8List bytes) async {
    final ref = _storage.ref('users/$uid/profile.jpg');
    final snapshot = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return snapshot.ref.getDownloadURL();
  }
}
