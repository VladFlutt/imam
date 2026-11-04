// Тексты первого запуска: выбор языка и знакомство с приложением.
// На всех поддерживаемых языках; тексты на языках СНГ перед релизом
// нужно вычитать носителям языка.

const onboardingStrings = <String, Map<String, String>>{
  'ru': {
    'onb_choose_lang': 'Выберите язык',
    'onb_lang_later': 'Язык можно изменить в любой момент в Настройках.',
    'onb_continue': 'Продолжить',
    'onb_skip': 'Пропустить',
    'onb_next': 'Далее',
    'onb_start': 'Начать',
    'onb_show_again': 'Показать знакомство с приложением',
    'onb1_title': 'Ассаляму алейкум!',
    'onb1_body':
        'Имам — справочник мусульманина на каждый день: намаз, Коран, календарь и всё нужное в одном месте.',
    'onb2_title': 'Время намаза и Кибла',
    'onb2_body':
        'Точное время намаза для вашего города, направление на Каабу и напоминания об азане.',
    'onb3_title': 'Коран, хадисы и дуа',
    'onb3_body':
        'Арабский текст с переводом смыслов, 40 хадисов ан-Навави и дуа с транскрипцией.',
    'onb4_title': 'Мечети и халяль рядом',
    'onb4_body':
        'Ближайшие мечети, халяльные магазины и рестораны на карте, исламский календарь с праздниками.',
    'onb5_title': 'Помощник с опорой на источники',
    'onb5_body':
        'Отвечает со ссылками на аяты Корана и хадисы. Это не фетва: в сложных вопросах обратитесь к имаму.',
  },
  'en': {
    'onb_choose_lang': 'Choose your language',
    'onb_lang_later': 'You can change the language at any time in Settings.',
    'onb_continue': 'Continue',
    'onb_skip': 'Skip',
    'onb_next': 'Next',
    'onb_start': 'Get started',
    'onb_show_again': 'Show the app introduction',
    'onb1_title': 'Assalamu alaykum!',
    'onb1_body':
        'Imam is an everyday guide for Muslims: prayer, Quran, calendar and everything you need in one place.',
    'onb2_title': 'Prayer times and Qibla',
    'onb2_body':
        'Accurate prayer times for your city, the direction of the Kaaba and adhan reminders.',
    'onb3_title': 'Quran, hadith and duas',
    'onb3_body':
        'Arabic text with a translation of the meanings, an-Nawawi\'s 40 hadith and duas with transliteration.',
    'onb4_title': 'Mosques and halal nearby',
    'onb4_body':
        'Nearby mosques, halal shops and restaurants on the map, plus the Islamic calendar of holidays.',
    'onb5_title': 'An assistant grounded in sources',
    'onb5_body':
        'Answers cite verses of the Quran and hadith. It is not a fatwa: for complex questions, consult an imam.',
  },
  'ar': {
    'onb_choose_lang': 'اختر اللغة',
    'onb_lang_later': 'يمكنك تغيير اللغة في أي وقت من الإعدادات.',
    'onb_continue': 'متابعة',
    'onb_skip': 'تخطٍّ',
    'onb_next': 'التالي',
    'onb_start': 'ابدأ',
    'onb_show_again': 'عرض التعريف بالتطبيق',
    'onb1_title': 'السلام عليكم!',
    'onb1_body':
        '«إمام» دليل يومي للمسلم: الصلاة والقرآن والتقويم وكل ما تحتاجه في مكان واحد.',
    'onb2_title': 'مواقيت الصلاة والقبلة',
    'onb2_body':
        'مواقيت دقيقة للصلاة في مدينتك، واتجاه الكعبة، وتذكير بالأذان.',
    'onb3_title': 'القرآن والحديث والأدعية',
    'onb3_body':
        'النص العربي مع ترجمة المعاني، والأربعون النووية، والأدعية المأثورة.',
    'onb4_title': 'المساجد والحلال بالقرب منك',
    'onb4_body':
        'أقرب المساجد والمتاجر والمطاعم الحلال على الخريطة، والتقويم الهجري بالمناسبات.',
    'onb5_title': 'مساعد يستند إلى المصادر',
    'onb5_body':
        'يجيب مع ذكر الآيات والأحاديث. وليس ذلك فتوى: في المسائل الدقيقة ارجع إلى إمام أو عالم.',
  },
  'tt': {
    'onb_choose_lang': 'Телне сайлагыз',
    'onb_lang_later': 'Телне теләсә кайчан Көйләүләрдә алыштырып була.',
    'onb_continue': 'Дәвам итү',
    'onb_skip': 'Калдыру',
    'onb_next': 'Алга',
    'onb_start': 'Башлау',
    'onb_show_again': 'Кушымта белән танышуны күрсәтү',
    'onb1_title': 'Әссәләмү галәйкүм!',
    'onb1_body':
        'Имам — мөселман өчен көндәлек белешмә: намаз, Коръән, календарь һәм кирәкле бар нәрсә бер урында.',
    'onb2_title': 'Намаз вакытлары һәм Кыйбла',
    'onb2_body':
        'Шәһәрегез өчен төгәл намаз вакытлары, Кәгъбә юнәлеше һәм азан турында искәртүләр.',
    'onb3_title': 'Коръән, хәдисләр һәм догалар',
    'onb3_body':
        'Гарәп тексты һәм мәгънәләр тәрҗемәсе, ән-Нәвәвинең 40 хәдисе, транскрипцияле догалар.',
    'onb4_title': 'Якындагы мәчетләр һәм хәләл',
    'onb4_body':
        'Харитада якындагы мәчетләр, хәләл кибетләр һәм рестораннар, бәйрәмнәр белән ислам календаре.',
    'onb5_title': 'Чыганакларга таянган ярдәмче',
    'onb5_body':
        'Җавапларда Коръән аятьләренә һәм хәдисләргә сылтамалар бар. Бу фәтва түгел: катлаулы сорауларда имамга мөрәҗәгать итегез.',
  },
  'uz': {
    'onb_choose_lang': 'Tilni tanlang',
    'onb_lang_later': 'Tilni istalgan vaqtda Sozlamalarda oʻzgartirish mumkin.',
    'onb_continue': 'Davom etish',
    'onb_skip': 'Oʻtkazib yuborish',
    'onb_next': 'Keyingi',
    'onb_start': 'Boshlash',
    'onb_show_again': 'Ilova bilan tanishuvni koʻrsatish',
    'onb1_title': 'Assalomu alaykum!',
    'onb1_body':
        'Imom — musulmon uchun har kunlik qoʻllanma: namoz, Qurʼon, taqvim va kerakli hamma narsa bir joyda.',
    'onb2_title': 'Namoz vaqtlari va Qibla',
    'onb2_body':
        'Shahringiz uchun aniq namoz vaqtlari, Kaʼba yoʻnalishi va azon eslatmalari.',
    'onb3_title': 'Qurʼon, hadislar va duolar',
    'onb3_body':
        'Arabcha matn va maʼnolar tarjimasi, an-Navaviyning 40 hadisi, transkripsiyali duolar.',
    'onb4_title': 'Yaqin masjidlar va halol',
    'onb4_body':
        'Xaritada yaqin masjidlar, halol doʻkonlar va restoranlar, bayramlar bilan islomiy taqvim.',
    'onb5_title': 'Manbalarga tayangan yordamchi',
    'onb5_body':
        'Javoblarda Qurʼon oyatlari va hadislarga havolalar beriladi. Bu fatvo emas: murakkab savollarda imomga murojaat qiling.',
  },
  'kk': {
    'onb_choose_lang': 'Тілді таңдаңыз',
    'onb_lang_later': 'Тілді кез келген уақытта Баптауларда өзгертуге болады.',
    'onb_continue': 'Жалғастыру',
    'onb_skip': 'Өткізіп жіберу',
    'onb_next': 'Келесі',
    'onb_start': 'Бастау',
    'onb_show_again': 'Қолданбамен танысуды көрсету',
    'onb1_title': 'Ассаламу алейкум!',
    'onb1_body':
        'Имам — мұсылманға арналған күнделікті анықтамалық: намаз, Құран, күнтізбе және қажеттінің бәрі бір жерде.',
    'onb2_title': 'Намаз уақыттары және Құбыла',
    'onb2_body':
        'Қалаңыз үшін нақты намаз уақыттары, Қағба бағыты және азан туралы еске салғыштар.',
    'onb3_title': 'Құран, хадистер және дұғалар',
    'onb3_body':
        'Арабша мәтін мен мағына аудармасы, ән-Нәуәуидің 40 хадисі, транскрипциясы бар дұғалар.',
    'onb4_title': 'Жақын маңдағы мешіттер мен халал',
    'onb4_body':
        'Картада жақын мешіттер, халал дүкендер мен мейрамханалар, мерекелері бар ислам күнтізбесі.',
    'onb5_title': 'Дереккөздерге сүйенетін көмекші',
    'onb5_body':
        'Жауаптарда Құран аяттары мен хадистерге сілтемелер беріледі. Бұл пәтуа емес: күрделі сұрақтарда имамға жүгініңіз.',
  },
  'ky': {
    'onb_choose_lang': 'Тилди тандаңыз',
    'onb_lang_later': 'Тилди каалаган убакта Жөндөөлөрдөн өзгөртсөңүз болот.',
    'onb_continue': 'Улантуу',
    'onb_skip': 'Өткөрүп жиберүү',
    'onb_next': 'Кийинки',
    'onb_start': 'Баштоо',
    'onb_show_again': 'Колдонмо менен таанышууну көрсөтүү',
    'onb1_title': 'Ассалому алейкум!',
    'onb1_body':
        'Имам — мусулман үчүн күнүмдүк маалымдама: намаз, Куран, календарь жана керектүүнүн баары бир жерде.',
    'onb2_title': 'Намаз убактылары жана Кыбла',
    'onb2_body':
        'Шаарыңыз үчүн так намаз убактылары, Кааба багыты жана азан эскертмелери.',
    'onb3_title': 'Куран, хадистер жана дубалар',
    'onb3_body':
        'Арабча текст жана маанилердин котормосу, ан-Нававинин 40 хадиси, транскрипциясы менен дубалар.',
    'onb4_title': 'Жакын жердеги мечиттер жана адал',
    'onb4_body':
        'Картада жакын мечиттер, адал дүкөндөр жана ресторандар, майрамдары менен ислам календары.',
    'onb5_title': 'Булактарга таянган жардамчы',
    'onb5_body':
        'Жоопторда Курандын аяттарына жана хадистерге шилтемелер берилет. Бул фатва эмес: татаал суроолордо имамга кайрылыңыз.',
  },
  'tg': {
    'onb_choose_lang': 'Забонро интихоб кунед',
    'onb_lang_later':
        'Забонро дар вақти дилхоҳ дар Танзимот иваз кардан мумкин аст.',
    'onb_continue': 'Идома',
    'onb_skip': 'Гузаштан',
    'onb_next': 'Баъдӣ',
    'onb_start': 'Оғоз',
    'onb_show_again': 'Шиносоӣ бо барномаро нишон додан',
    'onb1_title': 'Ассалому алайкум!',
    'onb1_body':
        'Имом — дастури ҳаррӯзаи мусулмон: намоз, Қуръон, тақвим ва ҳар чизи зарурӣ дар як ҷо.',
    'onb2_title': 'Вақти намоз ва Қибла',
    'onb2_body':
        'Вақти дақиқи намоз барои шаҳри шумо, самти Каъба ва ёдраскуниҳои азон.',
    'onb3_title': 'Қуръон, ҳадисҳо ва дуоҳо',
    'onb3_body':
        'Матни арабӣ бо тарҷумаи маъноҳо, 40 ҳадиси ан-Нававӣ ва дуоҳо бо транскрипсия.',
    'onb4_title': 'Масҷидҳо ва ҳалол дар наздикӣ',
    'onb4_body':
        'Масҷидҳои наздик, мағозаҳо ва тарабхонаҳои ҳалол дар харита, тақвими исломӣ бо идҳо.',
    'onb5_title': 'Ёваре, ки ба манбаъҳо такя мекунад',
    'onb5_body':
        'Ҷавобҳо бо истинод ба оятҳои Қуръон ва ҳадисҳо дода мешаванд. Ин фатво нест: дар масъалаҳои душвор ба имом муроҷиат кунед.',
  },
  'az': {
    'onb_choose_lang': 'Dili seçin',
    'onb_lang_later': 'Dili istənilən vaxt Ayarlarda dəyişə bilərsiniz.',
    'onb_continue': 'Davam et',
    'onb_skip': 'Keç',
    'onb_next': 'Növbəti',
    'onb_start': 'Başla',
    'onb_show_again': 'Tətbiqlə tanışlığı göstər',
    'onb1_title': 'Əssəlamu aleykum!',
    'onb1_body':
        'İmam — müsəlman üçün gündəlik bələdçi: namaz, Quran, təqvim və lazım olan hər şey bir yerdə.',
    'onb2_title': 'Namaz vaxtları və Qiblə',
    'onb2_body':
        'Şəhəriniz üçün dəqiq namaz vaxtları, Kəbənin istiqaməti və azan xatırlatmaları.',
    'onb3_title': 'Quran, hədislər və dualar',
    'onb3_body':
        'Ərəbcə mətn və mənaların tərcüməsi, ən-Nəvəvinin 40 hədisi, transkripsiyalı dualar.',
    'onb4_title': 'Yaxındakı məscidlər və halal',
    'onb4_body':
        'Xəritədə yaxın məscidlər, halal mağazalar və restoranlar, bayramlarla İslam təqvimi.',
    'onb5_title': 'Mənbələrə əsaslanan köməkçi',
    'onb5_body':
        'Cavablarda Quran ayələrinə və hədislərə istinad verilir. Bu fətva deyil: mürəkkəb suallarda imama müraciət edin.',
  },
};
