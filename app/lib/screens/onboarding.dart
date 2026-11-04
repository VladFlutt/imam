import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/quran.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Первый запуск: сначала выбор языка, затем знакомство с приложением
/// на выбранном языке. При [replay] (из настроек) по завершении экран
/// просто закрывается.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.replay = false});
  final bool replay;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _langPicked = false;

  void _finish() {
    final s = AppScope.read(context);
    if (widget.replay) {
      Navigator.of(context).pop();
    } else {
      s.onboarded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _langPicked
          ? IntroPages(key: const ValueKey('intro'), onDone: _finish)
          : LanguagePicker(
              key: const ValueKey('lang'),
              onContinue: () => setState(() => _langPicked = true),
            ),
    );
  }
}

/// Список всех языков, каждый — своим письмом. Выбор применяется сразу,
/// поэтому заголовок и кнопка тут же переходят на выбранный язык.
class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key, required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: PatternHeader(
                child: Column(
                  children: [
                    const Icon(Icons.translate, color: Palette.gold, size: 36),
                    const SizedBox(height: 12),
                    Text(
                      l.t('onb_choose_lang'),
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.t('onb_lang_later'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  for (final code in L10n.supported)
                    _LangTile(
                      code: code,
                      selected: code == s.lang,
                      onTap: () async {
                        s.lang = code;
                        await QuranRepo.instance.ensureTranslation(s.quranTr);
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: scheme.primary,
                ),
                onPressed: onContinue,
                icon: const Icon(Icons.arrow_forward),
                label: Text(l.t('onb_continue')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  const _LangTile({
    required this.code,
    required this.selected,
    required this.onTap,
  });
  final String code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rtl = code == 'ar';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: selected
            ? scheme.primary.withValues(alpha: 0.12)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? scheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  // Название языка — его собственным письмом и направлением.
                  child: Text(
                    L10n.names[code]!,
                    textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                    // Выравниваем по направлению интерфейса, чтобы
                    // все названия стояли в одну колонку.
                    textAlign: Directionality.of(context) == TextDirection.rtl
                        ? TextAlign.right
                        : TextAlign.left,
                    style: TextStyle(
                      fontFamily: uiFont(code),
                      fontSize: rtl ? 20 : 17,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? scheme.primary : scheme.outlineVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Несколько экранов о главных разделах. Листаются свайпом; в арабском
/// интерфейсе PageView сам листает справа налево.
class IntroPages extends StatefulWidget {
  const IntroPages({super.key, required this.onDone});
  final VoidCallback onDone;

  static const pages = <IconData>[
    Icons.mosque,
    Icons.access_time_filled,
    Icons.menu_book,
    Icons.place,
    Icons.auto_awesome,
  ];

  @override
  State<IntroPages> createState() => _IntroPagesState();
}

class _IntroPagesState extends State<IntroPages> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _last => _page == IntroPages.pages.length - 1;

  void _next() {
    if (_last) {
      widget.onDone();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L10nScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: AnimatedOpacity(
                  opacity: _last ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: _last ? null : widget.onDone,
                    child: Text(l.t('onb_skip')),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: IntroPages.pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.primary.withValues(alpha: 0.1),
                          border: Border.all(color: Palette.gold, width: 2),
                        ),
                        child: Icon(
                          IntroPages.pages[i],
                          size: 64,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        l.t('onb${i + 1}_title'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l.t('onb${i + 1}_body'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: scheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < IntroPages.pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == _page ? Palette.gold : scheme.outlineVariant,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: _next,
                // Стрелка сама зеркалится в RTL.
                icon: Icon(_last ? Icons.check : Icons.arrow_forward),
                label: Text(l.t(_last ? 'onb_start' : 'onb_next')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
