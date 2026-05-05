/// Centralized mock data for the Vitalis Appointments app.
class MockData {
  MockData._();

  // ── Doctors ─────────────────────────────────────────────────
  static final List<Map<String, dynamic>> doctors = [
    {
      'name': 'Dr. Julian Sterling',
      'specialty': 'Cardiologist',
      'experience': '12 years',
      'rating': 4.9,
      'reviews': '1.2k',
      'patients': '8k+',
      'fee': 120,
      'image': 'https://i.pravatar.cc/300?img=11',
      'location': 'Heart Center, Block B',
      'availableToday': true,
      'about':
          'Dr. Sterling is a board-certified cardiologist with over 12 years of experience in interventional cardiology. He specializes in preventive heart care and minimally invasive procedures.',
    },
    {
      'name': 'Dr. Sarah Jenkins',
      'specialty': 'Dermatologist',
      'experience': '8 years',
      'rating': 4.8,
      'reviews': '850',
      'patients': '5k+',
      'fee': 90,
      'image': 'https://i.pravatar.cc/300?img=5',
      'location': 'Skin & Wellness Clinic',
      'availableToday': true,
      'about':
          'Dr. Jenkins is an expert in cosmetic dermatology and skin cancer detection. She combines the latest technology with a patient-first approach to deliver outstanding care.',
    },
    {
      'name': 'Dr. Elena Rodriguez',
      'specialty': 'Neurologist',
      'experience': '10 years',
      'rating': 5.0,
      'reviews': '2k+',
      'patients': '10k+',
      'fee': 150,
      'image': 'https://i.pravatar.cc/300?img=9',
      'location': 'Neuro Wellness Institute',
      'availableToday': false,
      'about':
          'Dr. Rodriguez is a leading neurologist specializing in headache disorders and neurodegenerative diseases. She is known for her compassionate and thorough diagnostic approach.',
    },
    {
      'name': 'Dr. Marcus Chen',
      'specialty': 'Orthopedic Surgeon',
      'experience': '15 years',
      'rating': 4.7,
      'reviews': '1.8k',
      'patients': '12k+',
      'fee': 200,
      'image': 'https://i.pravatar.cc/300?img=12',
      'location': 'City Bone & Joint Center',
      'availableToday': true,
      'about':
          'Dr. Chen specializes in sports medicine and joint replacement surgery. He has helped thousands of patients return to active lifestyles through advanced surgical techniques.',
    },
    {
      'name': 'Dr. Amelia Hart',
      'specialty': 'Pediatrician',
      'experience': '9 years',
      'rating': 4.9,
      'reviews': '960',
      'patients': '7k+',
      'fee': 80,
      'image': 'https://i.pravatar.cc/300?img=32',
      'location': 'Children\'s Health Pavilion',
      'availableToday': true,
      'about':
          'Dr. Hart provides comprehensive pediatric care from newborns to adolescents. Her warm and gentle approach makes every visit comfortable for children and parents alike.',
    },
    {
      'name': 'Dr. David Kim',
      'specialty': 'Psychiatrist',
      'experience': '11 years',
      'rating': 4.8,
      'reviews': '720',
      'patients': '4k+',
      'fee': 130,
      'image': 'https://i.pravatar.cc/300?img=14',
      'location': 'Mind & Wellness Center',
      'availableToday': false,
      'about':
          'Dr. Kim is a compassionate psychiatrist focusing on anxiety, depression, and stress management. He integrates evidence-based therapy with holistic wellness strategies.',
    },
  ];

  // ── Categories ──────────────────────────────────────────────
  static const List<Map<String, dynamic>> categories = [
    {'label': 'General', 'icon': 'medical_services'},
    {'label': 'Dentist', 'icon': 'clean_hands'},
    {'label': 'Heart', 'icon': 'favorite'},
    {'label': 'Brain', 'icon': 'psychology'},
    {'label': 'Eye', 'icon': 'visibility'},
    {'label': 'Bone', 'icon': 'accessibility_new'},
  ];

  // ── Time Slots ──────────────────────────────────────────────
  static const List<String> morningSlots = [
    '08:00 AM',
    '08:30 AM',
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
  ];

  static const List<String> afternoonSlots = [
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
  ];

  static const List<String> eveningSlots = [
    '05:00 PM',
    '05:30 PM',
    '06:00 PM',
    '06:30 PM',
  ];

  // ── Upcoming Appointments ───────────────────────────────────
  static final List<Map<String, String>> upcomingAppointments = [
    {
      'name': 'Dr. Julian Sterling',
      'specialty': 'Cardiologist',
      'date': 'Tomorrow',
      'time': '10:00 AM',
      'location': 'Heart Center, Block B',
      'status': 'CONFIRMED',
    },
    {
      'name': 'Dr. Sarah Jenkins',
      'specialty': 'Dermatologist',
      'date': 'May 8, 2026',
      'time': '02:15 PM',
      'location': 'Skin & Wellness Clinic',
      'status': 'PENDING',
    },
  ];

  static final List<Map<String, String>> pastAppointments = [
    {
      'name': 'Dr. Marcus Chen',
      'specialty': 'Orthopedic Surgeon',
      'date': 'Apr 20, 2026',
      'time': '11:00 AM',
      'location': 'City Bone & Joint Center',
      'status': 'COMPLETED',
    },
    {
      'name': 'Dr. Amelia Hart',
      'specialty': 'Pediatrician',
      'date': 'Apr 12, 2026',
      'time': '03:45 PM',
      'location': 'Children\'s Health Pavilion',
      'status': 'COMPLETED',
    },
  ];
}