/// Города для ручного выбора, если геолокация недоступна.
/// utcOffset — постоянное смещение (в этих странах нет перехода на летнее время).
class City {
  const City(
    this.id,
    this.ru,
    this.en,
    this.ar,
    this.lat,
    this.lng,
    this.utcOffset,
  );
  final String id;
  final String ru;
  final String en;
  final String ar;
  final double lat;
  final double lng;
  final double utcOffset;

  String name(String lang) => switch (lang) {
    'ar' => ar,
    'en' || 'uz' || 'az' => en,
    _ => ru,
  };
}

const cities = <City>[
  City('moscow', 'Москва', 'Moscow', 'موسكو', 55.7558, 37.6173, 3),
  City(
    'spb',
    'Санкт-Петербург',
    'Saint Petersburg',
    'سانت بطرسبرغ',
    59.9343,
    30.3351,
    3,
  ),
  City('kazan', 'Казань', 'Kazan', 'قازان', 55.7963, 49.1088, 3),
  City('ufa', 'Уфа', 'Ufa', 'أوفا', 54.7388, 55.9721, 5),
  City(
    'makhachkala',
    'Махачкала',
    'Makhachkala',
    'محج قلعة',
    42.9849,
    47.5047,
    3,
  ),
  City('grozny', 'Грозный', 'Grozny', 'غروزني', 43.3178, 45.6949, 3),
  City('nalchik', 'Нальчик', 'Nalchik', 'نالتشيك', 43.4853, 43.6071, 3),
  City(
    'nizhny',
    'Нижний Новгород',
    'Nizhny Novgorod',
    'نيجني نوفغورود',
    56.2965,
    43.9361,
    3,
  ),
  City(
    'ekb',
    'Екатеринбург',
    'Yekaterinburg',
    'يكاترينبورغ',
    56.8389,
    60.6057,
    5,
  ),
  City(
    'novosibirsk',
    'Новосибирск',
    'Novosibirsk',
    'نوفوسيبيرسك',
    55.0084,
    82.9357,
    7,
  ),
  City('tashkent', 'Ташкент', 'Tashkent', 'طشقند', 41.2995, 69.2401, 5),
  City('samarkand', 'Самарканд', 'Samarkand', 'سمرقند', 39.6542, 66.9597, 5),
  City('almaty', 'Алматы', 'Almaty', 'ألماتي', 43.2220, 76.8512, 5),
  City('astana', 'Астана', 'Astana', 'أستانا', 51.1694, 71.4491, 5),
  City('bishkek', 'Бишкек', 'Bishkek', 'بيشكيك', 42.8746, 74.5698, 6),
  City('dushanbe', 'Душанбе', 'Dushanbe', 'دوشنبه', 38.5598, 68.7870, 5),
  City('baku', 'Баку', 'Baku', 'باكو', 40.4093, 49.8671, 4),
  City('ashgabat', 'Ашхабад', 'Ashgabat', 'عشق آباد', 37.9601, 58.3261, 5),
];
