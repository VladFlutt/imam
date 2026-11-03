import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'quran.dart';

/// Адрес сервера ИИ (Cloudflare Worker). Задаётся при сборке:
/// flutter build web --dart-define=AI_ENDPOINT=https://imam-ai.ACCOUNT.workers.dev
const aiEndpoint = String.fromEnvironment('AI_ENDPOINT');

enum FilterAction { allow, refuse, imam, specialist }

class AssistantReply {
  AssistantReply({required this.kind, this.text, this.ayat = const []});
  final FilterAction kind;
  final String? text; // ответ модели (null — показываем только аяты)
  final List<Ayah> ayat;
  bool offline = false;
}

/// Словарь запретных слов и тем — тот же файл использует сервер.
class ContentFilter {
  ContentFilter._(this._cats);
  final List<(FilterAction, List<String>)> _cats;
  static ContentFilter? _instance;

  static Future<ContentFilter> load() async {
    if (_instance != null) return _instance!;
    final raw =
        jsonDecode(await rootBundle.loadString('assets/ai/blocklist.json'))
            as Map<String, dynamic>;
    final cats = <(FilterAction, List<String>)>[];
    (raw['categories'] as Map<String, dynamic>).forEach((_, v) {
      final action = switch (v['action']) {
        'imam' => FilterAction.imam,
        'specialist' => FilterAction.specialist,
        _ => FilterAction.refuse,
      };
      cats.add((
        action,
        (v['stems'] as List).cast<String>().map(QuranRepo.normalize).toList(),
      ));
    });
    return _instance = ContentFilter._(cats);
  }

  /// Самая строгая подходящая категория: отказ важнее отсылки к имаму.
  FilterAction check(String text) {
    final t = ' ${QuranRepo.normalize(text).replaceAll(RegExp(r'\s+'), ' ')}';
    var result = FilterAction.allow;
    for (final (action, stems) in _cats) {
      for (final s in stems) {
        // Совпадение по началу слова, чтобы «бомба» не ловилось внутри других слов.
        if (t.contains(' $s') || t.contains('«$s') || t.contains('"$s')) {
          if (action == FilterAction.refuse) return FilterAction.refuse;
          if (action == FilterAction.specialist || result == FilterAction.allow)
            result = action;
        }
      }
    }
    return result;
  }
}

class AssistantService {
  static Future<AssistantReply> ask(
    String question, {
    required String lang,
    required String trCode,
  }) async {
    final filter = await ContentFilter.load();
    final action = filter.check(question);
    if (action == FilterAction.refuse) return AssistantReply(kind: action);
    if (action == FilterAction.specialist) return AssistantReply(kind: action);

    final repo = QuranRepo.instance;
    await repo.load();
    await repo.ensureTranslation(trCode);
    final ayat = repo.search(question, trCode, limit: 8);
    if (action == FilterAction.imam)
      return AssistantReply(kind: action, ayat: ayat.take(4).toList());

    if (aiEndpoint.isEmpty) {
      return AssistantReply(kind: FilterAction.allow, ayat: ayat)
        ..offline = true;
    }
    try {
      final r = await http
          .post(
            Uri.parse('$aiEndpoint/ask'),
            headers: {'content-type': 'application/json'},
            body: jsonEncode({
              'question': question,
              'lang': lang,
              'ayat': [
                for (final a in ayat)
                  {
                    'ref': a.ref,
                    'text': trCode == 'ar'
                        ? a.arabic
                        : repo.translation(a.surah.id, a.number, trCode),
                  },
              ],
            }),
          )
          .timeout(const Duration(seconds: 45));
      final data = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      final kind = switch (data['status']) {
        'refuse' => FilterAction.refuse,
        'imam' => FilterAction.imam,
        'specialist' => FilterAction.specialist,
        _ => FilterAction.allow,
      };
      final refs = (data['refs'] as List? ?? const []).cast<String>();
      final cited = [
        for (final ref in refs) repo.byRef(ref),
      ].whereType<Ayah>().toList();
      return AssistantReply(
        kind: kind,
        text: data['answer'] as String?,
        ayat: cited.isEmpty ? ayat.take(3).toList() : cited,
      );
    } catch (_) {
      return AssistantReply(kind: FilterAction.allow, ayat: ayat)
        ..offline = true;
    }
  }
}
