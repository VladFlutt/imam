import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/hijri.dart';
import '../services/prayer.dart';
import '../theme.dart';
import '../widgets/common.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final now = PrayerService.placeNow(s);
    final scheme = Theme.of(context).colorScheme;
    final list = upcomingDates(now, count: 12);
    return Scaffold(
      appBar: AppBar(title: Text(l.t('calendar'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          PatternHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.t('today'),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
                ),
                Text(
                  HijriDate.of(now).format(l, s.num),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  gregorianDate(now, l, s.num),
                  style: const TextStyle(color: Palette.gold),
                ),
              ],
            ),
          ),
          SectionTitle(l.t('upcoming')),
          for (final u in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            u.holy.major ? Icons.star : Icons.nightlight_round,
                            color: u.holy.major ? Palette.gold : scheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l.tr(u.holy.title),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            () {
                              final d =
                                  DateTime(
                                        u.date.year,
                                        u.date.month,
                                        u.date.day,
                                      )
                                      .difference(
                                        DateTime(now.year, now.month, now.day),
                                      )
                                      .inDays;
                              return d == 0
                                  ? l.t('today')
                                  : '${s.num('$d')} ${l.t('days_left')}';
                            }(),
                            style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${gregorianDate(u.date, l, s.num)} · ${HijriDate.of(u.date).format(l, s.num)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.tr(u.holy.desc),
                        style: const TextStyle(height: 1.45),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Text(
            l.t('calendar_note'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
