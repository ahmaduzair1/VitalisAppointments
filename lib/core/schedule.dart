/// Shared visit date/time helpers. Stored values stay in the existing
/// "Sep 9, 2026" + "08:00 AM" format so older bookings keep working.
class VisitSchedule {
  VisitSchedule._();

  static const List<String> morningSlots = [
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
  ];
  static const List<String> afternoonSlots = [
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];
  static const List<String> eveningSlots = [
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
    '08:00 PM',
  ];

  static const List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static List<String> get allSlots => [
        ...morningSlots,
        ...afternoonSlots,
        ...eveningSlots,
      ];

  /// Stable Firestore document id for a doctor + date + time lock.
  static String slotDocId(String doctorId, String date, String time) {
    return '$doctorId|$date|$time';
  }

  static List<DateTime> nextDays({int count = 7}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return List.generate(count, (i) => start.add(Duration(days: i)));
  }

  static String dayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  static String formatDate(DateTime date) {
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  static DateTime? parseDate(String date) {
    final match = RegExp(r'^([A-Za-z]{3}) (\d{1,2}), (\d{4})$').firstMatch(date.trim());
    if (match == null) return null;
    final monthIndex = monthNames.indexWhere(
      (m) => m.toLowerCase() == match.group(1)!.toLowerCase(),
    );
    if (monthIndex < 0) return null;
    final day = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);
    if (day == null || year == null) return null;
    return DateTime(year, monthIndex + 1, day);
  }

  static DateTime? parseTime(String time) {
    final match =
        RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false).firstMatch(time.trim());
    if (match == null) return null;
    var hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) return null;
    final period = match.group(3)!.toUpperCase();
    if (period == 'AM') {
      if (hour == 12) hour = 0;
    } else if (hour != 12) {
      hour += 12;
    }
    return DateTime(1970, 1, 1, hour, minute);
  }

  static DateTime? parseVisit(String date, String time) {
    final d = parseDate(date);
    final t = parseTime(time);
    if (d == null || t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  static bool isSlotInPast(DateTime date, String time) {
    final visit = parseVisit(formatDate(date), time);
    if (visit == null) return false;
    return visit.isBefore(DateTime.now());
  }

  static VisitProximity proximity(String date, String time) {
    final visit = parseVisit(date, time);
    if (visit == null) return VisitProximity.unknown;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final visitDay = DateTime(visit.year, visit.month, visit.day);
    final diff = visitDay.difference(today).inDays;
    if (diff < 0 || visit.isBefore(now)) return VisitProximity.past;
    if (diff == 0) return VisitProximity.today;
    if (diff == 1) return VisitProximity.tomorrow;
    return VisitProximity.later;
  }
}

enum VisitProximity { past, today, tomorrow, later, unknown }
