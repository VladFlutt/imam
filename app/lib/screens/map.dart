import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/places.dart';
import '../theme.dart';

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

  Future<void> _load() async {
    final b = _map.camera.visibleBounds;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await PlacesService.fetch(b.south, b.west, b.north, b.east);
      if (mounted) {
        setState(() {
          _places = r;
          _loadedOnce = true;
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
              if (p.kind == PlaceKind.halal) ...[
                const SizedBox(height: 12),
                Text(
                  l.t('halal_unverified'),
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
            ],
          ),
        ),
      ),
    );
  }
}
