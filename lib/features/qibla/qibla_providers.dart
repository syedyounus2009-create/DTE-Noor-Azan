import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/math/great_circle.dart';
import '../../providers/app_providers.dart';

class QiblaInfo {
  final double bearingDegrees;
  final double distanceKm;
  final double? heading; // null if sensor unavailable
  const QiblaInfo({required this.bearingDegrees, required this.distanceKm, this.heading});

  /// Signed delta the user needs to rotate to align (degrees, -180..180).
  double? get delta {
    if (heading == null) return null;
    var d = bearingDegrees - heading!;
    d = (d + 540) % 360 - 180;
    return d;
  }

  bool get isAligned => delta != null && delta!.abs() < 5;
}

/// Device compass heading, degrees from magnetic/true north. Null stream
/// events mean the sensor is unavailable (FR-34 fallback).
final compassHeadingProvider = StreamProvider<double?>((ref) {
  final events = FlutterCompass.events;
  if (events == null) {
    return Stream<double?>.value(null);
  }
  return events.map((e) => e.heading);
});

final qiblaInfoProvider = Provider<QiblaInfo?>((ref) {
  final location = ref.watch(currentLocationProvider).valueOrNull;
  if (location == null) return null;

  final heading = ref.watch(compassHeadingProvider).valueOrNull;
  final bearing = GreatCircle.qiblaBearingFrom(
    location.point.latitude,
    location.point.longitude,
  );
  final distance = GreatCircle.distanceToKaabaKm(
    location.point.latitude,
    location.point.longitude,
  );
  return QiblaInfo(bearingDegrees: bearing, distanceKm: distance, heading: heading);
});
