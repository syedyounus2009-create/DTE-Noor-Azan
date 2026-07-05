import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

/// Thin wrapper around the `timezone` package so the rest of the app
/// only deals with "give me the UTC offset in hours for this IANA id on
/// this date" — correctly handling DST transitions.
class TimezoneResolver {
  static bool _initialized = false;

  static void ensureInitialized() {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    _initialized = true;
  }

  static double utcOffsetHours(String ianaId, DateTime date) {
    ensureInitialized();
    final location = tz.getLocation(ianaId);
    final tzDate = tz.TZDateTime(location, date.year, date.month, date.day, 12);
    return tzDate.timeZoneOffset.inMinutes / 60.0;
  }
}
