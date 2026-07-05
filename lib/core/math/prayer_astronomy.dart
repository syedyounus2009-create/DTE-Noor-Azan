import 'dart:math' as math;

/// Low-level solar position and hour-angle math used to derive prayer
/// times. This is the same class of formulas used by widely published
/// prayer-time calculators (based on standard low-precision solar
/// position equations). Pure functions, no I/O, no external packages —
/// this is why it lives in `core` rather than `domain` or `data`.
class PrayerAstronomy {
  const PrayerAstronomy._();

  /// Julian Date for a Gregorian calendar date (at 00:00 UTC), with an
  /// optional fractional-day correction for longitude (so the "local
  /// solar noon" reference lines up before we compute sun position).
  static double julianDate(int year, int month, int day) {
    var y = year;
    var m = month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524.5;
  }

  /// Returns (declination in degrees, equation of time in hours) for the
  /// given Julian Date.
  static (double declinationDeg, double equationOfTimeHours) sunPosition(
    double jd,
  ) {
    final d = jd - 2451545.0;
    final g = _deg2rad((357.529 + 0.98560028 * d) % 360);
    final q = (280.459 + 0.98564736 * d) % 360;
    final l = _deg2rad(
      (q + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g)) % 360,
    );
    final e = _deg2rad(23.439 - 0.00000036 * d);

    final decl = math.asin(math.sin(e) * math.sin(l));
    var ra = _rad2deg(math.atan2(math.cos(e) * math.sin(l), math.cos(l))) / 15.0;
    ra = ra % 24;
    if (ra < 0) ra += 24;

    var eqt = q / 15.0 - ra;
    if (eqt > 12) eqt -= 24;
    if (eqt < -12) eqt += 24;

    return (_rad2deg(decl), eqt);
  }

  /// Hour angle (in hours) at which the sun reaches `angleDeg` degrees
  /// below the horizon (positive = below horizon), for a given latitude
  /// and solar declination. Used for Fajr, Sunrise, Maghrib, Isha.
  static double hourAngle(double latDeg, double declDeg, double angleDeg) {
    final lat = _deg2rad(latDeg);
    final decl = _deg2rad(declDeg);
    var val = (-math.sin(_deg2rad(angleDeg)) - math.sin(lat) * math.sin(decl)) /
        (math.cos(lat) * math.cos(decl));
    val = val.clamp(-1.0, 1.0);
    return _rad2deg(math.acos(val)) / 15.0;
  }

  /// Hour angle for Asr, using the shadow-length method.
  /// [shadowFactor] = 1 for the standard/Shafi'i madhab, 2 for Hanafi.
  static double asrHourAngle(
    double latDeg,
    double declDeg,
    double shadowFactor,
  ) {
    final lat = _deg2rad(latDeg);
    final decl = _deg2rad(declDeg);
    final a = (lat - decl).abs();
    final altitude = math.atan(1.0 / (shadowFactor + math.tan(a)));
    var val = (math.sin(altitude) - math.sin(lat) * math.sin(decl)) /
        (math.cos(lat) * math.cos(decl));
    val = val.clamp(-1.0, 1.0);
    return _rad2deg(math.acos(val)) / 15.0;
  }

  static double _deg2rad(double d) => d * math.pi / 180.0;
  static double _rad2deg(double r) => r * 180.0 / math.pi;
}
