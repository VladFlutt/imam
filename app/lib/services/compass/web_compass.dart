// Компас в браузере (DeviceOrientationEvent). На других платформах — заглушка.
export 'web_compass_stub.dart'
    if (dart.library.js_interop) 'web_compass_web.dart';
