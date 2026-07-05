import 'package:flutter_test/flutter_test.dart';
import 'package:noor/core/math/prayer_astronomy.dart';
import 'package:noor/domain/models/calculation_method.dart';
import 'package:noor/domain/models/geo_point.dart';
import 'package:noor/domain/models/prayer_day.dart';
import 'package:noor/domain/models/prayer_time_engine.dart';

void main() {
  group('PrayerAstronomy', () {
    test('julianDate matches known reference for 2000-01-01', () {
      expect(PrayerAstronomy.julianDate(2000, 1, 1), closeTo(2451544.5, 0.001));
    });

    test('hourAngle stays within valid domain for mid-latitudes', () {
      final ha = PrayerAstronomy.hourAngle(30.0, 10.0, 18.0);
      expect(ha, greaterThan(0));
      expect(ha, lessThan(12));
    });
  });

  group('PrayerTimeEngine', () {
    test('Cairo, Egyptian method, prayers are correctly ordered', () {
      final day = PrayerTimeEngine.compute(
        location: const GeoPoint(30.0444, 31.2357),
        date: DateTime(2026, 3, 4),
        utcOffsetHours: 2,
        params: const CalculationParams(
          method: CalculationMethod(
            code: 'egypt',
            displayName: 'Egyptian General Authority',
            fajrAngle: 19.5,
            ishaAngle: 17.5,
          ),
        ),
      );

      expect(day[Prayer.fajr].isBefore(day[Prayer.sunrise]), isTrue);
      expect(day[Prayer.sunrise].isBefore(day[Prayer.dhuhr]), isTrue);
      expect(day[Prayer.dhuhr].isBefore(day[Prayer.asr]), isTrue);
      expect(day[Prayer.asr].isBefore(day[Prayer.maghrib]), isTrue);
      expect(day[Prayer.maghrib].isBefore(day[Prayer.isha]), isTrue);

      // Cross-checked against a reference Python implementation of the
      // same formulas: Fajr ≈ 04:52, Dhuhr ≈ 12:07 local time.
      expect(day[Prayer.fajr].hour, 4);
      expect(day[Prayer.dhuhr].hour, 12);
    });

    test('Hanafi Asr is later than standard Asr for the same day', () {
      const location = GeoPoint(30.0444, 31.2357);
      final base = CalculationParams(
        method: CalculationMethod.byCode('egypt'),
      );

      final standard = PrayerTimeEngine.compute(
        location: location,
        date: DateTime(2026, 3, 4),
        utcOffsetHours: 2,
        params: base,
      );
      final hanafi = PrayerTimeEngine.compute(
        location: location,
        date: DateTime(2026, 3, 4),
        utcOffsetHours: 2,
        params: CalculationParams(method: base.method, madhab: Madhab.hanafi),
      );

      expect(hanafi[Prayer.asr].isAfter(standard[Prayer.asr]), isTrue);
    });
  });
}
