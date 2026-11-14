import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  static const _uploadTimeout = Duration(seconds: 30);

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
    final upload = ref.putData(bytes, SettableMetadata(contentType: mimeType));
    late final TaskSnapshot snapshot;
    try {
      snapshot = await upload.timeout(_uploadTimeout);
    } on TimeoutException {
      await upload.cancel();
      throw TimeoutException(
        'Photo upload timed out. Check your connection and try again.',
      );
    }
    return snapshot.ref.getDownloadURL().timeout(
      _uploadTimeout,
      onTimeout: () => throw TimeoutException(
        'Getting the uploaded photo timed out. Please try again.',
      ),
    );
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
