import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'assistant.dart' show aiEndpoint;

enum PlaceKind { mosque, halal }

class Certificate {
  const Certificate({required this.issuer, this.number, this.until, this.url});
  final String issuer;
  final String? number;
  final DateTime? until;
  final String? url;

  bool get expired =>
      until != null &&
      until!.isBefore(DateTime.now().subtract(const Duration(days: 1)));
}

class Place {
  Place(
    this.kind,
    this.name,
    this.lat,
    this.lng,
    this.hours,
    this.address,
    this.tags, {
    this.osmId,
    this.certificate,
    this.checked,
    this.fromCatalog = false,
  });
  final PlaceKind kind;
  final String name;
  final double lat, lng;
  final String? hours;
  final String? address;
  final Map<String, dynamic> tags;

  /// «node/123», «way/456» — для объектов OpenStreetMap.
  final String? osmId;
  final Certificate? certificate;
  final DateTime? checked;

  /// Запись из модерируемого каталога (проверена человеком).
  final bool fromCatalog;

  bool get certified => certificate != null && !certificate!.expired;
}

/// Мечети и халяль-места из OpenStreetMap (Overpass API, лицензия ODbL).
/// На сервер уходят только границы видимой области карты, без данных пользователя.
class PlacesService {
  /// Запасные серверы Overpass, если наш сервер недоступен.
  static const mirrors = [
    'https://overpass-api.de/api/interpreter',
    'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
  ];

  static Future<List<Place>> fetch(
    double south,
    double west,
    double north,
    double east,
  ) async {
    final data = await _query(south, west, north, east);
    return parse(data);
  }

  /// Сначала наш сервер (перебирает зеркала Overpass и кеширует ответ на
  /// сутки), затем зеркала напрямую.
  static Future<Map<String, dynamic>> _query(
    double south,
    double west,
    double north,
    double east,
  ) async {
    Object? lastError;
    if (aiEndpoint.isNotEmpty && north - south <= 1.5 && east - west <= 1.5) {
      try {
        final r = await http
            .get(
              Uri.parse('$aiEndpoint/places').replace(
                queryParameters: {
                  's': '$south',
                  'w': '$west',
                  'n': '$north',
                  'e': '$east',
                },
              ),
            )
            .timeout(const Duration(seconds: 45));
        if (r.statusCode == 200) {
          return jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
        }
        lastError = Exception('places ${r.statusCode}');
      } catch (e) {
        lastError = e;
      }
    }
    final bbox = '$south,$west,$north,$east';
    final query =
        '''
[out:json][timeout:25];
(
  nwr["amenity"="place_of_worship"]["religion"="muslim"]($bbox);
  nwr["diet:halal"~"^(yes|only)\$"]($bbox);
  nwr["cuisine"~"halal"]($bbox);
  nwr["halal"="yes"]($bbox);
);
out center tags 300;
''';
    for (final url in mirrors) {
      try {
        final r = await http
            .post(Uri.parse(url), body: {'data': query})
            .timeout(const Duration(seconds: 30));
        if (r.statusCode == 200) {
          return jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
        }
        lastError = Exception('overpass ${r.statusCode}');
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? Exception('overpass');
  }

  /// Разбор ответа Overpass.
  static List<Place> parse(Map<String, dynamic> data) {
    final out = <Place>[];
    for (final e in data['elements'] as List) {
      final tags = (e['tags'] as Map?)?.cast<String, dynamic>() ?? {};
      final lat = (e['lat'] ?? e['center']?['lat']) as num?;
      final lng = (e['lon'] ?? e['center']?['lon']) as num?;
      if (lat == null || lng == null) continue;
      final isMosque = tags['amenity'] == 'place_of_worship';
      final name =
          (tags['name:ru'] ?? tags['name'] ?? tags['name:en'] ?? '') as String;
      final street = tags['addr:street'] as String?;
      final house = tags['addr:housenumber'] as String?;
      out.add(
        Place(
          isMosque ? PlaceKind.mosque : PlaceKind.halal,
          name,
          lat.toDouble(),
          lng.toDouble(),
          tags['opening_hours'] as String?,
          street == null
              ? null
              : [street, house].whereType<String>().join(', '),
          tags,
          osmId: '${e['type']}/${e['id']}',
        ),
      );
    }
    return out;
  }

  /// OpenStreetMap + каталог. Записи каталога заменяют совпавшие объекты OSM.
  /// Если OSM недоступен, показываем хотя бы каталог и пробрасываем ошибку.
  static Future<(List<Place>, Object?)> fetchAll(
    double south,
    double west,
    double north,
    double east,
  ) async {
    final catalog = (await HalalCatalog.load())
        .where(
          (p) =>
              p.lat >= south &&
              p.lat <= north &&
              p.lng >= west &&
              p.lng <= east,
        )
        .toList();
    List<Place> osm = const [];
    Object? error;
    try {
      osm = await fetch(south, west, north, east);
    } catch (e) {
      error = e;
    }
    final replaced = {for (final p in catalog) ?p.osmId};
    return (
      [...catalog, ...osm.where((p) => !replaced.contains(p.osmId))],
      error,
    );
  }
}

/// Модерируемый каталог: assets/halal/catalog.json. Свежая версия берётся
/// из репозитория, при неудаче — последняя сохранённая или встроенная.
class HalalCatalog {
  static const remote =
      'https://raw.githubusercontent.com/VladFlutt/imam/main/app/assets/halal/catalog.json';
  static const _cacheKey = 'halalCatalog';
  static List<Place>? _places;

  static Future<List<Place>> load() async {
    if (_places != null) return _places!;
    final prefs = await SharedPreferences.getInstance();
    String raw =
        prefs.getString(_cacheKey) ??
        await rootBundle.loadString('assets/halal/catalog.json');
    try {
      final r = await http
          .get(Uri.parse(remote))
          .timeout(const Duration(seconds: 8));
      if (r.statusCode == 200) {
        final body = utf8.decode(r.bodyBytes);
        parse(body); // проверяем, что JSON корректен
        raw = body;
        await prefs.setString(_cacheKey, body);
      }
    } catch (_) {
      // офлайн — используем сохранённую копию
    }
    return _places = parse(raw);
  }

  static List<Place> parse(String raw) {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return [
      for (final e in (data['places'] as List? ?? const []))
        Place(
          e['kind'] == 'mosque' ? PlaceKind.mosque : PlaceKind.halal,
          e['name'] as String,
          (e['lat'] as num).toDouble(),
          (e['lng'] as num).toDouble(),
          e['hours'] as String?,
          e['address'] as String?,
          const {},
          osmId: e['osm'] as String?,
          checked: DateTime.tryParse(e['checked'] as String? ?? ''),
          fromCatalog: true,
          certificate: e['certificate'] == null
              ? null
              : Certificate(
                  issuer: e['certificate']['issuer'] as String,
                  number: e['certificate']['number'] as String?,
                  until: DateTime.tryParse(
                    e['certificate']['until'] as String? ?? '',
                  ),
                  url: e['certificate']['url'] as String?,
                ),
        ),
    ];
  }
}

/// Заявка на добавление или исправление места.
class PlaceSuggestion {
  PlaceSuggestion({
    required this.kind,
    required this.name,
    required this.lat,
    required this.lng,
    this.address = '',
    this.certificate = '',
    this.comment = '',
    this.osmId,
    this.isCorrection = false,
  });
  final PlaceKind kind;
  final String name, address, certificate, comment;
  final double lat, lng;
  final String? osmId;
  final bool isCorrection;

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'name': name,
    'lat': double.parse(lat.toStringAsFixed(6)),
    'lng': double.parse(lng.toStringAsFixed(6)),
    'address': address,
    'certificate': certificate,
    'comment': comment,
    'osm': ?osmId,
    'correction': isCorrection,
  };

  /// Запасной путь без сервера: форма нового issue на GitHub.
  Uri githubIssueUrl() {
    final title =
        '${isCorrection ? 'Исправление' : 'Новое место'}: ${name.isEmpty ? '(без названия)' : name}';
    final body = [
      'Тип: ${kind == PlaceKind.mosque ? 'мечеть' : 'халяль'}',
      'Координаты: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
      if (osmId != null) 'OSM: https://www.openstreetmap.org/$osmId',
      if (address.isNotEmpty) 'Адрес: $address',
      if (certificate.isNotEmpty) 'Сертификат: $certificate',
      if (comment.isNotEmpty) 'Комментарий: $comment',
    ].join('\n');
    return Uri.https('github.com', '/VladFlutt/imam/issues/new', {
      'title': title,
      'body': body,
      'labels': 'halal-place',
    });
  }
}
