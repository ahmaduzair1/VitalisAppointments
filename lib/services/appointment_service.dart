import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/app_config.dart';
import '../core/schedule.dart';
import '../models/appointment.dart';
import 'reminder_service.dart';

class AppointmentService {
  AppointmentService._();
  static final AppointmentService instance = AppointmentService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _appointments =>
      _db.collection('appointments');
  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('notifications');
  CollectionReference<Map<String, dynamic>> get _slots =>
      _db.collection('bookedSlots');

  Stream<List<Appointment>> watchMine() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _appointments.where('patientId', isEqualTo: uid).snapshots().map((snap) {
      final list = snap.docs.map(Appointment.fromFirestore).toList();
      list.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return list;
    });
  }

  Stream<List<Appointment>> watchAllForAdmin() {
    return _appointments.snapshots().map((snap) {
      final list = snap.docs.map(Appointment.fromFirestore).toList();
      list.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return list;
    });
  }

  Stream<Set<String>> watchTakenTimes({
    required String doctorId,
    required String date,
    String? exceptAppointmentId,
  }) {
    if (doctorId.isEmpty) return Stream.value({});
    return _slots.where('doctorId', isEqualTo: doctorId).snapshots().map((snap) {
      final times = <String>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['date'] != date) continue;
        if (exceptAppointmentId != null &&
            data['appointmentId'] == exceptAppointmentId) {
          continue;
        }
        final time = '${data['time'] ?? ''}';
        if (time.isNotEmpty) times.add(time);
      }
      return times;
    });
  }

  Map<String, dynamic> _slotPayload({
    required String doctorId,
    required String date,
    required String time,
    required String appointmentId,
  }) {
    return {
      'doctorId': doctorId,
      'date': date,
      'time': time,
      'appointmentId': appointmentId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  bool _isSlotConflict(Object error) {
    return error is FirebaseException &&
        (error.code == 'permission-denied' || error.code == 'already-exists');
  }

  Future<void> book({
    required Map<String, dynamic> doctor,
    required String date,
    required String time,
    required String paymentMethod,
    required String patientName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please sign in to book.');
    final doctorId = '${doctor['id'] ?? ''}';
    if (doctorId.isEmpty) {
      throw Exception('This doctor record is incomplete. Go back and open it again.');
    }

    final payNow = paymentMethod == 'card' || paymentMethod == 'wallet';
    final appointmentRef = _appointments.doc();
    final notificationRef = _notifications.doc();
    final fee = doctor['fee'] is num
        ? doctor['fee'] as num
        : num.tryParse('${doctor['fee']}') ?? 0;

    final batch = _db.batch();
    batch.set(appointmentRef, {
      'patientId': user.uid,
      'patientName': patientName.trim().isEmpty
          ? 'Patient'
          : (patientName.trim().length > 80
              ? patientName.trim().substring(0, 80)
              : patientName.trim()),
      'doctorId': doctorId,
      'doctorName': '${doctor['name'] ?? 'Doctor'}',
      'doctorImage': '${doctor['image'] ?? ''}',
      'doctorSpecialty': '${doctor['specialty'] ?? 'General'}',
      'location': '${doctor['location'] ?? AppConfig.clinicName}',
      'date': date,
      'time': time,
      'fee': fee,
      'status': 'upcoming',
      'paymentStatus': payNow ? 'paid' : 'unpaid',
      'paymentMethod': paymentMethod,
      'createdAt': FieldValue.serverTimestamp(),
      if (payNow) 'paidAt': FieldValue.serverTimestamp(),
    });

    final payLabel = payNow ? 'Payment received.' : 'Pay at the clinic on arrival.';
    batch.set(notificationRef, {
      'userId': user.uid,
      'title': 'Appointment booked',
      'body':
          'Your visit with ${doctor['name']} is set for $date at $time. $payLabel',
      'type': 'booking',
      'isRead': false,
      'appointmentId': appointmentRef.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      _slots.doc(VisitSchedule.slotDocId(doctorId, date, time)),
      _slotPayload(
        doctorId: doctorId,
        date: date,
        time: time,
        appointmentId: appointmentRef.id,
      ),
    );

    try {
      await batch.commit();
    } catch (e) {
      if (_isSlotConflict(e)) {
        throw Exception('This time is already booked. Please pick another slot.');
      }
      rethrow;
    }
    unawaited(_refreshReminders());
  }

  Future<Appointment?> getById(String id) async {
    if (id.isEmpty) return null;
    try {
      final doc = await _appointments.doc(id).get();
      if (!doc.exists) return null;
      return Appointment.fromFirestore(doc);
    } catch (_) {
      return null;
    }
  }

  Future<void> reschedule(
    Appointment appointment, {
    required String date,
    required String time,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please sign in.');
    if (!appointment.isUpcoming) {
      throw Exception('Only upcoming visits can be rescheduled.');
    }
    if (date == appointment.date && time == appointment.time) return;

    final oldSlotRef = _slots.doc(
      VisitSchedule.slotDocId(appointment.doctorId, appointment.date, appointment.time),
    );
    final newSlotRef = _slots.doc(
      VisitSchedule.slotDocId(appointment.doctorId, date, time),
    );
    final oldSlot = await oldSlotRef.get();

    final batch = _db.batch();
    batch.update(_appointments.doc(appointment.id), {
      'date': date,
      'time': time,
    });
    batch.set(_notifications.doc(), {
      'userId': appointment.patientId,
      'title': 'Appointment rescheduled',
      'body':
          'Your visit with ${appointment.doctorName} was moved to $date at $time. Open Settings to change it again or cancel.',
      'type': 'booking',
      'isRead': false,
      'appointmentId': appointment.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (oldSlot.exists) batch.delete(oldSlotRef);
    batch.set(
      newSlotRef,
      _slotPayload(
        doctorId: appointment.doctorId,
        date: date,
        time: time,
        appointmentId: appointment.id,
      ),
    );

    try {
      await batch.commit();
    } catch (e) {
      if (_isSlotConflict(e)) {
        throw Exception('This time is already booked. Please pick another slot.');
      }
      rethrow;
    }
    unawaited(_refreshReminders());
  }

  Future<void> cancel(Appointment appointment) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please sign in.');

    final slotRef = _slots.doc(
      VisitSchedule.slotDocId(appointment.doctorId, appointment.date, appointment.time),
    );
    final slotSnap = await slotRef.get();

    final batch = _db.batch();
    batch.update(_appointments.doc(appointment.id), {
      'status': 'cancelled',
    });
    batch.set(_notifications.doc(), {
      'userId': appointment.patientId,
      'title': 'Appointment cancelled',
      'body':
          'Your visit with ${appointment.doctorName} on ${appointment.date} was cancelled.',
      'type': 'cancel',
      'isRead': false,
      'appointmentId': appointment.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (slotSnap.exists) batch.delete(slotRef);
    await batch.commit();
    try {
      await ReminderService.instance.cancelFor(appointment.id);
    } catch (_) {}
  }

  Future<void> _refreshReminders() async {
    try {
      await ReminderService.instance.sync();
    } catch (_) {}
  }

  Future<void> markPaid(Appointment appointment, {String method = 'card'}) async {
    await _appointments.doc(appointment.id).update({
      'paymentStatus': 'paid',
      'paymentMethod': method,
      'paidAt': FieldValue.serverTimestamp(),
    });

    await _notifications.add({
      'userId': appointment.patientId,
      'title': 'Payment confirmed',
      'body':
          'Payment for your visit with ${appointment.doctorName} is marked as paid.',
      'type': 'payment',
      'isRead': false,
      'appointmentId': appointment.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(Appointment appointment, String status) async {
    await _appointments.doc(appointment.id).update({'status': status});

    final title = status == 'completed' ? 'Visit completed' : 'Appointment updated';
    final body = status == 'completed'
        ? 'Your session with ${appointment.doctorName} is marked complete.'
        : 'Your appointment with ${appointment.doctorName} is now $status.';

    await _notifications.add({
      'userId': appointment.patientId,
      'title': title,
      'body': body,
      'type': status == 'completed' ? 'system' : 'booking',
      'isRead': false,
      'appointmentId': appointment.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> ensureMySlots() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      final snap = await _appointments.where('patientId', isEqualTo: uid).get();
      await _writeMissingSlots(
        snap.docs.map(Appointment.fromFirestore).where((a) => a.isUpcoming),
      );
    } catch (_) {}
  }

  Future<void> backfillUpcomingSlots() async {
    if (!AppConfig.isAdminEmail(_auth.currentUser?.email)) return;
    try {
      final snap = await _appointments.where('status', isEqualTo: 'upcoming').get();
      await _writeMissingSlots(snap.docs.map(Appointment.fromFirestore));
    } catch (_) {}
  }

  Future<void> _writeMissingSlots(Iterable<Appointment> appointments) async {
    for (final apt in appointments) {
      if (apt.doctorId.isEmpty || apt.date.isEmpty || apt.time.isEmpty) continue;
      final ref = _slots.doc(VisitSchedule.slotDocId(apt.doctorId, apt.date, apt.time));
      try {
        final existing = await ref.get();
        if (existing.exists) continue;
        await ref.set(
          _slotPayload(
            doctorId: apt.doctorId,
            date: apt.date,
            time: apt.time,
            appointmentId: apt.id,
          ),
        );
      } catch (_) {}
    }
  }
}
