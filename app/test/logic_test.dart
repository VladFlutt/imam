import 'package:flutter_test/flutter_test.dart';
import 'package:imam/data/content.dart';
import 'package:imam/data/content_cis.dart';
import 'package:imam/l10n.dart';
import 'package:imam/services/hijri.dart';
import 'package:imam/services/quran.dart';

void main() {
  test('поиск: синонимы и стоп-слова', () {
    expect(QuranRepo.tokenize('Как правильно сделать талак?'), ['развод']);
    expect(
      QuranRepo.tokenize('Что Коран говорит о терпении'),
      containsAll(['терпел', 'терпени']),
    );
  });

  test('арабский текст нормализуется без огласовок', () {
    expect(QuranRepo.normalizeArabic('ٱلرَّحۡمَٰنِ'), 'الرحمن');
  });

  test('ближайшие даты идут по порядку и не в прошлом', () {
    final from = DateTime(2026, 11, 3);
    final list = upcomingDates(from, count: 10);
    expect(list.length, 10);
    for (var i = 1; i < list.length; i++) {
      expect(list[i].date.isBefore(list[i - 1].date), isFalse);
    }
    expect(list.first.date.isBefore(from), isFalse);
  });

  test('Рамадан 1448 начинается в феврале 2027', () {
    final ramadan = upcomingDates(
      DateTime(2026, 11, 3),
      count: 12,
    ).firstWhere((u) => u.holy.month == 9 && u.holy.day == 1);
    expect(ramadan.date.year, 2027);
    expect(ramadan.date.month, 2);
  });

  test('весь редакционный контент переведён на языки СНГ', () {
    final all = <Map<String, String>>[
      for (final d in dailyItems) ...[d.tip, ?d.text],
      for (final d in duas) ...[d.title, d.when, ?d.text],
      for (final h in holyDates) ...[h.title, h.desc],
      ...duaGroups,
    ];
    for (final m in all) {
      for (final lang in const ['tt', 'uz', 'kk', 'ky', 'tg', 'az']) {
        expect(
          cisContent[m['ru']]?[lang],
          isNotNull,
          reason: '$lang: ${m['ru']}',
        );
        expect(L10n(lang).tr(m), cisContent[m['ru']]![lang]);
      }
    }
  });
}
