import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/app_config.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  bool get isAdmin => AppConfig.isAdminEmail(_auth.currentUser?.email);

  Future<void> ensureUserDocument() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final ref = _firestore.collection('users').doc(user.uid);
      final snap = await ref.get();
      if (!snap.exists) {
        await _createUserDocument(user, user.displayName ?? 'Patient');
        return;
      }
      final data = snap.data() ?? {};
      final patch = <String, dynamic>{};
      if (data['role'] == null) patch['role'] = 'patient';
      if (data['uid'] == null) patch['uid'] = user.uid;
      if (data['email'] == null) patch['email'] = user.email ?? '';
      if (data['phone'] == null) patch['phone'] = '';
      if (data['photoUrl'] == null) patch['photoUrl'] = user.photoURL ?? '';
      if (data['allergies'] == null) patch['allergies'] = '';
      if (data['conditions'] == null) patch['conditions'] = '';
      if (data['notificationsEnabled'] == null) {
        patch['notificationsEnabled'] = true;
      }
      if (data['createdAt'] == null) {
        patch['createdAt'] = FieldValue.serverTimestamp();
      }
      if (patch.isNotEmpty) await ref.update(patch);
    } catch (_) {}
  }

  Future<String> currentPatientName() async {
    final user = _auth.currentUser;
    if (user == null) return 'Patient';
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final name = doc.data()?['name'] as String?;
      if (name != null && name.trim().isNotEmpty) return name.trim();
    } catch (_) {}
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }
    return 'Patient';
  }

  Future<void> _createUserDocument(User user, String name) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': user.email ?? '',
      'role': 'patient',
      'phone': '',
      'photoUrl': user.photoURL ?? '',
      'allergies': '',
      'conditions': '',
      'notificationsEnabled': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<User?> signUpWithEmailPassword(
      String email, String password, String name) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final trimmed = name.trim().isEmpty
            ? 'Patient'
            : (name.trim().length > 80 ? name.trim().substring(0, 80) : name.trim());
        await credential.user!.updateDisplayName(trimmed);
        await _createUserDocument(credential.user!, trimmed);
        await credential.user!.sendEmailVerification();
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('User already exists, please login.');
      }
      throw Exception(e.message ?? 'An error occurred during sign up.');
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }

  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Password is incorrect.');
      } else if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      }
      throw Exception(e.message ?? 'An error occurred during sign in.');
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          await _createUserDocument(
            userCredential.user!,
            userCredential.user!.displayName ?? 'Google User',
          );
        }
      }

      return userCredential.user;
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? allergies,
    String? conditions,
    bool? notificationsEnabled,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please sign in.');

    final data = <String, dynamic>{};
    if (name != null) {
      final trimmed = name.trim().isEmpty
          ? 'Patient'
          : (name.trim().length > 80 ? name.trim().substring(0, 80) : name.trim());
      data['name'] = trimmed;
    }
    if (phone != null) data['phone'] = phone;
    if (allergies != null) data['allergies'] = allergies;
    if (conditions != null) data['conditions'] = conditions;
    if (notificationsEnabled != null) {
      data['notificationsEnabled'] = notificationsEnabled;
    }
    if (data.isEmpty) return;
    try {
      await _firestore.collection('users').doc(user.uid).update(data);
      if (name != null) await user.updateDisplayName(data['name'] as String);
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Could not update profile.');
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
