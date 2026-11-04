import 'package:flutter/widgets.dart';

import 'data/content_cis.dart';
import 'l10n_cis.dart';

/// Простая локализация на трёх языках без кодогенерации.
/// Ключи — английские идентификаторы, значения — ru / en / ar.
class L10n {
  L10n(this.lang);
  final String lang;

  static const supported = [
    'ru',
    'en',
    'ar',
    'tt',
    'uz',
    'kk',
    'ky',
    'tg',
    'az',
  ];

  /// Самоназвания языков для переключателя.
  static const names = {
    'ru': 'Русский',
    'en': 'English',
    'ar': 'العربية',
    'tt': 'Татарча',
    'uz': 'Oʻzbekcha',
    'kk': 'Қазақша',
    'ky': 'Кыргызча',
    'tg': 'Тоҷикӣ',
    'az': 'Azərbaycanca',
  };

  /// Языки, для которых во Flutter есть системная локализация (кнопки, даты).
  /// Для остальных системные элементы показываются по-русски.
  static const _materialSupported = {'ru', 'en', 'ar', 'uz', 'kk', 'ky', 'az'};
  String get materialLang => _materialSupported.contains(lang) ? lang : 'ru';

  /// Перевод Корана по умолчанию для языка интерфейса.
  /// Для казахского и кыргызского свободного перевода пока нет — используется русский.
  static const _quranTr = {
    'ru': 'ru',
    'en': 'en',
    'ar': 'ar',
    'tt': 'tt',
    'uz': 'uz',
    'kk': 'ru',
    'ky': 'ru',
    'tg': 'tg',
    'az': 'az',
  };
  String get defaultQuranTr => _quranTr[lang] ?? 'ru';

  /// Редакционный контент (советы, описания дат) пока есть на ru/en/ar.
  String get contentLang =>
      const {'ru', 'en', 'ar'}.contains(lang) ? lang : 'ru';
  String tr(Map<String, String> m) {
    if (m.containsKey(lang)) return m[lang]!;
    final cis = cisContent[m['ru']]?[lang];
    return cis ?? m[contentLang] ?? m['ru'] ?? '';
  }

  bool get isRtl => lang == 'ar';

  /// Языки на латинице: для них — латинская транслитерация и названия городов.
  bool get latinScript => const {'en', 'uz', 'az'}.contains(lang);

  /// Транслитерация дуа (в арабском интерфейсе не показываем).
  String? translit(String cyr) => switch (lang) {
    'ar' => null,
    _ when latinScript => latinTranslit[cyr] ?? cyr,
    _ => cyr,
  };

  /// «аль-Бухари 1, Муслим 1907» на языке интерфейса.
  String source(String s) {
    if (lang == 'ru') return s;
    var out = s;
    hadithCollections.forEach((ru, names) {
      out = out.replaceAll(ru, names[lang] ?? ru);
    });
    return lang == 'ar' ? out.replaceAll(',', '،') : out;
  }

  String t(String key) =>
      cisStrings[lang]?[key] ??
      _strings[key]?[lang] ??
      _strings[key]?['ru'] ??
      key;

  String inTime(String t) => this.t('in_fmt').replaceAll('{t}', t);

  /// Цифры: при включённой опции в арабском интерфейсе — восточно-арабские.
  static String digits(String s, {required bool arabic}) {
    if (!arabic) return s;
    const western = '0123456789';
    const eastern = '٠١٢٣٤٥٦٧٨٩';
    final b = StringBuffer();
    for (final ch in s.split('')) {
      final i = western.indexOf(ch);
      b.write(i >= 0 ? eastern[i] : ch);
    }
    return b.toString();
  }

  static const _strings = <String, Map<String, String>>{
    'app_name': {'ru': 'Имам', 'en': 'Imam', 'ar': 'إمام'},
    'tab_home': {'ru': 'Главная', 'en': 'Home', 'ar': 'الرئيسية'},
    'tab_prayer': {'ru': 'Намаз', 'en': 'Prayer', 'ar': 'الصلاة'},
    'tab_quran': {'ru': 'Коран', 'en': 'Quran', 'ar': 'القرآن'},
    'tab_map': {'ru': 'Карта', 'en': 'Map', 'ar': 'الخريطة'},
    'tab_more': {'ru': 'Ещё', 'en': 'More', 'ar': 'المزيد'},
    'fajr': {'ru': 'Фаджр', 'en': 'Fajr', 'ar': 'الفجر'},
    'sunrise': {'ru': 'Восход', 'en': 'Sunrise', 'ar': 'الشروق'},
    'dhuhr': {'ru': 'Зухр', 'en': 'Dhuhr', 'ar': 'الظهر'},
    'asr': {'ru': 'Аср', 'en': 'Asr', 'ar': 'العصر'},
    'maghrib': {'ru': 'Магриб', 'en': 'Maghrib', 'ar': 'المغرب'},
    'isha': {'ru': 'Иша', 'en': 'Isha', 'ar': 'العشاء'},
    'next_prayer': {
      'ru': 'Следующий намаз',
      'en': 'Next prayer',
      'ar': 'الصلاة القادمة',
    },
    'in_fmt': {'ru': 'через {t}', 'en': 'in {t}', 'ar': 'بعد {t}'},
    'content_note': {'ru': '', 'en': '', 'ar': ''},
    'gps_off': {
      'ru': 'Геолокация выключена. Включите её в настройках телефона.',
      'en': 'Location is turned off. Turn it on in the phone settings.',
      'ar': 'خدمة الموقع متوقفة. فعّلها من إعدادات الهاتف.',
    },
    'gps_denied_forever': {
      'ru':
          'Доступ к геолокации запрещён. Разрешите его в настройках приложения или браузера.',
      'en':
          'Location access is blocked. Allow it in the app or browser settings.',
      'ar': 'تم حظر الوصول إلى الموقع. اسمح به من إعدادات التطبيق أو المتصفح.',
    },
    'gps_timeout': {
      'ru':
          'Не удалось определить местоположение. Попробуйте ещё раз или выберите город.',
      'en': 'Could not determine your location. Try again or pick a city.',
      'ar': 'تعذّر تحديد موقعك. حاول مرة أخرى أو اختر مدينة.',
    },
    'open_settings': {'ru': 'Настройки', 'en': 'Settings', 'ar': 'الإعدادات'},
    'compass_enable': {
      'ru': 'Включить компас',
      'en': 'Enable compass',
      'ar': 'تشغيل البوصلة',
    },
    'compass_unavailable': {
      'ru':
          'Компас недоступен в этом браузере. Откройте приложение на телефоне или ориентируйтесь по градусам от севера.',
      'en':
          'The compass is not available in this browser. Open the app on a phone or use the degrees from north.',
      'ar':
          'البوصلة غير متاحة في هذا المتصفح. افتح التطبيق على الهاتف أو استخدم الدرجات من الشمال.',
    },
    'suggest_place': {
      'ru': 'Предложить место',
      'en': 'Suggest a place',
      'ar': 'اقترح مكاناً',
    },
    'report_error': {
      'ru': 'Сообщить об ошибке',
      'en': 'Report a mistake',
      'ar': 'الإبلاغ عن خطأ',
    },
    'suggest_hint': {
      'ru':
          'Место отметится в центре карты (крестик). Модератор проверит заявку и сертификат, прежде чем добавить место в каталог.',
      'en':
          'The place is marked at the centre of the map (the cross). A moderator checks the request and the certificate before adding it to the catalogue.',
      'ar':
          'يُحدَّد المكان في وسط الخريطة (العلامة +). يراجع المشرف الطلب والشهادة قبل إضافته إلى الدليل.',
    },
    'report_hint': {
      'ru':
          'Опишите, что не так: закрыто, другое время работы, нет сертификата, неверное место.',
      'en':
          'Describe what is wrong: closed, different hours, no certificate, wrong location.',
      'ar': 'صف المشكلة: مغلق، أوقات عمل مختلفة، لا توجد شهادة، موقع خاطئ.',
    },
    'suggest_name': {'ru': 'Название', 'en': 'Name', 'ar': 'الاسم'},
    'suggest_address': {'ru': 'Адрес', 'en': 'Address', 'ar': 'العنوان'},
    'suggest_cert': {
      'ru': 'Сертификат халяль: кто выдал, номер',
      'en': 'Halal certificate: issuer and number',
      'ar': 'شهادة الحلال: الجهة المانحة والرقم',
    },
    'suggest_comment': {'ru': 'Комментарий', 'en': 'Comment', 'ar': 'تعليق'},
    'suggest_send': {
      'ru': 'Отправить на проверку',
      'en': 'Send for review',
      'ar': 'أرسل للمراجعة',
    },
    'suggest_sent': {
      'ru': 'Спасибо! Модератор проверит заявку.',
      'en': 'Thank you! A moderator will review it.',
      'ar': 'شكراً! سيراجع المشرف الطلب.',
    },
    'cert_badge': {
      'ru': 'Сертификат халяль',
      'en': 'Halal certified',
      'ar': 'شهادة حلال',
    },
    'cert_expired': {
      'ru': 'Срок сертификата истёк',
      'en': 'Certificate expired',
      'ar': 'انتهت صلاحية الشهادة',
    },
    'cert_until': {'ru': 'до', 'en': 'until', 'ar': 'حتى'},
    'cert_check': {
      'ru': 'Проверить на сайте органа сертификации',
      'en': 'Verify with the certifier',
      'ar': 'تحقق لدى جهة الإصدار',
    },
    'catalog_checked': {
      'ru': 'Проверено модератором: {date}',
      'en': 'Checked by a moderator: {date}',
      'ar': 'راجعه المشرف: {date}',
    },
    'hadith40': {
      'ru': '40 хадисов ан-Навави',
      'en': 'An-Nawawi’s Forty Hadith',
      'ar': 'الأربعون النووية',
    },
    'hadith_n': {'ru': 'Хадис {n}', 'en': 'Hadith {n}', 'ar': 'الحديث {n}'},
    'hadith_review': {
      'ru':
          'Арабский текст по классическому сборнику имама ан-Навави. Перевод подготовлен редакцией и до выпуска приложения проходит проверку имамом. Смысл хадисов разъясняют учёные: с вопросами обращайтесь к имаму.',
      'en':
          'Arabic text from Imam an-Nawawi’s classical collection. The translation was prepared by the editors and is being checked by an imam before release. Scholars explain the meaning of hadith: please ask an imam.',
      'ar':
          'النص العربي من مجموع الإمام النووي. يُرجع في فهم الأحاديث وشرحها إلى أهل العلم.',
    },
    'hadith_ru_only': {'ru': '', 'en': '', 'ar': ''},
    'qibla_live': {
      'ru':
          'Держите телефон горизонтально и поворачивайтесь, пока золотая стрелка не окажется вверху.',
      'en':
          'Hold the phone flat and turn until the gold arrow points to the top.',
      'ar': 'أمسك الهاتف أفقياً واستدر حتى يشير السهم الذهبي إلى الأعلى.',
    },
    'qibla_aligned': {
      'ru': 'Вы смотрите на Киблу',
      'en': 'You are facing the Qibla',
      'ar': 'أنت متجه إلى القبلة',
    },
    'qibla_calibrate': {
      'ru':
          'Если стрелка скачет, поводите телефоном восьмёркой и отойдите от металла и магнитов.',
      'en':
          'If the arrow jumps, move the phone in a figure eight and keep away from metal and magnets.',
      'ar':
          'إذا اضطرب السهم فحرّك الهاتف على شكل الرقم ثمانية وابتعد عن المعادن والمغناطيس.',
    },
    'azan_notify': {
      'ru': 'Уведомления о намазе',
      'en': 'Prayer notifications',
      'ar': 'تنبيهات الصلاة',
    },
    'azan_notify_sub': {
      'ru':
          'В начале времени каждого намаза, на месяц вперёд (на iPhone — на 12 дней). Обновляются при открытии приложения.',
      'en':
          'At the start of each prayer time, a month ahead (12 days on iPhone). Refreshed whenever you open the app.',
      'ar':
          'عند دخول وقت كل صلاة لشهر قادم (12 يوماً على آيفون)، وتُحدَّث عند فتح التطبيق.',
    },
    'azan_renew': {
      'ru': 'Откройте приложение, чтобы продлить напоминания о намазе.',
      'en': 'Open the app to keep your prayer reminders going.',
      'ar': 'افتح التطبيق لتجديد تنبيهات الصلاة.',
    },
    'azan_mobile_only': {
      'ru': 'Доступно в мобильном приложении',
      'en': 'Available in the mobile app',
      'ar': 'متاح في تطبيق الهاتف',
    },
    'azan_denied': {
      'ru': 'Разрешите уведомления для приложения в настройках телефона.',
      'en': 'Allow notifications for the app in your phone settings.',
      'ar': 'اسمح بالإشعارات للتطبيق من إعدادات الهاتف.',
    },
    'azan_title': {
      'ru': 'Время намаза: {p}',
      'en': 'Prayer time: {p}',
      'ar': 'حان وقت صلاة {p}',
    },
    'h': {'ru': 'ч', 'en': 'h', 'ar': 'س'},
    'min': {'ru': 'мин', 'en': 'min', 'ar': 'د'},
    'ayah_of_day': {
      'ru': 'Аят дня',
      'en': 'Verse of the day',
      'ar': 'آية اليوم',
    },
    'hadith_of_day': {
      'ru': 'Хадис дня',
      'en': 'Hadith of the day',
      'ar': 'حديث اليوم',
    },
    'tip_of_day': {
      'ru': 'Совет дня',
      'en': 'Tip of the day',
      'ar': 'نصيحة اليوم',
    },
    'upcoming': {
      'ru': 'Ближайшие даты',
      'en': 'Upcoming dates',
      'ar': 'المناسبات القادمة',
    },
    'days_left': {'ru': 'дн.', 'en': 'days', 'ar': 'يوم'},
    'today': {'ru': 'Сегодня', 'en': 'Today', 'ar': 'اليوم'},
    'qibla': {'ru': 'Кибла', 'en': 'Qibla', 'ar': 'القبلة'},
    'qibla_hint': {
      'ru':
          'Направление на Каабу от севера по часовой стрелке. Положите телефон горизонтально и поверните верхний край к северу: стрелка покажет Киблу.',
      'en':
          'Direction to the Kaaba, clockwise from north. Lay the phone flat with its top edge pointing north: the arrow shows the Qibla.',
      'ar':
          'اتجاه الكعبة من الشمال باتجاه عقارب الساعة. ضع الهاتف أفقياً ووجّه طرفه العلوي نحو الشمال: يشير السهم إلى القبلة.',
    },
    'distance_makkah': {
      'ru': 'До Мекки',
      'en': 'To Makkah',
      'ar': 'المسافة إلى مكة',
    },
    'km': {'ru': 'км', 'en': 'km', 'ar': 'كم'},
    'calendar': {'ru': 'Календарь', 'en': 'Calendar', 'ar': 'التقويم'},
    'calendar_note': {
      'ru':
          'Даты рассчитаны по календарю Умм аль-Кура и могут отличаться на ±1 день. Сверяйтесь с объявлением ДУМ вашего региона.',
      'en':
          'Dates follow the Umm al-Qura calendar and may differ by ±1 day. Check your local Muslim board announcement.',
      'ar':
          'التواريخ وفق تقويم أم القرى وقد تختلف بيوم واحد. يرجى مراجعة إعلان الإدارة الدينية في منطقتك.',
    },
    'duas': {
      'ru': 'Дуа и азкары',
      'en': 'Duas and adhkar',
      'ar': 'الأدعية والأذكار',
    },
    'tasbih': {'ru': 'Тасбих', 'en': 'Tasbih', 'ar': 'التسبيح'},
    'reset': {'ru': 'Сбросить', 'en': 'Reset', 'ar': 'إعادة'},
    'assistant': {
      'ru': 'ИИ-помощник',
      'en': 'AI assistant',
      'ar': 'المساعد الذكي',
    },
    'settings': {'ru': 'Настройки', 'en': 'Settings', 'ar': 'الإعدادات'},
    'about': {'ru': 'О приложении', 'en': 'About', 'ar': 'حول التطبيق'},
    'language': {'ru': 'Язык', 'en': 'Language', 'ar': 'اللغة'},
    'location': {'ru': 'Город', 'en': 'City', 'ar': 'المدينة'},
    'use_gps': {
      'ru': 'Определить по GPS',
      'en': 'Use GPS',
      'ar': 'تحديد عبر GPS',
    },
    'gps_denied': {
      'ru': 'Нет доступа к геолокации',
      'en': 'Location access denied',
      'ar': 'لا يمكن الوصول إلى الموقع',
    },
    'my_location': {
      'ru': 'Моё местоположение',
      'en': 'My location',
      'ar': 'موقعي',
    },
    'method': {
      'ru': 'Метод расчёта',
      'en': 'Calculation method',
      'ar': 'طريقة الحساب',
    },
    'madhab': {
      'ru': 'Мазхаб (время асра)',
      'en': 'Madhab (Asr time)',
      'ar': 'المذهب (وقت العصر)',
    },
    'hanafi': {'ru': 'Ханафитский', 'en': 'Hanafi', 'ar': 'الحنفي'},
    'shafii': {
      'ru': 'Шафиитский, маликитский, ханбалитский',
      'en': "Shafi'i, Maliki, Hanbali",
      'ar': 'الشافعي والمالكي والحنبلي',
    },
    'dark_theme': {
      'ru': 'Тёмная тема',
      'en': 'Dark theme',
      'ar': 'الوضع الليلي',
    },
    'large_text': {'ru': 'Крупный текст', 'en': 'Large text', 'ar': 'خط كبير'},
    'arabic_digits': {
      'ru': 'Арабские цифры',
      'en': 'Arabic-Indic digits',
      'ar': 'الأرقام العربية',
    },
    'translation': {'ru': 'Перевод', 'en': 'Translation', 'ar': 'الترجمة'},
    'search': {'ru': 'Поиск', 'en': 'Search', 'ar': 'بحث'},
    'search_quran': {
      'ru': 'Поиск по Корану',
      'en': 'Search the Quran',
      'ar': 'البحث في القرآن',
    },
    'ayahs': {'ru': 'аятов', 'en': 'verses', 'ar': 'آية'},
    'meccan': {'ru': 'Мекканская', 'en': 'Meccan', 'ar': 'مكية'},
    'medinan': {'ru': 'Мединская', 'en': 'Medinan', 'ar': 'مدنية'},
    'bookmarks': {'ru': 'Закладки', 'en': 'Bookmarks', 'ar': 'العلامات'},
    'no_bookmarks': {
      'ru': 'Пока нет закладок. Нажмите на аят, чтобы сохранить его.',
      'en': 'No bookmarks yet. Tap a verse to save it.',
      'ar': 'لا توجد علامات بعد. اضغط على الآية لحفظها.',
    },
    'mosques': {'ru': 'Мечети', 'en': 'Mosques', 'ar': 'المساجد'},
    'halal': {'ru': 'Халяль', 'en': 'Halal', 'ar': 'حلال'},
    'loading': {'ru': 'Загрузка…', 'en': 'Loading…', 'ar': 'جارٍ التحميل…'},
    'net_error': {
      'ru': 'Не удалось загрузить данные. Проверьте интернет.',
      'en': 'Could not load data. Check your connection.',
      'ar': 'تعذر تحميل البيانات. تحقق من الاتصال.',
    },
    'nothing_found': {
      'ru': 'Ничего не найдено поблизости',
      'en': 'Nothing found nearby',
      'ar': 'لم يتم العثور على شيء قريب',
    },
    'hours': {'ru': 'Часы работы', 'en': 'Opening hours', 'ar': 'ساعات العمل'},
    'hours_unknown': {
      'ru': 'часы не указаны',
      'en': 'hours not listed',
      'ar': 'الساعات غير محددة',
    },
    'route': {'ru': 'Маршрут', 'en': 'Directions', 'ar': 'الاتجاهات'},
    'refresh_area': {
      'ru': 'Искать здесь',
      'en': 'Search this area',
      'ar': 'ابحث هنا',
    },
    'halal_unverified': {
      'ru':
          'Статус «халяль» взят из OpenStreetMap со слов заведения или пользователей и не подтверждён сертификатом.',
      'en':
          'Halal status comes from OpenStreetMap, as stated by the venue or users, and is not certificate-verified.',
      'ar':
          'حالة «حلال» مأخوذة من OpenStreetMap وفق المكان أو المستخدمين ولم يتم التحقق منها بشهادة.',
    },
    'osm_credit': {
      'ru': '© участники OpenStreetMap',
      'en': '© OpenStreetMap contributors',
      'ar': '© مساهمو OpenStreetMap',
    },
    'ask_placeholder': {
      'ru': 'Задайте вопрос о Коране…',
      'en': 'Ask about the Quran…',
      'ar': 'اسأل عن القرآن…',
    },
    'ai_intro': {
      'ru':
          'Ас-саляму алейкум! Я отвечаю на вопросы, опираясь только на аяты Корана, и всегда даю ссылки. Я не даю фетв: в сложных и личных вопросах обратитесь к имаму.',
      'en':
          'As-salamu alaykum! I answer using only verses of the Quran and always cite them. I do not issue fatwas: for complex or personal matters, please consult an imam.',
      'ar':
          'السلام عليكم! أجيب بالاعتماد على آيات القرآن فقط مع ذكر المراجع دائماً. لا أصدر فتاوى: في المسائل الشخصية والمعقدة يُرجى استشارة إمام.',
    },
    'ai_disclaimer': {
      'ru': 'Это не фетва. В сложных вопросах обратитесь к имаму.',
      'en': 'This is not a fatwa. For complex questions, consult an imam.',
      'ar': 'هذه ليست فتوى. في المسائل المعقدة استشر إماماً.',
    },
    'ai_refuse': {
      'ru':
          'Простите, на эту тему я не отвечаю. Я помогаю с вопросами о Коране, вере и повседневной практике, без политики, оскорблений и призывов к насилию.',
      'en':
          'Sorry, I do not discuss this topic. I help with questions about the Quran, faith and daily practice, without politics, insults or calls to violence.',
      'ar':
          'عذراً، لا أتناول هذا الموضوع. أساعد في أسئلة القرآن والإيمان والعبادات اليومية دون سياسة أو إساءة أو دعوة إلى العنف.',
    },
    'ai_imam': {
      'ru':
          'Это личный вопрос, по которому нужна фетва с учётом всех обстоятельств. Пожалуйста, обратитесь к имаму ближайшей мечети: их список есть на вкладке «Карта». Ниже аяты, которые касаются темы.',
      'en':
          'This is a personal matter that needs a fatwa based on all the circumstances. Please consult the imam of a nearby mosque (see the Map tab). Below are verses related to the topic.',
      'ar':
          'هذه مسألة شخصية تحتاج إلى فتوى تراعي جميع الظروف. يُرجى استشارة إمام أقرب مسجد (انظر تبويب الخريطة). فيما يلي آيات تتعلق بالموضوع.',
    },
    'ai_specialist': {
      'ru':
          'С этим лучше обратиться к специалисту: врачу или юристу. Если вам плохо или есть угроза жизни, позвоните 112 прямо сейчас.',
      'en':
          'Please talk to a specialist, a doctor or a lawyer. If you feel unsafe or your life is at risk, call your local emergency number now.',
      'ar':
          'يُرجى التوجه إلى مختص، طبيب أو محامٍ. إذا كنت في خطر فاتصل برقم الطوارئ فوراً.',
    },
    'ai_offline': {
      'ru':
          'Сервер помощника не подключён, поэтому показываю аяты Корана, которые подходят к вашему вопросу:',
      'en':
          'The assistant server is not connected, so here are Quran verses matching your question:',
      'ar': 'خادم المساعد غير متصل، لذا إليك آيات قرآنية تتعلق بسؤالك:',
    },
    'ai_no_ayat': {
      'ru':
          'Я не нашёл аятов по этому вопросу. Попробуйте сформулировать иначе или спросите имама.',
      'en':
          'I could not find verses on this question. Try rephrasing it or ask an imam.',
      'ar': 'لم أجد آيات حول هذا السؤال. جرّب صياغة أخرى أو اسأل إماماً.',
    },
    'ai_limit': {
      'ru':
          'Лимит вопросов на сегодня исчерпан. Возвращайтесь завтра, ин ша Аллах.',
      'en':
          'Daily question limit reached. Please come back tomorrow, in sha Allah.',
      'ar': 'تم بلوغ الحد اليومي للأسئلة. عُد غداً إن شاء الله.',
    },
    'sources': {'ru': 'Источники', 'en': 'Sources', 'ar': 'المصادر'},
    'about_text': {
      'ru':
          'Имам — бесплатный справочник мусульманина. Нейтральный суннитский подход, без политики и полемики. Приложение не собирает личные данные: настройки, закладки и история чата хранятся только на вашем устройстве.',
      'en':
          'Imam is a free reference app for Muslims. A neutral Sunni approach, with no politics or polemics. The app collects no personal data: settings, bookmarks and chat history stay on your device.',
      'ar':
          'إمام دليل مجاني للمسلم. نهج سني محايد بلا سياسة ولا جدال. لا يجمع التطبيق بيانات شخصية: الإعدادات والعلامات وسجل المحادثة تبقى على جهازك فقط.',
    },
    'prayer_times': {
      'ru': 'Время намаза',
      'en': 'Prayer times',
      'ar': 'مواقيت الصلاة',
    },
    'week': {'ru': 'На неделю', 'en': 'This week', 'ar': 'هذا الأسبوع'},
    'kids_mode': {
      'ru': 'Детский режим (без чата и карты)',
      'en': 'Kids mode (no chat or map)',
      'ar': 'وضع الأطفال (بدون محادثة وخريطة)',
    },
    'hijri_months': {
      'ru':
          'Мухаррам,Сафар,Раби аль-авваль,Раби ас-сани,Джумада аль-уля,Джумада ас-сания,Раджаб,Шаабан,Рамадан,Шавваль,Зуль-када,Зуль-хиджа',
      'en':
          'Muharram,Safar,Rabi al-Awwal,Rabi al-Thani,Jumada al-Ula,Jumada al-Thaniyah,Rajab,Shaban,Ramadan,Shawwal,Dhu al-Qadah,Dhu al-Hijjah',
      'ar':
          'محرم,صفر,ربيع الأول,ربيع الآخر,جمادى الأولى,جمادى الآخرة,رجب,شعبان,رمضان,شوال,ذو القعدة,ذو الحجة',
    },
    'greg_months': {
      'ru':
          'января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря',
      'en':
          'January,February,March,April,May,June,July,August,September,October,November,December',
      'ar':
          'يناير,فبراير,مارس,أبريل,مايو,يونيو,يوليو,أغسطس,سبتمبر,أكتوبر,نوفمبر,ديسمبر',
    },
    'weekdays': {
      'ru': 'Понедельник,Вторник,Среда,Четверг,Пятница,Суббота,Воскресенье',
      'en': 'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday',
      'ar': 'الاثنين,الثلاثاء,الأربعاء,الخميس,الجمعة,السبت,الأحد',
    },
    'ah': {'ru': 'г. х.', 'en': 'AH', 'ar': 'هـ'},
  };

  List<String> list(String key) => t(key).split(',');
}

class L10nScope extends InheritedWidget {
  const L10nScope({super.key, required this.l10n, required super.child});
  final L10n l10n;

  static L10n of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<L10nScope>()!.l10n;

  @override
  bool updateShouldNotify(L10nScope old) => old.l10n.lang != l10n.lang;
}
