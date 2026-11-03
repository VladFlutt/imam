import 'dart:convert';

import 'package:flutter/services.dart';

class Surah {
  Surah(this.id, this.ar, this.tr, this.ru, this.en, this.meccan, this.verses);
  final int id;
  final String ar; // арабское название
  final String tr; // транслитерация
  final String ru;
  final String en;
  final bool meccan;

  /// [арабский, русский (Кулиев), английский (Saheeh International)]
  final List<List<String>> verses;

  String title(String lang) => switch (lang) {
    'ar' => ar,
    'en' => '$tr · $en',
    'ru' => '$tr · $ru',
    _ => tr,
  };
}

class Ayah {
  Ayah(this.surah, this.number);
  final Surah surah;
  final int number;
  String get ref => '${surah.id}:$number';
  String get arabic => surah.verses[number - 1][0];
}

/// Коран целиком хранится в приложении и работает без интернета.
/// Источник: Tanzil (арабский текст Uthmani, переводы Э. Кулиева и Saheeh International)
/// через пакет quran-json (CC BY-SA 4.0); татарский, узбекский, таджикский
/// и азербайджанский переводы — Tanzil через пакет @ghoran/translation.
class QuranRepo {
  QuranRepo._();
  static final instance = QuranRepo._();

  List<Surah>? _surahs;
  final _extra = <String, List<String>>{};
  static const extraTranslations = {'tt', 'uz', 'tg', 'az'};
  static const translators = {
    'ar': 'نص عربي فقط · только арабский текст',
    'ru': 'Э. Кулиев',
    'en': 'Saheeh International',
    'tt': 'Якуб ибн Нугман',
    'uz': 'Муҳаммад Содиқ Муҳаммад Юсуф',
    'tg': 'Абдулмуҳаммад Оятӣ',
    'az': 'Məmmədəliyev, Bünyadov',
  };

  /// Смещение аята в сквозной нумерации 1..6236.
  final _offsets = <int>[];

  bool get loaded => _surahs != null;
  List<Surah> get surahs => _surahs ?? const [];

  Future<void> load() async {
    if (_surahs != null) return;
    final raw = await rootBundle.loadString('assets/quran/quran.json');
    final list = jsonDecode(raw) as List;
    _surahs = [
      for (final s in list)
        Surah(
          s['id'] as int,
          s['ar'] as String,
          s['tr'] as String,
          s['ru'] as String,
          s['en'] as String,
          s['type'] == 'meccan',
          [for (final v in s['v'] as List) (v as List).cast<String>()],
        ),
    ];
    var acc = 0;
    for (final s in _surahs!) {
      _offsets.add(acc);
      acc += s.verses.length;
    }
  }

  Future<void> ensureTranslation(String code) async {
    if (!extraTranslations.contains(code) || _extra.containsKey(code)) return;
    final raw = await rootBundle.loadString('assets/quran/tr_$code.json');
    _extra[code] = (jsonDecode(raw) as List).cast<String>();
  }

  /// Текст перевода аята. Если перевод ещё не загружен — русский.
  String translation(int surah, int ayah, String code) {
    final s = _surahs![surah - 1];
    if (code == 'ar') return '';
    if (code == 'en') return s.verses[ayah - 1][2];
    final extra = _extra[code];
    if (extra != null) return extra[_offsets[surah - 1] + ayah - 1];
    return s.verses[ayah - 1][1];
  }

  Ayah? byRef(String ref) {
    final parts = ref.split(':');
    if (parts.length != 2 || _surahs == null) return null;
    final s = int.tryParse(parts[0]), a = int.tryParse(parts[1]);
    if (s == null || a == null || s < 1 || s > 114) return null;
    final surah = _surahs![s - 1];
    if (a < 1 || a > surah.verses.length) return null;
    return Ayah(surah, a);
  }

  /// Поиск по переводу (и по арабскому тексту без огласовок).
  /// Возвращает до [limit] аятов, отсортированных по числу совпавших слов.
  List<Ayah> search(String query, String code, {int limit = 30}) {
    if (_surahs == null) return const [];
    final words = tokenize(query);
    if (words.isEmpty) return const [];
    final scored = <MapEntry<Ayah, int>>[];
    for (final s in _surahs!) {
      for (var i = 0; i < s.verses.length; i++) {
        final hay =
            '${normalize(translation(s.id, i + 1, code))} ${normalizeArabic(s.verses[i][0])}';
        var score = 0;
        for (final w in words) {
          if (hay.contains(w)) score += w.length >= 5 ? 2 : 1;
        }
        if (score > 0) scored.add(MapEntry(Ayah(s, i + 1), score));
      }
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(limit).map((e) => e.key).toList();
  }

  static String normalize(String s) => s.toLowerCase().replaceAll('ё', 'е');

  static String normalizeArabic(String s) => s
      .replaceAll(RegExp('[ً-ٰٟۖ-ۭـ]'), '')
      .replaceAll(RegExp('[إأآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه');

  static const _stop = {
    'и',
    'в',
    'во',
    'на',
    'с',
    'со',
    'по',
    'о',
    'об',
    'а',
    'но',
    'ли',
    'же',
    'что',
    'как',
    'это',
    'мне',
    'я',
    'ты',
    'он',
    'она',
    'мы',
    'вы',
    'они',
    'для',
    'из',
    'к',
    'от',
    'до',
    'не',
    'ни',
    'то',
    'ка',
    'про',
    'говорит',
    'сказано',
    'коран',
    'коране',
    'корана',
    'ведь',
    'бы',
    'есть',
    'какие',
    'какой',
    'какая',
    'почему',
    'зачем',
    'когда',
    'где',
    'чем',
    'кто',
    'the',
    'a',
    'an',
    'of',
    'in',
    'on',
    'to',
    'is',
    'are',
    'and',
    'or',
    'what',
    'does',
    'do',
    'how',
    'why',
    'about',
    'say',
    'says',
    'quran',
    'في',
    'من',
    'على',
    'عن',
    'ما',
    'ماذا',
    'هل',
    'القرآن',
  };

  /// Слова запроса без стоп-слов, обрезанные до основы (первые 5 букв),
  /// чтобы «молитва», «молитве», «молитвы» находили друг друга.
  /// Бытовые слова вопроса, которые не несут темы.
  static const _filler = {
    'правильно',
    'сделать',
    'делать',
    'нужно',
    'можно',
    'надо',
    'нельзя',
    'должен',
    'должна',
    'хочу',
    'могу',
    'жене',
    'мужу',
    'себя',
    'меня',
    'тебя',
    'всегда',
    'очень',
    'много',
    'сказать',
    'говорить',
    'сказал',
    'should',
    'can',
    'must',
    'want',
    'make',
    'how',
    'tell',
    'me',
  };

  /// Синонимы: термины, которых нет в переводе, заменяем словами перевода.
  static const _synonyms = {
    'талак': ['развод'],
    'намаз': ['молитв', 'намаз'],
    'салят': ['молитв'],
    'закят': ['закят', 'милостын'],
    'садака': ['милостын', 'садак'],
    'ураза': ['пост'],
    'хиджаб': ['покрывал'],
    'терпени': ['терпел', 'терпени'],
    'терпеть': ['терпел', 'терпени'],
    'родители': ['родител'],
    'дуа': ['взыва', 'мольб'],
    'зикр': ['помина'],
    'тауба': ['покая', 'раска'],
  };

  /// Слова запроса без стоп-слов, обрезанные до основы (первые 5 букв),
  /// чтобы «молитва», «молитве», «молитвы» находили друг друга.
  static List<String> tokenize(String q) {
    final clean = normalizeArabic(
      normalize(q),
    ).replaceAll(RegExp(r'[^\p{L}\s]', unicode: true), ' ');
    final out = <String>{};
    for (final w in clean.split(RegExp(r'\s+'))) {
      if (w.length < 3 || _stop.contains(w) || _filler.contains(w)) continue;
      final syn = _synonyms.entries
          .where((e) => w.startsWith(e.key))
          .firstOrNull;
      if (syn != null) {
        out.addAll(syn.value);
      } else {
        out.add(w.length > 6 ? w.substring(0, 5) : w);
      }
    }
    return out.toList();
  }
}
