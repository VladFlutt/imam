import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/quran.dart';
import '../theme.dart';
import '../widgets/common.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final _repo = QuranRepo.instance;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _repo.load().then((_) => mounted ? setState(() {}) : null);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('tab_quran')),
        actions: [
          IconButton(
            tooltip: l.t('bookmarks'),
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookmarksScreen()),
            ),
          ),
          const TranslationButton(),
        ],
      ),
      body: !_repo.loaded
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: l.t('search_quran'),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: scheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: scheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: scheme.outlineVariant),
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (q) async {
                      await _repo.ensureTranslation(s.quranTr);
                      setState(() => _query = q.trim());
                    },
                    onChanged: (q) {
                      if (q.isEmpty) setState(() => _query = '');
                    },
                  ),
                ),
                Expanded(
                  child: _query.isEmpty
                      ? _surahList(context, s, l)
                      : _results(context, s, l),
                ),
              ],
            ),
    );
  }

  Widget _surahList(BuildContext context, AppState s, L10n l) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _repo.surahs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final su = _repo.surahs[i];
        return Card(
          child: ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SurahScreen(surah: su)),
            ),
            leading: _Medallion(number: s.num('${su.id}')),
            title: Text(
              l.lang == 'ar' ? su.ar : su.tr,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${l.lang == 'ar' ? '' : '${l.lang == 'en' ? su.en : su.ru} · '}'
              '${l.t(su.meccan ? 'meccan' : 'medinan')} · ${s.num('${su.verses.length}')} ${l.t('ayahs')}',
            ),
            trailing: Text(
              su.ar,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 20,
                color: scheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _results(BuildContext context, AppState s, L10n l) {
    final found = _repo.search(_query, s.quranTr);
    if (found.isEmpty) return Center(child: Text(l.t('nothing_found')));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: found.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => openAyah(context, found[i]),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AyahBlock(ayah: found[i], compact: true),
          ),
        ),
      ),
    );
  }
}

class _Medallion extends StatelessWidget {
  const _Medallion({required this.number});
  final String number;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 40,
    height: 40,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: 0.785,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(color: Palette.gold, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border.all(color: Palette.gold, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text(
          number,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

/// Выбор перевода Корана.
class TranslationButton extends StatelessWidget {
  const TranslationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    return PopupMenuButton<String>(
      tooltip: l.t('translation'),
      icon: const Icon(Icons.translate),
      initialValue: s.quranTr,
      onSelected: (code) async {
        await QuranRepo.instance.ensureTranslation(code);
        s.quranTr = code;
      },
      itemBuilder: (_) => [
        for (final e in QuranRepo.translators.entries)
          PopupMenuItem(
            value: e.key,
            child: Text('${L10n.names[e.key]} — ${e.value}'),
          ),
      ],
    );
  }
}

void openAyah(BuildContext context, Ayah a) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final s = AppScope.of(context);
      final l = L10nScope.of(context);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AyahBlock(ayah: a),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      s.isBookmarked(a.surah.id, a.number)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                    ),
                    onPressed: () {
                      s.toggleBookmark(a.surah.id, a.number);
                      Navigator.pop(ctx);
                    },
                  ),
                  const Spacer(),
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SurahScreen(surah: a.surah, highlight: a.number),
                        ),
                      );
                    },
                    child: Text(a.surah.title(l.lang)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class SurahScreen extends StatefulWidget {
  const SurahScreen({super.key, required this.surah, this.highlight});
  final Surah surah;
  final int? highlight;

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  late final ScrollController _ctrl;

  @override
  void initState() {
    super.initState();
    // Примерный переход к нужному аяту (длина аятов разная, поэтому оценка).
    _ctrl = ScrollController(
      initialScrollOffset: widget.highlight == null
          ? 0
          : (widget.highlight! - 1) * 220.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final su = widget.surah;
    final repo = QuranRepo.instance;
    final scheme = Theme.of(context).colorScheme;
    final showBasmala = su.id != 1 && su.id != 9;
    return Scaffold(
      appBar: AppBar(
        title: Text(su.title(l.lang)),
        actions: const [TranslationButton()],
      ),
      body: ListView.builder(
        controller: _ctrl,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        itemCount: su.verses.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PatternHeader(
                child: Column(
                  children: [
                    Text(
                      su.ar,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 34,
                        color: Palette.gold,
                      ),
                    ),
                    Text(
                      '${su.tr} · ${l.t(su.meccan ? 'meccan' : 'medinan')} · ${s.num('${su.verses.length}')} ${l.t('ayahs')}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    if (showBasmala) ...[
                      const SizedBox(height: 12),
                      const Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                          style: TextStyle(
                            fontFamily: 'AmiriQuran',
                            fontSize: 24,
                            color: Colors.white,
                            height: 2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
          final n = i;
          final marked = s.isBookmarked(su.id, n);
          final hl = widget.highlight == n;
          return InkWell(
            onTap: () => s.toggleBookmark(su.id, n),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: hl
                    ? Palette.gold.withValues(alpha: 0.12)
                    : scheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hl ? Palette.gold : scheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        s.num('${su.id}:$n'),
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        marked ? Icons.bookmark : Icons.bookmark_border,
                        size: 20,
                        color: marked ? Palette.gold : scheme.outlineVariant,
                      ),
                    ],
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      '${su.verses[n - 1][0]} ﴿${L10n.digits('$n', arabic: true)}﴾',
                      style: quranStyle(context),
                    ),
                  ),
                  if (s.quranTr != 'ar') ...[
                    const SizedBox(height: 6),
                    Text(
                      repo.translation(su.id, n, s.quranTr),
                      style: const TextStyle(height: 1.5),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final repo = QuranRepo.instance;
    final list = s.bookmarks.map(repo.byRef).whereType<Ayah>().toList()
      ..sort(
        (a, b) => a.surah.id != b.surah.id
            ? a.surah.id - b.surah.id
            : a.number - b.number,
      );
    return Scaffold(
      appBar: AppBar(title: Text(l.t('bookmarks'))),
      body: list.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(l.t('no_bookmarks'), textAlign: TextAlign.center),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => Card(
                child: InkWell(
                  onTap: () => openAyah(context, list[i]),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AyahBlock(ayah: list[i], compact: true),
                  ),
                ),
              ),
            ),
    );
  }
}
