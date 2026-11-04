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

  /// Перевод для языка интерфейса: английский для en, без перевода для ar,
  /// русский для остальных (переводы на языки СНГ пока не готовы).
  String? translation(String lang) => switch (lang) {
    'ar' => null,
    'en' => en,
    _ => ru,
  };

  String titleFor(String lang) => lang == 'en' ? title['en']! : title['ru']!;
}

/// «Сорок хадисов» имама ан-Навави (42 хадиса).
/// Арабский текст: пакет @kazishariar/nawawi-40-hadith-data (CC BY 4.0).
/// Переводы на русский и английский подготовлены редакцией приложения
/// и до релиза проходят проверку имамом.
class HadithRepo {
  HadithRepo._();
  static final instance = HadithRepo._();
  List<Hadith>? _items;

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
  }
}
