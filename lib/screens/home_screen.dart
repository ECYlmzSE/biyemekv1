import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/restaurant_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../models/restaurant.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/connectivity_banner.dart';
import '../widgets/app_image.dart';
import 'restaurant_detail_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'filter_screen.dart';
import 'address_screen.dart';
import 'live_support_screen.dart';
import 'all_restaurants_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomePage(),
      const _SearchPage(),
      const OrdersScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: ConnectivityWrapper(child: pages[_idx]),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (ctx, cart, _) => Column(mainAxisSize: MainAxisSize.min, children: [
          if (!cart.isEmpty)
            GestureDetector(
              onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const CartScreen())),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(8)),
                    child: Text('${cart.itemCount}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Sepeti Görüntüle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15))),
                  Text('₺${cart.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ]),
              ),
            ),
          NavigationBar(
            selectedIndex: _idx,
            onDestinationSelected: (i) => setState(() => _idx = i),
            indicatorColor: AppTheme.primaryGreen.withOpacity(0.15),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Ana Sayfa'),
              NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Keşfet'),
              NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Siparişler'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
        ]),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// HOME PAGE
// ──────────────────────────────────────────────
class _BannerData {
  final String emoji, title, subtitle, code;
  final Color color1, color2;
  const _BannerData({required this.emoji, required this.title, required this.subtitle, required this.code, required this.color1, required this.color2});
}

class _HomePage extends StatefulWidget {
  const _HomePage();
  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  late final PageController _bannerCtrl;
  int _bannerIdx = 0;
  String? _lastLoadedAddressId; // track which address we last loaded for

  final List<_BannerData> _banners = [
    const _BannerData(emoji: '🍕', title: "Tüm Yemeklerde %30 İndirim", subtitle: "Tüm siparişlerde geçerli — BIYEMEK30", code: "BIYEMEK30", color1: Color(0xFFFF6B35), color2: Color(0xFFFF8C42)),
    const _BannerData(emoji: '☕', title: "Kahve Saati", subtitle: "Kahve & İçecek kategorisinde %15 indirim", code: "KAHVE15", color1: Color(0xFF6F4E37), color2: Color(0xFF8B6355)),
    const _BannerData(emoji: '🌮', title: "Sokak Lezzetleri", subtitle: "Sokak Lezzetleri kategorisinde %25 indirim", code: "SOKAK25", color1: Color(0xFFE91E8C), color2: Color(0xFFFF4B6E)),
    const _BannerData(emoji: '🎉', title: "İlk Siparişine Özel", subtitle: "İlk siparişinde %20 indirim — HOSGELDIN", code: "HOSGELDIN", color1: Color(0xFF7C3AED), color2: Color(0xFF9F67FA)),
  ];


  @override
  void initState() {
    super.initState();
    _bannerCtrl = PageController();
    Future.delayed(const Duration(seconds: 3), _autoScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNearbyIfNeeded());
  }

  /// Loads real restaurants near the selected address.
  /// Priority: selected address lat/lng → GPS → last known GPS → city coords.
  Future<void> _loadNearbyIfNeeded({bool force = false}) async {
    if (!mounted) return;
    final rp = context.read<RestaurantProvider>();
    if (!force && rp.hasRealData) return;

    final auth = context.read<AuthProvider>();
    final addr = auth.selectedAddress;

    // 1. Use selected address coordinates if available
    if (addr != null && addr.lat != null && addr.lng != null &&
        addr.lat! != 0.0 && addr.lng! != 0.0) {
      await rp.loadRealRestaurants(addr.lat!, addr.lng!, bypassCache: force);
      if (mounted) {
        if (addr.city.isNotEmpty) rp.syncCity(addr.city);
        _lastLoadedAddressId = addr.id;
      }
      return;
    }

    // 1b. Address has city but no lat/lng — use city coordinates (no GPS needed)
    if (addr != null && addr.city.isNotEmpty) {
      final coords = DataService.getCityCoordinates(addr.city);
      await rp.loadRealRestaurants(coords.lat, coords.lng, bypassCache: force);
      if (mounted) {
        rp.syncCity(addr.city);
        _lastLoadedAddressId = addr.id;
      }
      return;
    }

    // 2. Try GPS (8s timeout)
    try {
      final perm = await Geolocator.checkPermission();
      LocationPermission effective = perm;
      if (perm == LocationPermission.denied) {
        effective = await Geolocator.requestPermission();
      }
      if (effective != LocationPermission.denied &&
          effective != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 8),
        );
        await rp.loadRealRestaurants(pos.latitude, pos.longitude, bypassCache: force);
        if (mounted) _lastLoadedAddressId = addr?.id;
        return;
      }
    } catch (_) {}

    // 3. Last known GPS position
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        await rp.loadRealRestaurants(last.latitude, last.longitude, bypassCache: force);
        if (mounted) _lastLoadedAddressId = addr?.id;
        return;
      }
    } catch (_) {}

    // 4. Fallback: city coordinates from DataService
    final coords = DataService.getCityCoordinates(rp.selectedCity);
    await rp.loadRealRestaurants(coords.lat, coords.lng, bypassCache: force);
    if (mounted) _lastLoadedAddressId = addr?.id;
  }




  void _autoScroll() {
    if (!mounted) return;
    final next = (_bannerIdx + 1) % _banners.length;
    _bannerCtrl.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    Future.delayed(const Duration(seconds: 4), _autoScroll);
  }

  @override
  void dispose() {
    _bannerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rp = context.watch<RestaurantProvider>();
    final auth = context.watch<AuthProvider>();

    // When selected address city changes, reload restaurants for the new location.
    // Works even when the address has no lat/lng (manually entered addresses).
    final addr = auth.selectedAddress;
    final addressChanged = addr != null && addr.id != _lastLoadedAddressId;
    // Adres yoksa GPS ile yükle
    if (addr == null && !rp.hasRealData && !rp.isLoadingReal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadNearbyIfNeeded();
      });
    }

    if (addr != null &&
        (!rp.hasRealData || addressChanged) &&
        !rp.isLoadingReal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final rp2 = context.read<RestaurantProvider>();
        // City changed → setCity clears hasRealData.
        // Same city but different address → markStale clears hasRealData.
        if (addr.city.toLowerCase() != rp2.selectedCity.toLowerCase()) {
          rp2.setCity(addr.city);
        } else if (addr.id != _lastLoadedAddressId) {
          rp2.markStale();
        }
        _loadNearbyIfNeeded();
      });
    }

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: _buildHeader(context, auth)),
      SliverToBoxAdapter(child: _buildSearchBar(context, rp)),
      SliverToBoxAdapter(child: _buildBanners()),
      SliverToBoxAdapter(child: _buildCategories(rp)),
      if (rp.isLoadingReal)
        const SliverToBoxAdapter(child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen)),
            SizedBox(width: 10),
            Text('Yakınındaki restoranlar yükleniyor...', style: TextStyle(color: AppTheme.grey, fontSize: 13)),
          ]),
        )),
      if (rp.selectedCategory == 'Tümü') ...[
        SliverToBoxAdapter(child: _sectionHeader(context, '🔥 Popüler Restoranlar', rp.topRated)),
        SliverToBoxAdapter(child: _buildHList(context, rp.topRated)),
        SliverToBoxAdapter(child: _sectionHeader(context, '📍 Yakınındakiler', rp.nearbyRestaurants)),
        SliverList(delegate: SliverChildBuilderDelegate(
          (ctx2, i) {
            final list = rp.nearbyRestaurants;
            if (i >= list.length) return null;
            return _RestCard(restaurant: list[i]);
          },
          childCount: rp.nearbyRestaurants.length.clamp(0, 20),
        )),
      ] else ...[
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(children: [
            Text('${rp.selectedCategory}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Text('${rp.filteredRestaurants.length} restoran', style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ]),
        )),
        SliverList(delegate: SliverChildBuilderDelegate(
          (ctx2, i) {
            final list = rp.filteredRestaurants;
            if (i >= list.length) return null;
            return _RestCard(restaurant: list[i]);
          },
          childCount: rp.filteredRestaurants.length.clamp(0, 50),
        )),
      ],
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
    ]);
  }

  Widget _buildHeader(BuildContext context, AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 0),
      child: Row(children: [
        Expanded(child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen())),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 14),
              const SizedBox(width: 4),
              Text('Teslimat Adresi', style: TextStyle(fontSize: 11, color: AppTheme.grey)),
            ]),
            Row(children: [
              Flexible(child: Consumer<AuthProvider>(
                builder: (_, a, __) => Text(
                  a.isLoggedIn
                    ? (a.selectedAddress?.shortAddress ?? 'Adres Ekle')
                    : 'Giriş Yapın',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              )),
              const Icon(Icons.keyboard_arrow_down, size: 18),
            ]),
          ]),
        )),
        Material(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveSupportScreen())),
            child: Container(padding: const EdgeInsets.all(10), child: const Icon(Icons.headset_mic_outlined, size: 24)),
          ),
        ),
      ]),
    );
  }



  Widget _buildSearchBar(BuildContext context, RestaurantProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        Expanded(child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // Navigate to search tab (index 1) in HomeScreen
            final homeState = context.findAncestorStateOfType<_HomeScreenState>();
            homeState?.setState(() => homeState._idx = 1);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.search, color: AppTheme.grey),
              const SizedBox(width: 10),
              const Text('Restoran veya yemek ara...', style: TextStyle(color: AppTheme.grey, fontSize: 14)),
            ]),
          ),
        )),
        const SizedBox(width: 10),
        Material(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen())),
            child: Container(
              padding: const EdgeInsets.all(13),
              child: Stack(clipBehavior: Clip.none, children: [
                const Icon(Icons.tune),
                if (p.activeFilterCount > 0)
                  Positioned(right: -4, top: -4, child: Container(
                    width: 14, height: 14,
                    decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
                    child: Center(child: Text('${p.activeFilterCount}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                  )),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildBanners() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _bannerCtrl,
            onPageChanged: (i) => setState(() => _bannerIdx = i),
            itemCount: _banners.length,
            itemBuilder: (ctx, i) {
              final b = _banners[i];
              return GestureDetector(
                onTap: () => ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Kod: ${b.code}'), backgroundColor: AppTheme.primaryGreen, duration: const Duration(seconds: 2)),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [b.color1, b.color2], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(b.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(b.subtitle, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text('Kod: ${b.code}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ])),
                      Text(b.emoji, style: const TextStyle(fontSize: 60)),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _bannerIdx == i ? 20 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _bannerIdx == i ? AppTheme.primaryGreen : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          )),
        ),
      ]),
    );
  }

  /// Maps each category name to its local asset file.
  static const _catAsset = <String, String>{
    'Pizza'             : 'assets/categories/pizza.png',
    'Tavuk'             : 'assets/categories/tavuk.png',
    'Burger'            : 'assets/categories/burger.png',
    'Döner'             : 'assets/categories/doner.png',
    'Pide & Lahmacun'   : 'assets/categories/pide_lahmacun.png',
    'Sokak Lezzetleri'  : 'assets/categories/sokak_lezzetleri.png',
    'Çiğ Köfte'         : 'assets/categories/cig_kofte.png',
    'Kahvaltı'          : 'assets/categories/kahvalti.png',
    'Et'                : 'assets/categories/et.png',
    'Deniz Ürünleri'    : 'assets/categories/deniz_urunleri.png',
    'Mantı & Makarna'   : 'assets/categories/manti_makarna.png',
    'Vegan & Vejetaryen': 'assets/categories/vegan_vejetaryen.png',
    'Kahve & İçecek'    : 'assets/categories/kahve_icecek.png',
    'Pastane & Fırın'   : 'assets/categories/pastane_firin.png',
    'Tatlı'             : 'assets/categories/tatli.png',
    'Aperatif'          : 'assets/categories/aperatif.png',
    'Ev Yemekleri'      : 'assets/categories/ev_yemekleri.png',
    'Dünya Mutfakları'  : 'assets/categories/dunya_mutfaklari.png',
  };

  Widget _buildCategories(RestaurantProvider p) {
    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        itemCount: p.categories.length,
        itemBuilder: (ctx, i) {
          final cat = p.categories[i];
          final sel = p.selectedCategory == cat;
          final asset = _catAsset[cat];
          return GestureDetector(
            onTap: () => p.setCategory(cat),
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    border: sel
                        ? Border.all(color: AppTheme.primaryGreen, width: 2.5)
                        : null,
                    boxShadow: sel
                        ? [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))]
                        : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: asset != null
                      ? ClipOval(
                          child: Image.asset(
                            asset,
                            width: 56, height: 56,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(child: Text('🍽️', style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 64,
                  child: Text(
                    cat,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.2,
                      color: sel ? AppTheme.primaryGreen : AppTheme.grey,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, List<Restaurant> list) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AllRestaurantsScreen(title: title, restaurants: list))),
          child: const Text('Tümünü Gör', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }

  Widget _buildHList(BuildContext context, List<Restaurant> list) {
    if (list.isEmpty) return const SizedBox(height: 8);
    return SizedBox(
      height: 205,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length,
        itemBuilder: (ctx, i) => _HCard(restaurant: list[i]),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// SEARCH PAGE
// ──────────────────────────────────────────────
class _SearchPage extends StatefulWidget {
  const _SearchPage();
  @override
  State<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RestaurantProvider>();
    if (_ctrl.text != p.searchQuery && p.searchQuery.isEmpty) _ctrl.clear();
    return SafeArea(child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(children: [
          Expanded(child: TextField(
            controller: _ctrl,
            focusNode: _focus,
            autofocus: false,
            onChanged: p.setSearchQuery,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Restoran, yemek ara...'),
          )),
          const SizedBox(width: 10),
          Material(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen())),
              child: Container(
                padding: const EdgeInsets.all(13),
                child: Stack(clipBehavior: Clip.none, children: [
                  const Icon(Icons.tune),
                  if (p.activeFilterCount > 0)
                    Positioned(right: -4, top: -4, child: Container(
                      width: 14, height: 14,
                      decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
                      child: Center(child: Text('${p.activeFilterCount}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                    )),
                ]),
              ),
            ),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${p.filteredRestaurants.length} restoran', style: TextStyle(color: AppTheme.grey, fontSize: 13)),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen())),
            child: Text(p.sortOption.label, style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ]),
      ),
      Expanded(child: p.filteredRestaurants.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('🔍', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 12),
              Text('Sonuç bulunamadı', style: TextStyle(color: AppTheme.grey)),
            ]))
          : ListView.builder(
              itemCount: p.filteredRestaurants.length,
              itemBuilder: (ctx, i) => _RestCard(restaurant: p.filteredRestaurants[i]),
            )),
    ]));
  }
}

// ──────────────────────────────────────────────
// CARDS
// ──────────────────────────────────────────────
class _HCard extends StatelessWidget {
  final Restaurant restaurant;
  const _HCard({required this.restaurant});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurant: restaurant))),
    child: Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: AppImage(url: restaurant.imageUrl, height: 110, width: double.infinity, fit: BoxFit.cover,
              errorWidget: Container(height: 110, color: Theme.of(context).scaffoldBackgroundColor, child: const Icon(Icons.restaurant, size: 40, color: AppTheme.grey))),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(restaurant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Row(children: [
              const Icon(Icons.star, size: 12, color: Colors.amber),
              const SizedBox(width: 2),
              Text('${restaurant.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
              Text(restaurant.deliveryTimeLabel, style: TextStyle(fontSize: 11, color: AppTheme.grey)),
            ]),
            const SizedBox(height: 2),
            Text(
              restaurant.deliveryFee == 0 ? 'Ücretsiz Teslimat' : '₺${restaurant.deliveryFee.toStringAsFixed(0)} teslimat',
              style: TextStyle(fontSize: 10, color: restaurant.deliveryFee == 0 ? AppTheme.primaryGreen : AppTheme.grey),
            ),
          ]),
        ),
      ]),
    ),
  );
}

class _RestCard extends StatelessWidget {
  final Restaurant restaurant;
  const _RestCard({required this.restaurant});

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      if (!restaurant.isOpen) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bu restoran şu an kapalı'), backgroundColor: AppTheme.grey));
        return;
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurant: restaurant)));
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: ColorFiltered(
              colorFilter: restaurant.isOpen
                  ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                  : const ColorFilter.matrix([0.2126,0.7152,0.0722,0,0, 0.2126,0.7152,0.0722,0,0, 0.2126,0.7152,0.0722,0,0, 0,0,0,1,0]),
              child: AppImage(url: restaurant.imageUrl, height: 155, width: double.infinity, fit: BoxFit.cover,
                  errorWidget: Container(height: 155, color: Theme.of(context).scaffoldBackgroundColor, child: const Icon(Icons.restaurant, size: 50, color: AppTheme.grey))),
            ),
          ),
          if (!restaurant.isOpen)
            Positioned.fill(child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: const Center(child: Text('KAPALI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2))),
            )),
          Positioned(top: 10, right: 10, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.star, size: 12, color: Colors.amber),
              const SizedBox(width: 2),
              Text('${restaurant.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ]),
          )),
          if (restaurant.badges.isNotEmpty)
            Positioned(top: 10, left: 10, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(20)),
              child: Text(restaurant.badges.first, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            )),
        ]),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(restaurant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 2),
            Text(restaurant.cuisine, style: TextStyle(fontSize: 12, color: AppTheme.grey)),
            const SizedBox(height: 8),
            Row(children: [
              _chip(Icons.schedule, restaurant.deliveryTimeLabel),
              const SizedBox(width: 12),
              _chip(Icons.delivery_dining, restaurant.deliveryFee == 0 ? 'Ücretsiz' : '₺${restaurant.deliveryFee.toStringAsFixed(0)}'),
              const SizedBox(width: 12),
              _chip(Icons.shopping_bag_outlined, 'Min ₺${restaurant.minOrder.toStringAsFixed(0)}'),
            ]),
          ]),
        ),
      ]),
    ),
  );

  Widget _chip(IconData icon, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 13, color: AppTheme.grey),
    const SizedBox(width: 3),
    Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
  ]);
}
