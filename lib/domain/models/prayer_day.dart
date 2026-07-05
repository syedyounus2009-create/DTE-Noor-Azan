import 'calculation_method.dart';
import 'hijri_date.dart';

enum Prayer { fajr, sunrise, dhuhr, asr, maghrib, isha }

extension PrayerLabel on Prayer {
  String get label {
    switch (this) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
    }
  }

  /// Whether this entry is an actual obligatory prayer (Sunrise is shown
  /// for reference only and is never notified/counted as a prayer).
  bool get isObligatory => this != Prayer.sunrise;
}

class PrayerDay {
  final DateTime dateGregorian; // date-only, local
  final HijriDate dateHijri;
  final Map<Prayer, DateTime> times; // local wall-clock DateTimes
  final CalculationMethod method;
  final Madhab madhab;

  const PrayerDay({
    required this.dateGregorian,
    required this.dateHijri,
    required this.times,
    required this.method,
    required this.madhab,
  });

  DateTime operator [](Prayer p) => times[p]!;

  /// Returns the next upcoming obligatory prayer relative to [now], or
  /// null if all of today's prayers have passed (caller should then look
  /// at tomorrow's PrayerDay for Fajr).
  (Prayer, DateTime)? nextAfter(DateTime now) {
    for (final p in [Prayer.fajr, Prayer.dhuhr, Prayer.asr, Prayer.maghrib, Prayer.isha]) {
      final t = times[p]!;
      if (t.isAfter(now)) return (p, t);
    }
    return null;
  }
}
