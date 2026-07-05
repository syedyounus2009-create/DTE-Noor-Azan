import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/prayer_day.dart';
import '../../providers/app_providers.dart';
import 'home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(currentLocationProvider).valueOrNull;
    final day = ref.watch(todayPrayerDayProvider);
    final now = ref.watch(clockTickProvider).valueOrNull ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Noor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: location == null
          ? _NoLocationPrompt(onPick: () => context.push('/onboarding'))
          : day == null
              ? const Center(child: CircularProgressIndicator())
              : _HomeContent(day: day, now: now, locationLabel: location.cityName),
    );
  }
}

class _NoLocationPrompt extends StatelessWidget {
  final VoidCallback onPick;
  const _NoLocationPrompt({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_outlined, size: 48),
            const SizedBox(height: 16),
            Text('Set your location to see prayer times', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            FilledButton(onPressed: onPick, child: const Text('Choose location')),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final PrayerDay day;
  final DateTime now;
  final String locationLabel;

  const _HomeContent({required this.day, required this.now, required this.locationLabel});

  @override
  Widget build(BuildContext context) {
    final next = day.nextAfter(now);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${_weekday(day.dateGregorian)}, ${day.dateHijri.format()}',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        Text(
          _gregorian(day.dateGregorian),
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text('NEXT PRAYER', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                Text(
                  next?.$1.label ?? 'Fajr (tomorrow)',
                  style: theme.textTheme.headlineMedium,
                ),
                Text(
                  next != null ? _timeOfDay(next.$2) : '—',
                  style: theme.textTheme.displaySmall,
                ),
                if (next != null)
                  Text(
                    'in ${_countdown(next.$2, now)}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: Prayer.values.map((p) {
              final isNext = next?.$1 == p;
              return ListTile(
                leading: Icon(isNext ? Icons.play_arrow : null, color: theme.colorScheme.primary),
                title: Text(p.label),
                trailing: Text(
                  _timeOfDay(day[p]),
                  style: isNext ? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary) : null,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_outlined, size: 18),
            const SizedBox(width: 4),
            Text(locationLabel),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _NavChip(icon: Icons.calendar_month_outlined, label: 'Monthly', route: '/calendar'),
            _NavChip(icon: Icons.explore_outlined, label: 'Qibla', route: '/qibla'),
            _NavChip(icon: Icons.mosque_outlined, label: 'Mosques', route: '/mosques'),
            _NavChip(icon: Icons.more_horiz, label: 'More', route: '/settings'),
          ],
        ),
      ],
    );
  }

  static String _weekday(DateTime d) =>
      const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][d.weekday - 1];

  static String _gregorian(DateTime d) =>
      '${const ['January','February','March','April','May','June','July','August','September','October','November','December'][d.month - 1]} ${d.day}, ${d.year}';

  static String _timeOfDay(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final suffix = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $suffix';
  }

  static String _countdown(DateTime target, DateTime now) {
    final diff = target.difference(now);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}

class _NavChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  const _NavChip({required this.icon, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () => context.push(route),
    );
  }
}
