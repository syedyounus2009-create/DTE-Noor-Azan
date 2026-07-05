import 'dart:math' as math;

/// Great-circle bearing and distance calculations, specialized for the
/// fixed Kaaba reference point but usable for any two coordinates.
class GreatCircle {
  const GreatCircle._();

  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;
  static const double earthRadiusKm = 6371.0088;

  /// Initial great-circle bearing (degrees, 0..360, 0 = true North) from
  /// (fromLat, fromLng) toward (toLat, toLng).
  static double bearingDegrees({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final phi1 = _deg2rad(fromLat);
    final phi2 = _deg2rad(toLat);
    final deltaLambda = _deg2rad(toLng - fromLng);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final theta = math.atan2(y, x);
    return (_rad2deg(theta) + 360) % 360;
  }

  /// Great-circle (haversine) distance in kilometers between two points.
  static double distanceKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final phi1 = _deg2rad(fromLat);
    final phi2 = _deg2rad(toLat);
    final deltaPhi = _deg2rad(toLat - fromLat);
    final deltaLambda = _deg2rad(toLng - fromLng);

    final a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) * math.cos(phi2) * math.sin(deltaLambda / 2) * math.sin(deltaLambda / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Convenience: bearing from an arbitrary point to the Kaaba.
  static double qiblaBearingFrom(double lat, double lng) => bearingDegrees(
        fromLat: lat,
        fromLng: lng,
        toLat: kaabaLatitude,
        toLng: kaabaLongitude,
      );

  /// Convenience: distance from an arbitrary point to the Kaaba, in km.
  static double distanceToKaabaKm(double lat, double lng) => distanceKm(
        fromLat: lat,
        fromLng: lng,
        toLat: kaabaLatitude,
        toLng: kaabaLongitude,
      );

  static double _deg2rad(double d) => d * math.pi / 180.0;
  static double _rad2deg(double r) => r * 180.0 / math.pi;
}
