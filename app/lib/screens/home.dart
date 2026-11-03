import 'dart:async';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/content.dart';
import '../l10n.dart';
import '../services/hijri.dart';
import '../services/prayer.dart';
import '../services/quran.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'assistant.dart';
import 'calendar.dart';
import 'duas.dart';
import 'qibla.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenTab});
  final ValueChanged<int> onOpenTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() {}),
    );
    QuranRepo.instance.load().then((_) => mounted ? setState(() {}) : null);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final now = PrayerService.placeNow(s);
    final today = PrayerService.forDate(s, now);
    final next = PrayerService.next(s);
    final hijri = HijriDate.of(now);
    final weekday = l.list('weekdays')[now.weekday - 1];
    final onDark = Colors.white;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          PatternHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.place_outlined, color: Palette.gold, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        s.placeName(l),
                        style: TextStyle(color: onDark.withValues(alpha: 0.9)),
                      ),
                    ),
                    Text(
                      l.t('app_name'),
                      style: const TextStyle(
                        color: Palette.gold,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  hijri.format(l, s.num),
                  style: TextStyle(
                    color: onDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$weekday, ${gregorianDate(now, l, s.num)}',
                  style: TextStyle(color: onDark.withValues(alpha: 0.75)),
                ),
                const SizedBox(height: 18),
                Text(
                  l.t('next_prayer'),
                  style: TextStyle(color: onDark.withValues(alpha: 0.75)),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l.t(next.key),
                      style: TextStyle(
                        color: onDark,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        s.num(hhmm(next.value)),
                        style: const TextStyle(
                          color: Palette.gold,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Palette.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        durationText(
                          PrayerService.until(s, next.value),
                          l,
                          s.num,
                        ),
                        style: TextStyle(color: onDark, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (final e in today.items)
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              l.t(e.key),
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(
                                color:
                                    e.key == next.key &&
                                        next.value.day == now.day
                                    ? Palette.gold
                                    : onDark.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.num(hhmm(e.value)),
                              style: TextStyle(
                                color:
                                    e.key == next.key &&
                                        next.value.day == now.day
                                    ? Palette.gold
                                    : onDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _QuickRow(onOpenTab: widget.onOpenTab),
          _DailyCard(date: now),
          SectionTitle(
            l.t('upcoming'),
            trailing: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              ),
              child: Text(l.t('calendar')),
            ),
          ),
          for (final u in upcomingDates(now, count: 3))
            _UpcomingTile(u: u, now: now),
          if (l.t('content_note').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                l.t('content_note'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickRow extends StatelessWidget {
  const _QuickRow({required this.onOpenTab});
  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final items = <(IconData, String, VoidCallback)>[
      (
        Icons.explore_outlined,
        'qibla',
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QiblaScreen()),
        ),
      ),
      (Icons.menu_book_outlined, 'tab_quran', () => onOpenTab(2)),
      (
        Icons.volunteer_activism_outlined,
        'duas',
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DuasScreen()),
        ),
      ),
      if (!s.kidsMode)
        (
          Icons.chat_bubble_outline,
          'assistant',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AssistantScreen()),
          ),
        ),
    ];
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (final (icon, key, onTap) in items)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap,
                child: Ink(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Icon(icon, color: scheme.primary),
                      const SizedBox(height: 6),
                      Text(
                        l.t(key),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final l = L10nScope.of(context);
    final item = dailyItemFor(date);
    final repo = QuranRepo.instance;
    final ayah = item.isAyah && repo.loaded ? repo.byRef(item.ref!) : null;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(l.t(item.isAyah ? 'ayah_of_day' : 'hadith_of_day')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (item.isAyah)
                  ayah == null
                      ? const LinearProgressIndicator()
                      : AyahBlock(ayah: ayah)
                else ...[
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      item.arabic!,
                      style: arabicStyle(context, size: 22),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '«${l.tr(item.text!)}»',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.source!,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: scheme.primary),
                  ),
                ],
                const Divider(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Palette.gold,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.t('tip_of_day'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.tr(item.tip),
                            style: const TextStyle(height: 1.45),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UpcomingTile extends StatelessWidget {
  const _UpcomingTile({required this.u, required this.now});
  final UpcomingDate u;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final days = DateTime(
      u.date.year,
      u.date.month,
      u.date.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: (u.holy.major ? Palette.gold : scheme.primary)
                .withValues(alpha: 0.15),
            child: Icon(
              u.holy.major ? Icons.star : Icons.nightlight_round,
              color: u.holy.major ? Palette.gold : scheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            l.tr(u.holy.title),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(gregorianDate(u.date, l, s.num)),
          trailing: Text(
            days == 0 ? l.t('today') : '${s.num('$days')} ${l.t('days_left')}',
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
