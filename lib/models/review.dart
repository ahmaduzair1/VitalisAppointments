import 'package:cloud_firestore/cloud_firestore.dart';

class VisitReview {
  final String id;
  final String patientId;
  final String doctorId;
  final String appointmentId;
  final String doctorName;
  final String patientName;
  final int rating;
  final String comment;
  final String reply;
  final String repliedBy;
  final DateTime? createdAt;
  final DateTime? replyAt;

  const VisitReview({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentId,
    required this.doctorName,
    required this.patientName,
    required this.rating,
    required this.comment,
    required this.reply,
    required this.repliedBy,
    this.createdAt,
    this.replyAt,
  });

  bool get hasReply => reply.trim().isNotEmpty;

  factory VisitReview.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ratingNum = data['rating'];
    return VisitReview(
      id: doc.id,
      patientId: data['patientId'] as String? ?? '',
      doctorId: data['doctorId'] as String? ?? '',
      appointmentId: data['appointmentId'] as String? ?? doc.id,
      doctorName: data['doctorName'] as String? ?? 'Doctor',
      patientName: data['patientName'] as String? ?? 'Patient',
      rating: ratingNum is num ? ratingNum.round().clamp(1, 5) : 5,
      comment: data['comment'] as String? ?? '',
      reply: data['reply'] as String? ?? '',
      repliedBy: data['repliedBy'] as String? ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      replyAt: data['replyAt'] is Timestamp
          ? (data['replyAt'] as Timestamp).toDate()
          : null,
    );
  }
}
