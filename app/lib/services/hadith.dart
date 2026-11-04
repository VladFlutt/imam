import 'dart:convert';

import 'package:flutter/services.dart';

class Hadith {
  Hadith(
    this.n,
    this.title,
    this.arabic,
    this.ru,
    this.en,
    this.source,
    this.note,
  );
  final int n;
  final Map<String, String> title; // ru, en
  final String arabic;
  final String ru;
  final String en;
  final String source; // по-русски, переводится через L10n.source
  final Map<String, String>? note;

  /// Переводы на языки СНГ: язык → (заголовок, текст, пояснение).
  final Map<String, ({String title, String text, String? note})> local = {};

  /// Есть ли собственный перевод на этот язык (иначе показываем русский).
  bool hasOwn(String lang) =>
      lang == 'ru' || lang == 'en' || local.containsKey(lang);

  /// Перевод для языка интерфейса: без перевода для ar, свой перевод, если
  /// он есть, иначе русский.
  String? translation(String lang) => switch (lang) {
    'ar' => null,
    'en' => en,
    _ => local[lang]?.text ?? ru,
  };

  String titleFor(String lang) => switch (lang) {
    'en' => title['en']!,
    _ => local[lang]?.title ?? title['ru']!,
  };

  String? noteFor(String lang) {
    if (note == null || lang == 'ar') return null;
    if (lang == 'en') return note!['en'];
    return local[lang]?.note ?? note!['ru'];
  }
}

/// «Сорок хадисов» имама ан-Навави (42 хадиса).
/// Арабский текст: пакет @kazishariar/nawawi-40-hadith-data (CC BY 4.0).
/// Переводы на русский, английский и языки СНГ (nawawi_<язык>.json)
/// подготовлены редакцией приложения и до релиза проходят проверку имамом.
class HadithRepo {
  HadithRepo._();
  static final instance = HadithRepo._();
  List<Hadith>? _items;

  static const translations = ['uz', 'kk', 'tt', 'ky', 'tg', 'az'];

  bool get loaded => _items != null;
  List<Hadith> get items => _items ?? const [];

  Future<void> load() async {
    if (_items != null) return;
    final raw =
        jsonDecode(await rootBundle.loadString('assets/hadith/nawawi.json'))
            as List;
    _items = [
      for (final h in raw)
        Hadith(
          h['n'] as int,
          (h['title'] as Map).cast<String, String>(),
          h['ar'] as String,
          h['ru'] as String,
          h['en'] as String,
          h['src'] as String,
          (h['note'] as Map?)?.cast<String, String>(),
        ),
    ];
    for (final lang in translations) {
      final list =
          jsonDecode(
                await rootBundle.loadString('assets/hadith/nawawi_$lang.json'),
              )
              as List;
      for (final h in list) {
        final i = (h['n'] as int) - 1;
        if (i < 0 || i >= _items!.length) continue;
        _items![i].local[lang] = (
          title: h['title'] as String,
          text: h['text'] as String,
          note: h['note'] as String?,
        );
      }
    }
  }
}
