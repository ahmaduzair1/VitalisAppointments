/// App-wide configuration. Admin access is bootstrapped from this email only.
/// Sign in with this address (Google or email) and verify the email to open
/// the hospital admin dashboard. Users cannot grant themselves this role.
class AppConfig {
  AppConfig._();

  static const String adminEmail = 'admin@vitalis.app';
  static const String clinicName = 'Vitalis Clinic';
  static const String currencyPrefix = 'Rs ';

  static bool isAdminEmail(String? email) {
    if (email == null) return false;
    return email.trim().toLowerCase() == adminEmail;
  }
}
