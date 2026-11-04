import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../app_state.dart';
import '../data/cities.dart';
import '../l10n.dart';
import '../services/notifications.dart';
import '../services/quran.dart';
import 'prayer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.t('language')),
            subtitle: Text(L10n.names[l.lang]!),
            onTap: () => _pick<String>(
              context,
              l.t('language'),
              L10n.supported,
              (c) => L10n.names[c]!,
              l.lang,
              (v) async {
                s.lang = v;
                await QuranRepo.instance.ensureTranslation(s.quranTr);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(l.t('translation')),
            subtitle: Text(
              '${L10n.names[s.quranTr]} — ${QuranRepo.translators[s.quranTr]}',
            ),
            onTap: () => _pick<String>(
              context,
              l.t('translation'),
              QuranRepo.translators.keys.toList(),
              (c) => '${L10n.names[c]} — ${QuranRepo.translators[c]}',
              s.quranTr,
              (v) async {
                await QuranRepo.instance.ensureTranslation(v);
                s.quranTr = v;
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_city),
            title: Text(l.t('location')),
            subtitle: Text(s.placeName(l)),
            onTap: () => _pick<String>(
              context,
              l.t('location'),
              cities.map((c) => c.id).toList(),
              (id) => cities.firstWhere((c) => c.id == id).name(l.lang),
              s.useGps ? null : s.cityId,
              (v) => s.setCity(v),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.my_location),
            title: Text(l.t('use_gps')),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                var perm = await Geolocator.checkPermission();
                if (perm == LocationPermission.denied)
                  perm = await Geolocator.requestPermission();
                if (perm == LocationPermission.denied ||
                    perm == LocationPermission.deniedForever)
                  throw Exception();
                final p = await Geolocator.getCurrentPosition(
                  locationSettings: const LocationSettings(
                    accuracy: LocationAccuracy.low,
                  ),
                );
                s.setGps(p.latitude, p.longitude);
              } catch (_) {
                messenger.showSnackBar(
                  SnackBar(content: Text(l.t('gps_denied'))),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: Text(l.t('method')),
            subtitle: Text(methodLabel(s.method, l.lang)),
            onTap: () => _pick<PrayerMethod>(
              context,
              l.t('method'),
              PrayerMethod.values,
              (m) => methodLabel(m, l.lang),
              s.method,
              (v) => s.method = v,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.wb_sunny_outlined),
            title: Text(l.t('madhab')),
            subtitle: Text(l.t(s.hanafi ? 'hanafi' : 'shafii')),
            onTap: () => _pick<bool>(
              context,
              l.t('madhab'),
              const [true, false],
              (v) => l.t(v ? 'hanafi' : 'shafii'),
              s.hanafi,
              (v) => s.hanafi = v,
            ),
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: Text(l.t('dark_theme')),
            value: s.dark,
            onChanged: (v) => s.dark = v,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.text_increase),
            title: Text(l.t('large_text')),
            value: s.largeText,
            onChanged: (v) => s.largeText = v,
          ),
          if (l.lang == 'ar')
            SwitchListTile(
              secondary: const Icon(Icons.pin_outlined),
              title: Text(l.t('arabic_digits')),
              value: s.arabicDigits,
              onChanged: (v) => s.arabicDigits = v,
            ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: Text(l.t('azan_notify')),
            subtitle: Text(
              AzanNotifications.supported
                  ? l.t('azan_notify_sub')
                  : l.t('azan_mobile_only'),
            ),
            value: s.azanEnabled,
            onChanged: AzanNotifications.supported
                ? (v) async {
                    if (v && !await AzanNotifications.requestPermission()) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.t('azan_denied'))),
                        );
                      }
                      return;
                    }
                    s.azanEnabled = v;
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.child_care),
            title: Text(l.t('kids_mode')),
            value: s.kidsMode,
            onChanged: (v) => s.kidsMode = v,
          ),
        ],
      ),
    );
  }

  void _pick<T>(
    BuildContext context,
    String title,
    List<T> values,
    String Function(T) label,
    T? current,
    void Function(T) onPick,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.7,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(title, style: Theme.of(ctx).textTheme.titleMedium),
              ),
              for (final v in values)
                ListTile(
                  title: Text(label(v)),
                  trailing: v == current
                      ? Icon(
                          Icons.check,
                          color: Theme.of(ctx).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    onPick(v);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
