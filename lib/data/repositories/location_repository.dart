import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/result/result.dart';
import '../../domain/models/geo_point.dart';
import '../../domain/models/saved_location.dart';

abstract class ILocationRepository {
  Future<Result<GeoPoint>> getCurrentPosition();
  Future<List<SavedLocation>> getSaved();
  Future<void> saveLocation(SavedLocation location);
  Future<void> setCurrent(int id);
  Future<void> remove(int id);
}

class LocationRepository implements ILocationRepository {
  static const _key = 'noor.locations.v1';

  @override
  Future<Result<GeoPoint>> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Result.failure(
          Failure(FailureCode.locationUnavailable, 'Location services are disabled.'),
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const Result.failure(
          Failure(FailureCode.locationPermissionDenied, 'Location permission denied.'),
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      return Result.success(GeoPoint(position.latitude, position.longitude));
    } catch (e) {
      return Result.failure(Failure(FailureCode.locationUnavailable, e.toString()));
    }
  }

  @override
  Future<List<SavedLocation>> getSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    return raw
        .map((s) => SavedLocation.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveLocation(SavedLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getSaved();
    final next = [...list, location];
    await prefs.setStringList(
      _key,
      next.map((l) => jsonEncode(l.toJson())).toList(),
    );
  }

  @override
  Future<void> setCurrent(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getSaved();
    final next = list.map((l) => l.copyWith(isCurrent: l.id == id)).toList();
    await prefs.setStringList(
      _key,
      next.map((l) => jsonEncode(l.toJson())).toList(),
    );
  }

  @override
  Future<void> remove(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getSaved();
    final next = list.where((l) => l.id != id).toList();
    await prefs.setStringList(
      _key,
      next.map((l) => jsonEncode(l.toJson())).toList(),
    );
  }
}
