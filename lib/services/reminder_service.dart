import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/schedule.dart';
import '../models/appointment.dart';

class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  static const _channelId = 'visit_reminders';
  static const _channelName = 'Visit reminders';

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _plugin = FlutterLocalNotificationsPlugin();

  bool _ready = false;

  bool get _supportsLocalNotifications {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  Future<void> init() async {
    if (_ready || !_supportsLocalNotifications) return;
    try {
      tzdata.initializeTimeZones();
      try {
        final zone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(zone.identifier));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _plugin.initialize(
        settings: const InitializationSettings(android: android, iOS: ios),
      );

      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Day-before and same-day visit reminders',
          importance: Importance.high,
        ),
      );

      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

      _ready = true;
    } catch (e) {
      debugPrint('ReminderService.init failed: $e');
    }
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
    final upcoming = snap.docs
        .map(Appointment.fromFirestore)
        .where((a) => a.isUpcoming)
        .toList();

    for (final apt in upcoming) {
      await scheduleFor(apt);
      try {
        await _maybeCreateInAppReminder(apt);
      } catch (e) {
        debugPrint('In-app reminder failed: $e');
      }
    }
  }

  Future<void> scheduleFor(Appointment appointment) async {
    if (!_supportsLocalNotifications) return;
    await init();
    if (!_ready) return;

    final enabled = await _remindersEnabled(appointment.patientId);
    if (!enabled) {
      await cancelFor(appointment.id);
      return;
    }

    final visit = VisitSchedule.parseVisit(appointment.date, appointment.time);
    if (visit == null) return;

    await cancelFor(appointment.id);

    final now = DateTime.now();
    if (!visit.isAfter(now)) return;

    final visitDay = DateTime(visit.year, visit.month, visit.day);
    final dayBefore = visitDay.subtract(const Duration(days: 1)).add(const Duration(hours: 9));
    final dayOf = visitDay.add(const Duration(hours: 8));
    final hourBefore = visit.subtract(const Duration(hours: 1));

    if (dayBefore.isAfter(now)) {
      await _zonedNotify(
        id: _localId(appointment.id, 'before'),
        when: dayBefore,
        title: 'Visit tomorrow',
        body:
            'Reminder: you have an appointment with ${appointment.doctorName} tomorrow at ${appointment.time}. Open Settings to reschedule or cancel.',
      );
    }

    if (dayOf.isAfter(now) && dayOf.isBefore(visit)) {
      await _zonedNotify(
        id: _localId(appointment.id, 'today'),
        when: dayOf,
        title: 'Visit today',
        body:
            'Reminder: your appointment with ${appointment.doctorName} is today at ${appointment.time}. Open Settings to reschedule or cancel.',
      );
    }

    if (hourBefore.isAfter(now)) {
      await _zonedNotify(
        id: _localId(appointment.id, 'hour'),
        when: hourBefore,
        title: 'Visit in 1 hour',
        body:
            'Reminder: your appointment with ${appointment.doctorName} is at ${appointment.time}. Open Settings to reschedule or cancel.',
      );
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
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['notificationsEnabled'] != false;
  }

  Future<void> _maybeCreateInAppReminder(Appointment appointment) async {
    final proximity = VisitSchedule.proximity(appointment.date, appointment.time);
    if (proximity != VisitProximity.today && proximity != VisitProximity.tomorrow) {
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
      'body':
          'Reminder: you have an appointment with ${appointment.doctorName} $whenLabel at ${appointment.time}. Open Settings to reschedule or cancel.',
      'type': 'reminder',
      'isRead': false,
      'appointmentId': appointment.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
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
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Day-before and same-day visit reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Reminder schedule failed: $e');
    }
  }

  int _localId(String appointmentId, String kind) {
    return Object.hash(appointmentId, kind) & 0x7fffffff;
  }

  String _inAppId(String appointmentId, String kind) => 'r_${appointmentId}_$kind';
}
