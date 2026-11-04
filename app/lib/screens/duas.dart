import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../data/content.dart';
import '../l10n.dart';
import '../services/quran.dart';
import '../theme.dart';
import '../widgets/common.dart';

class DuasScreen extends StatefulWidget {
  const DuasScreen({super.key});

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
  @override
  void initState() {
    super.initState();
    QuranRepo.instance.load().then((_) => mounted ? setState(() {}) : null);
  }

  @override
  Widget build(BuildContext context) {
    final l = L10nScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final repo = QuranRepo.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('duas')),
        actions: [
          IconButton(
            tooltip: l.t('tasbih'),
            icon: const Icon(Icons.radio_button_checked),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TasbihScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          for (final g in duaGroups) ...[
            SectionTitle(l.tr(g)),
            for (final d in duas.where((d) => identical(d.when, g)))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: d.ref != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l.tr(d.title),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (repo.loaded && repo.byRef(d.ref!) != null)
                                AyahBlock(
                                  ayah: repo.byRef(d.ref!)!,
                                  compact: true,
                                )
                              else
                                const LinearProgressIndicator(),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      l.tr(d.title),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (d.count > 1)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Palette.gold.withValues(
                                          alpha: 0.18,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '×${d.count}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: Text(
                                  d.arabic!,
                                  style: arabicStyle(context, size: 22),
                                ),
                              ),
                              if (l.translit(d.translit!) case final tl?) ...[
                                const SizedBox(height: 4),
                                Text(
                                  tl,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Text(
                                l.tr(d.text!),
                                style: const TextStyle(height: 1.45),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l.source(d.source!),
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: scheme.primary),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final n = s.tasbih;
    const phrases = [
      'سُبْحَانَ اللَّهِ',
      'الْحَمْدُ لِلَّهِ',
      'اللَّهُ أَكْبَرُ',
    ];
    final phrase = phrases[((n > 0 ? n - 1 : 0) ~/ 33) % 3];
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('tasbih')),
        actions: [
          TextButton(onPressed: () => s.tasbih = 0, child: Text(l.t('reset'))),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          s.tasbih = n + 1;
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(phrase, style: arabicStyle(context, size: 34)),
              ),
              const SizedBox(height: 24),
              Container(
                width: 220,
                height: 220,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary.withValues(alpha: 0.08),
                  border: Border.all(color: Palette.gold, width: 3),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.num('${n % 33 == 0 && n > 0 ? 33 : n % 33}'),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                    Text('/ ${s.num('33')} · Σ ${s.num('$n')}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
