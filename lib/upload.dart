import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadDoctors() async {
  final doctors = [

    {
      "name": "Dr Hina Sheikh",
      "specialty": "Gynecologist",
      "location": "Rawalpindi",
      "experience": "11 Years",
      "rating": 4.9,
      "reviews": 230,
      "patients": "2.3k",
      "fee": 2600,
      "image": "https://randomuser.me/api/portraits/women/12.jpg"
    },
    {
      "name": "Dr Usman Tariq",
      "specialty": "ENT Specialist",
      "location": "Multan",
      "experience": "6 Years",
      "rating": 4.4,
      "reviews": 90,
      "patients": "800",
      "fee": 1400,
      "image": "https://randomuser.me/api/portraits/men/29.jpg"
    },
    {
      "name": "Dr Fatima Zahra",
      "specialty": "Dentist",
      "location": "Hyderabad",
      "experience": "5 Years",
      "rating": 4.3,
      "reviews": 70,
      "patients": "600",
      "fee": 1200,
      "image": "https://randomuser.me/api/portraits/women/21.jpg"
    },
    {
      "name": "Dr Imran Qureshi",
      "specialty": "General Physician",
      "location": "Quetta",
      "experience": "13 Years",
      "rating": 4.7,
      "reviews": 160,
      "patients": "1.7k",
      "fee": 1800,
      "image": "https://randomuser.me/api/portraits/men/55.jpg"
    },
    {
      "name": "Dr Noor ul Ain",
      "specialty": "Psychiatrist",
      "location": "Islamabad",
      "experience": "9 Years",
      "rating": 4.8,
      "reviews": 140,
      "patients": "1.4k",
      "fee": 2300,
      "image": "https://randomuser.me/api/portraits/women/33.jpg"
    }
  ];

  final firestore = FirebaseFirestore.instance;

  for (var doctor in doctors) {
    await firestore.collection('doctors').add(doctor);
  }

  print("✅ Doctors uploaded!");
}