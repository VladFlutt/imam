import 'dart:convert';

import 'package:http/http.dart' as http;

enum PlaceKind { mosque, halal }

class Place {
  Place(
    this.kind,
    this.name,
    this.lat,
    this.lng,
    this.hours,
    this.address,
    this.tags,
  );
  final PlaceKind kind;
  final String name;
  final double lat, lng;
  final String? hours;
  final String? address;
  final Map<String, dynamic> tags;
}

/// Мечети и халяль-места из OpenStreetMap (Overpass API, лицензия ODbL).
/// На сервер уходят только границы видимой области карты, без данных пользователя.
class PlacesService {
  static const endpoint = 'https://overpass-api.de/api/interpreter';

  static Future<List<Place>> fetch(
    double south,
    double west,
    double north,
    double east,
  ) async {
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
    final r = await http
        .post(Uri.parse(endpoint), body: {'data': query})
        .timeout(const Duration(seconds: 30));
    if (r.statusCode != 200) throw Exception('overpass ${r.statusCode}');
    final data = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
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
        ),
      );
    }
    return out;
  }
}
