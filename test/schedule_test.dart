import 'package:flutter_test/flutter_test.dart';
import 'package:vitalis_appointments/core/schedule.dart';

void main() {
  test('formats and parses booking dates', () {
    final date = DateTime(2026, 9, 9);
    expect(VisitSchedule.formatDate(date), 'Sep 9, 2026');
    expect(VisitSchedule.parseDate('Sep 9, 2026'), DateTime(2026, 9, 9));
  });

  test('parses 12-hour visit times', () {
    final morning = VisitSchedule.parseVisit('Sep 9, 2026', '08:00 AM');
    expect(morning, DateTime(2026, 9, 9, 8));

    final noon = VisitSchedule.parseVisit('Sep 9, 2026', '12:00 PM');
    expect(noon, DateTime(2026, 9, 9, 12));

    final evening = VisitSchedule.parseVisit('Sep 9, 2026', '08:00 PM');
    expect(evening, DateTime(2026, 9, 9, 20));
  });

  test('detects today and tomorrow visits', () {
    final now = DateTime.now();
    final today = VisitSchedule.formatDate(now);
    final lateToday = VisitSchedule.parseVisit(today, '11:59 PM');
    if (lateToday != null && lateToday.isAfter(now)) {
      expect(VisitSchedule.proximity(today, '11:59 PM'), VisitProximity.today);
    }

    final tomorrow = VisitSchedule.formatDate(now.add(const Duration(days: 1)));
    expect(VisitSchedule.proximity(tomorrow, '09:00 AM'), VisitProximity.tomorrow);
  });

  test('builds a unique lock id per doctor date and time', () {
    expect(
      VisitSchedule.slotDocId('docA', 'Sep 9, 2026', '02:00 PM'),
      'docA|Sep 9, 2026|02:00 PM',
    );
    expect(
      VisitSchedule.slotDocId('docA', 'Sep 9, 2026', '02:00 PM'),
      isNot(VisitSchedule.slotDocId('docB', 'Sep 9, 2026', '02:00 PM')),
    );
    expect(
      VisitSchedule.slotDocId('docA', 'Sep 9, 2026', '02:00 PM'),
      isNot(VisitSchedule.slotDocId('docA', 'Sep 9, 2026', '02:30 PM')),
    );
  });
}
