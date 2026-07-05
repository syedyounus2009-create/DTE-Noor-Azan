import '../../core/math/hijri_converter.dart';

class HijriDate {
  final int year;
  final int month; // 1..12
  final int day;

  const HijriDate(this.year, this.month, this.day);

  factory HijriDate.fromGregorian(DateTime date, {int offset = 0}) {
    final (y, m, d) = HijriConverter.fromGregorian(date, offset: offset);
    return HijriDate(y, m, d);
  }

  DateTime toGregorian() => HijriConverter.toGregorian(year, month, day);

  String get monthNameEn => HijriConverter.monthNamesEn[month - 1];
  String get monthNameAr => HijriConverter.monthNamesAr[month - 1];

  String format({bool arabic = false}) =>
      '$day ${arabic ? monthNameAr : monthNameEn} $year${arabic ? 'هـ' : 'AH'}';
}
