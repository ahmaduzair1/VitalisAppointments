import 'services/doctor_service.dart';

/// Optional one-off helper. Prefer Hospital board → Doctors → sparkle icon.
Future<void> uploadDoctors() => DoctorService.instance.seedCatalog();
