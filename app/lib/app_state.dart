import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/cities.dart';
import 'l10n.dart';

enum PrayerMethod {
  russia,
  muslimWorldLeague,
  ummAlQura,
  egyptian,
  turkiye,
  northAmerica,
}

/// Всё состояние приложения хранится только на устройстве (shared_preferences).
class AppState extends ChangeNotifier {
  AppState._(this._prefs);
  final SharedPreferences _prefs;

  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppState._(prefs);
  }

  String get lang {
    final saved = _prefs.getString('lang');
    if (saved != null && L10n.supported.contains(saved)) return saved;
    final sys = PlatformDispatcher.instance.locale.languageCode;
    // Приложение ориентировано на РФ и СНГ: английский системный язык не делаем языком по умолчанию.
    return L10n.supported.contains(sys) && sys != 'en' ? sys : 'ru';
  }

  set lang(String v) => _set(() => _prefs.setString('lang', v));

  L10n get l10n => L10n(lang);

  /// Перевод Корана: явно выбранный или по языку интерфейса.
  String get quranTr => _prefs.getString('quranTr') ?? l10n.defaultQuranTr;
  set quranTr(String v) => _set(() => _prefs.setString('quranTr', v));

  // Местоположение: город из списка или координаты GPS.
  String get cityId => _prefs.getString('city') ?? 'moscow';
  City get city =>
      cities.firstWhere((c) => c.id == cityId, orElse: () => cities.first);
  bool get useGps => _prefs.getBool('gps') ?? false;
  double get lat => useGps ? (_prefs.getDouble('lat') ?? city.lat) : city.lat;
  double get lng => useGps ? (_prefs.getDouble('lng') ?? city.lng) : city.lng;

  /// Смещение от UTC в часах для показа времени намаза.
  /// Для GPS — часовой пояс устройства, для города — его постоянный пояс.
  double get utcOffset =>
      useGps ? DateTime.now().timeZoneOffset.inMinutes / 60 : city.utcOffset;

  String placeName(L10n l) => useGps ? l.t('my_location') : city.name(l.lang);

  void setCity(String id) => _set(() async {
    await _prefs.setString('city', id);
    await _prefs.setBool('gps', false);
  });

  void setGps(double lat, double lng) => _set(() async {
    await _prefs.setDouble('lat', lat);
    await _prefs.setDouble('lng', lng);
    await _prefs.setBool('gps', true);
  });

  PrayerMethod get method =>
      PrayerMethod.values.byName(_prefs.getString('method') ?? 'russia');
  set method(PrayerMethod v) => _set(() => _prefs.setString('method', v.name));

  bool get hanafi => _prefs.getBool('hanafi') ?? true;
  set hanafi(bool v) => _set(() => _prefs.setBool('hanafi', v));

  bool get dark => _prefs.getBool('dark') ?? false;
  set dark(bool v) => _set(() => _prefs.setBool('dark', v));

  bool get largeText => _prefs.getBool('large') ?? false;
  set largeText(bool v) => _set(() => _prefs.setBool('large', v));

  bool get arabicDigits => _prefs.getBool('arDigits') ?? false;
  set arabicDigits(bool v) => _set(() => _prefs.setBool('arDigits', v));

  bool get kidsMode => _prefs.getBool('kids') ?? false;
  set kidsMode(bool v) => _set(() => _prefs.setBool('kids', v));

  Set<String> get bookmarks =>
      (_prefs.getStringList('bookmarks') ?? const []).toSet();
  bool isBookmarked(int s, int a) => bookmarks.contains('$s:$a');
  void toggleBookmark(int s, int a) => _set(() {
    final b = bookmarks;
    final key = '$s:$a';
    b.contains(key) ? b.remove(key) : b.add(key);
    return _prefs.setStringList('bookmarks', b.toList());
  });

  int get tasbih => _prefs.getInt('tasbih') ?? 0;
  set tasbih(int v) => _set(() => _prefs.setInt('tasbih', v));

  /// Счётчик вопросов ИИ за сутки (лимит бережёт бесплатные квоты).
  static const aiDailyLimit = 20;
  int get aiUsedToday {
    final day = DateTime.now().toIso8601String().substring(0, 10);
    return _prefs.getString('aiDay') == day
        ? (_prefs.getInt('aiCount') ?? 0)
        : 0;
  }

  Future<void> countAiQuestion() async {
    final day = DateTime.now().toIso8601String().substring(0, 10);
    final used = aiUsedToday;
    await _prefs.setString('aiDay', day);
    await _prefs.setInt('aiCount', used + 1);
  }

  void _set(dynamic Function() write) async {
    final r = write();
    if (r is Future) await r;
    notifyListeners();
  }

  /// Форматирование цифр с учётом настройки.
  String num(String s) => L10n.digits(s, arabic: arabicDigits && lang == 'ar');
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
