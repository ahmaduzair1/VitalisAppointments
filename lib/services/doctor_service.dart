import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorService {
  DoctorService._();
  static final DoctorService instance = DoctorService._();

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _doctors =>
      _db.collection('doctors');

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAll() => _doctors.snapshots();

  Future<void> upsert(String? id, Map<String, dynamic> data) async {
    final payload = {
      'name': data['name'],
      'specialty': data['specialty'],
      'location': data['location'],
      'experience': data['experience'],
      'rating': (data['rating'] is num) ? data['rating'] : num.tryParse('${data['rating']}') ?? 4.5,
      'reviews': (data['reviews'] is num) ? data['reviews'] : num.tryParse('${data['reviews']}') ?? 0,
      'patients': '${data['patients'] ?? '0'}',
      'fee': (data['fee'] is num) ? data['fee'] : num.tryParse('${data['fee']}') ?? 0,
      'image': data['image'],
      'availableToday': data['availableToday'] == true,
      'about': data['about'] ?? '',
    };
    try {
      if (id == null || id.isEmpty) {
        await _doctors.add(payload);
      } else {
        await _doctors.doc(id).set(payload);
      }
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Could not save doctor.');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _doctors.doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Could not delete doctor.');
    }
  }

  Future<int> seedCatalog() async {
    final existing = await _doctors.limit(1).get();
    if (existing.docs.isNotEmpty) return 0;

    for (final doctor in catalog) {
      await _doctors.add(doctor);
    }
    return catalog.length;
  }

  static const List<Map<String, dynamic>> catalog = [
    {
      'name': 'Dr Hina Sheikh',
      'specialty': 'Gynecologist',
      'location': 'Women\'s Health Wing, Rawalpindi',
      'experience': '11 Years',
      'rating': 4.9,
      'reviews': 230,
      'patients': '2.3k',
      'fee': 2600,
      'image': 'https://randomuser.me/api/portraits/women/12.jpg',
      'availableToday': true,
      'about':
          'Board-certified gynecologist focusing on prenatal care, fertility, and women\'s wellness.',
    },
    {
      'name': 'Dr Usman Tariq',
      'specialty': 'ENT Specialist',
      'location': 'ENT Clinic, Multan',
      'experience': '6 Years',
      'rating': 4.4,
      'reviews': 90,
      'patients': '800',
      'fee': 1400,
      'image': 'https://randomuser.me/api/portraits/men/29.jpg',
      'availableToday': true,
      'about':
          'Treats sinus, hearing, and throat conditions with a calm, clear approach for every age.',
    },
    {
      'name': 'Dr Fatima Zahra',
      'specialty': 'Dentist',
      'location': 'Dental Care, Hyderabad',
      'experience': '5 Years',
      'rating': 4.3,
      'reviews': 70,
      'patients': '600',
      'fee': 1200,
      'image': 'https://randomuser.me/api/portraits/women/21.jpg',
      'availableToday': true,
      'about':
          'Gentle dentistry for check-ups, fillings, and smile care, with a focus on prevention.',
    },
    {
      'name': 'Dr Imran Qureshi',
      'specialty': 'General Physician',
      'location': 'Outpatient Block, Quetta',
      'experience': '13 Years',
      'rating': 4.7,
      'reviews': 160,
      'patients': '1.7k',
      'fee': 1800,
      'image': 'https://randomuser.me/api/portraits/men/55.jpg',
      'availableToday': true,
      'about':
          'First-line care for fever, infections, and chronic conditions. Easy to talk to and thorough.',
    },
    {
      'name': 'Dr Noor ul Ain',
      'specialty': 'Psychiatrist',
      'location': 'Mind & Wellness Center, Islamabad',
      'experience': '9 Years',
      'rating': 4.8,
      'reviews': 140,
      'patients': '1.4k',
      'fee': 2300,
      'image': 'https://randomuser.me/api/portraits/women/33.jpg',
      'availableToday': false,
      'about':
          'Supports anxiety, depression, and stress with evidence-based therapy and medication when needed.',
    },
    {
      'name': 'Dr Julian Sterling',
      'specialty': 'Cardiologist',
      'location': 'Heart Center, Block B',
      'experience': '12 Years',
      'rating': 4.9,
      'reviews': 1200,
      'patients': '8k+',
      'fee': 3500,
      'image': 'https://i.pravatar.cc/300?img=11',
      'availableToday': true,
      'about':
          'Interventional cardiologist specializing in preventive heart care and minimally invasive procedures.',
    },
    {
      'name': 'Dr Amelia Hart',
      'specialty': 'Pediatrician',
      'location': 'Children\'s Health Pavilion',
      'experience': '9 Years',
      'rating': 4.9,
      'reviews': 960,
      'patients': '7k+',
      'fee': 1500,
      'image': 'https://i.pravatar.cc/300?img=32',
      'availableToday': true,
      'about':
          'Warm, unhurried pediatric visits from newborns through teens, with parents involved every step.',
    },
    {
      'name': 'Dr Marcus Chen',
      'specialty': 'Orthopedic Surgeon',
      'location': 'City Bone & Joint Center',
      'experience': '15 Years',
      'rating': 4.7,
      'reviews': 1800,
      'patients': '12k+',
      'fee': 4000,
      'image': 'https://i.pravatar.cc/300?img=12',
      'availableToday': false,
      'about':
          'Sports injuries and joint care, helping patients return to daily movement with a clear plan.',
    },
  ];
}
