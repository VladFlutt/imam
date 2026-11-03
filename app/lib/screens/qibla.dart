import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/prayer.dart';
import '../theme.dart';

/// Кибла: направление от севера. В прототипе — по координатам;
/// в мобильной версии добавится поворот по магнитному компасу телефона.
class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final bearing = PrayerService.qibla(s);
    final km = PrayerService.distanceToMakkah(s).round();
    return Scaffold(
      appBar: AppBar(title: Text(l.t('qibla'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            s.placeName(l),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          // Компас не зеркалится в RTL: стороны света одинаковы для всех языков.
          Directionality(
            textDirection: TextDirection.ltr,
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: _CompassPainter(
                  bearing,
                  Theme.of(context).colorScheme,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            s.num('${bearing.toStringAsFixed(1)}°'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            '${l.t('distance_makkah')}: ${s.num('$km')} ${l.t('km')}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l.t('qibla_hint'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter(this.bearing, this.scheme);
  final double bearing;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 8;
    canvas.drawCircle(c, r, Paint()..color = scheme.surface);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = scheme.outlineVariant
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    for (var i = 0; i < 72; i++) {
      final a = i * 5 * math.pi / 180;
      final len = i % 18 == 0 ? 16.0 : (i % 2 == 0 ? 9.0 : 5.0);
      final p1 = c + Offset(math.sin(a), -math.cos(a)) * r;
      final p2 = c + Offset(math.sin(a), -math.cos(a)) * (r - len);
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = scheme.onSurface.withValues(alpha: i % 18 == 0 ? 0.8 : 0.3)
          ..strokeWidth = i % 18 == 0 ? 2 : 1,
      );
    }
    const labels = ['N', 'E', 'S', 'W'];
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: i == 0 ? Colors.redAccent : scheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final p = c + Offset(math.sin(a), -math.cos(a)) * (r - 34);
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
    // Стрелка на Киблу.
    final a = bearing * math.pi / 180;
    final dir = Offset(math.sin(a), -math.cos(a));
    final normal = Offset(-dir.dy, dir.dx);
    final tip = c + dir * (r - 52);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((c + normal * 14).dx, (c + normal * 14).dy)
      ..lineTo((c - dir * 30).dx, (c - dir * 30).dy)
      ..lineTo((c - normal * 14).dx, (c - normal * 14).dy)
      ..close();
    canvas.drawPath(path, Paint()..color = Palette.gold);
    canvas.drawCircle(c, 6, Paint()..color = scheme.primary);
    // Кааба на конце стрелки.
    final k = c + dir * (r - 52);
    canvas.drawRect(
      Rect.fromCenter(center: k, width: 18, height: 18),
      Paint()..color = const Color(0xFF111111),
    );
    canvas.drawRect(
      Rect.fromCenter(center: k - const Offset(0, 4), width: 18, height: 3),
      Paint()..color = Palette.gold,
    );
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.bearing != bearing;
}
