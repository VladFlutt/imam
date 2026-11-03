import 'dart:math' as math;

import 'package:adhan_dart/adhan_dart.dart';

import '../app_state.dart';

class DayTimes {
  DayTimes(this.date, this.items);
  final DateTime date;

  /// Пары (ключ локализации, время в часовом поясе места).
  final List<MapEntry<String, DateTime>> items;
}

class PrayerService {
  static CalculationParameters params(AppState s) {
    final p = switch (s.method) {
      PrayerMethod.russia => CalculationMethodParameters.russia(),
      PrayerMethod.muslimWorldLeague =>
        CalculationMethodParameters.muslimWorldLeague(),
      PrayerMethod.ummAlQura => CalculationMethodParameters.ummAlQura(),
      PrayerMethod.egyptian => CalculationMethodParameters.egyptian(),
      PrayerMethod.turkiye => CalculationMethodParameters.turkiye(),
      PrayerMethod.northAmerica => CalculationMethodParameters.northAmerica(),
    };
    final coords = Coordinates(s.lat, s.lng);
    return p.copyWith(
      madhab: s.hanafi ? Madhab.hanafi : Madhab.shafi,
      // Для северных широт (Москва, Петербург летом) — правило седьмой части ночи.
      highLatitudeRule: s.lat.abs() > 48
          ? HighLatitudeRule.seventhOfTheNight
          : HighLatitudeRule.recommended(coords),
    );
  }

  /// Время намазов на дату по местному времени выбранного места.
  static DayTimes forDate(AppState s, DateTime day) {
    final pt = PrayerTimes(
      coordinates: Coordinates(s.lat, s.lng),
      date: DateTime(day.year, day.month, day.day),
      calculationParameters: params(s),
    );
    DateTime local(DateTime t) =>
        t.toUtc().add(Duration(minutes: (s.utcOffset * 60).round()));
    return DayTimes(day, [
      MapEntry('fajr', local(pt.fajr)),
      MapEntry('sunrise', local(pt.sunrise)),
      MapEntry('dhuhr', local(pt.dhuhr)),
      MapEntry('asr', local(pt.asr)),
      MapEntry('maghrib', local(pt.maghrib)),
      MapEntry('isha', local(pt.isha)),
    ]);
  }

  /// «Сейчас» в часовом поясе выбранного места (как наивное время).
  static DateTime placeNow(AppState s) =>
      DateTime.now().toUtc().add(Duration(minutes: (s.utcOffset * 60).round()));

  /// Следующий намаз (восход не считается намазом).
  static MapEntry<String, DateTime> next(AppState s) {
    final now = placeNow(s);
    final today = forDate(s, now);
    for (final e in today.items) {
      if (e.key != 'sunrise' && _naive(e.value).isAfter(_naive(now))) return e;
    }
    final tomorrow = forDate(s, now.add(const Duration(days: 1)));
    return tomorrow.items.first;
  }

  static DateTime _naive(DateTime t) =>
      DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second);

  static Duration until(AppState s, DateTime t) =>
      _naive(t).difference(_naive(placeNow(s)));

  static double qibla(AppState s) => Qibla.qibla(Coordinates(s.lat, s.lng));

  /// Расстояние до Каабы по большому кругу, км.
  static double distanceToMakkah(AppState s) {
    const r = 6371.0;
    final la1 = s.lat * math.pi / 180, la2 = 21.4225 * math.pi / 180;
    final dLa = la2 - la1, dLo = (39.8262 - s.lng) * math.pi / 180;
    final a =
        math.pow(math.sin(dLa / 2), 2) +
        math.cos(la1) * math.cos(la2) * math.pow(math.sin(dLo / 2), 2);
    return 2 * r * math.asin(math.sqrt(a));
  }
}

String hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
