import '../../core/math/prayer_astronomy.dart';
import 'calculation_method.dart';
import 'geo_point.dart';
import 'hijri_date.dart';
import 'prayer_day.dart';

/// Orchestrates `core/math` (pure astronomy) using domain models to
/// produce a fully-formed [PrayerDay]. This is intentionally the only
/// place that converts "hours since local midnight" into real local
/// [DateTime]s, and the only place higher-latitude rules are applied.
class PrayerTimeEngine {
  const PrayerTimeEngine._();

  /// [date] should be a local calendar date (time-of-day ignored).
  /// [utcOffsetHours] is the location's UTC offset *for that date*
  /// (callers should resolve DST via the IANA timezone before calling).
  static PrayerDay compute({
    required GeoPoint location,
    required DateTime date,
    required double utcOffsetHours,
    required CalculationParams params,
    int hijriOffsetDays = 0,
  }) {
    final jd = PrayerAstronomy.julianDate(date.year, date.month, date.day) -
        location.longitude / (15 * 24);
    final (decl, eqt) = PrayerAstronomy.sunPosition(jd);

    final dhuhrHours = 12 + utcOffsetHours - location.longitude / 15 - eqt;

    var fajrHours = dhuhrHours -
        PrayerAstronomy.hourAngle(location.latitude, decl, params.method.fajrAngle);
    final sunriseHours =
        dhuhrHours - PrayerAstronomy.hourAngle(location.latitude, decl, 0.833);
    final maghribHours =
        dhuhrHours + PrayerAstronomy.hourAngle(location.latitude, decl, 0.833);

    double ishaHours;
    if (params.method.ishaIntervalMinutes != null) {
      ishaHours = maghribHours + params.method.ishaIntervalMinutes! / 60.0;
    } else {
      ishaHours = dhuhrHours +
          PrayerAstronomy.hourAngle(location.latitude, decl, params.method.ishaAngle!);
    }

    var asrHours = dhuhrHours +
        PrayerAstronomy.asrHourAngle(
          location.latitude,
          decl,
          params.madhab.asrShadowFactor,
        );

    // Higher-latitude correction: when the night is short enough that the
    // sun-angle-based Fajr/Isha hour angle becomes undefined or extreme,
    // fall back to a fraction of the night. A simplified but standard
    // approach (adequate for V1; see README for the full spec reference).
    final nightHours = 24 - (maghribHours - sunriseHours);
    if (params.higherLatitudeRule != HigherLatitudeRule.none) {
      final double nightPortion = switch (params.higherLatitudeRule) {
        HigherLatitudeRule.oneSeventh => nightHours / 7,
        HigherLatitudeRule.middleOfNight => nightHours / 2,
        HigherLatitudeRule.angleBased =>
          nightHours * (params.method.fajrAngle / 60),
        HigherLatitudeRule.none => 0.0,
      };
      final safeFajr = sunriseHours - nightPortion;
      final safeIsha = maghribHours + nightPortion;
      if (fajrHours.isNaN || fajrHours < safeFajr) fajrHours = safeFajr;
      if (ishaHours.isNaN || ishaHours > safeIsha) ishaHours = safeIsha;
    }

    DateTime toLocalTime(double hours) {
      final totalMinutes = (hours * 60).round();
      return DateTime(date.year, date.month, date.day)
          .add(Duration(minutes: totalMinutes));
    }

    DateTime withAdjustment(double hours, Prayer prayer) {
      final base = toLocalTime(hours);
      final adj = params.adjustmentsMinutes[prayer.name] ?? 0;
      return base.add(Duration(minutes: adj));
    }

    final times = <Prayer, DateTime>{
      Prayer.fajr: withAdjustment(fajrHours, Prayer.fajr),
      Prayer.sunrise: withAdjustment(sunriseHours, Prayer.sunrise),
      Prayer.dhuhr: withAdjustment(dhuhrHours, Prayer.dhuhr),
      Prayer.asr: withAdjustment(asrHours, Prayer.asr),
      Prayer.maghrib: withAdjustment(maghribHours, Prayer.maghrib),
      Prayer.isha: withAdjustment(ishaHours, Prayer.isha),
    };

    return PrayerDay(
      dateGregorian: DateTime(date.year, date.month, date.day),
      dateHijri: HijriDate.fromGregorian(date, offset: hijriOffsetDays),
      times: times,
      method: params.method,
      madhab: params.madhab,
    );
  }
}
