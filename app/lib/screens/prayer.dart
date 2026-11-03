import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/hijri.dart';
import '../services/prayer.dart';
import '../theme.dart';
import 'qibla.dart';
import 'settings.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final now = PrayerService.placeNow(s);
    final today = PrayerService.forDate(s, now);
    final next = PrayerService.next(s);
    final scheme = Theme.of(context).colorScheme;
    final methodName = methodLabel(s.method);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('prayer_times')),
        actions: [
          IconButton(
            tooltip: l.t('qibla'),
            icon: const Icon(Icons.explore_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QiblaScreen()),
            ),
          ),
          IconButton(
            tooltip: l.t('settings'),
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(
            '${s.placeName(l)} · ${HijriDate.of(now).format(l, s.num)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '${l.t('method')}: $methodName · ${l.t(s.hanafi ? 'hanafi' : 'shafii')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                for (final e in today.items)
                  Container(
                    decoration: BoxDecoration(
                      color: e.key == next.key && next.value.day == now.day
                          ? scheme.primary.withValues(alpha: 0.10)
                          : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Icon(
                        _icon(e.key),
                        color: e.key == 'sunrise'
                            ? Palette.gold
                            : scheme.primary,
                      ),
                      title: Text(
                        l.t(e.key),
                        style: TextStyle(
                          fontWeight: e.key == next.key
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        s.num(hhmm(e.value)),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l.t('week'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 14,
                horizontalMargin: 12,
                columns: [
                  const DataColumn(label: Text('')),
                  for (final k in [
                    'fajr',
                    'sunrise',
                    'dhuhr',
                    'asr',
                    'maghrib',
                    'isha',
                  ])
                    DataColumn(label: Text(l.t(k))),
                ],
                rows: [
                  for (var i = 0; i < 7; i++)
                    () {
                      final d = now.add(Duration(days: i));
                      final t = PrayerService.forDate(s, d);
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${s.num('${d.day}')}.${s.num(d.month.toString().padLeft(2, '0'))}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          for (final e in t.items)
                            DataCell(Text(s.num(hhmm(e.value)))),
                        ],
                      );
                    }(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon(String k) => switch (k) {
    'fajr' => Icons.dark_mode_outlined,
    'sunrise' => Icons.wb_twilight,
    'dhuhr' => Icons.wb_sunny_outlined,
    'asr' => Icons.sunny_snowing,
    'maghrib' => Icons.nights_stay_outlined,
    _ => Icons.bedtime_outlined,
  };
}

String methodLabel(PrayerMethod m) => switch (m) {
  PrayerMethod.russia => 'ДУМ РФ (16° / 15°)',
  PrayerMethod.muslimWorldLeague => 'Muslim World League',
  PrayerMethod.ummAlQura => 'Umm al-Qura',
  PrayerMethod.egyptian => 'Egyptian Authority',
  PrayerMethod.turkiye => 'Diyanet (Türkiye)',
  PrayerMethod.northAmerica => 'ISNA',
};
