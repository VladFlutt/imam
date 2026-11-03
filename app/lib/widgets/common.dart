import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/quran.dart';
import '../theme.dart';

/// Сдержанный геометрический орнамент: сетка восьмиконечных звёзд.
class StarPatternPainter extends CustomPainter {
  StarPatternPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const step = 44.0;
    for (var y = -step / 2; y < size.height + step; y += step) {
      for (var x = -step / 2; x < size.width + step; x += step) {
        _star(canvas, Offset(x, y), 14, paint);
      }
    }
  }

  void _star(Canvas c, Offset o, double r, Paint p) {
    for (final rot in [0.0, math.pi / 4]) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final a = rot + i * math.pi / 2;
        final pt = o + Offset(math.cos(a), math.sin(a)) * r;
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      c.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(StarPatternPainter old) => old.color != color;
}

/// Шапка в изумрудных тонах с орнаментом.
class PatternHeader extends StatelessWidget {
  const PatternHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: dark
                ? const [Color(0xFF0E3B33), Palette.dusk]
                : const [Palette.emerald, Palette.pine],
          ),
        ),
        child: CustomPaint(
          painter: StarPatternPainter(Palette.gold.withValues(alpha: 0.13)),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 10),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: Palette.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

/// Аят: арабский текст справа налево + перевод + ссылка.
class AyahBlock extends StatelessWidget {
  const AyahBlock({super.key, required this.ayah, this.compact = false});
  final Ayah ayah;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final repo = QuranRepo.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            ayah.arabic,
            style: quranStyle(context, size: compact ? 22 : 26),
            textAlign: TextAlign.start,
          ),
        ),
        if (s.quranTr != 'ar') ...[
          const SizedBox(height: 8),
          Text(
            repo.translation(ayah.surah.id, ayah.number, s.quranTr),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ],
        const SizedBox(height: 6),
        Text(
          '${ayah.surah.title(l.lang)} · ${s.num(ayah.ref)}',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

String durationText(Duration d, L10n l, String Function(String) num) {
  final h = d.inHours, m = d.inMinutes % 60;
  final t = h > 0
      ? '${num('$h')} ${l.t('h')} ${num('$m')} ${l.t('min')}'
      : '${num('${math.max(m, 1)}')} ${l.t('min')}';
  return l.inTime(t);
}
