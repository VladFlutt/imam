import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Результат запроса местоположения: координаты или ключ строки с ошибкой.
typedef LocateResult = ({double? lat, double? lng, String? error});

/// Определяет местоположение с понятными ошибками:
/// gps_off — геолокация выключена на телефоне, gps_denied — нет разрешения,
/// gps_denied_forever — запрещено навсегда (нужно включить в настройках),
/// gps_timeout — не удалось определить за 15 секунд.
Future<LocateResult> locate() async {
  try {
    if (!kIsWeb && !await Geolocator.isLocationServiceEnabled()) {
      return (lat: null, lng: null, error: 'gps_off');
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      return (lat: null, lng: null, error: 'gps_denied_forever');
    }
    if (perm == LocationPermission.denied) {
      return (lat: null, lng: null, error: 'gps_denied');
    }
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return (lat: p.latitude, lng: p.longitude, error: null);
    } catch (_) {
      // Нет свежей точки — берём последнюю известную (на вебе её нет).
      if (!kIsWeb) {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          return (lat: last.latitude, lng: last.longitude, error: null);
        }
      }
      return (lat: null, lng: null, error: 'gps_timeout');
    }
  } catch (_) {
    return (lat: null, lng: null, error: 'gps_denied');
  }
}

/// Открыть настройки приложения (Android/iOS), чтобы выдать разрешение.
Future<void> openLocationSettings(String error) async {
  if (kIsWeb) return;
  if (error == 'gps_off') {
    await Geolocator.openLocationSettings();
  } else if (error == 'gps_denied_forever') {
    await Geolocator.openAppSettings();
  }
}
