import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/prayer_day.dart';
import '../../providers/app_providers.dart';

/// Derives today's [PrayerDay] from the current location + settings.
/// Returns null while either dependency is still loading/unset.
final todayPrayerDayProvider = Provider<PrayerDay?>((ref) {
  final location = ref.watch(currentLocationProvider).valueOrNull;
  final settings = ref.watch(settingsProvider).valueOrNull;
  if (location == null || settings == null) return null;

  final repo = ref.watch(prayerTimeRepositoryProvider);
  final result = repo.getDay(
    location: location.point,
    timezoneId: location.timezoneId,
    date: DateTime.now(),
    params: settings.toCalculationParams(),
  );
  return result.valueOrNull;
});

/// A ticking "now" provider (1/sec) so countdowns update live without
/// each widget managing its own Timer.
final clockTickProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
    yield DateTime.now();
  }
});
