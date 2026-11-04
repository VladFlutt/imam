import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// Компас в браузере телефона.
/// Android Chrome: событие deviceorientationabsolute (alpha от севера).
/// iOS Safari: deviceorientation с webkitCompassHeading; разрешение
/// запрашивается по нажатию кнопки (DeviceOrientationEvent.requestPermission).
class WebCompass {
  static JSObject? get _ctor =>
      globalContext.getProperty<JSAny?>('DeviceOrientationEvent'.toJS)
          as JSObject?;

  static bool get supported => _ctor != null;

  /// iOS 13+: без явного разрешения события не приходят.
  static bool get needsPermission => _ctor?.has('requestPermission') ?? false;

  static Future<bool> requestPermission() async {
    final ctor = _ctor;
    if (ctor == null) return false;
    if (!ctor.has('requestPermission')) return true;
    try {
      final res = await ctor
          .callMethod<JSPromise<JSString>>('requestPermission'.toJS)
          .toDart;
      return res.toDart == 'granted';
    } catch (_) {
      return false;
    }
  }

  static double _screenAngle() {
    try {
      return web.window.screen.orientation.angle.toDouble();
    } catch (_) {
      return 0;
    }
  }

  /// Куда смотрит верх экрана, градусы от севера по часовой стрелке.
  static Stream<double> headings() {
    late StreamController<double> c;
    JSFunction? absListener;
    JSFunction? relListener;
    var gotAbsolute = false;

    void emit(double h) {
      if (!c.isClosed) c.add((h + _screenAngle()) % 360);
    }

    c = StreamController<double>(
      onListen: () {
        absListener = ((web.Event e) {
          final ev = e as web.DeviceOrientationEvent;
          final alpha = ev.alpha;
          if (alpha == null) return;
          gotAbsolute = true;
          emit(360 - alpha);
        }).toJS;
        relListener = ((web.Event e) {
          final o = e as JSObject;
          final ios = o.getProperty<JSAny?>('webkitCompassHeading'.toJS);
          if (ios != null) {
            emit((ios as JSNumber).toDartDouble);
            return;
          }
          if (gotAbsolute) return;
          final ev = e as web.DeviceOrientationEvent;
          if (ev.absolute && ev.alpha != null) emit(360 - ev.alpha!);
        }).toJS;
        web.window.addEventListener('deviceorientationabsolute', absListener);
        web.window.addEventListener('deviceorientation', relListener);
      },
      onCancel: () {
        web.window.removeEventListener(
          'deviceorientationabsolute',
          absListener,
        );
        web.window.removeEventListener('deviceorientation', relListener);
      },
    );
    return c.stream;
  }
}
