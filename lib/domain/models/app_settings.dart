import 'calculation_method.dart';

enum ThemeModePref { light, dark, system, qamar }

class AppSettings {
  final String calculationMethodCode;
  final Madhab madhab;
  final HigherLatitudeRule higherLatitudeRule;
  final String languageCode;
  final ThemeModePref themeMode;
  final int prePrayerMinutes;
  final bool silentMode;
  final String adhanAudioId;
  final String dndStart; // "HH:mm"
  final String dndEnd;
  final Map<String, int> personalOffsets; // prayer -> minutes
  final int hijriOffsetDays;

  const AppSettings({
    this.calculationMethodCode = 'mwl',
    this.madhab = Madhab.standard,
    this.higherLatitudeRule = HigherLatitudeRule.middleOfNight,
    this.languageCode = 'en',
    this.themeMode = ThemeModePref.system,
    this.prePrayerMinutes = 10,
    this.silentMode = false,
    this.adhanAudioId = 'default_mishary',
    this.dndStart = '22:00',
    this.dndEnd = '06:00',
    this.personalOffsets = const {},
    this.hijriOffsetDays = 0,
  });

  CalculationParams toCalculationParams() => CalculationParams(
        method: CalculationMethod.byCode(calculationMethodCode),
        madhab: madhab,
        higherLatitudeRule: higherLatitudeRule,
        adjustmentsMinutes: personalOffsets,
      );

  AppSettings copyWith({
    String? calculationMethodCode,
    Madhab? madhab,
    HigherLatitudeRule? higherLatitudeRule,
    String? languageCode,
    ThemeModePref? themeMode,
    int? prePrayerMinutes,
    bool? silentMode,
    String? adhanAudioId,
    String? dndStart,
    String? dndEnd,
    Map<String, int>? personalOffsets,
    int? hijriOffsetDays,
  }) =>
      AppSettings(
        calculationMethodCode: calculationMethodCode ?? this.calculationMethodCode,
        madhab: madhab ?? this.madhab,
        higherLatitudeRule: higherLatitudeRule ?? this.higherLatitudeRule,
        languageCode: languageCode ?? this.languageCode,
        themeMode: themeMode ?? this.themeMode,
        prePrayerMinutes: prePrayerMinutes ?? this.prePrayerMinutes,
        silentMode: silentMode ?? this.silentMode,
        adhanAudioId: adhanAudioId ?? this.adhanAudioId,
        dndStart: dndStart ?? this.dndStart,
        dndEnd: dndEnd ?? this.dndEnd,
        personalOffsets: personalOffsets ?? this.personalOffsets,
        hijriOffsetDays: hijriOffsetDays ?? this.hijriOffsetDays,
      );

  Map<String, dynamic> toJson() => {
        'calculationMethodCode': calculationMethodCode,
        'madhab': madhab.name,
        'higherLatitudeRule': higherLatitudeRule.name,
        'languageCode': languageCode,
        'themeMode': themeMode.name,
        'prePrayerMinutes': prePrayerMinutes,
        'silentMode': silentMode,
        'adhanAudioId': adhanAudioId,
        'dndStart': dndStart,
        'dndEnd': dndEnd,
        'personalOffsets': personalOffsets,
        'hijriOffsetDays': hijriOffsetDays,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        calculationMethodCode: json['calculationMethodCode'] as String? ?? 'mwl',
        madhab: Madhab.values.byName(json['madhab'] as String? ?? 'standard'),
        higherLatitudeRule: HigherLatitudeRule.values
            .byName(json['higherLatitudeRule'] as String? ?? 'middleOfNight'),
        languageCode: json['languageCode'] as String? ?? 'en',
        themeMode: ThemeModePref.values.byName(json['themeMode'] as String? ?? 'system'),
        prePrayerMinutes: json['prePrayerMinutes'] as int? ?? 10,
        silentMode: json['silentMode'] as bool? ?? false,
        adhanAudioId: json['adhanAudioId'] as String? ?? 'default_mishary',
        dndStart: json['dndStart'] as String? ?? '22:00',
        dndEnd: json['dndEnd'] as String? ?? '06:00',
        personalOffsets: (json['personalOffsets'] as Map?)?.cast<String, int>() ?? const {},
        hijriOffsetDays: json['hijriOffsetDays'] as int? ?? 0,
      );
}
