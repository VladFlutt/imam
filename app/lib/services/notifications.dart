import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../app_state.dart';
import '../l10n.dart';
import 'prayer.dart';

/// Локальные напоминания о намазе (Android и iOS).
/// Android планирует на 30 дней вперёд, iOS — на 12 (предел iOS — 64 ожидающих
/// уведомления: 12 × 5 намазов + напоминание продлить). Перепланируем при каждом
/// запуске и при смене места или метода расчёта; за день до конца срока
/// приходит напоминание открыть приложение.
class AzanNotifications {
  AzanNotifications._();
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static int get days => defaultTargetPlatform == TargetPlatform.iOS ? 12 : 30;
  static const _renewId = 9999;

  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static Future<void> _init() async {
    if (_ready || !supported) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  /// Спрашивает разрешение (только по нажатию пользователя). true — можно.
  static Future<bool> requestPermission() async {
    if (!supported) return false;
    await _init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final ok = await android.requestNotificationsPermission() ?? false;
      if (ok && !(await android.canScheduleExactNotifications() ?? false)) {
        await android.requestExactAlarmsPermission();
      }
      return ok;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  static Future<void> reschedule(AppState s) async {
    if (!supported) return;
    try {
      await _init();
      await _plugin.cancelAll();
      if (!s.azanEnabled) return;
      final l = s.l10n;
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final exact = await android?.canScheduleExactNotifications() ?? true;
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'azan',
          l.t('azan_notify'),
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(presentSound: true),
      );
      final offset = Duration(minutes: (s.utcOffset * 60).round());
      final nowUtc = DateTime.now().toUtc();
      final start = PrayerService.placeNow(s);
      for (var d = 0; d < days; d++) {
        final day = PrayerService.forDate(s, start.add(Duration(days: d)));
        for (var i = 0; i < day.items.length; i++) {
          final e = day.items[i];
          if (e.key == 'sunrise') continue;
          // Время в списке — «наивное» местное; переводим обратно в UTC.
          final whenUtc = e.value.subtract(offset);
          if (!whenUtc.isAfter(nowUtc)) continue;
          await _plugin.zonedSchedule(
            id: d * 10 + i,
            scheduledDate: tz.TZDateTime.from(whenUtc, tz.UTC),
            notificationDetails: details,
            androidScheduleMode: exact
                ? AndroidScheduleMode.exactAllowWhileIdle
                : AndroidScheduleMode.inexactAllowWhileIdle,
            title: _title(l, e.key),
            body: '${s.placeName(l)} · ${s.num(hhmm(e.value))}',
          );
        }
      }
      // Срок напоминаний кончается — просим открыть приложение, чтобы продлить.
      final renewAt = nowUtc.add(Duration(days: days - 1));
      await _plugin.zonedSchedule(
        id: _renewId,
        scheduledDate: tz.TZDateTime.from(renewAt, tz.UTC),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: l.t('azan_notify'),
        body: l.t('azan_renew'),
      );
    } catch (e) {
      debugPrint('azan reschedule failed: $e');
    }
  }

  static String _title(L10n l, String key) =>
      l.t('azan_title').replaceAll('{p}', l.t(key));
}
