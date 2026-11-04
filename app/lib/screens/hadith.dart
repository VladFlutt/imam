import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/hadith.dart';
import '../theme.dart';

class HadithListScreen extends StatefulWidget {
  const HadithListScreen({super.key});

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  @override
  void initState() {
    super.initState();
    HadithRepo.instance.load().then((_) => mounted ? setState(() {}) : null);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final repo = HadithRepo.instance;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.t('hadith40'))),
      body: !repo.loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: repo.items.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Text(
                    l.t('hadith_review'),
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                final h = repo.items[i - 1];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scheme.primary.withValues(alpha: 0.12),
                      child: Text(
                        s.num('${h.n}'),
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(
                      l.lang == 'ar'
                          ? l.t('hadith_n').replaceAll('{n}', s.num('${h.n}'))
                          : h.titleFor(l.lang),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(l.source(h.source)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HadithScreen(hadith: h),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key, required this.hadith});
  final Hadith hadith;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final h = hadith;
    final scheme = Theme.of(context).colorScheme;
    final tr = h.translation(l.lang);
    final note = h.noteFor(l.lang);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('hadith_n').replaceAll('{n}', s.num('${h.n}'))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (l.lang != 'ar')
            Text(
              h.titleFor(l.lang),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.primary,
              ),
            ),
          const SizedBox(height: 16),
          Directionality(
            textDirection: TextDirection.rtl,
            child: SelectableText(
              h.arabic,
              style: arabicStyle(context, size: 22).copyWith(height: 1.9),
            ),
          ),
          if (tr != null) ...[
            const Divider(height: 32),
            SelectableText(
              tr,
              style: const TextStyle(fontSize: 16, height: 1.55),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            l.source(h.source),
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: scheme.primary),
          ),
          if (note != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Palette.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Palette.gold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(note, style: const TextStyle(height: 1.45)),
                  ),
                ],
              ),
            ),
          ],
          if (tr != null && !h.hasOwn(l.lang)) ...[
            const SizedBox(height: 16),
            Text(
              l.t('hadith_ru_only'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
