import '../../core/result/result.dart';
import '../../domain/models/calculation_method.dart';
import '../../domain/models/geo_point.dart';
import '../../domain/models/prayer_day.dart';
import '../../domain/models/prayer_time_engine.dart';
import '../local/timezone_resolver.dart';

abstract class IPrayerTimeRepository {
  Result<PrayerDay> getDay({
    required GeoPoint location,
    required String timezoneId,
    required DateTime date,
    required CalculationParams params,
  });

  Result<List<PrayerDay>> getRange({
    required GeoPoint location,
    required String timezoneId,
    required DateTime start,
    required int days,
    required CalculationParams params,
  });
}

/// In-memory cache keyed by (lat,lng,date,method,madhab). Full
/// architecture spec calls for a Drift/SQLite-backed cache (see
/// data_local/prayer_time table in the architecture doc) — swapping this
/// implementation out for one backed by Drift is a drop-in change since
/// callers only depend on [IPrayerTimeRepository].
class PrayerTimeRepository implements IPrayerTimeRepository {
  final Map<String, PrayerDay> _cache = {};

  String _cacheKey(GeoPoint location, DateTime date, CalculationParams params) {
    return '${location.latitude.toStringAsFixed(4)},'
        '${location.longitude.toStringAsFixed(4)},'
        '${date.year}-${date.month}-${date.day},'
        '${params.method.code},${params.madhab.name},${params.higherLatitudeRule.name}';
  }

  @override
  Result<PrayerDay> getDay({
    required GeoPoint location,
    required String timezoneId,
    required DateTime date,
    required CalculationParams params,
  }) {
    final key = _cacheKey(location, date, params);
    final cached = _cache[key];
    if (cached != null) return Result.success(cached);

    try {
      final offset = TimezoneResolver.utcOffsetHours(timezoneId, date);
      final day = PrayerTimeEngine.compute(
        location: location,
        date: date,
        utcOffsetHours: offset,
        params: params,
      );
      _cache[key] = day;
      return Result.success(day);
    } catch (e) {
      return Result.failure(Failure(FailureCode.unknown, e.toString()));
    }
  }

  @override
  Result<List<PrayerDay>> getRange({
    required GeoPoint location,
    required String timezoneId,
    required DateTime start,
    required int days,
    required CalculationParams params,
  }) {
    final out = <PrayerDay>[];
    for (var i = 0; i < days; i++) {
      final date = DateTime(start.year, start.month, start.day + i);
      final result = getDay(
        location: location,
        timezoneId: timezoneId,
        date: date,
        params: params,
      );
      switch (result) {
        case Success<PrayerDay>(:final value):
          out.add(value);
        case Failure_<PrayerDay>(:final failure):
          return Result.failure(failure);
      }
    }
    return Result.success(out);
  }
}
