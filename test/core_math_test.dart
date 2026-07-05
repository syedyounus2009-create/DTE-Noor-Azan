import 'package:flutter_test/flutter_test.dart';
import 'package:noor/core/math/great_circle.dart';
import 'package:noor/core/math/hijri_converter.dart';

void main() {
  group('HijriConverter', () {
    test('round-trips Gregorian -> Hijri -> Gregorian', () {
      final cases = [
        DateTime(2026, 3, 4),
        DateTime(2025, 6, 26),
        DateTime(2026, 7, 4),
      ];
      for (final date in cases) {
        final (hy, hm, hd) = HijriConverter.fromGregorian(date);
        final back = HijriConverter.toGregorian(hy, hm, hd);
        expect(back, DateTime(date.year, date.month, date.day));
      }
    });

    test('month names arrays are 12 entries long', () {
      expect(HijriConverter.monthNamesEn.length, 12);
      expect(HijriConverter.monthNamesAr.length, 12);
    });
  });

  group('GreatCircle', () {
    test('bearing and distance to Kaaba from Cairo are plausible', () {
      final bearing = GreatCircle.qiblaBearingFrom(30.0444, 31.2357);
      final distance = GreatCircle.distanceToKaabaKm(30.0444, 31.2357);

      // Cairo is roughly south-east of the Kaaba's bearing frame; the
      // known approximate real-world bearing is ~136°, distance ~1245km.
      expect(bearing, greaterThan(100));
      expect(bearing, lessThan(160));
      expect(distance, greaterThan(1000));
      expect(distance, lessThan(1500));
    });

    test('distance to self is zero', () {
      final d = GreatCircle.distanceKm(
        fromLat: 21.4225,
        fromLng: 39.8262,
        toLat: 21.4225,
        toLng: 39.8262,
      );
      expect(d, closeTo(0, 0.001));
    });
  });
}
