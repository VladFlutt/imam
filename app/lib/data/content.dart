// Редакционный контент: совет дня, дуа, памятные даты.
// ВАЖНО: перед релизом весь текст проходит проверку редакционного совета (имам / ДУМ).
// Тексты аятов не хранятся здесь: они подставляются из Корана по ссылке (сура:аят),
// поэтому перевод всегда совпадает с выбранным переводом Корана.

typedef Tr = Map<String, String>;

class DailyItem {
  const DailyItem.ayah(this.ref, this.tip)
    : arabic = null,
      text = null,
      source = null;
  const DailyItem.hadith(this.arabic, this.text, this.source, this.tip)
    : ref = null;

  final String? ref; // «сура:аят» для аята
  final String? arabic; // арабский текст хадиса
  final Tr? text; // перевод хадиса
  final String? source; // сборник и номер
  final Tr tip;

  bool get isAyah => ref != null;
}

const dailyItems = <DailyItem>[
  DailyItem.ayah('2:286', {
    'ru':
        'Если день кажется тяжёлым, вспомните: испытание всегда по силам. Сделайте сегодня одно дело, которое откладывали.',
    'en':
        'If the day feels heavy, remember that no trial is beyond your strength. Do one task you have been putting off.',
    'ar':
        'إذا بدا اليوم ثقيلاً فتذكّر أن الله لا يكلّف نفساً إلا وسعها. أنجز اليوم أمراً كنت تؤجله.',
  }),
  DailyItem.hadith(
    'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
    {
      'ru': 'Поистине, дела оцениваются по намерениям.',
      'en': 'Actions are judged only by intentions.',
      'ar': 'إنما الأعمال بالنيات.',
    },
    'аль-Бухари 1, Муслим 1907',
    {
      'ru':
          'Перед привычным делом — работой, учёбой, едой — обновите намерение ради Аллаха.',
      'en':
          'Before routine tasks such as work, study or a meal, renew your intention for the sake of Allah.',
      'ar': 'جدّد نيتك لله قبل الأعمال المعتادة كالعمل والدراسة والطعام.',
    },
  ),
  DailyItem.ayah('13:28', {
    'ru':
        'Найдите пять минут на зикр после намаза: 33 раза «СубханАллах», «Альхамдулиллях» и «Аллаху акбар».',
    'en':
        'Take five minutes for dhikr after prayer: 33 times SubhanAllah, Alhamdulillah and Allahu Akbar.',
    'ar':
        'خصّص خمس دقائق للذكر بعد الصلاة: سبحان الله والحمد لله والله أكبر ثلاثاً وثلاثين.',
  }),
  DailyItem.hadith(
    'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ',
    {
      'ru': 'Твоя улыбка брату — садака.',
      'en': 'Your smile in the face of your brother is charity.',
      'ar': 'تبسمك في وجه أخيك لك صدقة.',
    },
    'ат-Тирмизи 1956',
    {
      'ru': 'Садака не всегда деньги. Поздоровайтесь с соседом и улыбнитесь.',
      'en': 'Charity is not always money. Greet a neighbour with a smile.',
      'ar': 'الصدقة ليست مالاً دائماً. سلّم على جارك بابتسامة.',
    },
  ),
  DailyItem.ayah('17:23', {
    'ru':
        'Позвоните сегодня родителям или сделайте дуа за них, если их уже нет рядом.',
    'en':
        'Call your parents today, or make dua for them if they are no longer with you.',
    'ar': 'اتصل بوالديك اليوم، أو ادعُ لهما إن لم يكونا معك.',
  }),
  DailyItem.hadith(
    'الطُّهُورُ شَطْرُ الْإِيمَانِ',
    {
      'ru': 'Чистота — половина веры.',
      'en': 'Purity is half of faith.',
      'ar': 'الطهور شطر الإيمان.',
    },
    'Муслим 223',
    {
      'ru': 'Совершайте омовение не спеша и полностью, следуя сунне.',
      'en': 'Perform wudu calmly and completely, following the Sunnah.',
      'ar': 'توضأ بهدوء وإسباغ على السنة.',
    },
  ),
  DailyItem.ayah('94:6', {
    'ru':
        'За трудностью приходит облегчение. Запишите три блага, за которые вы благодарны сегодня.',
    'en':
        'Ease comes with hardship. Write down three blessings you are grateful for today.',
    'ar': 'مع العسر يسر. اكتب ثلاث نعم تشكر الله عليها اليوم.',
  }),
  DailyItem.hadith(
    'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
    {
      'ru': 'Лучший из вас тот, кто изучает Коран и обучает ему.',
      'en': 'The best of you are those who learn the Quran and teach it.',
      'ar': 'خيركم من تعلم القرآن وعلّمه.',
    },
    'аль-Бухари 5027',
    {
      'ru':
          'Прочитайте сегодня одну короткую суру с переводом и расскажите о ней близким.',
      'en':
          'Read one short surah with its translation today and share it with your family.',
      'ar': 'اقرأ اليوم سورة قصيرة مع تفسيرها وشاركها مع أهلك.',
    },
  ),
  DailyItem.ayah('2:152', {
    'ru':
        'Поминайте Аллаха в пути: по дороге на работу можно повторять истигфар.',
    'en': 'Remember Allah on the go: repeat istighfar on your way to work.',
    'ar': 'اذكر الله في طريقك: ردّد الاستغفار وأنت ذاهب إلى العمل.',
  }),
  DailyItem.hadith(
    'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
    {
      'ru':
          'Не уверует никто из вас, пока не пожелает брату того же, чего желает себе.',
      'en':
          'None of you truly believes until he loves for his brother what he loves for himself.',
      'ar': 'لا يؤمن أحدكم حتى يحب لأخيه ما يحب لنفسه.',
    },
    'аль-Бухари 13, Муслим 45',
    {
      'ru':
          'Помогите сегодня коллеге или однокурснику без ожидания благодарности.',
      'en': 'Help a colleague or classmate today without expecting thanks.',
      'ar': 'ساعد زميلاً اليوم دون انتظار شكر.',
    },
  ),
  DailyItem.ayah('65:3', {
    'ru': 'Сделайте всё, что от вас зависит, а результат доверьте Аллаху.',
    'en': 'Do everything within your power and entrust the outcome to Allah.',
    'ar': 'ابذل ما في وسعك وتوكّل على الله في النتيجة.',
  }),
  DailyItem.hadith(
    'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
    {
      'ru':
          'Кто верует в Аллаха и в Последний день, пусть говорит благое или молчит.',
      'en':
          'Whoever believes in Allah and the Last Day, let him speak good or remain silent.',
      'ar': 'من كان يؤمن بالله واليوم الآخر فليقل خيراً أو ليصمت.',
    },
    'аль-Бухари 6018, Муслим 47',
    {
      'ru':
          'Перед тем как написать комментарий в сети, спросите себя: это благо?',
      'en': 'Before posting a comment online, ask yourself: is it good?',
      'ar': 'قبل أن تكتب تعليقاً على الإنترنت، اسأل نفسك: هل هو خير؟',
    },
  ),
  DailyItem.ayah('49:13', {
    'ru':
        'Люди созданы разными, чтобы узнавать друг друга. Познакомьтесь с соседом по мечети.',
    'en':
        'People were made different so they may know one another. Get to know someone at your mosque.',
    'ar': 'خُلق الناس مختلفين ليتعارفوا. تعرّف على أحد رواد مسجدك.',
  }),
  DailyItem.hadith(
    'لَيْسَ الشَّدِيدُ بِالصُّرَعَةِ، إِنَّمَا الشَّدِيدُ الَّذِي يَمْلِكُ نَفْسَهُ عِنْدَ الْغَضَبِ',
    {
      'ru':
          'Сильный не тот, кто побеждает в борьбе, а тот, кто владеет собой в гневе.',
      'en':
          'The strong one is not the good wrestler, but the one who controls himself when angry.',
      'ar': 'ليس الشديد بالصرعة، إنما الشديد الذي يملك نفسه عند الغضب.',
    },
    'аль-Бухари 6114, Муслим 2609',
    {
      'ru':
          'Почувствовали гнев — сделайте паузу, произнесите «А‘узу билляхи мин аш-шайтан ар-раджим».',
      'en':
          'When anger rises, pause and say: A‘udhu billahi min ash-shaytan ar-rajim.',
      'ar': 'إذا غضبت فتوقف وقل: أعوذ بالله من الشيطان الرجيم.',
    },
  ),
  DailyItem.ayah('3:134', {
    'ru':
        'Простите сегодня кого-то, кто вас обидел, даже если он не просил прощения.',
    'en': 'Forgive someone who hurt you today, even if they did not ask.',
    'ar': 'اعفُ اليوم عمّن أساء إليك ولو لم يعتذر.',
  }),
  DailyItem.hadith(
    'أَحَبُّ الْأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ',
    {
      'ru': 'Самые любимые Аллахом дела — постоянные, даже если они малы.',
      'en':
          'The deeds most beloved to Allah are the most constant, even if small.',
      'ar': 'أحب الأعمال إلى الله أدومها وإن قلّ.',
    },
    'аль-Бухари 6464, Муслим 783',
    {
      'ru':
          'Выберите маленькую ежедневную привычку: одну страницу Корана или два ракаата духа.',
      'en':
          'Pick one small daily habit: one page of the Quran or two rakahs of Duha.',
      'ar': 'اختر عادة يومية صغيرة: صفحة من القرآن أو ركعتي الضحى.',
    },
  ),
  DailyItem.ayah('39:53', {
    'ru':
        'Никогда не поздно покаяться. Сделайте искренний истигфар перед сном.',
    'en':
        'It is never too late to repent. Make sincere istighfar before sleep.',
    'ar': 'لا يفوت أوان التوبة أبداً. استغفر بصدق قبل النوم.',
  }),
  DailyItem.hadith(
    'يَسِّرُوا وَلَا تُعَسِّرُوا، وَبَشِّرُوا وَلَا تُنَفِّرُوا',
    {
      'ru': 'Облегчайте и не затрудняйте, радуйте и не отталкивайте.',
      'en':
          'Make things easy, not difficult; give good news and do not drive people away.',
      'ar': 'يسّروا ولا تعسّروا، وبشّروا ولا تنفّروا.',
    },
    'аль-Бухари 69, Муслим 1734',
    {
      'ru':
          'Объясняя религию детям или новичкам, начинайте с милости, а не со страха.',
      'en':
          'When explaining faith to children or newcomers, start with mercy, not fear.',
      'ar': 'عند شرح الدين للأطفال أو المبتدئين ابدأ بالرحمة لا بالتخويف.',
    },
  ),
  DailyItem.ayah('2:186', {
    'ru': 'Аллах близок. Попросите в дуа о чём-то конкретном своими словами.',
    'en': 'Allah is near. Ask for something specific in your own words.',
    'ar': 'الله قريب. اطلب في دعائك أمراً محدداً بكلماتك.',
  }),
  DailyItem.hadith(
    'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ',
    {
      'ru': 'Тому, кто встал на путь поиска знания, Аллах облегчит путь в рай.',
      'en':
          'Whoever takes a path seeking knowledge, Allah makes easy for him a path to Paradise.',
      'ar': 'من سلك طريقاً يلتمس فيه علماً سهّل الله له به طريقاً إلى الجنة.',
    },
    'Муслим 2699',
    {
      'ru':
          'Узнайте сегодня одно новое значение имени Аллаха или выучите короткое дуа.',
      'en':
          'Learn the meaning of one of the names of Allah today, or memorise a short dua.',
      'ar': 'تعلّم اليوم معنى اسم من أسماء الله أو احفظ دعاءً قصيراً.',
    },
  ),
  DailyItem.ayah('31:18', {
    'ru':
        'Скромность украшает. Не хвалитесь сегодня успехами, а поблагодарите за них Аллаха.',
    'en':
        'Humility adorns you. Instead of boasting about success today, thank Allah for it.',
    'ar': 'التواضع زينة. اشكر الله على نجاحك بدل التفاخر به.',
  }),
  DailyItem.hadith(
    'الْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ',
    {
      'ru': 'Доброе слово — садака.',
      'en': 'A good word is charity.',
      'ar': 'الكلمة الطيبة صدقة.',
    },
    'аль-Бухари 2989, Муслим 1009',
    {
      'ru': 'Скажите тёплые слова тому, кто устал: родным, кассиру, водителю.',
      'en':
          'Say a kind word to someone who is tired: family, a cashier, a driver.',
      'ar': 'قل كلمة طيبة لمن أتعبه يومه: أهلك أو البائع أو السائق.',
    },
  ),
  DailyItem.ayah('2:153', {
    'ru':
        'В трудный момент обратитесь к терпению и намазу: совершите два ракаата.',
    'en': 'In hard moments, turn to patience and prayer: pray two rakahs.',
    'ar': 'في الشدة استعن بالصبر والصلاة: صلِّ ركعتين.',
  }),
  DailyItem.hadith(
    'مَنْ لَا يَرْحَمُ النَّاسَ لَا يَرْحَمُهُ اللَّهُ',
    {
      'ru': 'Кто не милосерден к людям, к тому не будет милосерден Аллах.',
      'en':
          'Whoever shows no mercy to people, Allah will show no mercy to him.',
      'ar': 'من لا يرحم الناس لا يرحمه الله.',
    },
    'аль-Бухари 7376, Муслим 2319',
    {
      'ru':
          'Проявите милосердие: накормите бездомное животное или помогите пожилому человеку.',
      'en': 'Show mercy: feed a stray animal or help an elderly person.',
      'ar': 'كن رحيماً: أطعم حيواناً شارداً أو ساعد مسناً.',
    },
  ),
  DailyItem.ayah('20:114', {
    'ru': 'Просите Аллаха о пользе знания: «Господи, прибавь мне знания».',
    'en':
        'Ask Allah for beneficial knowledge: "My Lord, increase me in knowledge."',
    'ar': 'اسأل الله علماً نافعاً: «رب زدني علماً».',
  }),
  DailyItem.ayah('103:3', {
    'ru': 'Время — капитал. Отложите телефон на час и проведите его с семьёй.',
    'en':
        'Time is capital. Put your phone away for an hour and spend it with family.',
    'ar': 'الوقت رأس مال. ضع هاتفك جانباً ساعة واقضها مع أسرتك.',
  }),
  DailyItem.ayah('93:11', {
    'ru':
        'Рассказывайте о милостях Господа: поделитесь сегодня хорошей новостью.',
    'en': 'Proclaim the blessings of your Lord: share some good news today.',
    'ar': 'حدّث بنعمة ربك: شارك خبراً ساراً اليوم.',
  }),
  DailyItem.ayah('25:63', {
    'ru': 'Отвечайте спокойно, даже если с вами говорят грубо.',
    'en': 'Reply calmly, even when spoken to harshly.',
    'ar': 'أجب بهدوء ولو خوطبت بغلظة.',
  }),
  DailyItem.ayah('64:16', {
    'ru':
        'Бойтесь Аллаха, насколько можете: не требуйте от себя невозможного, но не останавливайтесь.',
    'en':
        'Be mindful of Allah as much as you can: do not demand the impossible of yourself, but keep going.',
    'ar': 'اتقوا الله ما استطعتم: لا تطلب من نفسك المستحيل، لكن لا تتوقف.',
  }),
  DailyItem.ayah('16:97', {
    'ru': 'Благое дело приносит благую жизнь. Сделайте сегодня тайную садаку.',
    'en': 'Righteous deeds bring a good life. Give a secret charity today.',
    'ar': 'العمل الصالح يورث حياة طيبة. تصدّق اليوم صدقة سرّ.',
  }),
];

DailyItem dailyItemFor(DateTime date) {
  final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
  return dailyItems[dayOfYear % dailyItems.length];
}

class Dua {
  const Dua.quran(this.title, this.ref, this.when)
    : arabic = null,
      translit = null,
      text = null,
      source = null,
      count = 1;
  const Dua.sunnah(
    this.title,
    this.arabic,
    this.translit,
    this.text,
    this.source,
    this.when, {
    this.count = 1,
  }) : ref = null;
  final Tr title;
  final String? ref;
  final String? arabic;
  final String? translit;
  final Tr? text;
  final String? source;
  final Tr when;
  final int count;
}

const _morning = {
  'ru': 'Утро и вечер',
  'en': 'Morning and evening',
  'ar': 'الصباح والمساء',
};
const _prayer = {
  'ru': 'После намаза',
  'en': 'After prayer',
  'ar': 'بعد الصلاة',
};
const _daily = {
  'ru': 'Каждый день',
  'en': 'Daily life',
  'ar': 'الحياة اليومية',
};
const _quranic = {
  'ru': 'Дуа из Корана',
  'en': 'Duas from the Quran',
  'ar': 'أدعية قرآنية',
};

const duas = <Dua>[
  Dua.sunnah(
    {
      'ru': 'Истигфар после намаза',
      'en': 'Istighfar after prayer',
      'ar': 'الاستغفار بعد الصلاة',
    },
    'أَسْتَغْفِرُ اللَّهَ',
    'Астагфируллах',
    {
      'ru': 'Прошу прощения у Аллаха.',
      'en': 'I seek forgiveness from Allah.',
      'ar': 'أستغفر الله.',
    },
    'Муслим 591',
    _prayer,
    count: 3,
  ),
  Dua.quran(
    {'ru': 'Аят аль-Курси', 'en': 'Ayat al-Kursi', 'ar': 'آية الكرسي'},
    '2:255',
    _prayer,
  ),
  Dua.sunnah(
    {
      'ru': 'Тасбих после намаза',
      'en': 'Tasbih after prayer',
      'ar': 'التسبيح بعد الصلاة',
    },
    'سُبْحَانَ اللَّهِ · الْحَمْدُ لِلَّهِ · اللَّهُ أَكْبَرُ',
    'СубханАллах · Альхамдулиллях · Аллаху акбар',
    {
      'ru': 'Пречист Аллах · Хвала Аллаху · Аллах велик (по 33 раза).',
      'en':
          'Glory be to Allah · Praise be to Allah · Allah is the Greatest (33 times each).',
      'ar': 'سبحان الله والحمد لله والله أكبر (ثلاثاً وثلاثين).',
    },
    'Муслим 597',
    _prayer,
    count: 33,
  ),
  Dua.sunnah(
    {'ru': 'При пробуждении', 'en': 'Upon waking', 'ar': 'عند الاستيقاظ'},
    'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
    'Альхамдулилляхи ллязи ахйана ба‘да ма аматана ва иляйхи-н-нушур',
    {
      'ru':
          'Хвала Аллаху, который оживил нас после того, как умертвил, и к Нему возвращение.',
      'en':
          'Praise be to Allah who gave us life after He caused us to die, and to Him is the return.',
      'ar': 'الحمد لله الذي أحيانا بعد ما أماتنا وإليه النشور.',
    },
    'аль-Бухари 6312',
    _morning,
  ),
  Dua.sunnah(
    {'ru': 'Перед сном', 'en': 'Before sleep', 'ar': 'قبل النوم'},
    'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    'Бисмика Аллахумма амуту ва ахйа',
    {
      'ru': 'С Твоим именем, о Аллах, я умираю и оживаю.',
      'en': 'In Your name, O Allah, I die and I live.',
      'ar': 'باسمك اللهم أموت وأحيا.',
    },
    'аль-Бухари 6324',
    _morning,
  ),
  Dua.sunnah(
    {'ru': 'Перед едой', 'en': 'Before eating', 'ar': 'قبل الطعام'},
    'بِسْمِ اللَّهِ',
    'Бисмиллях',
    {
      'ru': 'С именем Аллаха.',
      'en': 'In the name of Allah.',
      'ar': 'بسم الله.',
    },
    'Абу Дауд 3767, ат-Тирмизи 1858',
    _daily,
  ),
  Dua.sunnah(
    {'ru': 'После еды', 'en': 'After eating', 'ar': 'بعد الطعام'},
    'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
    'Альхамдулилляхи ллязи ат‘амани хаза ва разаканихи мин гайри хаулин минни ва ля куввах',
    {
      'ru':
          'Хвала Аллаху, который накормил меня этим и наделил этим без моей силы и мощи.',
      'en':
          'Praise be to Allah who fed me this and provided it for me without any might or power from me.',
      'ar': 'الحمد لله الذي أطعمني هذا ورزقنيه من غير حول مني ولا قوة.',
    },
    'Абу Дауд 4023, ат-Тирмизи 3458',
    _daily,
  ),
  Dua.sunnah(
    {
      'ru': 'Выходя из дома',
      'en': 'Leaving home',
      'ar': 'عند الخروج من المنزل',
    },
    'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    'Бисмиллях, таваккальту ‘аля-Ллах, ва ля хауля ва ля куввата илля би-Ллях',
    {
      'ru':
          'С именем Аллаха, уповаю на Аллаха, нет мощи и силы ни у кого, кроме Аллаха.',
      'en':
          'In the name of Allah, I rely on Allah; there is no might nor power except with Allah.',
      'ar': 'بسم الله، توكلت على الله، ولا حول ولا قوة إلا بالله.',
    },
    'Абу Дауд 5095, ат-Тирмизи 3426',
    _daily,
  ),
  Dua.sunnah(
    {
      'ru': 'Входя в мечеть',
      'en': 'Entering the mosque',
      'ar': 'عند دخول المسجد',
    },
    'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
    'Аллахумма-фтах ли абваба рахматик',
    {
      'ru': 'О Аллах, открой мне врата Своей милости.',
      'en': 'O Allah, open for me the gates of Your mercy.',
      'ar': 'اللهم افتح لي أبواب رحمتك.',
    },
    'Муслим 713',
    _daily,
  ),
  Dua.sunnah(
    {
      'ru': 'Выходя из мечети',
      'en': 'Leaving the mosque',
      'ar': 'عند الخروج من المسجد',
    },
    'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
    'Аллахумма инни ас’алюка мин фадлик',
    {
      'ru': 'О Аллах, я прошу Тебя о Твоей щедрости.',
      'en': 'O Allah, I ask You of Your bounty.',
      'ar': 'اللهم إني أسألك من فضلك.',
    },
    'Муслим 713',
    _daily,
  ),
  Dua.quran(
    {
      'ru': 'О благе этого мира и вечного',
      'en': 'For good in this life and the next',
      'ar': 'خير الدنيا والآخرة',
    },
    '2:201',
    _quranic,
  ),
  Dua.quran(
    {'ru': 'О знании', 'en': 'For knowledge', 'ar': 'طلب العلم'},
    '20:114',
    _quranic,
  ),
  Dua.quran(
    {'ru': 'О родителях', 'en': 'For parents', 'ar': 'للوالدين'},
    '17:24',
    _quranic,
  ),
  Dua.quran(
    {'ru': 'О семье', 'en': 'For family', 'ar': 'للأسرة'},
    '25:74',
    _quranic,
  ),
  Dua.quran(
    {'ru': 'Покаяние Адама', 'en': 'Repentance of Adam', 'ar': 'توبة آدم'},
    '7:23',
    _quranic,
  ),
  Dua.quran(
    {
      'ru': 'О прощении себя, родителей и верующих',
      'en': 'Forgiveness for oneself, parents and believers',
      'ar': 'المغفرة للنفس والوالدين والمؤمنين',
    },
    '14:41',
    _quranic,
  ),
  Dua.quran(
    {
      'ru': 'Последние аяты суры «Корова»',
      'en': 'Last verses of al-Baqarah',
      'ar': 'خواتيم سورة البقرة',
    },
    '2:286',
    _quranic,
  ),
];

List<Tr> get duaGroups => const [_prayer, _morning, _daily, _quranic];

class HolyDate {
  const HolyDate(
    this.month,
    this.day,
    this.title,
    this.desc, {
    this.major = false,
  });
  final int month;
  final int day;
  final Tr title;
  final Tr desc;
  final bool major;
}

const holyDates = <HolyDate>[
  HolyDate(
    1,
    1,
    {
      'ru': 'Новый год по хиджре',
      'en': 'Islamic New Year',
      'ar': 'رأس السنة الهجرية',
    },
    {
      'ru':
          'Начало месяца Мухаррам. Память о переселении Пророка ﷺ из Мекки в Медину.',
      'en':
          'The start of Muharram, commemorating the Hijrah of the Prophet ﷺ from Makkah to Madinah.',
      'ar': 'بداية شهر محرم وذكرى هجرة النبي ﷺ من مكة إلى المدينة.',
    },
  ),
  HolyDate(
    1,
    10,
    {'ru': 'День Ашура', 'en': 'Day of Ashura', 'ar': 'يوم عاشوراء'},
    {
      'ru': 'Желательный пост 9 и 10 Мухаррама или 10 и 11 (Муслим 1134).',
      'en':
          'Recommended fasting on the 9th and 10th of Muharram, or the 10th and 11th (Muslim 1134).',
      'ar':
          'يستحب صيام التاسع والعاشر من محرم أو العاشر والحادي عشر (مسلم ١١٣٤).',
    },
  ),
  HolyDate(
    3,
    12,
    {'ru': 'Мавлид', 'en': 'Mawlid', 'ar': 'المولد النبوي'},
    {
      'ru':
          'Памятная дата рождения Пророка ﷺ. Многие мусульмане отмечают её чтением сиры и салаватами; часть учёных не считает её праздником.',
      'en':
          'The remembered birth of the Prophet ﷺ. Many Muslims mark it by reading the Seerah; some scholars do not consider it a festival.',
      'ar':
          'ذكرى مولد النبي ﷺ. يحييها كثير من المسلمين بقراءة السيرة، ولا يعدّها بعض العلماء عيداً.',
    },
  ),
  HolyDate(
    7,
    27,
    {
      'ru': 'Ночь Исра и Мирадж',
      'en': 'Isra and Miraj',
      'ar': 'الإسراء والمعراج',
    },
    {
      'ru':
          'Память о ночном путешествии Пророка ﷺ и вознесении, когда был предписан намаз (сура 17:1). Дата по распространённому мнению.',
      'en':
          'Remembering the Night Journey and Ascension, when prayer was prescribed (17:1). The date follows the common opinion.',
      'ar':
          'ذكرى الإسراء والمعراج حين فُرضت الصلاة (الإسراء ١). التاريخ وفق القول المشهور.',
    },
  ),
  HolyDate(
    8,
    15,
    {'ru': 'Середина Шаабана', 'en': 'Mid-Shaban', 'ar': 'ليلة النصف من شعبان'},
    {
      'ru':
          'Ночь Бараат. Многие проводят её в молитве и дуа; оценки учёных о её особенностях различаются.',
      'en':
          'Laylat al-Baraah. Many spend it in prayer and dua; scholarly views on its specifics differ.',
      'ar':
          'ليلة البراءة. يحييها كثيرون بالصلاة والدعاء، وتختلف آراء العلماء في خصائصها.',
    },
  ),
  HolyDate(
    9,
    1,
    {'ru': 'Начало Рамадана', 'en': 'Start of Ramadan', 'ar': 'بداية رمضان'},
    {
      'ru': 'Месяц обязательного поста и ниспослания Корана (сура 2:185).',
      'en':
          'The month of obligatory fasting in which the Quran was revealed (2:185).',
      'ar': 'شهر الصيام الذي أُنزل فيه القرآن (البقرة ١٨٥).',
    },
    major: true,
  ),
  HolyDate(
    9,
    27,
    {'ru': 'Ляйлят аль-Кадр', 'en': 'Laylat al-Qadr', 'ar': 'ليلة القدر'},
    {
      'ru':
          'Ночь предопределения лучше тысячи месяцев (сура 97). Её ищут в нечётные ночи последней декады Рамадана; 27-я — по распространённому мнению.',
      'en':
          'The Night of Decree is better than a thousand months (97). It is sought in the odd nights of the last ten; the 27th is a common view.',
      'ar':
          'ليلة القدر خير من ألف شهر (سورة القدر). تُلتمس في الوتر من العشر الأواخر، والسابع والعشرون قول مشهور.',
    },
  ),
  HolyDate(
    10,
    1,
    {'ru': 'Ураза-байрам', 'en': 'Eid al-Fitr', 'ar': 'عيد الفطر'},
    {
      'ru':
          'Праздник разговения. До праздничного намаза выплачивается закят аль-фитр.',
      'en':
          'The festival of breaking the fast. Zakat al-Fitr is paid before the Eid prayer.',
      'ar': 'عيد الفطر. تُخرج زكاة الفطر قبل صلاة العيد.',
    },
    major: true,
  ),
  HolyDate(
    12,
    9,
    {'ru': 'День Арафа', 'en': 'Day of Arafah', 'ar': 'يوم عرفة'},
    {
      'ru':
          'Главный день хаджа. Для не совершающих хадж желателен пост (Муслим 1162).',
      'en':
          'The central day of Hajj. Fasting is recommended for those not on Hajj (Muslim 1162).',
      'ar': 'ركن الحج الأعظم. يستحب صيامه لغير الحاج (مسلم ١١٦٢).',
    },
  ),
  HolyDate(
    12,
    10,
    {'ru': 'Курбан-байрам', 'en': 'Eid al-Adha', 'ar': 'عيد الأضحى'},
    {
      'ru':
          'Праздник жертвоприношения в память о пророке Ибрахиме (мир ему). Длится четыре дня.',
      'en':
          'The festival of sacrifice remembering Prophet Ibrahim (peace be upon him). It lasts four days.',
      'ar': 'عيد الأضحى إحياءً لسنة إبراهيم عليه السلام، ويمتد أربعة أيام.',
    },
    major: true,
  ),
];
