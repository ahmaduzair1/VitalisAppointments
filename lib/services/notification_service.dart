import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_notification.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<List<AppNotification>> watchMine() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(AppNotification.fromFirestore).toList();
      list.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return list;
    });
  }

  Stream<int> unreadCount() {
    return watchMine().map((items) => items.where((n) => !n.isRead).length);
  }

  Future<void> markRead(String id) async {
    try {
      await _db.collection('notifications').doc(id).update({'isRead': true});
    } catch (_) {}
  }

  Future<void> markAllRead(List<AppNotification> items) async {
    final unread = items.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;
    try {
      final batch = _db.batch();
      for (final item in unread) {
        batch.update(_db.collection('notifications').doc(item.id), {'isRead': true});
      }
      await batch.commit();
    } catch (_) {}
  }
}
