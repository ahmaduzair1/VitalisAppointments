import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/device_timezone.dart';
import '../core/schedule.dart';
import '../models/appointment.dart';

class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  static const _channelId = 'vitalis_visits';
  static const _channelName = 'Vitalis';
  static const _brandColor = Color(0xFF0F766E);

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _plugin = FlutterLocalNotificationsPlugin();

  bool _ready = false;

  bool get _supportsLocalNotifications {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  Future<void> init() async {
    if (_ready || !_supportsLocalNotifications) return;
    try {
      await DeviceTimezone.applyLocal();

      const android = AndroidInitializationSettings('@drawable/ic_stat_vitalis');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: android,
          iOS: ios,
          macOS: ios,
          web: WebInitializationSettings(),
        ),
      );

      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Visit bookings and reminders from Vitalis',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );

      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

      _ready = true;
    } catch (e) {
      debugPrint('ReminderService.init failed: $e');
    }
  }

  Future<void> onBooked(Appointment appointment) async {
    await init();
    await showNow(
      id: _localId(appointment.id, 'booked'),
      title: 'Appointment booked',
      body: _bookedBody(appointment),
    );
    await scheduleFor(appointment);
  }

  Future<void> onRescheduled(Appointment appointment) async {
    await init();
    await showNow(
      id: _localId(appointment.id, 'booked'),
      title: 'Visit rescheduled',
      body: _rescheduledBody(appointment),
    );
    await scheduleFor(appointment);
  }

  Future<void> sync() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await init();

    final enabled = await _remindersEnabled(user.uid);
    if (!enabled) {
      await cancelAllLocal();
      return;
    }

    final snap = await _db
        .collection('appointments')
        .where('patientId', isEqualTo: user.uid)
        .get();
    final visits = snap.docs
        .map(Appointment.fromFirestore)
        .where((a) => a.status != 'cancelled')
        .toList();

    for (final apt in visits) {
      await scheduleFor(apt);
      try {
        await _maybeCreateInAppReminder(apt);
      } catch (e) {
        debugPrint('In-app reminder failed: $e');
      }
    }
  }

  Future<void> scheduleFor(Appointment appointment) async {
    final visit = VisitSchedule.parseVisit(appointment.date, appointment.time);
    if (visit == null) return;

    final enabled = await _remindersEnabled(appointment.patientId);

    if (_supportsLocalNotifications) {
      await init();
      if (_ready) {
        await cancelFor(appointment.id);
        final now = DateTime.now();
        if (enabled && visit.isAfter(now)) {
          final visitDay = DateTime(visit.year, visit.month, visit.day);
          final dayBefore = visitDay
              .subtract(const Duration(days: 1))
              .add(const Duration(hours: 9));
          final dayOf = visitDay.add(const Duration(hours: 8));
          final hourBefore = visit.subtract(const Duration(hours: 1));
          final soon = visit.subtract(const Duration(minutes: 15));

          if (dayBefore.isAfter(now)) {
            await _zonedNotify(
              id: _localId(appointment.id, 'before'),
              when: dayBefore,
              title: 'Visit tomorrow',
              body: _visitBody(
                appointment,
                lead: 'You have a visit tomorrow.',
              ),
            );
          }

          if (dayOf.isAfter(now) && dayOf.isBefore(visit)) {
            await _zonedNotify(
              id: _localId(appointment.id, 'today'),
              when: dayOf,
              title: 'Visit today',
              body: _visitBody(
                appointment,
                lead: 'You have a visit today.',
              ),
            );
          }

          if (hourBefore.isAfter(now)) {
            await _zonedNotify(
              id: _localId(appointment.id, 'hour'),
              when: hourBefore,
              title: 'Visit in 1 hour',
              body: _visitBody(
                appointment,
                lead: 'Your visit starts in 1 hour.',
              ),
            );
          }

          if (soon.isAfter(now)) {
            await _zonedNotify(
              id: _localId(appointment.id, 'soon'),
              when: soon,
              title: 'Visit in 15 minutes',
              body: _visitBody(
                appointment,
                lead: 'Your visit starts in 15 minutes. Please head to the clinic.',
              ),
            );
          }
        }
      }
    }

    await _scheduleReviewPrompt(
      appointment,
      visit,
      notifyDevice: enabled,
    );
  }

  Future<void> onVisitCompleted(Appointment appointment) async {
    await init();
    await _ensureReviewPrompt(appointment, popup: true);
  }

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_supportsLocalNotifications) return;
    await init();
    if (!_ready) return;
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _details(body),
      );
    } catch (e) {
      debugPrint('Immediate notification failed: $e');
    }
  }

  Future<void> cancelFor(String appointmentId) async {
    if (!_supportsLocalNotifications) return;
    await init();
    if (!_ready) return;
    try {
      await _plugin.cancel(id: _localId(appointmentId, 'before'));
      await _plugin.cancel(id: _localId(appointmentId, 'today'));
      await _plugin.cancel(id: _localId(appointmentId, 'hour'));
      await _plugin.cancel(id: _localId(appointmentId, 'soon'));
      await _plugin.cancel(id: _localId(appointmentId, 'review'));
    } catch (_) {}
  }

  Future<void> cancelAllLocal() async {
    if (!_supportsLocalNotifications) return;
    await init();
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  Future<bool> _remindersEnabled(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data()?['notificationsEnabled'] != false;
    } catch (_) {
      return true;
    }
  }

  Future<void> _maybeCreateInAppReminder(Appointment appointment) async {
    final proximity =
        VisitSchedule.proximity(appointment.date, appointment.time);
    if (proximity != VisitProximity.today &&
        proximity != VisitProximity.tomorrow) {
      return;
    }

    final kind = proximity == VisitProximity.today ? 'today' : 'tomorrow';
    final docId = _inAppId(appointment.id, kind);
    final ref = _db.collection('notifications').doc(docId);
    final existing = await ref.get();
    if (existing.exists) return;

    final whenLabel = proximity == VisitProximity.today ? 'today' : 'tomorrow';
    await ref.set({
      'userId': appointment.patientId,
      'title': proximity == VisitProximity.today ? 'Visit today' : 'Visit tomorrow',
      'body': _visitBody(
        appointment,
        lead: 'You have a visit $whenLabel.',
      ),
      'type': 'reminder',
      'isRead': false,
      'appointmentId': appointment.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _scheduleReviewPrompt(
    Appointment appointment,
    DateTime visit, {
    required bool notifyDevice,
  }) async {
    if (appointment.status == 'cancelled') return;
    try {
      final existing = await _db.collection('reviews').doc(appointment.id).get();
      if (existing.exists) return;
    } catch (_) {}

    final due = visit.add(const Duration(minutes: 30));
    final now = DateTime.now();
    if (due.isAfter(now) && appointment.status != 'completed') {
      if (notifyDevice) {
        await _zonedNotify(
          id: _localId(appointment.id, 'review'),
          when: due,
          title: 'How was your visit?',
          body: _reviewBody(appointment),
        );
      }
      return;
    }

    await _ensureReviewPrompt(
      appointment,
      popup: notifyDevice && kIsWeb,
    );
  }

  Future<void> _ensureReviewPrompt(
    Appointment appointment, {
    required bool popup,
  }) async {
    try {
      final reviewed = await _db.collection('reviews').doc(appointment.id).get();
      if (reviewed.exists) return;
    } catch (_) {}

    final docId = _inAppId(appointment.id, 'review');
    final ref = _db.collection('notifications').doc(docId);
    try {
      final existing = await ref.get();
      if (!existing.exists) {
        await ref.set({
          'userId': appointment.patientId,
          'title': 'How was your visit?',
          'body': _reviewBody(appointment),
          'type': 'review',
          'isRead': false,
          'appointmentId': appointment.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Review prompt failed: $e');
    }

    if (popup) {
      await showNow(
        id: _localId(appointment.id, 'review'),
        title: 'How was your visit?',
        body: _reviewBody(appointment),
      );
    }
  }

  String _reviewBody(Appointment appointment) {
    return 'How was your visit with ${appointment.doctorName}? '
        'Open Notifications and leave a short rating so the hospital can follow up.';
  }

  Future<void> _zonedNotify({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(when, tz.local),
        notificationDetails: _details(body),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Reminder schedule failed: $e');
      try {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.from(when, tz.local),
          notificationDetails: _details(body),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (fallback) {
        debugPrint('Reminder fallback schedule failed: $fallback');
      }
    }
  }

  NotificationDetails _details(String body) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Visit bookings and reminders from Vitalis',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@drawable/ic_stat_vitalis',
        color: _brandColor,
        colorized: false,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        styleInformation: BigTextStyleInformation(body),
        ticker: 'Vitalis',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  String _bookedBody(Appointment appointment) {
    final when = _whenPhrase(appointment);
    return 'Your appointment is confirmed $when.\n'
        'Doctor: ${appointment.doctorName}\n'
        'Specialty: ${appointment.doctorSpecialty}\n'
        'Date: ${appointment.date}\n'
        'Time: ${appointment.time}\n'
        'Clinic: ${appointment.location}\n'
        'Vitalis will remind you before the visit, even if the app is closed.';
  }

  String _rescheduledBody(Appointment appointment) {
    final when = _whenPhrase(appointment);
    return 'Your visit was moved $when.\n'
        'Doctor: ${appointment.doctorName}\n'
        'Date: ${appointment.date}\n'
        'Time: ${appointment.time}\n'
        'Clinic: ${appointment.location}';
  }

  String _visitBody(Appointment appointment, {required String lead}) {
    return '$lead\n'
        'Doctor: ${appointment.doctorName}\n'
        'Date: ${appointment.date}\n'
        'Time: ${appointment.time}\n'
        'Clinic: ${appointment.location}';
  }

  String _whenPhrase(Appointment appointment) {
    final proximity =
        VisitSchedule.proximity(appointment.date, appointment.time);
    return switch (proximity) {
      VisitProximity.today => 'for today at ${appointment.time}',
      VisitProximity.tomorrow => 'for tomorrow at ${appointment.time}',
      _ => 'for ${appointment.date} at ${appointment.time}',
    };
  }

  int _localId(String appointmentId, String kind) {
    return Object.hash(appointmentId, kind) & 0x7fffffff;
  }

  String _inAppId(String appointmentId, String kind) => 'r_${appointmentId}_$kind';
}
