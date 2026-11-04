import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/assistant.dart' show aiEndpoint;
import '../services/location.dart';
import '../services/places.dart';
import '../services/hijri.dart' show gregorianDate;
import '../theme.dart';
import '../widgets/location_error.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _map = MapController();
  List<Place> _places = [];
  bool _loading = false;
  String? _error;
  bool _mosques = true, _halal = true;
  String? _centerKey;
  bool _loadedOnce = false;
  bool _locating = false;

  /// Кнопка «моё местоположение»: берём GPS и переносим карту.
  /// Перенос и загрузку мест делает обработчик смены координат в build.
  Future<void> _locateMe() async {
    final messenger = ScaffoldMessenger.of(context);
    final l = L10nScope.of(context);
    final s = AppScope.read(context);
    setState(() => _locating = true);
    final r = await locate();
    if (!mounted) return;
    setState(() => _locating = false);
    if (r.error != null) {
      showLocationError(messenger, l, r.error!);
      return;
    }
    final same = s.useGps && s.lat == r.lat && s.lng == r.lng;
    s.setGps(r.lat!, r.lng!);
    if (same) {
      _map.move(LatLng(r.lat!, r.lng!), 14);
      _load();
    }
  }

  Future<void> _load() async {
    final b = _map.camera.visibleBounds;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final (r, err) = await PlacesService.fetchAll(
        b.south,
        b.west,
        b.north,
        b.east,
      );
      if (mounted) {
        setState(() {
          _places = r;
          _loadedOnce = true;
          if (err != null) _error = 'net_error';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'net_error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final center = LatLng(s.lat, s.lng);
    // Город сменился в настройках — переносим карту.
    final key = '${s.lat},${s.lng}';
    if (_centerKey != null && _centerKey != key) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _map.move(center, 13);
        _load();
      });
    }
    _centerKey = key;
    final visible = _places
        .where((p) => p.kind == PlaceKind.mosque ? _mosques : _halal)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.t('tab_map'))),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13,
              onMapReady: _load,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'ru.imam.app',
              ),
              MarkerLayer(
                markers: [
                  for (final p in visible)
                    Marker(
                      point: LatLng(p.lat, p.lng),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _details(context, p),
                        child: Container(
                          decoration: BoxDecoration(
                            color: p.kind == PlaceKind.mosque
                                ? Palette.emerald
                                : Palette.gold,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(blurRadius: 4, color: Colors.black26),
                            ],
                          ),
                          child: Icon(
                            p.kind == PlaceKind.mosque
                                ? Icons.mosque
                                : Icons.restaurant,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  for (final p in visible.where((p) => p.certified))
                    Marker(
                      point: LatLng(p.lat, p.lng),
                      width: 40,
                      height: 40,
                      alignment: const Alignment(-0.6, 0.6),
                      child: IgnorePointer(
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              RichAttributionWidget(
                attributions: [TextSourceAttribution(l.t('osm_credit'))],
              ),
            ],
          ),
          PositionedDirectional(
            top: 8,
            start: 12,
            end: 12,
            child: Row(
              children: [
                FilterChip(
                  avatar: const Icon(Icons.mosque, size: 18),
                  label: Text(l.t('mosques')),
                  selected: _mosques,
                  onSelected: (v) => setState(() => _mosques = v),
                  backgroundColor: scheme.surface,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  avatar: const Icon(Icons.restaurant, size: 18),
                  label: Text(l.t('halal')),
                  selected: _halal,
                  onSelected: (v) => setState(() => _halal = v),
                  backgroundColor: scheme.surface,
                ),
                const Spacer(),
                if (_loading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
              ],
            ),
          ),
          if (_error != null || (!_loading && _loadedOnce && visible.isEmpty))
            PositionedDirectional(
              top: 60,
              start: 12,
              end: 12,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l.t(_error ?? 'nothing_found'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          PositionedDirectional(
            bottom: 24,
            start: 0,
            end: 0,
            child: Center(
              child: FilledButton.icon(
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.search),
                label: Text(l.t('refresh_area')),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 132,
            end: 12,
            child: FloatingActionButton.small(
              heroTag: 'locate',
              tooltip: l.t('use_gps'),
              onPressed: _locating ? null : _locateMe,
              child: _locating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),
          PositionedDirectional(
            bottom: 80,
            end: 12,
            child: FloatingActionButton.small(
              heroTag: 'suggest',
              tooltip: l.t('suggest_place'),
              onPressed: () {
                final c = _map.camera.center;
                _suggest(
                  context,
                  PlaceSuggestion(
                    kind: PlaceKind.halal,
                    name: '',
                    lat: c.latitude,
                    lng: c.longitude,
                  ),
                );
              },
              child: const Icon(Icons.add_location_alt_outlined),
            ),
          ),
          // Перекрестие: заявка отмечает центр карты.
          const IgnorePointer(
            child: Center(
              child: Icon(Icons.add, size: 28, color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }

  void _details(BuildContext context, Place p) {
    final l = L10nScope.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.name.isEmpty
                    ? l.t(p.kind == PlaceKind.mosque ? 'mosques' : 'halal')
                    : p.name,
                style: Theme.of(
                  ctx,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (p.address != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(p.address!),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l.t('hours')}: ${p.hours ?? l.t('hours_unknown')}',
                    ),
                  ),
                ],
              ),
              if (p.certificate != null) ...[
                const SizedBox(height: 12),
                _CertificateBlock(p.certificate!),
              ] else if (p.kind == PlaceKind.halal) ...[
                const SizedBox(height: 12),
                Text(
                  l.t('halal_unverified'),
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
              ],
              if (p.fromCatalog && p.checked != null) ...[
                const SizedBox(height: 6),
                Text(
                  l
                      .t('catalog_checked')
                      .replaceAll(
                        '{date}',
                        gregorianDate(p.checked!, l, (x) => x),
                      ),
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.directions),
                label: Text(l.t('route')),
                onPressed: () => launchUrl(
                  Uri.parse(
                    'https://yandex.ru/maps/?rtext=~${p.lat},${p.lng}&rtt=auto',
                  ),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.flag_outlined),
                label: Text(l.t('report_error')),
                onPressed: () {
                  Navigator.pop(ctx);
                  _suggest(
                    context,
                    PlaceSuggestion(
                      kind: p.kind,
                      name: p.name,
                      lat: p.lat,
                      lng: p.lng,
                      address: p.address ?? '',
                      osmId: p.osmId,
                      isCorrection: true,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _suggest(BuildContext context, PlaceSuggestion base) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _SuggestSheet(base: base),
    );
  }
}

class _CertificateBlock extends StatelessWidget {
  const _CertificateBlock(this.c);
  final Certificate c;

  @override
  Widget build(BuildContext context) {
    final l = L10nScope.of(context);
    final ok = !c.expired;
    final color = ok
        ? Colors.green.shade700
        : Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ok ? Icons.verified : Icons.warning_amber, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.t(ok ? 'cert_badge' : 'cert_expired'),
                  style: TextStyle(fontWeight: FontWeight.w700, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    c.issuer,
                    ?c.number,
                    if (c.until != null)
                      '${l.t('cert_until')} ${gregorianDate(c.until!, l, (x) => x)}',
                  ].join(' · '),
                ),
                if (c.url != null)
                  TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () => launchUrl(
                      Uri.parse(c.url!),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(l.t('cert_check')),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestSheet extends StatefulWidget {
  const _SuggestSheet({required this.base});
  final PlaceSuggestion base;

  @override
  State<_SuggestSheet> createState() => _SuggestSheetState();
}

class _SuggestSheetState extends State<_SuggestSheet> {
  late PlaceKind _kind = widget.base.kind;
  late final _name = TextEditingController(text: widget.base.name);
  late final _address = TextEditingController(text: widget.base.address);
  final _cert = TextEditingController();
  final _comment = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    for (final c in [_name, _address, _cert, _comment]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _send() async {
    final l = L10nScope.of(context);
    final b = widget.base;
    final s = PlaceSuggestion(
      kind: _kind,
      name: _name.text.trim(),
      lat: b.lat,
      lng: b.lng,
      address: _address.text.trim(),
      certificate: _cert.text.trim(),
      comment: _comment.text.trim(),
      osmId: b.osmId,
      isCorrection: b.isCorrection,
    );
    setState(() => _sending = true);
    var sent = false;
    if (aiEndpoint.isNotEmpty) {
      try {
        final r = await http
            .post(
              Uri.parse('$aiEndpoint/suggest'),
              headers: {'content-type': 'application/json'},
              body: jsonEncode(s.toJson()),
            )
            .timeout(const Duration(seconds: 20));
        sent = r.statusCode == 200;
      } catch (_) {}
    }
    if (!sent) {
      // Сервера нет — открываем форму заявки на GitHub.
      sent = await launchUrl(
        s.githubIssueUrl(),
        mode: LaunchMode.externalApplication,
      );
    }
    if (!mounted) return;
    setState(() => _sending = false);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(content: Text(l.t(sent ? 'suggest_sent' : 'net_error'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L10nScope.of(context);
    final b = widget.base;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.t(b.isCorrection ? 'report_error' : 'suggest_place'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              l.t(b.isCorrection ? 'report_hint' : 'suggest_hint'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SegmentedButton<PlaceKind>(
              segments: [
                ButtonSegment(
                  value: PlaceKind.halal,
                  icon: const Icon(Icons.restaurant),
                  label: Text(l.t('halal')),
                ),
                ButtonSegment(
                  value: PlaceKind.mosque,
                  icon: const Icon(Icons.mosque),
                  label: Text(l.t('mosques')),
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (v) => setState(() => _kind = v.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              maxLength: 120,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: l.t('suggest_name')),
            ),
            TextField(
              controller: _address,
              maxLength: 200,
              decoration: InputDecoration(labelText: l.t('suggest_address')),
            ),
            if (_kind == PlaceKind.halal)
              TextField(
                controller: _cert,
                maxLength: 200,
                decoration: InputDecoration(labelText: l.t('suggest_cert')),
              ),
            TextField(
              controller: _comment,
              maxLength: 500,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(labelText: l.t('suggest_comment')),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _sending || _name.text.trim().isEmpty ? null : _send,
              child: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l.t('suggest_send')),
            ),
          ],
        ),
      ),
    );
  }
}
