/// Заглушка: вне браузера компас даёт flutter_compass.
class WebCompass {
  static bool get supported => false;
  static bool get needsPermission => false;
  static Future<bool> requestPermission() async => false;
  static Stream<double> headings() => const Stream.empty();
}
