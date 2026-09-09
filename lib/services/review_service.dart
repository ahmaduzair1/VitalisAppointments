import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/app_config.dart';
import '../core/schedule.dart';
import '../models/appointment.dart';
import '../models/review.dart';

class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _db.collection('reviews');

  Future<VisitReview?> getForAppointment(String appointmentId) async {
    if (appointmentId.isEmpty) return null;
    try {
      final snap = await _reviews.doc(appointmentId).get();
      if (!snap.exists) return null;
      return VisitReview.fromFirestore(snap);
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasReviewed(String appointmentId) async {
    final existing = await getForAppointment(appointmentId);
    return existing != null;
  }

  Stream<List<VisitReview>> watchAllForAdmin() {
    if (!AppConfig.isAdminEmail(_auth.currentUser?.email)) {
      return const Stream.empty();
    }
    return _reviews.snapshots().map((snap) {
      final list = snap.docs.map(VisitReview.fromFirestore).toList();
      list.sort((a, b) => (b.createdAt ?? DateTime(0))
          .compareTo(a.createdAt ?? DateTime(0)));
      return list;
    });
  }

  bool isEligible(Appointment appointment) {
    if (appointment.status == 'cancelled') return false;
    if (appointment.status == 'completed') return true;
    final visit = VisitSchedule.parseVisit(appointment.date, appointment.time);
    if (visit == null) return false;
    return !visit.isAfter(DateTime.now());
  }

  Future<void> submit({
    required Appointment appointment,
    required int rating,
    required String comment,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Please sign in.');
    if (appointment.patientId != uid) {
      throw Exception('You can only review your own visit.');
    }
    if (!isEligible(appointment)) {
      throw Exception('You can leave a review after the visit time.');
    }
    final stars = rating.clamp(1, 5);
    final note = comment.trim();
    final clipped = note.length > 400 ? note.substring(0, 400) : note;
    String clipName(String value, String fallback) {
      final t = value.trim();
      if (t.isEmpty) return fallback;
      return t.length > 80 ? t.substring(0, 80) : t;
    }

    try {
      await _reviews.doc(appointment.id).set({
        'patientId': appointment.patientId,
        'doctorId': appointment.doctorId,
        'appointmentId': appointment.id,
        'doctorName': clipName(appointment.doctorName, 'Doctor'),
        'patientName': clipName(appointment.patientName, 'Patient'),
        'rating': stars,
        'comment': clipped,
        'reply': '',
        'repliedBy': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'already-exists' || e.code == 'permission-denied') {
        throw Exception('This visit already has a review.');
      }
      throw Exception(e.message ?? 'Could not send your review.');
    }
  }

  Future<void> reply({
    required VisitReview review,
    required String message,
  }) async {
    if (!AppConfig.isAdminEmail(_auth.currentUser?.email)) {
      throw Exception('Only hospital staff can reply.');
    }
    final text = message.trim();
    if (text.isEmpty) throw Exception('Write a short reply first.');
    final clipped = text.length > 400 ? text.substring(0, 400) : text;
    final staff = _auth.currentUser?.email ?? 'Hospital';

    try {
      await _reviews.doc(review.id).update({
        'reply': clipped,
        'repliedBy': staff.length > 80 ? staff.substring(0, 80) : staff,
        'replyAt': FieldValue.serverTimestamp(),
      });

      await _db.collection('notifications').add({
        'userId': review.patientId,
        'title': 'Hospital replied to your review',
        'body': clipped,
        'type': 'review',
        'isRead': false,
        'appointmentId': review.appointmentId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Could not send the reply.');
    }
  }
}
