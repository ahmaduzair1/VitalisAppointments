import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

/// Stores compressed JPEGs in Firestore so photos work on the free Spark plan.
/// Firebase Storage on this project requires a paid Blaze upgrade.
class ImageUploadService {
  ImageUploadService._();
  static final ImageUploadService instance = ImageUploadService._();

  static const _maxBase64Chars = 700000;

  final _picker = ImagePicker();
  final _db = FirebaseFirestore.instance;

  static String profileRef(String uid) => 'fs:profile:$uid';
  static String doctorRef(String doctorId) => 'fs:doctor:$doctorId';

  Future<Uint8List?> pickPhoto({bool camera = false}) async {
    try {
      if (camera && kIsWeb) {
        camera = false;
      }
      final file = await _picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 480,
        maxHeight: 480,
        imageQuality: 52,
      );
      if (file == null) return null;
      return await file.readAsBytes();
    } catch (e) {
      throw Exception('Could not pick a photo. $e');
    }
  }

  Future<String> uploadUserAvatar(Uint8List bytes) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Please sign in.');
    await _save(collection: 'profilePhotos', id: uid, bytes: bytes);
    return profileRef(uid);
  }

  Future<String> uploadDoctorPhoto(String doctorId, Uint8List bytes) async {
    if (doctorId.isEmpty) {
      throw Exception('Save the doctor first, then add a photo.');
    }
    await _save(collection: 'doctorPhotos', id: doctorId, bytes: bytes);
    return doctorRef(doctorId);
  }

  Future<void> _save({
    required String collection,
    required String id,
    required Uint8List bytes,
  }) async {
    final encoded = base64Encode(bytes);
    if (encoded.length > _maxBase64Chars) {
      throw Exception('That photo is too large. Pick a closer, smaller picture.');
    }
    try {
      await _db.collection(collection).doc(id).set({
        'bytes': encoded,
        'contentType': 'image/jpeg',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Could not save the photo.');
    }
  }
}
