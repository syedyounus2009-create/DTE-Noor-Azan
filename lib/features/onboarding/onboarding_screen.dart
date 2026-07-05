import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/calculation_method.dart';
import '../../domain/models/geo_point.dart';
import '../../domain/models/saved_location.dart';
import '../../providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  bool _resolving = false;
  String? _error;

  Future<void> _useMyLocation() async {
    setState(() {
      _resolving = true;
      _error = null;
    });
    final repo = ref.read(locationRepositoryProvider);
    final result = await repo.getCurrentPosition();
    result.when(
      success: (point) {
        setState(() {
          _resolving = false;
          _step = 2;
        });
        _pendingPoint = point;
      },
      failure: (f) {
        setState(() {
          _resolving = false;
          _error = f.message;
        });
      },
    );
  }

  GeoPoint? _pendingPoint;

  void _finish(String methodCode) async {
    final point = _pendingPoint ?? const GeoPoint(21.4225, 39.8262); // fallback: Makkah
    await ref.read(currentLocationProvider.notifier).setLocation(
          SavedLocation(
            id: DateTime.now().millisecondsSinceEpoch,
            label: 'Current',
            countryCode: '',
            cityName: 'Selected location',
            point: point,
            timezoneId: 'UTC',
            isCurrent: true,
          ),
        );
    await ref
        .read(settingsProvider.notifier)
        .update((s) => s.copyWith(calculationMethodCode: methodCode));
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: IndexedStack(
            index: _step,
            children: [
              _WelcomeStep(onNext: () => setState(() => _step = 1)),
              _LocationStep(
                resolving: _resolving,
                error: _error,
                onUseGps: _useMyLocation,
                onManual: () {
                  _pendingPoint = const GeoPoint(21.4225, 39.8262);
                  setState(() => _step = 2);
                },
              ),
              _MethodStep(onDone: _finish),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomeStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.nightlight_round, size: 72),
        const SizedBox(height: 24),
        Text('Noor', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 8),
        const Text('Find your prayer, anywhere on Earth.', textAlign: TextAlign.center),
        const SizedBox(height: 32),
        FilledButton(onPressed: onNext, child: const Text('Get started')),
      ],
    );
  }
}

class _LocationStep extends StatelessWidget {
  final bool resolving;
  final String? error;
  final VoidCallback onUseGps;
  final VoidCallback onManual;

  const _LocationStep({
    required this.resolving,
    required this.error,
    required this.onUseGps,
    required this.onManual,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Where are you?', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        if (resolving) const CircularProgressIndicator(),
        if (error != null) Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(error!, style: const TextStyle(color: Colors.red)),
        ),
        if (!resolving) ...[
          FilledButton.icon(
            onPressed: onUseGps,
            icon: const Icon(Icons.my_location),
            label: const Text('Use my location'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onManual, child: const Text('Choose a city manually')),
        ],
      ],
    );
  }
}

class _MethodStep extends StatefulWidget {
  final void Function(String methodCode) onDone;
  const _MethodStep({required this.onDone});

  @override
  State<_MethodStep> createState() => _MethodStepState();
}

class _MethodStepState extends State<_MethodStep> {
  String _selected = CalculationMethod.catalog.first.code;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Calculation method', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        DropdownButton<String>(
          value: _selected,
          items: CalculationMethod.catalog
              .map((m) => DropdownMenuItem(value: m.code, child: Text(m.displayName)))
              .toList(),
          onChanged: (v) => setState(() => _selected = v ?? _selected),
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: () => widget.onDone(_selected), child: const Text('Finish')),
      ],
    );
  }
}
