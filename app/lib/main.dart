import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_state.dart';
import 'l10n.dart';
import 'screens/home.dart';
import 'screens/map.dart';
import 'screens/more.dart';
import 'screens/prayer.dart';
import 'screens/quran.dart';
import 'services/quran.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = await AppState.load();
  // Коран грузим в фоне: главный экран показывается сразу.
  QuranRepo.instance.load().then(
    (_) => QuranRepo.instance.ensureTranslation(state.quranTr),
  );
  runApp(AppScope(state: state, child: const ImamApp()));
}

class ImamApp extends StatelessWidget {
  const ImamApp({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = s.l10n;
    return L10nScope(
      l10n: l,
      child: MaterialApp(
        title: l.t('app_name'),
        debugShowCheckedModeBanner: false,
        locale: Locale(l.materialLang),
        supportedLocales: const [
          Locale('ru'),
          Locale('en'),
          Locale('ar'),
          Locale('uz'),
          Locale('kk'),
          Locale('ky'),
          Locale('az'),
        ],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: buildTheme(
          dark: s.dark,
          lang: l.lang,
          scale: s.largeText ? 1.3 : 1.0,
        ),
        // Направление текста задаём сами: для арабского — справа налево.
        builder: (context, child) => Directionality(
          textDirection: l.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(s.largeText ? 1.3 : 1.0)),
            child: child!,
          ),
        ),
        home: const Shell(),
      ),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final tabs = <(IconData, IconData, String, Widget)>[
      (
        Icons.home_outlined,
        Icons.home,
        'tab_home',
        HomeScreen(onOpenTab: (i) => setState(() => _index = i)),
      ),
      (
        Icons.access_time,
        Icons.access_time_filled,
        'tab_prayer',
        const PrayerScreen(),
      ),
      (
        Icons.menu_book_outlined,
        Icons.menu_book,
        'tab_quran',
        const QuranScreen(),
      ),
      if (!s.kidsMode)
        (Icons.mosque_outlined, Icons.mosque, 'tab_map', const MapScreen()),
      (
        Icons.grid_view_outlined,
        Icons.grid_view_rounded,
        'tab_more',
        const MoreScreen(),
      ),
    ];
    final index = _index.clamp(0, tabs.length - 1);
    return Scaffold(
      body: IndexedStack(index: index, children: [for (final t in tabs) t.$4]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final t in tabs)
            NavigationDestination(
              icon: Icon(t.$1),
              selectedIcon: Icon(t.$2),
              label: l.t(t.$3),
            ),
        ],
      ),
    );
  }
}
