import 'package:flutter_test/flutter_test.dart';
import 'package:vitalis_appointments/core/formatters.dart';

void main() {
  test('formats clinic fees', () {
    expect(Formatters.fee(1500), 'Rs 1500');
    expect(Formatters.fee('200'), 'Rs 200');
  });
}

