import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/hijri_date.dart';
import '../../domain/models/prayer_day.dart';
import '../../providers/app_providers.dart';

final _visibleMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());
final _selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(_visibleMonthProvider);
    final selected = ref.watch(_selectedDayProvider);
    final location = ref.watch(currentLocationProvider).valueOrNull;
    final settings = ref.watch(settingsProvider).valueOrNull;

    PrayerDay? selectedDay;
    if (location != null && settings != null) {
      final repo = ref.watch(prayerTimeRepositoryProvider);
      selectedDay = repo
          .getDay(
            location: location.point,
            timezoneId: location.timezoneId,
            date: selected,
            params: settings.toCalculationParams(),
          )
          .valueOrNull;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => ref.read(_visibleMonthProvider.notifier).state =
                  DateTime(month.year, month.month - 1),
            ),
            Text('${_monthName(month.month)} ${month.year}'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => ref.read(_visibleMonthProvider.notifier).state =
                  DateTime(month.year, month.month + 1),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _WeekdayHeader(),
          Expanded(
            child: _MonthGrid(
              month: month,
              selected: selected,
              onSelect: (d) => ref.read(_selectedDayProvider.notifier).state = d,
            ),
          ),
          if (selectedDay != null) _SelectedDayDetail(day: selectedDay),
        ],
      ),
    );
  }

  static String _monthName(int m) => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ][m - 1];
}

class _WeekdayHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: const ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
            .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold)))))
            .toList(),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  const _MonthGrid({required this.month, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday % 7; // Sunday = 0

    final cells = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final isSelected = date.year == selected.year && date.month == selected.month && date.day == selected.day;
      final isToday = _isSameDay(date, DateTime.now());
      cells.add(_DayCell(date: date, isSelected: isSelected, isToday: isToday, onTap: () => onSelect(date)));
    }

    return GridView.count(
      crossAxisCount: 7,
      children: cells,
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _DayCell({required this.date, required this.isSelected, required this.isToday, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : null,
          border: isToday && !isSelected ? Border.all(color: theme.colorScheme.primary) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(color: isSelected ? theme.colorScheme.onPrimary : null),
        ),
      ),
    );
  }
}

class _SelectedDayDetail extends StatelessWidget {
  final PrayerDay day;
  const _SelectedDayDetail({required this.day});

  @override
  Widget build(BuildContext context) {
    final hijri = HijriDate.fromGregorian(day.dateGregorian);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hijri.format(), style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: Prayer.values
                .where((p) => p.isObligatory || p == Prayer.sunrise)
                .map((p) => Text('${p.label} ${_fmt(day[p])}'))
                .toList(),
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour >= 12 ? 'PM' : 'AM'}';
  }
}
