import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/location_repository.dart';
import '../data/repositories/prayer_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../domain/models/app_settings.dart';
import '../domain/models/saved_location.dart';

final settingsRepositoryProvider = Provider<ISettingsRepository>((ref) {
  return SettingsRepository();
});

final locationRepositoryProvider = Provider<ILocationRepository>((ref) {
  return LocationRepository();
});

final prayerTimeRepositoryProvider = Provider<IPrayerTimeRepository>((ref) {
  return PrayerTimeRepository();
});

/// Current app settings, loaded once and updatable from the Settings
/// screen. Using AsyncNotifier keeps the loading/error states explicit.
final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() {
    return ref.read(settingsRepositoryProvider).load();
  }

  Future<void> update(AppSettings Function(AppSettings current) updater) async {
    final current = state.value ?? const AppSettings();
    final next = updater(current);
    state = AsyncData(next);
    await ref.read(settingsRepositoryProvider).save(next);
  }
}

/// The currently-selected location. Defaults to null until onboarding /
/// GPS resolves one; the home screen shows a "choose location" prompt
/// in that state.
final currentLocationProvider =
    AsyncNotifierProvider<CurrentLocationNotifier, SavedLocation?>(
  CurrentLocationNotifier.new,
);

class CurrentLocationNotifier extends AsyncNotifier<SavedLocation?> {
  @override
  Future<SavedLocation?> build() async {
    final saved = await ref.read(locationRepositoryProvider).getSaved();
    if (saved.isEmpty) return null;
    return saved.firstWhere((l) => l.isCurrent, orElse: () => saved.first);
  }

  Future<void> setLocation(SavedLocation location) async {
    state = AsyncData(location);
    await ref.read(locationRepositoryProvider).saveLocation(location);
    if (location.id != null) {
      await ref.read(locationRepositoryProvider).setCurrent(location.id!);
    }
  }
}
