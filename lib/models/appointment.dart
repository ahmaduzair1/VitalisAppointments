import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String doctorImage;
  final String doctorSpecialty;
  final String location;
  final String date;
  final String time;
  final num fee;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime? createdAt;
  final DateTime? paidAt;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.doctorImage,
    required this.doctorSpecialty,
    required this.location,
    required this.date,
    required this.time,
    required this.fee,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.createdAt,
    this.paidAt,
  });

  bool get isUpcoming => status == 'upcoming';
  bool get isPaid => paymentStatus == 'paid';

  Appointment copyWith({
    String? date,
    String? time,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    DateTime? paidAt,
  }) {
    return Appointment(
      id: id,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorImage: doctorImage,
      doctorSpecialty: doctorSpecialty,
      location: location,
      date: date ?? this.date,
      time: time ?? this.time,
      fee: fee,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Appointment(
      id: doc.id,
      patientId: data['patientId'] as String? ?? '',
      patientName: data['patientName'] as String? ?? 'Patient',
      doctorId: data['doctorId'] as String? ?? '',
      doctorName: data['doctorName'] as String? ?? 'Doctor',
      doctorImage: data['doctorImage'] as String? ?? '',
      doctorSpecialty: data['doctorSpecialty'] as String? ?? '',
      location: data['location'] as String? ?? 'Vitalis Clinic',
      date: data['date'] as String? ?? '',
      time: data['time'] as String? ?? '',
      fee: data['fee'] is num ? data['fee'] as num : num.tryParse('${data['fee']}') ?? 0,
      status: data['status'] as String? ?? 'upcoming',
      paymentStatus: data['paymentStatus'] as String? ?? 'unpaid',
      paymentMethod: data['paymentMethod'] as String? ?? 'clinic',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      paidAt: data['paidAt'] is Timestamp
          ? (data['paidAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorImage': doctorImage,
        'doctorSpecialty': doctorSpecialty,
        'location': location,
        'date': date,
        'time': time,
        'fee': fee,
        'status': status,
        'paymentStatus': paymentStatus,
        'paymentMethod': paymentMethod,
      };
}
