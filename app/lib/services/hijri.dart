import 'package:hijri/hijri_calendar.dart';

import '../data/content.dart';
import '../l10n.dart';

class HijriDate {
  HijriDate(this.year, this.month, this.day);
  final int year, month, day;

  factory HijriDate.of(DateTime d) {
    final h = HijriCalendar.fromDate(DateTime(d.year, d.month, d.day));
    return HijriDate(h.hYear, h.hMonth, h.hDay);
  }

  String format(L10n l, String Function(String) num) =>
      '${num('$day')} ${l.list('hijri_months')[month - 1]} ${num('$year')} ${l.t('ah')}';
}

class UpcomingDate {
  UpcomingDate(this.holy, this.date);
  final HolyDate holy;
  final DateTime date;
}

DateTime _toGregorian(int y, int m, int d) =>
    HijriCalendar().hijriToGregorian(y, m, d);

/// Памятные даты на ближайшие ~13 месяцев, по порядку.
List<UpcomingDate> upcomingDates(DateTime from, {int count = 12}) {
  final today = DateTime(from.year, from.month, from.day);
  final h = HijriDate.of(today);
  final out = <UpcomingDate>[];
  for (final year in [h.year, h.year + 1]) {
    for (final hd in holyDates) {
      final g = _toGregorian(year, hd.month, hd.day);
      if (!g.isBefore(today)) out.add(UpcomingDate(hd, g));
    }
  }
  out.sort((a, b) => a.date.compareTo(b.date));
  return out.take(count).toList();
}

String gregorianDate(DateTime d, L10n l, String Function(String) num) =>
    '${num('${d.day}')} ${l.list('greg_months')[d.month - 1]} ${num('${d.year}')}';
