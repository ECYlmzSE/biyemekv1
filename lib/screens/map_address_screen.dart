import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/turkey_geo_data.dart';
import 'address_detail_screen.dart';

const _kApiKey  = 'AIzaSyB8voNd5dgCVAGQpVIQJCt5CPdk3FZhoTY';
const _kAnkara  = LatLng(39.9334, 32.8597);
const _kZoom    = 14.0;

class MapAddressScreen extends StatefulWidget {
  const MapAddressScreen({super.key});
  @override
  State<MapAddressScreen> createState() => _State();
}

class _State extends State<MapAddressScreen> {
  final _mapCtrl  = MapController();
  LatLng  _center = _kAnkara;
  bool    _locating  = true;
  bool    _geocoding = false;
  String  _preview   = 'Konum belirleniyor…';
  Map<String,String> _geo = {};
  int     _reqId = 0;

  // Arama
  final _searchCtrl = TextEditingController();
  List<Map<String,String>> _sugg = [];
  Timer? _debounce;

  @override
  void initState() { super.initState(); _gps(); }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _mapCtrl.dispose();
    super.dispose();
  }

  // ── GPS ──────────────────────────────────────────────────────
  Future<void> _gps() async {
    if (!mounted) return;
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) { _gpsEnd(); return; }
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.deniedForever) { _gpsEnd(); return; }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 8));
      if (!mounted) return;
      final ll = LatLng(pos.latitude, pos.longitude);
      setState(() { _center = ll; _locating = false; });
      _mapCtrl.move(ll, 15);
      _geocode(ll);
    } catch (_) { _gpsEnd(); _geocode(_center); }
  }

  void _gpsEnd() { if (mounted) setState(() => _locating = false); }

  // ── Geocode (Nominatim - ücretsiz) ───────────────────────────
  Future<void> _geocode(LatLng ll) async {
    if (!mounted) return;
    final id = ++_reqId;
    setState(() { _geocoding = true; _preview = 'Adres belirleniyor…'; });
    try {
      // Önce Google Maps API dene
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=${ll.latitude},${ll.longitude}&language=tr&key=$_kApiKey');
      final res = await http.get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 6));
      if (!mounted || id != _reqId) return;
      final j = jsonDecode(res.body) as Map<String,dynamic>;
      if (j['status'] == 'OK') {
        final r = (j['results'] as List).first as Map<String,dynamic>;
        setState(() {
          _preview   = r['formatted_address'] as String;
          _geo       = _parseGoogle(r['address_components'] as List);
          _geocoding = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback: Nominatim (OSM - ücretsiz, API key yok)
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${ll.latitude}&lon=${ll.longitude}&format=json&accept-language=tr&addressdetails=1&zoom=16');
      final res = await http.get(uri,
          headers: {'User-Agent': 'BiYemek/1.0 (contact@biyemek.com)'})
          .timeout(const Duration(seconds: 6));
      if (!mounted || id != _reqId) return;
      final j = jsonDecode(res.body) as Map<String,dynamic>;
      final addr = j['address'] as Map<String,dynamic>? ?? {};
      final display = j['display_name'] as String? ?? 'Adres alınamadı';
      setState(() {
        _preview   = display;
        _geo       = _parseNominatim(addr, displayName: display);
        _geocoding = false;
      });
      return;
    } catch (_) {}

    if (mounted && id == _reqId) {
      setState(() { _preview = 'Adres alınamadı'; _geocoding = false; });
    }
  }

  Map<String,String> _parseGoogle(List comps) {
    String city='', dist='', neigh='', street='';
    for (final c in comps) {
      final t = List<String>.from(c['types'] as List);
      final n = c['long_name'] as String;
      if (t.contains('administrative_area_level_1'))
        city = n.replaceAll(' Province','').replaceAll(' İli','');
      if (t.contains('administrative_area_level_2')) dist = n;
      if (t.contains('neighborhood')||t.contains('sublocality_level_1')||
          t.contains('sublocality')) neigh = n;
      if (t.contains('route')) street = n;
    }
    return {'city':city,'district':dist,'neighborhood':neigh,'street':street};
  }

  // Yaygın ASCII → Türkçe karakter düzeltme sözlüğü (tam kelime eşleşmesi)
  static const _trWords = {
    // Aylar
    'mayis':'Mayıs','agustos':'Ağustos','eylul':'Eylül',
    'aralik':'Aralık','subat':'Şubat','kasim':'Kasım',
    // Ünlü kişi/yer isimleri
    'ataturk':'Atatürk','inonu':'İnönü','ismet':'İsmet',
    'istasyon':'İstasyon','izmit':'İzmit','izmir':'İzmir',
    'iskender':'İskender','kazim':'Kazım',
    // Yaygın adres kelimeleri
    'sehit':'Şehit','sehitler':'Şehitler','sehitlik':'Şehitlik',
    'kucuk':'Küçük','buyuk':'Büyük',
    'bahce':'Bahçe','bahcesi':'Bahçesi','bahcelik':'Bahçelik',
    'gol':'Göl','golbasi':'Gölbaşı',
    'dag':'Dağ','dagi':'Dağı',
    'cinar':'Çınar','cinarlı':'Çınarlı',
    'celik':'Çelik','cayonu':'Çayönü','cay':'Çay',
    'sahin':'Şahin','sahinkaya':'Şahinkaya',
    'gumus':'Gümüş','gumushane':'Gümüşhane',
    'koy':'Köy','koyu':'Köyü','koprubasi':'Köprübaşı',
    'yuzuncu':'Yüzüncü','uc':'Üç',
    'ozgur':'Özgür','ozgurluk':'Özgürlük',
    'golcuk':'Gölcük','gokce':'Gökçe',
    'koruyolu':'Koruyolu',
    '19mayis':'19 Mayıs',
  };

  /// Tek bir kelimeyi sözlükle düzeltir (büyük/küçük harf agnostik).
  String _fixWord(String w) {
    final lower = w.toLowerCase();
    return _trWords[lower] ?? w;
  }

  /// Cümledeki her kelimeyi düzeltir + suffix'leri temizler.
  String _fixTurkish(String s) {
    if (s.isEmpty) return s;
    final cleaned = s
        .replaceAll(' Province', '').replaceAll(' İli', '')
        .replaceAll(' Ilçesi', '').replaceAll(' İlçesi', '')
        .replaceAll(' Mahallesi', '').replaceAll(' Mahalle', '')
        .replaceAll(' Köyü', '').replaceAll(' Koyü', '').trim();
    return cleaned.split(' ').map(_fixWord).join(' ');
  }

  /// display_name comma parçalarından anlamsız olanları filtreler.
  bool _isSkippablePart(String p) {
    final l = p.trim().toLowerCase();
    // Posta kodu (sayısal), ülke adı, boş
    if (l.isEmpty) return true;
    if (RegExp(r'^\d+$').hasMatch(l)) return true;
    if (l == 'türkiye' || l == 'turkey' || l == 'turkiye') return true;
    return false;
  }

  String _cleanSuffix(String s) => s
      .replaceAll(' Mahallesi', '').replaceAll(' Mahalle', '')
      .replaceAll(' Mah.', '').replaceAll(' Mah', '')
      .replaceAll(' İlçesi', '').replaceAll(' Ilçesi', '')
      .replaceAll(' Province', '').replaceAll(' İli', '')
      .replaceAll(' Köyü', '').trim();

  /// Nominatim'in display_name'ini birincil kaynak olarak kullanır.
  /// Format: "Mahalle, İlçe, İl, [Posta Kodu,] Türkiye"
  /// address alanları sadece display_name eksikse devreye girer.
  Map<String,String> _parseNominatim(Map<String,dynamic> a, {String displayName = ''}) {
    String s(String k) => (a[k] as String? ?? '').trim();

    // ── Şehir ────────────────────────────────────────────────────
    final city = s('province').isNotEmpty ? s('province')
               : s('state').isNotEmpty    ? s('state')
               : s('city');

    // ── Mahalle (en spesifik alan önce) ──────────────────────────
    final neigh = s('neighbourhood').isNotEmpty ? s('neighbourhood')
                : s('suburb').isNotEmpty        ? s('suburb')
                : s('quarter');

    // ── İlçe: city_district ve municipality Türkiye'de daha güvenilir
    //    county son seçenek — ama mahalle adıyla aynıysa kullanma
    String dist = s('city_district').isNotEmpty ? s('city_district')
                : s('municipality').isNotEmpty  ? s('municipality')
                : '';

    if (dist.isEmpty) {
      final county = s('county').isNotEmpty ? s('county')
                   : s('district').isNotEmpty ? s('district')
                   : s('town');
      // county mahalle adıyla aynıysa ya da mahalle gibi görünüyorsa kullanma
      final sameAsNeigh = county.toLowerCase() == neigh.toLowerCase();
      final looksMahalle = county.toLowerCase().contains('mahalle');
      if (!sameAsNeigh && !looksMahalle) dist = county;
    }

    // ── Mahalle display_name'den geliyor olabilir (daha iyi karakter)
    // display_name → "Mahalle, İlçe, İl, Türkiye" formatında
    if (displayName.isNotEmpty && neigh.isEmpty) {
      final parts = displayName.split(',')
          .map((p) => p.trim())
          .where((p) => !_isSkippablePart(p))
          .toList();
      if (parts.isNotEmpty) {
        final first = _cleanSuffix(parts[0]);
        if (first.isNotEmpty) {
          // Sadece mahalle için kullan, ilçe/şehir zaten address field'dan geliyor
        }
      }
    }

    final street = s('road');

    return {
      'city'        : _fixTurkish(city),
      'district'    : _fixTurkish(dist),
      'neighborhood': _fixTurkish(neigh),
      'street'      : _fixTurkish(street),
    };
  }

  // ── Arama (Google Places Autocomplete) ───────────────────────
  void _onSearch(String q) {
    _debounce?.cancel();
    if (q.length < 2) { setState(() => _sugg=[]); return; }
    _debounce = Timer(const Duration(milliseconds: 450), () => _search(q));
  }

  Future<void> _search(String q) async {
    try {
      final r = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(q)}&language=tr&components=country:tr'
        '&types=geocode|establishment&key=$_kApiKey'))
          .timeout(const Duration(seconds: 5));
      if (!mounted) return;
      final j = jsonDecode(r.body) as Map<String,dynamic>;
      if (j['status']=='OK') {
        final list = (j['predictions'] as List).take(5).map((p) {
          final f = p['structured_formatting'] as Map<String,dynamic>;
          return <String,String>{
            'id'  : p['place_id'] as String,
            'main': (f['main_text']??'') as String,
            'sub' : (f['secondary_text']??'') as String,
          };
        }).toList();
        if (mounted) setState(() => _sugg = list);
      }
    } catch (_) {}
  }

  Future<void> _pick(Map<String,String> s) async {
    FocusScope.of(context).unfocus();
    setState(() { _sugg=[]; _searchCtrl.text=s['main']!; });
    try {
      final r = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=${s['id']}&fields=geometry&language=tr&key=$_kApiKey'))
          .timeout(const Duration(seconds: 5));
      if (!mounted) return;
      final j = jsonDecode(r.body) as Map<String,dynamic>;
      if (j['status']=='OK') {
        final loc = (j['result'] as Map)['geometry']['location'];
        final ll  = LatLng((loc['lat'] as num).toDouble(),(loc['lng'] as num).toDouble());
        setState(() => _center = ll);
        _mapCtrl.move(ll, 16);
        _geocode(ll);
      }
    } catch (_) {}
  }

  // ── Harita hareket ──────────────────────────────────────────
  void _onMapMove(MapCamera cam, bool _) {
    if (!mounted) return;
    setState(() => _center = cam.center);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      if (mounted) _geocode(_center);
    });
  }

  /// Türkçe karşılaştırma için normalize eder.
  /// 'İ' toLowerCase'den ÖNCE 'i'ye çevrilmeli (Dart U+0130 → 'i\u0307' üretir).
  static String _norm(String s) => s
      .replaceAll('İ', 'i').replaceAll('I', 'i')
      .toLowerCase()
      .replaceAll('ı', 'i').replaceAll('ğ', 'g').replaceAll('ü', 'u')
      .replaceAll('ş', 's').replaceAll('ö', 'o').replaceAll('ç', 'c');

  // ── Devam ───────────────────────────────────────────────────
  void _confirm() {
    if (_geocoding || _locating) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konum belirlenmesini bekleyin')));
      return;
    }
    FocusScope.of(context).unfocus();
    _debounce?.cancel();

    // TurkeyGeoData'daki şehir ismiyle normalize eşleştir
    final cities = TurkeyGeoData.allCities;
    final rawCity = _geo['city'] ?? '';
    String matchedCity = rawCity;
    if (rawCity.isNotEmpty) {
      final rn = _norm(rawCity);
      for (final c in cities) {
        final cn = _norm(c);
        if (cn == rn || rn.contains(cn) || cn.contains(rn)) {
          matchedCity = c; break;
        }
      }
    }

    Navigator.push(context, MaterialPageRoute(
      builder: (_) => AddressDetailScreen(
        lat: _center.latitude, lng: _center.longitude,
        city: matchedCity,
        district: _geo['district'] ?? '',
        neighborhood: _geo['neighborhood'] ?? '',
        street: _geo['street'] ?? '',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      body: Stack(children: [

        // ── Flutter Map (OpenStreetMap) ──────────────────────
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: _center,
            initialZoom: _kZoom,
            onPositionChanged: _onMapMove,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.biyemek.app',
              maxZoom: 19,
            ),
          ],
        ),

        // ── Sabit merkez pin ─────────────────────────────────
        const Center(child: _Pin()),

        // ── GPS yükleniyor ────────────────────────────────────
        if (_locating)
          Positioned.fill(child: Container(
            color: Colors.black38,
            child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 12),
              Text('Konum alınıyor…',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
            ])),
          )),

        // ── Arama çubuğu + öneriler ──────────────────────────
        Positioned(top: 0, left: 0, right: 0,
          child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              margin: const EdgeInsets.fromLTRB(12,8,12,0),
              decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15),
                    blurRadius: 12, offset: const Offset(0,4))]),
              child: Row(children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context)),
                Expanded(child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearch,
                  decoration: const InputDecoration(
                    hintText: 'Mahalle, sokak veya yer ara…',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppTheme.grey, fontSize: 14),
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                )),
                if (_searchCtrl.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, color: AppTheme.grey, size: 20),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _sugg=[]);
                    })
                else
                  const Padding(padding: EdgeInsets.only(right: 14),
                    child: Icon(Icons.search, color: AppTheme.grey)),
              ]),
            ),
            if (_sugg.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(14)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
                      blurRadius: 8, offset: const Offset(0,6))]),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Divider(height: 1),
                  ..._sugg.map((s) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined,
                        color: AppTheme.primaryGreen, size: 20),
                    title: Text(s['main']!, style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text(s['sub']!, style: const TextStyle(
                        fontSize: 11, color: AppTheme.grey)),
                    onTap: () => _pick(s),
                  )),
                ]),
              ),
          ])),
        ),

        // ── Zoom + GPS butonları ─────────────────────────────
        Positioned(right: 12, bottom: pad.bottom + 190,
          child: Column(children: [
            _Btn(icon: Icons.add,
                onTap: () => _mapCtrl.move(_center, _mapCtrl.camera.zoom + 1)),
            const SizedBox(height: 4),
            _Btn(icon: Icons.remove,
                onTap: () => _mapCtrl.move(_center, _mapCtrl.camera.zoom - 1)),
            const SizedBox(height: 4),
            _Btn(icon: Icons.my_location, color: AppTheme.primaryGreen,
                onTap: _gps),
          ]),
        ),

        // ── Alt adres kartı ──────────────────────────────────
        Positioned(bottom: 0, left: 0, right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12),
                  blurRadius: 16, offset: const Offset(0,-4))],
            ),
            padding: EdgeInsets.fromLTRB(20, 14, 20, pad.bottom + 16),
            child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 12),
              const Text('Seçilen Konum',
                  style: TextStyle(fontSize: 12, color: AppTheme.grey,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 20),
                const SizedBox(width: 8),
                Expanded(child: _geocoding
                  ? const Row(children: [
                      SizedBox(width:16, height:16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.primaryGreen)),
                      SizedBox(width: 10),
                      Text('Adres belirleniyor…',
                          style: TextStyle(color: AppTheme.grey, fontSize: 13)),
                    ])
                  : Text(_preview,
                      style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w500),
                      maxLines: 2, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 14),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: (_geocoding || _locating) ? null : _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  disabledBackgroundColor: Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Bu Konumu Kullan',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                      color: Colors.white)),
              )),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin();
  @override
  Widget build(BuildContext c) => IgnorePointer(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: AppTheme.primaryGreen,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.5),
              blurRadius: 10, offset: const Offset(0,3))]),
        child: const Text('Teslimat noktası',
            style: TextStyle(color: Colors.white, fontSize: 12,
                fontWeight: FontWeight.bold))),
      CustomPaint(size: const Size(16,9), painter: _Tri()),
      Container(width:18, height:18,
        decoration: BoxDecoration(color: AppTheme.primaryGreen,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25),
              blurRadius: 6, offset: const Offset(0,3))])),
      const SizedBox(height: 3),
      Container(width: 6, height: 4,
        decoration: BoxDecoration(color: Colors.black26,
            borderRadius: BorderRadius.circular(3))),
    ]),
  );
}

class _Tri extends CustomPainter {
  @override void paint(Canvas c, Size s) => c.drawPath(
    ui.Path()..moveTo(0,0)..lineTo(s.width,0)..lineTo(s.width/2,s.height)..close(),
    Paint()..color = AppTheme.primaryGreen);
  @override bool shouldRepaint(_)=>false;
}

class _Btn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap; final Color? color;
  const _Btn({required this.icon, required this.onTap, this.color});
  @override
  Widget build(BuildContext c) => Material(
    color: Colors.white, shape: const CircleBorder(), elevation: 3,
    child: InkWell(customBorder: const CircleBorder(), onTap: onTap,
      child: SizedBox(width: 42, height: 42,
          child: Icon(icon, size: 22, color: color??Colors.black87))));
}
