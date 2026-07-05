import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'qibla_providers.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(qiblaInfoProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Qibla')),
      body: info == null
          ? const Center(child: Text('Set your location first'))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: _CompassDial(
                      bearingDegrees: info.bearingDegrees,
                      heading: info.heading,
                    ),
                  ),
                  const Spacer(),
                  Text('Bearing: ${info.bearingDegrees.toStringAsFixed(0)}°', style: theme.textTheme.bodyLarge),
                  Text(
                    'Distance: ${info.distanceKm.toStringAsFixed(0)} km',
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (info.heading != null)
                    Text('Heading: ${info.heading!.toStringAsFixed(0)}°', style: theme.textTheme.bodyLarge)
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Compass sensor unavailable — point using the bearing above.',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (info.delta != null)
                    Text(
                      info.isAligned
                          ? '✅ Aligned with Qibla'
                          : 'Turn ${info.delta!.abs().toStringAsFixed(0)}° ${info.delta! > 0 ? 'right' : 'left'}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: info.isAligned ? Colors.green : theme.colorScheme.primary,
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _CompassDial extends StatelessWidget {
  final double bearingDegrees;
  final double? heading;
  const _CompassDial({required this.bearingDegrees, this.heading});

  @override
  Widget build(BuildContext context) {
    // Needle rotation: bearing relative to device heading, so it always
    // points at the Kaaba regardless of which way the phone faces.
    final relative = bearingDegrees - (heading ?? 0);
    return CustomPaint(
      painter: _CompassPainter(
        relativeBearingDegrees: relative,
        color: Theme.of(context).colorScheme.primary,
        trackColor: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double relativeBearingDegrees;
  final Color color;
  final Color trackColor;

  _CompassPainter({
    required this.relativeBearingDegrees,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 4, trackPaint);

    // Cardinal ticks
    for (var deg = 0; deg < 360; deg += 30) {
      final rad = deg * math.pi / 180;
      final outer = center + Offset(math.sin(rad), -math.cos(rad)) * (radius - 4);
      final inner = center + Offset(math.sin(rad), -math.cos(rad)) * (radius - 14);
      canvas.drawLine(inner, outer, trackPaint);
    }

    // Needle toward Qibla
    final rad = relativeBearingDegrees * math.pi / 180;
    final tip = center + Offset(math.sin(rad), -math.cos(rad)) * (radius - 24);
    final needlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final perp = rad + math.pi / 2;
    final base1 = center + Offset(math.cos(perp), math.sin(perp)) * 8;
    final base2 = center - Offset(math.cos(perp), math.sin(perp)) * 8;

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base1.dx, base1.dy)
      ..lineTo(base2.dx, base2.dy)
      ..close();
    canvas.drawPath(path, needlePaint);
    canvas.drawCircle(center, 6, needlePaint);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.relativeBearingDegrees != relativeBearingDegrees;
}
