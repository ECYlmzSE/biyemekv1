import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../providers/restaurant_provider.dart';
import '../services/turkey_geo_data.dart';

// ── Türkiye'deki tüm üniversiteler ──────────────────────────────
const _kUniversities = [
  'ABDULLAH GÜL ÜNİVERSİTESİ',
  'ACIBADEM MEHMET ALİ AYDINLAR ÜNİVERSİTESİ',
  'ADANA ALPARSLAN TÜRKEŞ BİLİM VE TEKNOLOJİ ÜNİVERSİTESİ',
  'ADIYAMAN ÜNİVERSİTESİ',
  'AFYON KOCATEPE ÜNİVERSİTESİ',
  'AFYONKARAHİSAR SAĞLIK BİLİMLERİ ÜNİVERSİTESİ',
  'AĞRI İBRAHİM ÇEÇEN ÜNİVERSİTESİ',
  'AKDENİZ ÜNİVERSİTESİ',
  'AKSARAY ÜNİVERSİTESİ',
  'ALANYA ALAADDİN KEYKUBAT ÜNİVERSİTESİ',
  'ALANYA ÜNİVERSİTESİ',
  'ALTINBAŞ ÜNİVERSİTESİ',
  'AMASYA ÜNİVERSİTESİ',
  'ANADOLU ÜNİVERSİTESİ',
  'ANKARA BİLİM ÜNİVERSİTESİ',
  'ANKARA HACI BAYRAM VELİ ÜNİVERSİTESİ',
  'ANKARA MEDİPOL ÜNİVERSİTESİ',
  'ANKARA MÜZİK VE GÜZEL SANATLAR ÜNİVERSİTESİ',
  'ANKARA SOSYAL BİLİMLER ÜNİVERSİTESİ',
  'ANKARA ÜNİVERSİTESİ',
  'ANKARA YILDIRIM BEYAZIT ÜNİVERSİTESİ',
  'ANTALYA BELEK ÜNİVERSİTESİ',
  'ANTALYA BİLİM ÜNİVERSİTESİ',
  'ARDAHAN ÜNİVERSİTESİ',
  'ARTVİN ÇORUH ÜNİVERSİTESİ',
  'ATAŞEHİR ADIGÜZEL MESLEK YÜKSEKOKULU',
  'ATATÜRK ÜNİVERSİTESİ',
  'ATILIM ÜNİVERSİTESİ',
  'AVRASYA ÜNİVERSİTESİ',
  'AYDIN ADNAN MENDERES ÜNİVERSİTESİ',
  'BAHÇEŞEHİR ÜNİVERSİTESİ',
  'BALIKESİR ÜNİVERSİTESİ',
  'BANDIRMA ONYEDİ EYLÜL ÜNİVERSİTESİ',
  'BARTIN ÜNİVERSİTESİ',
  'BAŞKENT ÜNİVERSİTESİ',
  'BATMAN ÜNİVERSİTESİ',
  'BAYBURT ÜNİVERSİTESİ',
  'BEYKOZ ÜNİVERSİTESİ',
  'BEZM-İ ÂLEM VAKIF ÜNİVERSİTESİ',
  'BİLECİK ŞEYH EDEBALİ ÜNİVERSİTESİ',
  'BİNGÖL ÜNİVERSİTESİ',
  'BİRUNİ ÜNİVERSİTESİ',
  'BİTLİS EREN ÜNİVERSİTESİ',
  'BOĞAZİÇİ ÜNİVERSİTESİ',
  'BOLU ABANT İZZET BAYSAL ÜNİVERSİTESİ',
  'BURDUR MEHMET AKİF ERSOY ÜNİVERSİTESİ',
  'BURSA TEKNİK ÜNİVERSİTESİ',
  'BURSA ULUDAĞ ÜNİVERSİTESİ',
  'ÇAĞ ÜNİVERSİTESİ',
  'ÇANAKKALE ONSEKİZ MART ÜNİVERSİTESİ',
  'ÇANKAYA ÜNİVERSİTESİ',
  'ÇANKIRI KARATEKİN ÜNİVERSİTESİ',
  'ÇUKUROVA ÜNİVERSİTESİ',
  'DEMİROĞLU BİLİM ÜNİVERSİTESİ',
  'DİCLE ÜNİVERSİTESİ',
  'DOĞUŞ ÜNİVERSİTESİ',
  'DOKUZ EYLÜL ÜNİVERSİTESİ',
  'DÜZCE ÜNİVERSİTESİ',
  'EGE ÜNİVERSİTESİ',
  'ERCİYES ÜNİVERSİTESİ',
  'ERZİNCAN BİNALİ YILDIRIM ÜNİVERSİTESİ',
  'ERZURUM TEKNİK ÜNİVERSİTESİ',
  'ESKİŞEHİR OSMANGAZİ ÜNİVERSİTESİ',
  'ESKİŞEHİR TEKNİK ÜNİVERSİTESİ',
  'FATİH SULTAN MEHMET VAKIF ÜNİVERSİTESİ',
  'FENERBAHÇE ÜNİVERSİTESİ',
  'FIRAT ÜNİVERSİTESİ',
  'GALATASARAY ÜNİVERSİTESİ',
  'GAZİ ÜNİVERSİTESİ',
  'GAZİANTEP İSLAM BİLİM VE TEKNOLOJİ ÜNİVERSİTESİ',
  'GAZİANTEP ÜNİVERSİTESİ',
  'GEBZE TEKNİK ÜNİVERSİTESİ',
  'GİRESUN ÜNİVERSİTESİ',
  'GÜMÜŞHANE ÜNİVERSİTESİ',
  'HACETTEPE ÜNİVERSİTESİ',
  'HAKKARİ ÜNİVERSİTESİ',
  'HALİÇ ÜNİVERSİTESİ',
  'HARRAN ÜNİVERSİTESİ',
  'HASAN KALYONCU ÜNİVERSİTESİ',
  'HATAY MUSTAFA KEMAL ÜNİVERSİTESİ',
  'HİTİT ÜNİVERSİTESİ',
  'IĞDIR ÜNİVERSİTESİ',
  'ISPARTA UYGULAMALI BİLİMLER ÜNİVERSİTESİ',
  'IŞIK ÜNİVERSİTESİ',
  'İBN HALDUN ÜNİVERSİTESİ',
  'İHSAN DOĞRAMACI BİLKENT ÜNİVERSİTESİ',
  'İNÖNÜ ÜNİVERSİTESİ',
  'İSKENDERUN TEKNİK ÜNİVERSİTESİ',
  'İSTANBUL 29 MAYIS ÜNİVERSİTESİ',
  'İSTANBUL AREL ÜNİVERSİTESİ',
  'İSTANBUL ATLAS ÜNİVERSİTESİ',
  'İSTANBUL AYDIN ÜNİVERSİTESİ',
  'İSTANBUL BEYKENT ÜNİVERSİTESİ',
  'İSTANBUL BİLGİ ÜNİVERSİTESİ',
  'İSTANBUL ESENYURT ÜNİVERSİTESİ',
  'İSTANBUL GALATA ÜNİVERSİTESİ',
  'İSTANBUL GEDİK ÜNİVERSİTESİ',
  'İSTANBUL GELİŞİM ÜNİVERSİTESİ',
  'İSTANBUL KENT ÜNİVERSİTESİ',
  'İSTANBUL KÜLTÜR ÜNİVERSİTESİ',
  'İSTANBUL MEDENİYET ÜNİVERSİTESİ',
  'İSTANBUL MEDİPOL ÜNİVERSİTESİ',
  'İSTANBUL NİŞANTAŞI ÜNİVERSİTESİ',
  'İSTANBUL OKAN ÜNİVERSİTESİ',
  'İSTANBUL RUMELİ ÜNİVERSİTESİ',
  'İSTANBUL SABAHATTİN ZAİM ÜNİVERSİTESİ',
  'İSTANBUL SAĞLIK VE SOSYAL BİLİMLER MESLEK YÜKSEKOKULU',
  'İSTANBUL SAĞLIK VE TEKNOLOJİ ÜNİVERSİTESİ',
  'İSTANBUL ŞİŞLİ MESLEK YÜKSEKOKULU',
  'İSTANBUL TEKNİK ÜNİVERSİTESİ',
  'İSTANBUL TİCARET ÜNİVERSİTESİ',
  'İSTANBUL TOPKAPI ÜNİVERSİTESİ',
  'İSTANBUL ÜNİVERSİTESİ',
  'İSTANBUL ÜNİVERSİTESİ-CERRAHPAŞA',
  'İSTANBUL YENİ YÜZYIL ÜNİVERSİTESİ',
  'İSTİNYE ÜNİVERSİTESİ',
  'İZMİR BAKIRÇAY ÜNİVERSİTESİ',
  'İZMİR DEMOKRASİ ÜNİVERSİTESİ',
  'İZMİR EKONOMİ ÜNİVERSİTESİ',
  'İZMİR KATİP ÇELEBİ ÜNİVERSİTESİ',
  'İZMİR KAVRAM MESLEK YÜKSEKOKULU',
  'İZMİR TINAZTEPE ÜNİVERSİTESİ',
  'İZMİR YÜKSEK TEKNOLOJİ ENSTİTÜSÜ',
  'KADİR HAS ÜNİVERSİTESİ',
  'KAFKAS ÜNİVERSİTESİ',
  'KAHRAMANMARAŞ İSTİKLAL ÜNİVERSİTESİ',
  'KAHRAMANMARAŞ SÜTÇÜ İMAM ÜNİVERSİTESİ',
  'KAPADOKYA ÜNİVERSİTESİ',
  'KARABÜK ÜNİVERSİTESİ',
  'KARADENİZ TEKNİK ÜNİVERSİTESİ',
  'KARAMANOĞLU MEHMETBEY ÜNİVERSİTESİ',
  'KASTAMONU ÜNİVERSİTESİ',
  'KAYSERİ ÜNİVERSİTESİ',
  'KIRIKKALE ÜNİVERSİTESİ',
  'KIRKLARELİ ÜNİVERSİTESİ',
  'KIRŞEHİR AHİ EVRAN ÜNİVERSİTESİ',
  'KİLİS 7 ARALIK ÜNİVERSİTESİ',
  'KOCAELİ SAĞLIK VE TEKNOLOJİ ÜNİVERSİTESİ',
  'KOCAELİ ÜNİVERSİTESİ',
  'KOÇ ÜNİVERSİTESİ',
  'KONYA GIDA VE TARIM ÜNİVERSİTESİ',
  'KONYA TEKNİK ÜNİVERSİTESİ',
  'KTO KARATAY ÜNİVERSİTESİ',
  'KÜTAHYA DUMLUPINAR ÜNİVERSİTESİ',
  'KÜTAHYA SAĞLIK BİLİMLERİ ÜNİVERSİTESİ',
  'LOKMAN HEKİM ÜNİVERSİTESİ',
  'MALATYA TURGUT ÖZAL ÜNİVERSİTESİ',
  'MALTEPE ÜNİVERSİTESİ',
  'MANİSA CELÂL BAYAR ÜNİVERSİTESİ',
  'MARDİN ARTUKLU ÜNİVERSİTESİ',
  'MARMARA ÜNİVERSİTESİ',
  'MEF ÜNİVERSİTESİ',
  'MERSİN ÜNİVERSİTESİ',
  'MİMAR SİNAN GÜZEL SANATLAR ÜNİVERSİTESİ',
  'MUDANYA ÜNİVERSİTESİ',
  'MUĞLA SITKI KOÇMAN ÜNİVERSİTESİ',
  'MUNZUR ÜNİVERSİTESİ',
  'MUŞ ALPARSLAN ÜNİVERSİTESİ',
  'NECMETTİN ERBAKAN ÜNİVERSİTESİ',
  'NEVŞEHİR HACI BEKTAŞ VELİ ÜNİVERSİTESİ',
  'NİĞDE ÖMER HALİSDEMİR ÜNİVERSİTESİ',
  'NUH NACİ YAZGAN ÜNİVERSİTESİ',
  'ONDOKUZ MAYIS ÜNİVERSİTESİ',
  'ORDU ÜNİVERSİTESİ',
  'ORTA DOĞU TEKNİK ÜNİVERSİTESİ',
  'OSMANİYE KORKUT ATA ÜNİVERSİTESİ',
  'OSTİM TEKNİK ÜNİVERSİTESİ',
  'ÖZYEĞİN ÜNİVERSİTESİ',
  'PAMUKKALE ÜNİVERSİTESİ',
  'PİRİ REİS ÜNİVERSİTESİ',
  'RECEP TAYYİP ERDOĞAN ÜNİVERSİTESİ',
  'SABANCI ÜNİVERSİTESİ',
  'SAĞLIK BİLİMLERİ ÜNİVERSİTESİ',
  'SAKARYA UYGULAMALI BİLİMLER ÜNİVERSİTESİ',
  'SAKARYA ÜNİVERSİTESİ',
  'SAMSUN ÜNİVERSİTESİ',
  'SANKO ÜNİVERSİTESİ',
  'SELÇUK ÜNİVERSİTESİ',
  'SİİRT ÜNİVERSİTESİ',
  'SİNOP ÜNİVERSİTESİ',
  'SİVAS BİLİM VE TEKNOLOJİ ÜNİVERSİTESİ',
  'SİVAS CUMHURİYET ÜNİVERSİTESİ',
  'SÜLEYMAN DEMİREL ÜNİVERSİTESİ',
  'ŞIRNAK ÜNİVERSİTESİ',
  'TARSUS ÜNİVERSİTESİ',
  'TED ÜNİVERSİTESİ',
  'TEKİRDAĞ NAMIK KEMAL ÜNİVERSİTESİ',
  'TOBB EKONOMİ VE TEKNOLOJİ ÜNİVERSİTESİ',
  'TOKAT GAZİOSMANPAŞA ÜNİVERSİTESİ',
  'TOROS ÜNİVERSİTESİ',
  'TRABZON ÜNİVERSİTESİ',
  'TRAKYA ÜNİVERSİTESİ',
  'TÜRK HAVA KURUMU ÜNİVERSİTESİ',
  'TÜRK-ALMAN ÜNİVERSİTESİ',
  'UFUK ÜNİVERSİTESİ',
  'UŞAK ÜNİVERSİTESİ',
  'ÜSKÜDAR ÜNİVERSİTESİ',
  'VAN YÜZÜNCÜ YIL ÜNİVERSİTESİ',
  'YALOVA ÜNİVERSİTESİ',
  'YAŞAR ÜNİVERSİTESİ',
  'YEDİTEPE ÜNİVERSİTESİ',
  'YILDIZ TEKNİK ÜNİVERSİTESİ',
  'YOZGAT BOZOK ÜNİVERSİTESİ',
  'YÜKSEK İHTİSAS ÜNİVERSİTESİ',
  'ZONGULDAK BÜLENT ECEVİT ÜNİVERSİTESİ',
];

class AddressDetailScreen extends StatefulWidget {
  final double lat;
  final double lng;
  final String city;
  final String district;
  final String neighborhood;
  final String street;

  const AddressDetailScreen({
    super.key,
    required this.lat,
    required this.lng,
    required this.city,
    required this.district,
    required this.neighborhood,
    required this.street,
  });

  @override
  State<AddressDetailScreen> createState() => _AddressDetailScreenState();
}

class _AddressDetailScreenState extends State<AddressDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving   = false;
  String _title  = 'Ev';

  late String       _city;
  late String       _district;
  late String       _neighborhood;
  late List<String> _districts;
  late List<String> _neighborhoods;

  late final TextEditingController _streetCtrl;
  // Ev
  final _siteCtrl     = TextEditingController(); // Site / Apartman Adı
  final _buildingCtrl = TextEditingController(); // Bina / Blok
  final _floorCtrl    = TextEditingController(); // Kat
  final _doorCtrl     = TextEditingController(); // Daire
  // İş — reuses _buildingCtrl, _floorCtrl, _doorCtrl
  // Okul
  String _university  = '';
  final _facultyCtrl  = TextEditingController(); // Fakülte / Blok
  // Tüm tipler
  final _descCtrl     = TextEditingController(); // Adres tarifi

  @override
  void initState() {
    super.initState();
    _streetCtrl = TextEditingController(text: widget.street);
    final cities = TurkeyGeoData.allCities;
    _city        = _matchCity(widget.city, cities);
    _districts   = TurkeyGeoData.getDistricts(_city);
    // GPS'den ilçe gelmediyse mahalle adından bulmaya çalış
    String gpsDist = widget.district;
    if (gpsDist.isEmpty && widget.neighborhood.isNotEmpty) {
      gpsDist = TurkeyGeoData.findDistrictByNeighborhood(_city, widget.neighborhood);
    }
    _district      = gpsDist; // kullanıcı boş bırakabilir, zorunlu validator yakalar
    _neighborhoods = TurkeyGeoData.getNeighborhoods(_district);
    _neighborhood  = widget.neighborhood.isNotEmpty ? widget.neighborhood
        : (_neighborhoods.isNotEmpty ? _neighborhoods.first : '');
  }

  @override
  void dispose() {
    _streetCtrl.dispose();
    _siteCtrl.dispose();
    _buildingCtrl.dispose();
    _floorCtrl.dispose();
    _doorCtrl.dispose();
    _facultyCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _matchCity(String raw, List<String> list) {
    if (list.isEmpty) return '';
    if (raw.isEmpty) return list.first;
    final lo = raw.toLowerCase();
    for (final c in list) {
      if (c.toLowerCase() == lo || lo.contains(c.toLowerCase())) return c;
    }
    return list.first;
  }

  void _onCityChanged(String? city) {
    if (city == null) return;
    final dists  = TurkeyGeoData.getDistricts(city);
    final dist   = dists.isNotEmpty ? dists.first : '';
    final neighs = TurkeyGeoData.getNeighborhoods(dist);
    setState(() {
      _city = city; _districts = dists; _district = dist;
      _neighborhoods = neighs;
      _neighborhood  = neighs.isNotEmpty ? neighs.first : '';
    });
  }

  void _onDistrictChanged(String dist) {
    final neighs = TurkeyGeoData.getNeighborhoods(dist);
    setState(() {
      _district = dist; _neighborhoods = neighs;
      // Mahalle alanını sıfırla
      _neighborhood = neighs.isNotEmpty ? neighs.first : '';
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Okul: üniversite seçilmeli
    if (_title == 'Okul' && _university.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lütfen üniversite seçiniz'),
        backgroundColor: AppTheme.red,
      ));
      return;
    }
    setState(() => _saving = true);
    try {
      final addr = UserAddress(
        id          : const Uuid().v4(),
        title       : _title,
        lat         : widget.lat,
        lng         : widget.lng,
        city        : _city,
        district    : _district,
        neighborhood: _neighborhood,
        street      : _streetCtrl.text.trim(),
        aptName     : _title == 'Okul'
            ? _university
            : _siteCtrl.text.trim(),
        buildingNo  : _title == 'Okul'
            ? _facultyCtrl.text.trim()
            : (_title == 'Diğer' ? '' : _buildingCtrl.text.trim()),
        floor       : (_title == 'Ev' || _title == 'İş')
            ? _floorCtrl.text.trim() : '',
        apartmentNo : (_title == 'Ev' || _title == 'İş')
            ? _doorCtrl.text.trim() : '',
        directions  : _descCtrl.text.trim(),
      );
      if (!mounted) return;
      await context.read<AuthProvider>().addAddress(addr);
      if (!mounted) return;
      context.read<RestaurantProvider>().setCity(_city);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Adres kaydedildi ✓'),
        backgroundColor: AppTheme.primaryGreen,
      ));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Kayıt hatası: $e'),
        backgroundColor: AppTheme.red,
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cities = TurkeyGeoData.allCities;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Adres Detayları')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [

          // ── Adres Tipi ─────────────────────────────────────────
          _label('Adres Tipi'),
          _TypeSelector(
            selected: _title,
            onChanged: (t) => setState(() {
              _title = t;
              // alanları sıfırla
              _siteCtrl.clear(); _buildingCtrl.clear();
              _floorCtrl.clear(); _doorCtrl.clear();
              _facultyCtrl.clear(); _descCtrl.clear();
              _university = '';
            }),
          ),
          const SizedBox(height: 20),

          // ── İl ─────────────────────────────────────────────────
          _label('İl *'),
          _dropdown(
            value: cities.contains(_city) ? _city : (cities.isNotEmpty ? cities.first : null),
            items: cities, onChanged: _onCityChanged),
          const SizedBox(height: 14),

          // ── İlçe ───────────────────────────────────────────────
          _label('İlçe *'),
          _SearchableField(
            value: _district,
            hint: 'İlçe yazın veya seçin',
            suggestions: _districts,
            onChanged: _onDistrictChanged,
            validator: (v) => (v?.trim().isEmpty ?? true) ? 'Zorunlu alan' : null,
          ),
          const SizedBox(height: 14),

          // ── Mahalle ────────────────────────────────────────────
          _label('Mahalle *'),
          _NeighborhoodField(
            value: _neighborhood,
            suggestions: _neighborhoods,
            onChanged: (v) => setState(() => _neighborhood = v),
          ),
          const SizedBox(height: 14),

          // ── Cadde / Sokak ──────────────────────────────────────
          _label('Cadde / Sokak *'),
          _field(_streetCtrl, 'Örn: Atatürk Caddesi',
            validator: (v) => (v?.trim().isEmpty ?? true) ? 'Zorunlu alan' : null),
          const SizedBox(height: 14),

          // ── Tipe özel alanlar ──────────────────────────────────
          ..._typeFields(),

          const SizedBox(height: 32),

          // ── Kaydet ─────────────────────────────────────────────
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _saving
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Adresi Kaydet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          )),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  // ── Tipe göre değişen alanlar ───────────────────────────────────
  List<Widget> _typeFields() {
    switch (_title) {
      case 'Ev':
        return [
          _label('Site / Apartman Adı (Opsiyonel)'),
          _field(_siteCtrl, 'Örn: Güneş Sitesi, Lale Apartmanı'),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Bina / Blok *'),
              _field(_buildingCtrl, '12A',
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Zorunlu' : null),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Kat *'),
              _field(_floorCtrl, '3', type: TextInputType.number,
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Zorunlu' : null),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Daire *'),
              _field(_doorCtrl, '7', type: TextInputType.number,
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Zorunlu' : null),
            ])),
          ]),
          const SizedBox(height: 14),
          _label('Adres Tarifi (Opsiyonel)'),
          _field(_descCtrl, 'Örn: Sarı bina, 2. giriş', maxLines: 3),
        ];

      case 'İş':
        return [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Bina / Blok *'),
              _field(_buildingCtrl, '12A',
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Zorunlu' : null),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Kat'),
              _field(_floorCtrl, '3', type: TextInputType.number),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Daire No'),
              _field(_doorCtrl, '7', type: TextInputType.number),
            ])),
          ]),
          const SizedBox(height: 14),
          _label('Adres Tarifi (Opsiyonel)'),
          _field(_descCtrl, 'Örn: A blok, güney cephe', maxLines: 3),
        ];

      case 'Okul':
        return [
          _label('Üniversite Adı *'),
          _SearchableField(
            value: _university,
            hint: 'Üniversite adı yazın veya seçin',
            suggestions: _kUniversities,
            onChanged: (v) => setState(() => _university = v),
          ),
          const SizedBox(height: 14),
          _label('Fakülte / Blok (Opsiyonel)'),
          _field(_facultyCtrl, 'Örn: Mühendislik Fakültesi, B Blok'),
          const SizedBox(height: 14),
          _label('Ekstra Adres Tarifi (Opsiyonel)'),
          _field(_descCtrl, 'Örn: Kütüphane yanı, kuzey kapı', maxLines: 3),
        ];

      case 'Diğer':
      default:
        return [
          _label('Adres Tarifi (Opsiyonel)'),
          _field(_descCtrl, 'Örn: AVM giriş katı, 3. kapı', maxLines: 3),
        ];
    }
  }

  // ── Yardımcı widget'lar ─────────────────────────────────────────

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.grey)));

  Widget _dropdown({String? value, required List<String> items,
      required Function(String?) onChanged}) {
    final safe = (value != null && items.contains(value))
        ? value : (items.isNotEmpty ? items.first : null);
    if (safe == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: safe, isExpanded: true,
        items: items.map((i) => DropdownMenuItem(
            value: i, child: Text(i, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: onChanged,
      )),
    );
  }

  Widget _field(TextEditingController ctrl, String hint,
      {int maxLines = 1, TextInputType? type,
       String? Function(String?)? validator}) =>
    TextFormField(
      controller: ctrl, maxLines: maxLines,
      keyboardType: type, validator: validator,
      decoration: InputDecoration(
        hintText: hint, filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryGreen)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.red)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
}

// ── Adres tipi seçici (2×2 grid) ────────────────────────────────
class _TypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _TypeSelector({required this.selected, required this.onChanged});

  static const _types = [
    ('Ev',    Icons.home_outlined),
    ('İş',    Icons.work_outline),
    ('Okul',  Icons.school_outlined),
    ('Diğer', Icons.location_on_outlined),
  ];

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 4,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    childAspectRatio: 1.1,
    children: _types.map((e) {
      final active = selected == e.$1;
      return GestureDetector(
        onTap: () => onChanged(e.$1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: active ? AppTheme.primaryGreen : Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(e.$2,
                  color: active ? Colors.white : AppTheme.grey, size: 22),
              const SizedBox(height: 4),
              Text(e.$1, style: TextStyle(
                color: active ? Colors.white : AppTheme.grey,
                fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }).toList(),
  );
}

// ── Arama kutulu seçim alanı (mahalle ve üniversite için) ────────
class _SearchableField extends StatefulWidget {
  final String value;
  final String hint;
  final List<String> suggestions;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  const _SearchableField({
    required this.value,
    required this.hint,
    required this.suggestions,
    required this.onChanged,
    this.validator,
  });
  @override
  State<_SearchableField> createState() => _SearchableFieldState();
}

class _SearchableFieldState extends State<_SearchableField> {
  late TextEditingController _ctrl;
  late FocusNode _focus;
  bool _showList = false;
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _ctrl  = TextEditingController(text: widget.value);
    _focus = FocusNode();
    _focus.addListener(() {
      if (!_focus.hasFocus && mounted) setState(() => _showList = false);
    });
    _filtered = widget.suggestions;
  }

  @override
  void didUpdateWidget(_SearchableField old) {
    super.didUpdateWidget(old);
    if (old.suggestions != widget.suggestions) {
      _filtered = widget.suggestions;
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  void _onChanged(String v) {
    widget.onChanged(v);
    final q = v.toLowerCase();
    setState(() {
      _showList = true;
      _filtered = q.isEmpty
          ? widget.suggestions
          : widget.suggestions
              .where((s) => s.toLowerCase().contains(q)).toList();
    });
  }

  void _select(String v) {
    _ctrl.text = v;
    widget.onChanged(v);
    _focus.unfocus();
    setState(() => _showList = false);
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        controller: _ctrl,
        focusNode: _focus,
        onChanged: _onChanged,
        validator: widget.validator,
        onTap: () => setState(() {
          _showList = true;
          _filtered = widget.suggestions;
        }),
        decoration: InputDecoration(
          hintText: widget.hint,
          filled: true, fillColor: Colors.white,
          suffixIcon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryGreen)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      if (_showList && _filtered.isNotEmpty)
        Container(
          constraints: const BoxConstraints(maxHeight: 220),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12)),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: _filtered.map((s) => ListTile(
              dense: true,
              title: Text(s, style: const TextStyle(fontSize: 13)),
              onTap: () => _select(s),
            )).toList(),
          ),
        ),
    ],
  );
}

// ── Mahalle alanı (_SearchableField ile aynı ama zorunlu validator ─
class _NeighborhoodField extends StatelessWidget {
  final String value;
  final List<String> suggestions;
  final ValueChanged<String> onChanged;
  const _NeighborhoodField({
    required this.value,
    required this.suggestions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => _SearchableField(
    value: value,
    hint: 'Mahalle yazın veya listeden seçin',
    suggestions: suggestions,
    onChanged: onChanged,
    validator: (v) => (v?.trim().isEmpty ?? true) ? 'Zorunlu alan' : null,
  );
}
