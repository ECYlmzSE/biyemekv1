import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../providers/restaurant_provider.dart';
import '../theme/app_theme.dart';
import 'address_detail_screen.dart';
import '../services/turkey_geo_data.dart';

// ── Google Maps API Key ──────────────────────────────────────
// Hem burada hem AndroidManifest.xml'de aynı key kullanılmalı
const String _kGoogleApiKey = 'AIzaSyB8voNd5dgCVAGQpVIQJCt5CPdk3FZhoTY';

// ─────────────────────────────────────────────────────────────
//  MAIN ADDRESS SCREEN
// ─────────────────────────────────────────────────────────────
class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Teslimat Adresi')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGreen,
        onPressed: () => _startAddFlow(context),
        icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
        label: const Text('Yeni Adres Ekle',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: auth.addresses.isEmpty
          ? _emptyState(context)
          : ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 100), children: [
              Text('Kayıtlı Adreslerim',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: theme.brightness == Brightness.dark
                          ? AppTheme.darkSubtext : AppTheme.grey)),
              const SizedBox(height: 10),
              ...auth.addresses.asMap().entries.map((e) => _AddressTile(
                address: e.value,
                isSelected: auth.selectedAddress?.id == e.value.id,
                onSelect: () {
                  auth.selectAddress(e.key);
                  context.read<RestaurantProvider>().setCity(e.value.city);
                  Navigator.pop(context);
                },
                onEdit: () => _editAddress(context, e.value),
                onDelete: () => auth.deleteAddress(e.value.id),
              )),
            ]),
    );
  }

  Widget _emptyState(BuildContext ctx) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
        child: const Icon(Icons.location_off_outlined, size: 52, color: AppTheme.primaryGreen)),
      const SizedBox(height: 20),
      const Text('Henüz adres eklemediniz',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Haritadan konumunuzu seçerek hızlıca adres ekleyin',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.grey, fontSize: 14)),
      const SizedBox(height: 28),
      ElevatedButton.icon(
        onPressed: () => _startAddFlow(ctx),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Adres Ekle'),
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
      ),
    ]),
  );

  void _startAddFlow(BuildContext ctx) {
    Navigator.of(ctx)
        .push(MaterialPageRoute(builder: (_) => const MapPickerScreen()))
        .then((result) {
      if (result != null && ctx.mounted) {
        final r = result as Map<String, dynamic>;
        Navigator.of(ctx).push(MaterialPageRoute(
          builder: (_) => AddressDetailScreen(
            lat: (r['lat'] as num?)?.toDouble() ?? 0.0,
            lng: (r['lng'] as num?)?.toDouble() ?? 0.0,
            city: r['city'] ?? '',
            district: r['district'] ?? '',
            neighborhood: r['neighborhood'] ?? '',
            street: r['road'] ?? r['street'] ?? '',
          ),
        ));
      }
    });
  }

  void _editAddress(BuildContext ctx, UserAddress e) {
    Navigator.of(ctx).push(MaterialPageRoute(
        builder: (_) => AddressFormScreen(existing: e)));
  }
}

// ─────────────────────────────────────────────────────────────
//  ADDRESS TILE
// ─────────────────────────────────────────────────────────────
class _AddressTile extends StatelessWidget {
  final UserAddress address;
  final bool isSelected;
  final VoidCallback onSelect, onEdit, onDelete;
  const _AddressTile({required this.address, required this.isSelected,
      required this.onSelect, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withOpacity(0.09) : theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected ? AppTheme.primaryGreen : theme.dividerColor,
              width: isSelected ? 1.5 : 1)),
        child: Row(children: [
          Icon(_icon(address.title),
              color: isSelected ? AppTheme.primaryGreen : AppTheme.grey, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(address.title, style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14,
                color: isSelected ? AppTheme.primaryGreen : null)),
            const SizedBox(height: 2),
            Text(address.displayAddress,
                style: const TextStyle(color: AppTheme.grey, fontSize: 12),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            if (address.lat != null)
              const Padding(padding: EdgeInsets.only(top: 3), child: Row(children: [
                Icon(Icons.gps_fixed, size: 10, color: AppTheme.primaryGreen),
                SizedBox(width: 3),
                Text('GPS kayıtlı', style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen)),
              ])),
          ])),
          IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.grey),
              onPressed: onEdit, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 4),
          if (!isSelected)
            IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.red),
                onPressed: onDelete, padding: EdgeInsets.zero, constraints: const BoxConstraints())
          else
            const Padding(padding: EdgeInsets.all(8),
                child: Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 20)),
        ]),
      ),
    );
  }

  IconData _icon(String t) {
    final l = t.toLowerCase();
    if (l.contains('ev') || l.contains('home')) return Icons.home_outlined;
    if (l.contains('iş') || l.contains('ofis')) return Icons.work_outline;
    if (l.contains('okul')) return Icons.school_outlined;
    return Icons.location_on_outlined;
  }
}

// ─────────────────────────────────────────────────────────────
//  MAP PICKER SCREEN  (Google Maps + Places API via HTTP)
// ─────────────────────────────────────────────────────────────
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});
  @override State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final _mapCtrl = MapController();
  final _searchCtrl = TextEditingController();

  LatLng _center = const LatLng(39.9255, 32.8663);
  LatLng? _pinned;
  String? _label;
  bool _loadingLoc = false, _denied = false;

  // Places autocomplete via HTTP
  List<Map<String, dynamic>> _predictions = [];
  bool _loadingSearch = false;
  Timer? _debounce;
  String _sessionToken = '';

  @override
  void initState() {
    super.initState();
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
    _searchCtrl.addListener(_onSearchChanged);
    _tryLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _mapCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      setState(() => _predictions = []);
      if (_pinned != null) _reverseGeocode(_pinned!);
      return;
    }
    if (q.length < 2) {
      setState(() => _predictions = []);
      return;
    }
    setState(() => _loadingSearch = true);
    _debounce = Timer(const Duration(milliseconds: 300), () => _fetchPredictions(q));
  }

  // ── Google Places Autocomplete API (HTTP) ───────────────────
  Future<void> _fetchPredictions(String q) async {
    if (q.trim().length < 2) return;
    setState(() => _loadingSearch = true);

    final results = <Map<String, dynamic>>[];

    // ── 1) Google Places API ─────────────────────────────────
    try {
      final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=${Uri.encodeComponent(q)}'
          '&language=tr'
          '&components=country:tr'
          '&sessiontoken=$_sessionToken'
          '&key=$_kGoogleApiKey');
      final res = await http.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data   = jsonDecode(res.body) as Map<String, dynamic>;
        final status = data['status'] as String? ?? '';
        debugPrint('Places status: $status');
        if (status == 'OK') {
          final preds = (data['predictions'] as List? ?? [])
              .cast<Map<String, dynamic>>();
          results.addAll(preds);
        }
      }
    } catch (e) {
      debugPrint('Places API error: $e');
    }

    // ── 2) Nominatim (always runs, fills gaps) ───────────────
    try {
      final res = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search'
            '?q=${Uri.encodeComponent(q)}'
            '&format=json&limit=8&accept-language=tr'
            '&countrycodes=tr&addressdetails=1&dedupe=1'),
        headers: const {'User-Agent': 'BiYemek/1.0 contact@biyemek.app'},
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
        for (final r in list) {
          final displayName = (r['display_name'] as String? ?? '');
          final parts = displayName.split(',');
          final mainText = parts.first.trim();
          final subText  = parts.skip(1).take(3).map((s) => s.trim())
              .where((s) => s.isNotEmpty).join(', ');
          results.add({
            'place_id':    r['place_id']?.toString() ?? '',
            'description': displayName,
            'structured_formatting': {
              'main_text':      mainText,
              'secondary_text': subText,
            },
            '_lat':       r['lat'],
            '_lon':       r['lon'],
            '_nominatim': true,
          });
        }
      }
    } catch (e) {
      debugPrint('Nominatim error: $e');
    }

    if (mounted) setState(() {
      _predictions = results;
      _loadingSearch = false;
    });
  }

  // ── Select a prediction ─────────────────────────────────────
  Future<void> _selectPrediction(Map<String, dynamic> pred) async {
    setState(() { _predictions = []; _searchCtrl.clear(); });

    // If it's a Nominatim result, use stored lat/lng directly
    if (pred['_nominatim'] == true) {
      final lat = double.tryParse(pred['_lat']?.toString() ?? '');
      final lng = double.tryParse(pred['_lon']?.toString() ?? '');
      if (lat != null && lng != null) {
        final ll = LatLng(lat, lng);
        setState(() { _center = ll; _pinned = ll; _label = pred['description']; });
        _mapCtrl.move(ll, 17);
        _reverseGeocode(ll);
      }
      return;
    }

    // Google Places: get coordinates from place details
    try {
      final placeId = pred['place_id'] as String? ?? '';
      final uri = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&fields=geometry,formatted_address'
          '&sessiontoken=$_sessionToken'
          '&language=tr'
          '&key=$_kGoogleApiKey');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data   = jsonDecode(res.body) as Map<String, dynamic>;
        final result = data['result'] as Map<String, dynamic>?;
        final loc    = result?['geometry']?['location'] as Map<String, dynamic>?;
        if (loc != null) {
          final ll = LatLng(
            (loc['lat'] as num).toDouble(),
            (loc['lng'] as num).toDouble(),
          );
          _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
          setState(() {
            _center = ll; _pinned = ll;
            _label = result?['formatted_address'] ?? pred['description'];
          });
          _mapCtrl.move(ll, 17);
          _reverseGeocode(ll);
        }
      }
    } catch (e) {
      debugPrint('Place details error: $e');
    }
  }

  // ── Location ────────────────────────────────────────────────
  Future<void> _tryLocation() async {
    setState(() => _loadingLoc = true);
    try {
      var status = await Permission.locationWhenInUse.status;
      if (status.isDenied) status = await Permission.locationWhenInUse.request();
      if (status.isPermanentlyDenied) {
        setState(() { _denied = true; _loadingLoc = false; });
        await _tryLast(); return;
      }
      if (status.isGranted || status.isLimited) {
        if (!await Geolocator.isLocationServiceEnabled()) {
          setState(() => _loadingLoc = false); await _tryLast(); return;
        }
        Position? pos;
        try {
          pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 8));
        } catch (_) {
          try {
            pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 14));
          } catch (_) {}
        }
        if (pos != null && mounted) {
          final ll = LatLng(pos.latitude, pos.longitude);
          setState(() { _center = ll; _pinned = ll; _loadingLoc = false; });
          _mapCtrl.move(ll, 16);
          _reverseGeocode(ll);
          return;
        }
      }
    } catch (e) { debugPrint('Loc: $e'); }
    setState(() => _loadingLoc = false);
    await _tryLast();
  }

  Future<void> _tryLast() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && mounted) {
        final ll = LatLng(last.latitude, last.longitude);
        setState(() { _center = ll; _pinned = ll; });
        _mapCtrl.move(ll, 14);
        _reverseGeocode(ll);
      }
    } catch (_) {}
  }

  // ── Reverse Geocode (Nominatim - free, no quota) ─────────────
  Future<void> _reverseGeocode(LatLng ll) async {
    try {
      final res = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse'
            '?lat=${ll.latitude}&lon=${ll.longitude}'
            '&format=json&accept-language=tr&addressdetails=1&zoom=18'),
        headers: const {'User-Agent': 'BiYemek/1.0'});
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final addr = data['address'] as Map<String, dynamic>? ?? {};
        String clean(String s) => s
            .replaceAll(' Mahallesi','').replaceAll(' Mah.','')
            .replaceAll(' İlçesi','').replaceAll(' Province','').trim();
        final parts = [
          addr['road'] ?? addr['pedestrian'] ?? '',
          clean((addr['suburb'] ?? addr['neighbourhood'] ?? '').toString()),
          clean((addr['county'] ?? '').toString()),
          clean((addr['province'] ?? addr['state'] ?? '').toString()),
        ].where((s) => s.isNotEmpty).toList();
        if (mounted) setState(() => _label = parts.join(', '));
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>> _getDetails(LatLng ll) async {
    try {
      final res = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse'
            '?lat=${ll.latitude}&lon=${ll.longitude}'
            '&format=json&accept-language=tr&addressdetails=1&zoom=18'),
        headers: const {'User-Agent': 'BiYemek/1.0'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final addr = data['address'] as Map<String, dynamic>? ?? {};
        String clean(String s) => s
            .replaceAll(' Province','').replaceAll(' İli','')
            .replaceAll(' İlçesi','').replaceAll(' Mahallesi','')
            .replaceAll(' Mah.','').trim();
        return {
          'lat':          ll.latitude,
          'lng':          ll.longitude,
          'city':         clean((addr['province'] ?? addr['state'] ?? addr['city'] ?? '').toString()),
          'district':     clean((addr['county'] ?? addr['city_district'] ?? '').toString()),
          'neighborhood': clean((addr['suburb'] ?? addr['neighbourhood'] ?? '').toString()),
          'road':         (addr['road'] ?? addr['pedestrian'] ?? '').toString().trim(),
          'label':        (data['display_name'] ?? '').toString(),
        };
      }
    } catch (_) {}
    return {'lat': ll.latitude, 'lng': ll.longitude,
            'city': '', 'district': '', 'neighborhood': '', 'road': '', 'label': ''};
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Konum Seç')),
      body: Stack(children: [

        // Flutter Map (OpenStreetMap – no API key required)
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: _center,
            initialZoom: 13,
            onTap: (_, ll) {
              setState(() { _pinned = ll; _label = null; });
              _reverseGeocode(ll);
            },
            onPositionChanged: (pos, _) {
              if (mounted) setState(() => _center = pos.center);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: isDark
                  ? 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                  : 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
              userAgentPackageName: 'com.biyemek.app',
              additionalOptions: const {'r': '@2x'},
            ),
            if (_pinned != null)
              MarkerLayer(markers: [
                Marker(
                  point: _pinned!,
                  width: 48, height: 48,
                  child: const Icon(Icons.location_pin,
                      color: AppTheme.primaryGreen, size: 48),
                ),
              ]),
          ],
        ),

        // Search bar + autocomplete dropdown
        Positioned(top: 12, left: 12, right: 12, child: Column(children: [
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.13),
                  blurRadius: 12, offset: const Offset(0, 3))]),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Mahalle, sokak, cadde ara...',
                prefixIcon: _loadingSearch
                    ? const Padding(padding: EdgeInsets.all(12),
                        child: SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.primaryGreen)))
                    : const Icon(Icons.search, color: AppTheme.grey),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _predictions = []);
                        })
                    : null,
                border: InputBorder.none,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 14)),
            )),

          // Autocomplete predictions
          if (_predictions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(maxHeight: 260),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
              child: ListView.separated(
                shrinkWrap: true, padding: EdgeInsets.zero,
                itemCount: _predictions.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: theme.dividerColor),
                itemBuilder: (_, i) {
                  final pred = _predictions[i];
                  final fmt  = pred['structured_formatting'] as Map<String, dynamic>?;
                  final main = fmt?['main_text'] as String?
                      ?? pred['description'] as String? ?? '';
                  final sub  = fmt?['secondary_text'] as String? ?? '';
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined,
                        color: AppTheme.primaryGreen, size: 18),
                    title: Text(main,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                    subtitle: sub.isNotEmpty
                        ? Text(sub,
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.grey),
                            maxLines: 1, overflow: TextOverflow.ellipsis)
                        : null,
                    onTap: () => _selectPrediction(pred),
                  );
                }),
            ),
        ])),

        // Loading overlay
        if (_loadingLoc)
          Container(
            color: Colors.black.withOpacity(0.35),
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16)),
              child: const Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(color: AppTheme.primaryGreen),
                SizedBox(height: 14),
                Text('Konum alınıyor...',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ])))),

        // Permission denied banner
        if (_denied)
          Positioned(top: 80, left: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppTheme.orange.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Expanded(child: Text(
                    'Konum izni reddedildi. Haritadan manuel seçim yapabilirsin.',
                    style: TextStyle(color: Colors.white, fontSize: 12))),
                TextButton(
                    onPressed: openAppSettings,
                    child: const Text('Ayarlar',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold))),
              ]))),

        // Map controls
        Positioned(right: 12, bottom: 155,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            FloatingActionButton.small(
              heroTag: 'gps', backgroundColor: theme.cardColor,
              onPressed: _tryLocation,
              child: const Icon(Icons.my_location,
                  color: AppTheme.primaryGreen)),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'zi', backgroundColor: theme.cardColor,
              onPressed: () =>
                  _mapCtrl.move(_center, _mapCtrl.camera.zoom + 1),
              child: const Icon(Icons.add)),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'zo', backgroundColor: theme.cardColor,
              onPressed: () =>
                  _mapCtrl.move(_center, _mapCtrl.camera.zoom - 1),
              child: const Icon(Icons.remove)),
          ])),

        // Confirm bar
        Positioned(bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16, offset: const Offset(0, -4))]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.location_pin,
                      color: _pinned != null
                          ? AppTheme.primaryGreen
                          : AppTheme.grey,
                      size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    _pinned == null
                        ? 'Haritaya dokun veya arama yap'
                        : (_label?.isNotEmpty == true
                            ? _label!
                            : 'Konum seçildi'),
                    style: TextStyle(
                        fontSize: 13,
                        color: _pinned == null ? AppTheme.grey : null),
                    maxLines: 2, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _pinned == null
                        ? null
                        : () async {
                            final d = await _getDetails(_pinned!);
                            if (mounted) Navigator.pop(context, d);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pinned == null
                          ? AppTheme.grey
                          : AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                    child: const Text('Bu Konumu Onayla',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  )),
              ]),
          )),
      ]),
    );
  }
}

// (Dark map style handled via Stadia Maps tile URL)

// ─────────────────────────────────────────────────────────────
//  ADDRESS FORM SCREEN
// ─────────────────────────────────────────────────────────────
class AddressFormScreen extends StatefulWidget {
  final Map<String, dynamic>? mapResult;
  final UserAddress? existing;
  const AddressFormScreen({super.key, this.mapResult, this.existing});
  @override State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title, _city, _street, _buildingNo, _floor, _aptNo, _directions;
  // İş tipine özel
  late final TextEditingController _companyName, _officeNo;
  // Okul tipine özel
  late final TextEditingController _schoolName, _faculty, _block, _securityNote;
  // Diğer tipine özel
  late final TextEditingController _placeName;

  String? _selectedDistrict;
  String? _selectedNeighborhood;
  List<String> _neighborhoodList = [];
  bool _loadingNeigh = false;
  double? _lat, _lng;
  String _type = 'Ev';
  bool _saving = false;

  static const _types = ['Ev', 'İş', 'Okul', 'Diğer'];

  @override
  void initState() {
    super.initState();
    final r = widget.mapResult;
    final e = widget.existing;

    _lat = (r?['lat'] as num?)?.toDouble() ?? e?.lat;
    _lng = (r?['lng'] as num?)?.toDouble() ?? e?.lng;

    // Correct field mapping from Nominatim result
    final initCity     = _cleanCity(e?.city ?? r?['city'] ?? '');
    final initDistrict = _cleanDistrict(e?.district ?? r?['district'] ?? '');
    final initNeigh    = _cleanNeigh(e?.neighborhood ?? r?['neighborhood'] ?? '');

    _title       = TextEditingController(text: e?.title ?? '');
    _city        = TextEditingController(text: initCity);
    _street      = TextEditingController(text: e?.street ?? (r?['road'] ?? ''));
    _buildingNo  = TextEditingController(text: e?.buildingNo ?? '');
    _floor       = TextEditingController(text: e?.floor ?? '');
    _aptNo       = TextEditingController(text: e?.apartmentNo ?? '');
    _directions  = TextEditingController(text: e?.directions ?? '');
    // Extra controllers (parsed from directions/buildingInfo for existing addresses)
    _companyName = TextEditingController();
    _officeNo    = TextEditingController();
    _schoolName  = TextEditingController();
    _faculty     = TextEditingController();
    _block       = TextEditingController();
    _securityNote= TextEditingController();
    _placeName   = TextEditingController();

    if (initDistrict.isNotEmpty) _selectedDistrict = initDistrict;
    if (initNeigh.isNotEmpty) _selectedNeighborhood = initNeigh;

    if (e != null) {
      final t = e.title.toLowerCase();
      _type = t.contains('ev') ? 'Ev' : t.contains('iş') || t.contains('ofis') ? 'İş'
            : t.contains('okul') ? 'Okul' : 'Diğer';
    }

    // Load neighborhoods if we have district + coordinates
    // Auto-select district + neighborhood from map data
    if (initDistrict.isNotEmpty || initCity.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final districts = _getDistricts();
        String? matchedDistrict;
        if (initDistrict.isNotEmpty && districts.isNotEmpty) {
          // Exact match
          for (final d in districts) {
            if (d.toLowerCase() == initDistrict.toLowerCase()) { matchedDistrict = d; break; }
          }
          // Fuzzy: starts-with
          if (matchedDistrict == null) {
            for (final d in districts) {
              if (initDistrict.toLowerCase().startsWith(d.toLowerCase()) ||
                  d.toLowerCase().startsWith(initDistrict.toLowerCase())) { matchedDistrict = d; break; }
            }
          }
          if (matchedDistrict != null && mounted) {
            setState(() => _selectedDistrict = matchedDistrict);
          }
        }
        final districtToLoad = matchedDistrict ?? initDistrict;
        if (districtToLoad.isNotEmpty) {
          _loadNeighborhoods(initCity, districtToLoad, preSelect: initNeigh);
        }
      });
    }
  }

  // Clean up Nominatim values
  String _cleanCity(String s) => s
      .replaceAll(' Province', '').replaceAll(' İli', '')
      .replaceAll(' Ili', '').trim();

  String _cleanDistrict(String s) => s
      .replaceAll(' İlçesi', '').replaceAll(' Ilcesi', '')
      .replaceAll(' District', '').trim();

  String _cleanNeigh(String s) => s
      .replaceAll(' Mahallesi', '').replaceAll(' Mah.', '')
      .replaceAll(' Neighbourhood', '').trim();

  @override
  void dispose() {
    for (final c in [_title, _city, _street, _buildingNo, _floor, _aptNo, _directions,
                     _companyName, _officeNo, _schoolName, _faculty, _block, _securityNote, _placeName]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Get districts for selected city ─────────────────────────
  List<String> _getDistricts() {
    return TurkeyGeoData.getDistricts(_city.text.trim());
  }

  // ── Load neighborhoods: static data first, Nominatim fallback ──
  Future<void> _loadNeighborhoods(String city, String district, {String preSelect = ''}) async {
    if (district.isEmpty) return;
    setState(() { _loadingNeigh = true; _neighborhoodList = []; });

    // 1) Try static data first (instant, reliable)
    List<String> staticList = _getStaticNeighborhoods(district);

    if (staticList.isNotEmpty) {
      // Auto-select preSelect if it matches (fuzzy)
      String? matched;
      if (preSelect.isNotEmpty) {
        for (final n in staticList) {
          if (n.toLowerCase() == preSelect.toLowerCase()) { matched = n; break; }
        }
        if (matched == null) {
          for (final n in staticList) {
            if (n.toLowerCase().contains(preSelect.toLowerCase()) ||
                preSelect.toLowerCase().contains(n.toLowerCase())) { matched = n; break; }
          }
        }
      }
      setState(() {
        _neighborhoodList = staticList;
        _loadingNeigh = false;
        if (matched != null) _selectedNeighborhood = matched;
        else if (preSelect.isNotEmpty && !staticList.contains(preSelect)) {
          // Add GPS-detected neighbourhood to top of list
          _neighborhoodList = [preSelect, ...staticList];
          _selectedNeighborhood = preSelect;
        }
      });
      return;
    }

    // 2) Fallback: Nominatim search
    try {
      final q = '$district, $city, Turkey';
      final res = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search'
            '?q=${Uri.encodeComponent(q)}&format=json&limit=50'
            '&accept-language=tr&addressdetails=1'),
        headers: const {'User-Agent': 'BiYemek/1.0'});
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
        final set = <String>{};
        for (final item in list) {
          final addr = item['address'] as Map<String, dynamic>? ?? {};
          final n = _cleanNeigh((addr['suburb'] ?? addr['neighbourhood'] ?? '').toString());
          if (n.isNotEmpty && n != district && n != city) set.add(n);
        }
        final sorted = set.toList()..sort();
        if (preSelect.isNotEmpty && !sorted.contains(preSelect)) sorted.insert(0, preSelect);
        setState(() {
          _neighborhoodList = sorted;
          if (preSelect.isNotEmpty) _selectedNeighborhood = preSelect;
        });
      }
    } catch (e) { debugPrint('Neighborhoods: $e'); }
    setState(() => _loadingNeigh = false);
  }

  // ── Static neighborhood lookup ───────────────────────────────
  List<String> _getStaticNeighborhoods(String district) {
    return TurkeyGeoData.getNeighborhoods(district);
  }

  // ── District Picker ──────────────────────────────────────────
  Future<void> _pickDistrict() async {
    final city = _city.text.trim();
    if (city.isEmpty) {
      _showSnack('Önce il giriniz'); return;
    }
    final districts = _getDistricts();
    final result = await _searchablePicker(
        title: 'İlçe Seç',
        items: districts,
        selected: _selectedDistrict,
        emptyHint: 'İlçe listesi yüklenmedi. Yazarak devam edebilirsiniz.');
    if (result != null && mounted) {
      setState(() { _selectedDistrict = result; _selectedNeighborhood = null; _neighborhoodList = []; });
      _loadNeighborhoods(city, result);
    }
  }

  // ── Neighborhood Picker ──────────────────────────────────────
  Future<void> _pickNeighborhood() async {
    if (_selectedDistrict == null) { _showSnack('Önce ilçe seçiniz'); return; }
    if (_loadingNeigh) { _showSnack('Mahalleler yükleniyor...'); return; }
    if (_neighborhoodList.isEmpty) {
      await _loadNeighborhoods(_city.text.trim(), _selectedDistrict!);
      if (!mounted) return;
    }
    final result = await _searchablePicker(
        title: 'Mahalle Seç',
        items: _neighborhoodList,
        selected: _selectedNeighborhood,
        emptyHint: 'Mahalle bulunamadı. Yazarak devam edebilirsiniz.');
    if (result != null && mounted) setState(() => _selectedNeighborhood = result);
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));

  // ── Searchable Bottom Sheet Picker ───────────────────────────
  Future<String?> _searchablePicker({
    required String title, required List<String> items,
    String? selected, String emptyHint = '',
  }) {
    return showModalBottomSheet<String>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => _SearchPickerSheet(
        title: title, items: items, selected: selected, emptyHint: emptyHint),
    );
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Adresi Düzenle' : 'Adres Detayları')),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(20), children: [

        // GPS badge
        if (_lat != null && !isEdit) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.gps_fixed, size: 16, color: AppTheme.primaryGreen), const SizedBox(width: 8),
              Expanded(child: Text(
                widget.mapResult?['label']?.toString().isNotEmpty == true
                    ? (widget.mapResult!['label'] as String).split(',').take(3).join(',') : 'GPS konumu seçildi',
                style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen),
                maxLines: 2, overflow: TextOverflow.ellipsis)),
            ])),
          const SizedBox(height: 16),
        ],

        // Adres tipi
        _label('Adres Tipi'),
        const SizedBox(height: 8),
        Row(children: _types.asMap().entries.map((e) {
          final sel = e.value == _type;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() { _type = e.value; if (_title.text.isEmpty) _title.text = e.value; }),
            child: Container(
              margin: EdgeInsets.only(right: e.key < _types.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? AppTheme.primaryGreen : theme.cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sel ? AppTheme.primaryGreen : theme.dividerColor)),
              child: Text(e.value, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : AppTheme.grey)))));
        }).toList()),
        const SizedBox(height: 16),

        // Başlık
        _tf(_title, 'Adres Başlığı *', Icons.label_outline, required: true),
        const SizedBox(height: 14),

        // Tip bazlı form alanları
        ..._buildTypeFields(),
        const SizedBox(height: 28),

        SizedBox(height: 54, child: ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(isEdit ? 'Güncelle' : 'Adresi Kaydet',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        )),
      ])),
    );
  }

  // ── Type-specific form fields ───────────────────────────────
  List<Widget> _buildTypeFields() {
    switch (_type) {

      // ── EV ──────────────────────────────────────────────────
      case 'Ev':
        return [
          _locationFields(),
          const SizedBox(height: 14),
          _tf(_street, 'Cadde / Sokak', Icons.route_outlined),
          const SizedBox(height: 14),
          _label('Bina ve Daire Bilgisi'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _tf(_buildingNo, 'Bina No *', Icons.domain_outlined, required: true)),
            const SizedBox(width: 10),
            Expanded(child: _tf(_floor, 'Kat No', Icons.stairs_outlined, keyboardType: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(child: _tf(_aptNo, 'Daire No *', Icons.tag, required: true, keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 14),
          _tarifField('Örn: Sarı bina, asansörlü blok, soldan 3. daire...'),
        ];

      // ── İŞ ──────────────────────────────────────────────────
      case 'İş':
        return [
          _tf(_companyName, 'Şirket / Kurum Adı *', Icons.business_outlined, required: true),
          const SizedBox(height: 14),
          _locationFields(),
          const SizedBox(height: 14),
          _tf(_street, 'Cadde / Sokak', Icons.route_outlined),
          const SizedBox(height: 14),
          _label('Bina ve Ofis Bilgisi'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _tf(_buildingNo, 'Bina No *', Icons.domain_outlined, required: true)),
            const SizedBox(width: 10),
            Expanded(child: _tf(_floor, 'Kat', Icons.stairs_outlined, keyboardType: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(child: _tf(_officeNo, 'Ofis No', Icons.meeting_room_outlined, keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 14),
          _tarifField('Örn: Resepsiyon masasına bırakın, güvenlik +90 532 ... arayın...'),
        ];

      // ── OKUL ─────────────────────────────────────────────────
      case 'Okul':
        return [
          _tf(_schoolName, 'Okul / Üniversite Adı *', Icons.school_outlined, required: true),
          const SizedBox(height: 14),
          _tf(_faculty, 'Fakülte / Bölüm / Sınıf', Icons.account_balance_outlined),
          const SizedBox(height: 14),
          _tf(_block, 'Kapı / Blok / Giriş Noktası', Icons.door_front_door_outlined),
          const SizedBox(height: 14),
          _label('Konum (opsiyonel)'),
          const SizedBox(height: 6),
          _cityField(),
          const SizedBox(height: 14),
          _label('Güvenlik & Teslim Notu *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _securityNote,
            maxLines: 3, maxLength: 250,
            validator: (v) => v?.trim().isEmpty == true ? 'Teslim notu zorunludur' : null,
            decoration: const InputDecoration(
              hintText: 'Örn: Ana kapıdan girin, güvenliğe "yemek siparişi" deyin, D Blok önünde bekleyeceğim.',
              alignLabelWithHint: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
          ),
        ];

      // ── DİĞER ────────────────────────────────────────────────
      default: // 'Diğer'
        return [
          _tf(_placeName, 'Mekan Adı', Icons.place_outlined),
          const SizedBox(height: 14),
          _locationFields(),
          const SizedBox(height: 14),
          _tf(_street, 'Cadde / Sokak', Icons.route_outlined),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _tf(_buildingNo, 'Kapı / Bina No', Icons.domain_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _tf(_floor, 'Kat', Icons.stairs_outlined, keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 14),
          _tarifField('Örn: Tarihi çarşının karşısı, turuncu tabelası var...'),
        ];
    }
  }

  // ── Shared location fields (İl + İlçe + Mahalle) ──────────
  Widget _locationFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('İl *'),
      const SizedBox(height: 6),
      _cityField(),
      const SizedBox(height: 14),
      _label('İlçe *'),
      const SizedBox(height: 6),
      _pickerRow(value: _selectedDistrict, hint: 'İlçe seçin',
          loading: false, icon: Icons.map_outlined,
          onTap: _pickDistrict, required: true),
      const SizedBox(height: 14),
      _label('Mahalle *'),
      const SizedBox(height: 6),
      _pickerRow(
          value: _selectedNeighborhood,
          hint: _selectedDistrict == null ? 'Önce ilçe seçin' : 'Mahalle seçin',
          loading: _loadingNeigh, icon: Icons.holiday_village_outlined,
          onTap: _pickNeighborhood, required: true),
    ],
  );

  // ── City field ──────────────────────────────────────────────
  Widget _cityField() => TextFormField(
    controller: _city,
    validator: (v) => v?.trim().isEmpty == true ? 'İl zorunludur' : null,
    onChanged: (v) {
      if (v.trim().length >= 2) {
        setState(() { _selectedDistrict = null; _selectedNeighborhood = null; _neighborhoodList = []; });
      }
    },
    decoration: InputDecoration(
      hintText: 'İstanbul, Ankara...',
      prefixIcon: const Icon(Icons.location_city_outlined, size: 18),
      filled: true, fillColor: AppTheme.primaryGreen.withOpacity(0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
  );

  // ── Tarif field ─────────────────────────────────────────────
  Widget _tarifField(String hint) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Adres Tarifi (opsiyonel)'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _directions, maxLines: 3, maxLength: 200,
        decoration: InputDecoration(
          hintText: hint,
          alignLabelWithHint: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
      ),
    ],
  );

  Widget _label(String t) => Text(t,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3, color: AppTheme.grey));

  Widget _tf(TextEditingController c, String label, IconData icon,
      {bool required = false, TextInputType? keyboardType}) {
    return TextFormField(
      controller: c, keyboardType: keyboardType,
      validator: required ? (v) => v?.trim().isEmpty == true ? 'Zorunlu' : null : null,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)));
  }

  Widget _pickerRow({
    required String? value, required String hint, required bool loading,
    required IconData icon, required VoidCallback onTap, bool required = false,
  }) {
    final theme = Theme.of(context);
    final hasValue = value != null && value.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor)),
        child: Row(children: [
          Icon(icon, size: 18, color: hasValue ? AppTheme.primaryGreen : AppTheme.grey),
          const SizedBox(width: 12),
          Expanded(child: loading
            ? const Row(children: [
                SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen)),
                SizedBox(width: 10),
                Text('Yükleniyor...', style: TextStyle(color: AppTheme.grey, fontSize: 13)),
              ])
            : Text(value ?? hint,
                style: TextStyle(fontSize: 14, color: hasValue ? null : AppTheme.grey,
                    fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal))),
          Icon(Icons.keyboard_arrow_down, color: AppTheme.grey, size: 20),
        ]),
      ),
    );
  }

  Future<void> _save() async {
    // Okul tipi için il/ilçe/mahalle zorunlu değil
    final needsLocation = _type != 'Okul';
    if (needsLocation) {
      if (_selectedDistrict == null) { _showSnack('İlçe seçiniz'); return; }
      if (_selectedNeighborhood == null) { _showSnack('Mahalle seçiniz'); return; }
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    // Tipe göre directions alanını doldur
    String builtDirections;
    if (_type == 'Okul') {
      final parts = [
        if (_faculty.text.trim().isNotEmpty) _faculty.text.trim(),
        if (_block.text.trim().isNotEmpty) 'Kapı/Blok: ${_block.text.trim()}',
        if (_securityNote.text.trim().isNotEmpty) _securityNote.text.trim(),
      ];
      builtDirections = parts.join(' | ');
    } else if (_type == 'İş') {
      final parts = [
        if (_companyName.text.trim().isNotEmpty) _companyName.text.trim(),
        if (_officeNo.text.trim().isNotEmpty) 'Ofis: ${_officeNo.text.trim()}',
        if (_directions.text.trim().isNotEmpty) _directions.text.trim(),
      ];
      builtDirections = parts.join(' | ');
    } else if (_type == 'Diğer') {
      final parts = [
        if (_placeName.text.trim().isNotEmpty) _placeName.text.trim(),
        if (_directions.text.trim().isNotEmpty) _directions.text.trim(),
      ];
      builtDirections = parts.join(' | ');
    } else {
      builtDirections = _directions.text.trim();
    }

    // Okul için street = fakülte+blok, buildingNo = okul adı
    final isOkul = _type == 'Okul';
    final addr = UserAddress(
      id: widget.existing?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
      title: _title.text.trim().isEmpty ? (_type == 'Okul' ? _schoolName.text.trim() : _type) : _title.text.trim(),
      city: _city.text.trim().isEmpty ? '' : _city.text.trim(),
      district:     _selectedDistrict ?? '',
      neighborhood: _selectedNeighborhood ?? '',
      street:       isOkul ? (_faculty.text.trim().isNotEmpty ? _faculty.text.trim() : '') : _street.text.trim(),
      buildingNo:   isOkul ? _schoolName.text.trim() : _buildingNo.text.trim(),
      floor:        isOkul ? (_block.text.trim()) : _floor.text.trim(),
      apartmentNo:  _type == 'İş' ? _officeNo.text.trim() : _aptNo.text.trim(),
      directions:   builtDirections,
      lat: _lat, lng: _lng,
    );

    final auth = context.read<AuthProvider>();
    if (widget.existing != null) {
      await auth.updateAddress(addr);
    } else {
      await auth.addAddress(addr);
      if (mounted) context.read<RestaurantProvider>().setCity(addr.city);
    }
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }
}

// ─────────────────────────────────────────────────────────────
//  SEARCHABLE PICKER SHEET  (standalone widget — no dispose bug)
// ─────────────────────────────────────────────────────────────
class _SearchPickerSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? selected;
  final String emptyHint;
  const _SearchPickerSheet({
    required this.title,
    required this.items,
    required this.selected,
    required this.emptyHint,
  });
  @override
  State<_SearchPickerSheet> createState() => _SearchPickerSheetState();
}

class _SearchPickerSheetState extends State<_SearchPickerSheet> {
  final _ctrl = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final filtered = _filter.isEmpty
        ? widget.items
        : widget.items.where((i) => i.toLowerCase().contains(_filter.toLowerCase())).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(children: [
        // Handle
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: theme.dividerColor, borderRadius: BorderRadius.circular(2)),
        ),
        // Title row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(child: Text(widget.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ]),
        ),
        // Search field
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            controller: _ctrl,
            autofocus: true,
            onChanged: (v) => setState(() => _filter = v),
            decoration: InputDecoration(
              hintText: '${widget.title} ara veya yaz...',
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _filter.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => setState(() { _ctrl.clear(); _filter = ''; }),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
        // List or empty state
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(widget.emptyHint,
                        style: const TextStyle(color: AppTheme.grey),
                        textAlign: TextAlign.center),

                  ]),
                ))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final isSel = filtered[i] == widget.selected;
                    return ListTile(
                      title: Text(filtered[i],
                          style: TextStyle(
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                      trailing: isSel
                          ? const Icon(Icons.check_circle,
                              color: AppTheme.primaryGreen, size: 20)
                          : null,
                      tileColor: isSel
                          ? AppTheme.primaryGreen.withOpacity(0.08)
                          : null,
                      onTap: () => Navigator.pop(context, filtered[i]),
                    );
                  },
                ),
        ),
        // "Use as typed" option when filter has results

      ]),
    );
  }
}
