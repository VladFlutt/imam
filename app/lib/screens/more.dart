import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../widgets/common.dart';
import 'assistant.dart';
import 'calendar.dart';
import 'duas.dart';
import 'qibla.dart';
import 'settings.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final items = <(IconData, String, Widget)>[
      (Icons.calendar_month_outlined, 'calendar', const CalendarScreen()),
      (Icons.volunteer_activism_outlined, 'duas', const DuasScreen()),
      (Icons.radio_button_checked, 'tasbih', const TasbihScreen()),
      (Icons.explore_outlined, 'qibla', const QiblaScreen()),
      if (!s.kidsMode)
        (Icons.chat_bubble_outline, 'assistant', const AssistantScreen()),
      (Icons.settings_outlined, 'settings', const SettingsScreen()),
      (Icons.info_outline, 'about', const AboutScreen()),
    ];
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.t('tab_more'))),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final (icon, key, screen) = items[i];
          return Card(
            child: ListTile(
              leading: Icon(icon, color: scheme.primary),
              title: Text(
                l.t(key),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => screen),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10nScope.of(context);
    const sources = [
      'Коран: текст Uthmani и переводы — Tanzil.net (через quran-json, CC BY-SA 4.0, и @ghoran/translation)',
      'Переводы: Э. Кулиев (рус.), Saheeh International (англ.), Якуб ибн Нугман (тат.), М. Содик М. Юсуф (узб.), А. Ояти (тадж.), Мамедалиев и Бунятов (азерб.)',
      'Время намаза: библиотека adhan_dart (MIT), метод ДУМ РФ 16°/15° по умолчанию',
      'Календарь хиджры: Умм аль-Кура, пакет hijri (MIT)',
      'Мечети и халяль: © участники OpenStreetMap (ODbL)',
      'Шрифты: Amiri Quran, Amiri, Noto Naskh Arabic, Noto Sans (SIL OFL)',
      'Хадисы: аль-Бухари, Муслим, ат-Тирмизи, Абу Дауд (номера по нумерации Fuad Abd al-Baqi / Dar al-Salam)',
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.t('about'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l.t('about_text'), style: const TextStyle(height: 1.5)),
          SectionTitle(l.t('sources')),
          for (final s in sources)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(child: Text(s)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'v0.1.0 · прототип',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
