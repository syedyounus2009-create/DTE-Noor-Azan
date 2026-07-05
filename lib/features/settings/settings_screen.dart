import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/calculation_method.dart';
import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.valueOrNull ?? const AppSettings();
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Calculation'),
          ListTile(
            title: const Text('Method'),
            trailing: DropdownButton<String>(
              value: settings.calculationMethodCode,
              items: CalculationMethod.catalog
                  .map((m) => DropdownMenuItem(value: m.code, child: Text(m.displayName)))
                  .toList(),
              onChanged: (v) {
                if (v != null) notifier.update((s) => s.copyWith(calculationMethodCode: v));
              },
            ),
          ),
          ListTile(
            title: const Text('Asr (madhab)'),
            trailing: DropdownButton<Madhab>(
              value: settings.madhab,
              items: const [
                DropdownMenuItem(value: Madhab.standard, child: Text("Standard (Shafi'i)")),
                DropdownMenuItem(value: Madhab.hanafi, child: Text('Hanafi')),
              ],
              onChanged: (v) {
                if (v != null) notifier.update((s) => s.copyWith(madhab: v));
              },
            ),
          ),
          ListTile(
            title: const Text('High-latitude rule'),
            trailing: DropdownButton<HigherLatitudeRule>(
              value: settings.higherLatitudeRule,
              items: const [
                DropdownMenuItem(value: HigherLatitudeRule.none, child: Text('None')),
                DropdownMenuItem(value: HigherLatitudeRule.angleBased, child: Text('Angle-based')),
                DropdownMenuItem(value: HigherLatitudeRule.oneSeventh, child: Text('One-seventh')),
                DropdownMenuItem(value: HigherLatitudeRule.middleOfNight, child: Text('Middle of night')),
              ],
              onChanged: (v) {
                if (v != null) notifier.update((s) => s.copyWith(higherLatitudeRule: v));
              },
            ),
          ),
          const _SectionHeader('Azan'),
          ListTile(
            title: const Text('Pre-prayer reminder'),
            trailing: DropdownButton<int>(
              value: settings.prePrayerMinutes,
              items: const [0, 5, 10, 15, 20, 30]
                  .map((m) => DropdownMenuItem(value: m, child: Text(m == 0 ? 'Off' : '$m minutes before')))
                  .toList(),
              onChanged: (v) {
                if (v != null) notifier.update((s) => s.copyWith(prePrayerMinutes: v));
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Silent mode'),
            subtitle: const Text('Mute Azan, keep visual notification'),
            value: settings.silentMode,
            onChanged: (v) => notifier.update((s) => s.copyWith(silentMode: v)),
          ),
          const _SectionHeader('Appearance'),
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<ThemeModePref>(
              value: settings.themeMode,
              items: const [
                DropdownMenuItem(value: ThemeModePref.system, child: Text('System')),
                DropdownMenuItem(value: ThemeModePref.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeModePref.dark, child: Text('Dark')),
                DropdownMenuItem(value: ThemeModePref.qamar, child: Text('Qamar (auto)')),
              ],
              onChanged: (v) {
                if (v != null) notifier.update((s) => s.copyWith(themeMode: v));
              },
            ),
          ),
          const _SectionHeader('About'),
          const ListTile(title: Text('Version'), trailing: Text('1.0.0')),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
