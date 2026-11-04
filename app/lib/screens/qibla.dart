import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/compass/web_compass.dart';
import '../services/prayer.dart';
import '../theme.dart';

/// Кибла: направление от севера по координатам. На телефоне циферблат
/// поворачивается по компасу (датчик ориентации), и стрелка показывает
/// Киблу относительно того, куда смотрит верх телефона.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  static bool get _sensorPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  StreamSubscription<Object>? _sub;
  bool _webWaiting = false; // веб: ждём разрешения (iOS) или первых данных
  bool _webNoSensor = false;
  double? _heading; // куда смотрит верх телефона, градусы от севера
  double? _accuracy;
  bool _wasAligned = false;

  @override
  void initState() {
    super.initState();
    if (_sensorPlatform) {
      _sub = FlutterCompass.events?.listen((e) {
        if (e.heading != null) _onHeading(e.heading!, e.accuracy);
      });
    } else if (kIsWeb && WebCompass.supported) {
      // Слушаем сразу: в Chrome на Android данные идут без запроса. Если
      // браузер требует разрешения (Safari на iPhone), покажем кнопку.
      _startWeb(quiet: WebCompass.needsPermission);
    }
  }

  /// Веб: подписка на датчик ориентации. Если за 3 с данных нет —
  /// это компьютер или браузер без компаса.
  void _startWeb({bool quiet = false}) {
    _sub?.cancel();
    _webWaiting = !quiet;
    _webNoSensor = false;
    if (mounted) setState(() {});
    _sub = WebCompass.headings().listen((h) {
      _webWaiting = false;
      _onHeading(h, null);
    });
    if (quiet) return; // ждём нажатия кнопки
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _heading == null) {
        setState(() {
          _webWaiting = false;
          _webNoSensor = true;
        });
      }
    });
  }

  Future<void> _enableWeb() async {
    // Даже при отказе слушаем: часть браузеров отдаёт данные и так.
    await WebCompass.requestPermission();
    if (mounted) _startWeb();
  }

  void _onHeading(double heading, double? accuracy) {
    if (!mounted) return;
    // Держим угол непрерывным, чтобы при переходе 359° → 0° циферблат
    // не делал полный оборот.
    final prev = _heading;
    final raw = (heading + 360) % 360;
    final next = prev == null ? raw : prev + _delta(raw, prev % 360);
    final aligned =
        _delta(PrayerService.qibla(AppScope.read(context)), next % 360).abs() <
        5;
    if (aligned && !_wasAligned) HapticFeedback.mediumImpact();
    _wasAligned = aligned;
    setState(() {
      _heading = next;
      _accuracy = accuracy;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Угол от верха телефона до Киблы, -180..180.
  static double _delta(double bearing, double heading) =>
      ((bearing - heading + 540) % 360) - 180;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final bearing = PrayerService.qibla(s);
    final km = PrayerService.distanceToMakkah(s).round();
    final heading = _heading;
    final aligned = heading != null && _delta(bearing, heading % 360).abs() < 5;
    final scheme = Theme.of(context).colorScheme;
    // На iOS accuracy — погрешность в градусах; на Android — уровень 0..3.
    final poor =
        _accuracy != null &&
        (defaultTargetPlatform == TargetPlatform.iOS
            ? _accuracy! > 25 || _accuracy! < 0
            : _accuracy! < 2);
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
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: heading ?? 0),
                duration: const Duration(milliseconds: 250),
                builder: (context, h, _) => CustomPaint(
                  painter: _CompassPainter(
                    bearing,
                    scheme,
                    heading: heading == null ? 0 : h,
                    aligned: aligned,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (aligned)
            Text(
              l.t('qibla_aligned'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
              ),
            )
          else
            Text(
              s.num('${bearing.toStringAsFixed(1)}°'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.primary,
              ),
            ),
          Text(
            '${l.t('distance_makkah')}: ${s.num('$km')} ${l.t('km')}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l.t(heading == null ? 'qibla_hint' : 'qibla_live'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (kIsWeb && heading == null) ...[
            const SizedBox(height: 12),
            if (_webNoSensor)
              Text(
                l.t('compass_unavailable'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              )
            else if (WebCompass.needsPermission && !_webWaiting)
              Center(
                child: FilledButton.icon(
                  onPressed: _enableWeb,
                  icon: const Icon(Icons.explore_outlined),
                  label: Text(l.t('compass_enable')),
                ),
              ),
          ],
          if (heading != null && poor) ...[
            const SizedBox(height: 8),
            Text(
              l.t('qibla_calibrate'),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter(
    this.bearing,
    this.scheme, {
    this.heading = 0,
    this.aligned = false,
  });
  final double bearing;
  final ColorScheme scheme;
  final double heading;
  final bool aligned;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 8;
    // Метка «верх телефона» — не вращается.
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, 0)
        ..lineTo(c.dx - 8, -1 + 12)
        ..lineTo(c.dx + 8, -1 + 12)
        ..close(),
      Paint()..color = aligned ? scheme.primary : scheme.outline,
    );
    // Весь циферблат поворачиваем так, чтобы «N» смотрела на настоящий север.
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-heading * math.pi / 180);
    canvas.translate(-c.dx, -c.dy);
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
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CompassPainter old) =>
      old.bearing != bearing ||
      old.heading != heading ||
      old.aligned != aligned;
}
