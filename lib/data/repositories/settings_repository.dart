import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/app_settings.dart';

abstract class ISettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
  Stream<AppSettings> watch();
}

class SettingsRepository implements ISettingsRepository {
  static const _key = 'noor.settings.v1';
  final _controller = _LatestValueBroadcast<AppSettings>(const AppSettings());

  @override
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final settings = raw == null
        ? const AppSettings()
        : AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    _controller.add(settings);
    return settings;
  }

  @override
  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
    _controller.add(settings);
  }

  @override
  Stream<AppSettings> watch() => _controller.stream;
}

/// Minimal broadcast stream that always replays the latest value to new
/// listeners — enough for settings without pulling in rxdart.
class _LatestValueBroadcast<T> {
  T _value;
  final _controller = StreamController<T>.broadcast();

  _LatestValueBroadcast(this._value);

  void add(T value) {
    _value = value;
    _controller.add(value);
  }

  Stream<T> get stream async* {
    yield _value;
    yield* _controller.stream;
  }
}
