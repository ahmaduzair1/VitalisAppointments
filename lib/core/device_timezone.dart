import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Device timezone without flutter_timezone (that plugin breaks Kotlin
/// incremental compiles on Windows when the project and pub-cache are on
/// different drives).
class DeviceTimezone {
  static const _channel = MethodChannel('vitalis/timezone');

  static Future<void> applyLocal() async {
    tzdata.initializeTimeZones();
    var id = 'UTC';
    try {
      if (!kIsWeb) {
        final result = await _channel.invokeMethod<String>('getLocalTimezone');
        if (result != null && result.isNotEmpty) id = result;
      }
    } catch (_) {}
    try {
      tz.setLocalLocation(tz.getLocation(id));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }
}
