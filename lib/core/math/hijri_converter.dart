/// Tabular ("civil") Islamic calendar conversion, based on the widely
/// published Julian-Day-Number algorithm (the same integer arithmetic
/// used by many open-source calendar libraries). This gives a
/// deterministic civil Hijri date; it intentionally does not attempt
/// astronomical moon-sighting prediction — see README for why, and how
/// a per-region offset can be layered on top in Settings.
class HijriConverter {
  const HijriConverter._();

  static int gregorianToJdn(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y2 = year + 4800 - a;
    final m2 = month + 12 * a - 3;
    return day +
        ((153 * m2 + 2) ~/ 5) +
        365 * y2 +
        (y2 ~/ 4) -
        (y2 ~/ 100) +
        (y2 ~/ 400) -
        32045;
  }

  static (int year, int month, int day) jdnToGregorian(int jdn) {
    final a = jdn + 32044;
    final b = (4 * a + 3) ~/ 146097;
    final c = a - (146097 * b) ~/ 4;
    final d = (4 * c + 3) ~/ 1461;
    final e = c - (1461 * d) ~/ 4;
    final m = (5 * e + 2) ~/ 153;
    final day = e - (153 * m + 2) ~/ 5 + 1;
    final month = m + 3 - 12 * (m ~/ 10);
    final year = 100 * b + d - 4800 + (m ~/ 10);
    return (year, month, day);
  }

  static (int year, int month, int day) jdnToIslamic(int jdn) {
    var l = jdn - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
        (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;
    final month = (24 * l) ~/ 709;
    final day = l - (709 * month) ~/ 24;
    final year = 30 * n + j - 30;
    return (year, month, day);
  }

  static int islamicToJdn(int year, int month, int day) {
    return (11 * year + 3) ~/ 30 +
        354 * year +
        30 * month -
        (month - 1) ~/ 2 +
        day +
        1948440 -
        385;
  }

  /// Convert a Gregorian [DateTime] (date part only) to a Hijri
  /// (year, month, day) tuple, with an optional whole-day [offset] the
  /// user can apply in Settings to match local moonsighting.
  static (int year, int month, int day) fromGregorian(
    DateTime date, {
    int offset = 0,
  }) {
    final jdn = gregorianToJdn(date.year, date.month, date.day) + offset;
    return jdnToIslamic(jdn);
  }

  /// Convert a Hijri (year, month, day) back to a Gregorian [DateTime].
  static DateTime toGregorian(int year, int month, int day) {
    final jdn = islamicToJdn(year, month, day);
    final (gy, gm, gd) = jdnToGregorian(jdn);
    return DateTime(gy, gm, gd);
  }

  static const List<String> monthNamesEn = [
    'Muharram',
    'Safar',
    "Rabi' al-Awwal",
    "Rabi' al-Thani",
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    "Sha'ban",
    'Ramadan',
    'Shawwal',
    "Dhu al-Qi'dah",
    'Dhu al-Hijjah',
  ];

  static const List<String> monthNamesAr = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];
}
