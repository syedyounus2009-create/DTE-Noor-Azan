import 'geo_point.dart';

class SavedLocation {
  final int? id;
  final String label; // "Home", "Makkah", etc.
  final String countryCode;
  final String cityName;
  final GeoPoint point;
  final String timezoneId; // IANA, e.g. "Africa/Cairo"
  final bool isCurrent;

  const SavedLocation({
    this.id,
    required this.label,
    required this.countryCode,
    required this.cityName,
    required this.point,
    required this.timezoneId,
    this.isCurrent = false,
  });

  SavedLocation copyWith({
    int? id,
    String? label,
    bool? isCurrent,
  }) =>
      SavedLocation(
        id: id ?? this.id,
        label: label ?? this.label,
        countryCode: countryCode,
        cityName: cityName,
        point: point,
        timezoneId: timezoneId,
        isCurrent: isCurrent ?? this.isCurrent,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'countryCode': countryCode,
        'cityName': cityName,
        'latitude': point.latitude,
        'longitude': point.longitude,
        'timezoneId': timezoneId,
        'isCurrent': isCurrent,
      };

  factory SavedLocation.fromJson(Map<String, dynamic> json) => SavedLocation(
        id: json['id'] as int?,
        label: json['label'] as String,
        countryCode: json['countryCode'] as String,
        cityName: json['cityName'] as String,
        point: GeoPoint(
          (json['latitude'] as num).toDouble(),
          (json['longitude'] as num).toDouble(),
        ),
        timezoneId: json['timezoneId'] as String,
        isCurrent: json['isCurrent'] as bool? ?? false,
      );
}
