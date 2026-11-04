import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imam/data/content.dart';
import 'package:imam/data/content_cis.dart';
import 'package:imam/l10n.dart';
import 'package:imam/services/hadith.dart';
import 'package:imam/services/hijri.dart';
import 'package:imam/services/places.dart';
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

  test(
    '40 хадисов ан-Навави: 42 хадиса с арабским текстом и переводами',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await HadithRepo.instance.load();
      final items = HadithRepo.instance.items;
      expect(items.length, 42);
      for (final h in items) {
        expect(h.arabic, isNotEmpty);
        expect(h.ru.length, greaterThan(30));
        expect(h.en.length, greaterThan(30));
        expect(h.arabic.contains('صلى الله عليه'), isFalse);
      }
    },
  );

  test('источники хадисов переводятся', () {
    expect(
      L10n('en').source('Ибн Маджа, ад-Даракутни'),
      'Ibn Majah, ad-Daraqutni',
    );
    expect(L10n('uz').source('аль-Бухари, Муслим'), 'al-Buxoriy, Muslim');
  });

  test('каталог халяль: разбор записи и срок сертификата', () {
    final places = HalalCatalog.parse('''
{"version":1,"places":[
 {"id":"t1","kind":"halal","name":"Кафе","lat":55.7,"lng":37.6,"osm":"node/1",
  "certificate":{"issuer":"Орган","number":"№ 1","until":"2099-01-01"},"checked":"2026-11-04"},
 {"id":"t2","kind":"halal","name":"Магазин","lat":55.8,"lng":37.7,
  "certificate":{"issuer":"Орган","until":"2020-01-01"}}
]}''');
    expect(places.length, 2);
    expect(places[0].certified, isTrue);
    expect(places[0].osmId, 'node/1');
    expect(places[1].certified, isFalse);
    expect(places[1].certificate!.expired, isTrue);
  });

  test('встроенный каталог корректен', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final raw = await rootBundle.loadString('assets/halal/catalog.json');
    expect(HalalCatalog.parse(raw), isA<List<Place>>());
  });

  test('заявка на место: ссылка на форму GitHub', () {
    final u = PlaceSuggestion(
      kind: PlaceKind.halal,
      name: 'Кафе',
      lat: 55.75,
      lng: 37.61,
    ).githubIssueUrl();
    expect(u.host, 'github.com');
    expect(u.queryParameters['title'], 'Новое место: Кафе');
    expect(u.queryParameters['body'], contains('55.750000, 37.610000'));
  });
}
