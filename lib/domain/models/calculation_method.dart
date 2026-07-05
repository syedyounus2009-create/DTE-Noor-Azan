/// One of the ≥12 canonical prayer-time calculation methods (FR-11).
/// `ishaIntervalMinutes` is set instead of `ishaAngle` for methods (like
/// Umm al-Qura) that define Isha as a fixed offset after Maghrib rather
/// than a sun angle.
class CalculationMethod {
  final String code;
  final String displayName;
  final double fajrAngle;
  final double? ishaAngle;
  final int? ishaIntervalMinutes;

  const CalculationMethod({
    required this.code,
    required this.displayName,
    required this.fajrAngle,
    this.ishaAngle,
    this.ishaIntervalMinutes,
  }) : assert(
          ishaAngle != null || ishaIntervalMinutes != null,
          'Either ishaAngle or ishaIntervalMinutes must be set',
        );

  /// Built-in catalog per Appendix A of the Noor architecture spec.
  static const List<CalculationMethod> catalog = [
    CalculationMethod(code: 'mwl', displayName: 'Muslim World League', fajrAngle: 18, ishaAngle: 17),
    CalculationMethod(code: 'isna', displayName: 'Islamic Society of North America', fajrAngle: 15, ishaAngle: 15),
    CalculationMethod(code: 'egypt', displayName: 'Egyptian General Authority', fajrAngle: 19.5, ishaAngle: 17.5),
    CalculationMethod(code: 'karachi', displayName: 'Univ. of Islamic Sciences, Karachi', fajrAngle: 18, ishaAngle: 18),
    CalculationMethod(code: 'ummAlQura', displayName: 'Umm al-Qura, Makkah', fajrAngle: 18.5, ishaIntervalMinutes: 90),
    CalculationMethod(code: 'dubai', displayName: 'Dubai', fajrAngle: 18.2, ishaAngle: 18.2),
    CalculationMethod(code: 'moonsighting', displayName: 'Moonsighting Committee', fajrAngle: 18, ishaAngle: 18),
    CalculationMethod(code: 'singapore', displayName: 'Majlis Ugama Islam Singapura', fajrAngle: 20, ishaAngle: 18),
    CalculationMethod(code: 'tehran', displayName: 'Institute of Geophysics, Tehran', fajrAngle: 17.7, ishaAngle: 14),
    CalculationMethod(code: 'diyanet', displayName: 'Diyanet İşleri Başkanlığı', fajrAngle: 18, ishaAngle: 17),
    CalculationMethod(code: 'jakim', displayName: 'JAKIM (Malaysia)', fajrAngle: 20, ishaAngle: 18),
  ];

  static CalculationMethod byCode(String code) =>
      catalog.firstWhere((m) => m.code == code, orElse: () => catalog.first);
}

enum Madhab {
  standard, // Shafi'i / Maliki / Hanbali — shadow factor 1
  hanafi; // shadow factor 2

  double get asrShadowFactor => this == Madhab.hanafi ? 2 : 1;
}

enum HigherLatitudeRule { none, angleBased, oneSeventh, middleOfNight }

class CalculationParams {
  final CalculationMethod method;
  final Madhab madhab;
  final HigherLatitudeRule higherLatitudeRule;

  /// Per-prayer adjustments in minutes, keyed by prayer name
  /// ('fajr','sunrise','dhuhr','asr','maghrib','isha').
  final Map<String, int> adjustmentsMinutes;

  const CalculationParams({
    required this.method,
    this.madhab = Madhab.standard,
    this.higherLatitudeRule = HigherLatitudeRule.middleOfNight,
    this.adjustmentsMinutes = const {},
  });
}
