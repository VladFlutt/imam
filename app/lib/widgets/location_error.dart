import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n.dart';
import '../services/location.dart';

/// Сообщение об ошибке геолокации; где можно — с кнопкой «Настройки».
void showLocationError(ScaffoldMessengerState m, L10n l, String error) {
  final canOpen =
      !kIsWeb && (error == 'gps_off' || error == 'gps_denied_forever');
  m.showSnackBar(
    SnackBar(
      content: Text(l.t(error)),
      duration: const Duration(seconds: 6),
      action: canOpen
          ? SnackBarAction(
              label: l.t('open_settings'),
              onPressed: () => openLocationSettings(error),
            )
          : null,
    ),
  );
}
