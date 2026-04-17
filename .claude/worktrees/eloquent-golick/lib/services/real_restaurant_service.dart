import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant.dart';
import 'data_service.dart';
import 'overpass_service.dart';
import 'foursquare_service.dart';

// ── Paste your Foursquare API key here ──────────────────────
// Get one free at https://developer.foursquare.com
// Leave empty to skip Foursquare enrichment (app still works).
const String kFoursquareApiKey = 'SHTFI2TNESRVYBGEKGYBATL31CEQDAIXDS0W1KJRJSRAFZWJ';

class RealRestaurantService {
  static final Random _rng = Random();

  // Cache TTL: 2 hours
  static const _cacheTtlMs = 2 * 60 * 60 * 1000;

  // ── Public entry point ────────────────────────────────────────
  /// Fetches restaurants near [lat]/[lng]. Returns cached data when fresh.
  /// Falls back gracefully to an empty list if all APIs fail.
  static Future<List<Restaurant>> fetchNearby({
    required double lat,
    required double lng,
    int radiusMeters = 5000,
    String foursquareApiKey = kFoursquareApiKey,
    bool bypassCache = false,
  }) async {
    // 1. Try cache first (unless force-refreshing)
    if (!bypassCache) {
      final cached = await _loadCache(lat, lng);
      if (cached != null) {
        debugPrint('RealRestaurantService: serving ${cached.length} restaurants from cache');
        return cached;
      }
    }

    // 2. Fetch from Overpass
    final osmList = await OverpassService.fetchNearby(
        lat: lat, lng: lng, radiusMeters: radiusMeters);

    if (osmList.isEmpty) {
      debugPrint('RealRestaurantService: Overpass returned nothing, skip');
      return [];
    }

    // 3. Optionally get location context (city/district) via Nominatim
    final geoCtx = await OverpassService.reverseGeocode(lat, lng);

    // 4. Optionally enrich with Foursquare
    final fsqMap = <String, FsqVenue>{};
    if (foursquareApiKey.isNotEmpty) {
      final fsqVenues = await FoursquareService.searchNearby(
        lat: lat,
        lng: lng,
        apiKey: foursquareApiKey,
        radiusMeters: radiusMeters,
      );
      for (final v in fsqVenues) {
        fsqMap[_normalize(v.name)] = v;
      }
    }

    // 5. Convert OSM → Restaurant
    final restaurants = <Restaurant>[];
    for (final osm in osmList) {
      final r = _buildRestaurant(osm, fsqMap, geoCtx, lat, lng);
      if (r != null) restaurants.add(r);
    }

    // Sort by distance
    restaurants.sort((a, b) => a.distance.compareTo(b.distance));

    // 6. Cache result
    if (restaurants.isNotEmpty) await _saveCache(lat, lng, restaurants);

    debugPrint('RealRestaurantService: built ${restaurants.length} restaurants');
    return restaurants;
  }

  // ── Build a single Restaurant from OSM + optional FSQ match ──
  static Restaurant? _buildRestaurant(
    OsmRestaurant osm,
    Map<String, FsqVenue> fsqMap,
    ({String city, String district}) geoCtx,
    double userLat,
    double userLng,
  ) {
    try {
      if (osm.name.isEmpty) return null;

      // --- Foursquare match by name proximity ---
      final fsqMatch = _findFsqMatch(osm, fsqMap);

      // --- Cuisine ---
      final cuisine = _detectCuisine(osm.name, osm.cuisine, osm.amenity);

      // --- Image ---
      final imageUrl = fsqMatch?.photoUrl ?? DataService.fallbackImageForRestaurant(cuisine, osm.name);

      // --- Rating ---
      // Foursquare rate is 0-10; we convert to 0-5
      final double rating = fsqMatch?.rating5 ??
          _round(3.3 + _rng.nextDouble() * 1.6, 1); // 3.3–4.9 range

      // --- Review count ---
      final reviewCount = _rng.nextInt(480) + 20; // 20–500

      // --- Reviews ---
      final reviewsToGenerate = min(8, 3 + _rng.nextInt(6));
      final reviews = _generateReviews(rating, reviewsToGenerate);

      // --- Is open ---
      // If OSM has opening_hours we could parse it, but for now use random
      // biased towards open (80% chance)
      final isOpen = _rng.nextDouble() > 0.2;

      // --- Distance ---
      final dist = _haversine(userLat, userLng, osm.lat, osm.lng);
      if (dist > (5500 / 1000)) return null; // 5.5 km hard limit

      // --- Delivery times based on distance ---
      final times = _deliveryTimes(dist);

      // --- Delivery fee ---
      final fee = dist < 1.5
          ? 0.0
          : dist < 3.0
              ? 9.99
              : dist < 5.0
                  ? 14.99
                  : 19.99;

      // --- Min order ---
      final minOrder = _minOrder(cuisine);

      // --- Tags & badges ---
      final tags = _tags(cuisine);
      final badges = _badges(rating, reviewCount);

      // --- District / City ---
      final district = osm.resolvedDistrict.isNotEmpty
          ? osm.resolvedDistrict
          : geoCtx.district;
      final city = osm.resolvedCity.isNotEmpty ? osm.resolvedCity : geoCtx.city;

      // --- Address ---
      final address = osm.fullAddress.isNotEmpty ? osm.fullAddress : osm.name;

      return Restaurant(
        id: osm.id,
        name: osm.name,
        imageUrl: imageUrl,
        cuisine: cuisine,
        rating: rating,
        reviewCount: reviewCount,
        deliveryTimeMin: times[0],
        deliveryTimeMax: times[1],
        deliveryFee: fee,
        minOrder: minOrder,
        isOpen: isOpen,
        tags: tags,
        menu: DataService.getMenuForRestaurantByName(osm.id, cuisine, osm.name),
        address: address,
        distance: _round(dist, 1),
        city: city,
        district: district,
        latitude: osm.lat,
        longitude: osm.lng,
        badges: badges,
        reviews: reviews,
      );
    } catch (e) {
      debugPrint('Build restaurant error (${osm.name}): $e');
      return null;
    }
  }

  // ── Cuisine detection ─────────────────────────────────────────
  static String _detectCuisine(String name, String? osmCuisine, String? amenity) {
    // ── Zincir isim kontrolü HER ŞEYDEN ÖNCE (OSM tag'ini geçersiz kılar) ──
    final nameLower = name.toLowerCase();
    if (_anyIn(nameLower, ['komagene', 'çiğ köfte', 'cig kofte',
        'çiğköfte', 'cigkofte', 'çiğköfteci', 'cigkofteci'])) return 'Çiğ Köfte';
    if (_anyIn(nameLower, ['mcdonalds', "mcdonald's", 'mac donalds', 'burger king',
        'burgerking', 'big tasty', 'whopper', 'five guys',
        "arby's", 'arbys', 'arby', 'shake shack', 'smashburger',
        "carl's jr", 'hardee', "wendy's"])) return 'Burger';
    if (_anyIn(nameLower, ['subway'])) return 'Dünya Mutfakları';
    if (_anyIn(nameLower, ['kfc', 'popeyes', "popeye's",
        'tavuk dünyası', 'tavuk dunyasi', 'tavukçu şahin'])) return 'Tavuk';
    if (_anyIn(nameLower, ['pizza hut', 'pizzahut', "domino's", 'dominos',
        'little caesars', "papa john's", 'new york pizza', 'terra pizza'])) return 'Pizza';
    if (_anyIn(nameLower, ['starbucks', "gloria jean's", 'gloria jeans',
        'caribou coffee', 'costa coffee', 'kahve dünyası', 'kahve dunyasi',
        'altıncı his', 'dunkin'])) return 'Kahve & İçecek';
    if (_anyIn(nameLower, ['baydöner', 'baydoner', 'bereket döner', 'bereket doner',
        'usta dönerci', 'develi', 'büryan'])) return 'Döner';
    if (_anyIn(nameLower, ['simit sarayı', 'simit sarayi', 'simitçi dünyası',
        'simitci dunyasi', 'bülent börekçilik'])) return 'Pastane & Fırın';
    if (_anyIn(nameLower, ['köfteci yusuf', 'kofteci yusuf', 'köfteci ramiz',
        'aspava'])) return 'Et';
    if (_anyIn(nameLower, ['sushi', 'suşi', 'japon', 'thai', 'wok',
        'noodle', 'ramen', 'pho'])) return 'Dünya Mutfakları';

    // OSM cuisine tag
    if (osmCuisine != null && osmCuisine.isNotEmpty) {
      final lower = osmCuisine.toLowerCase();
      if (_anyIn(lower, ['pizza'])) return 'Pizza';
      if (_anyIn(lower, ['burger', 'hamburger'])) return 'Burger';
      if (_anyIn(lower, ['kebab', 'kebap', 'adana', 'urfa', 'doner', 'döner'])) return 'Döner';
      if (_anyIn(lower, ['chicken', 'tavuk'])) return 'Tavuk';
      if (_anyIn(lower, ['pide', 'lahmacun'])) return 'Pide & Lahmacun';
      if (_anyIn(lower, ['fish', 'seafood', 'balik', 'deniz'])) return 'Deniz Ürünleri';
      if (_anyIn(lower, ['steak', 'grill', 'et', 'kofte', 'köfte', 'mangal', 'ocakbaşı'])) return 'Et';
      if (_anyIn(lower, ['vegan', 'vegetarian', 'vejetaryen'])) return 'Vegan & Vejetaryen';
      if (_anyIn(lower, ['breakfast', 'kahvaltı'])) return 'Kahvaltı';
      if (_anyIn(lower, ['coffee', 'cafe', 'tea', 'kahve', 'çay'])) return 'Kahve & İçecek';
      if (_anyIn(lower, ['pastry', 'bakery', 'börek', 'fırın', 'pastane'])) return 'Pastane & Fırın';
      if (_anyIn(lower, ['manti', 'mantı', 'pasta', 'makarna'])) return 'Mantı & Makarna';
      if (_anyIn(lower, ['turkish', 'anatolian', 'lokanta', 'ev'])) return 'Ev Yemekleri';
      // fast_food OSM tag alone is not enough — fall through to name check
    }

    // (chain checks already done above)

    // ── Generic name heuristics ──
    if (_anyIn(nameLower, ['pizza', 'pizzacı', 'pizzeria'])) return 'Pizza';
    if (_anyIn(nameLower, ['burger', 'hamburger', 'smash'])) return 'Burger';
    if (_anyIn(nameLower, ['döner', 'doner', 'dürüm', 'durum', 'dürümcü',
        'kebap', 'kebab', 'kebapçı', 'iskender', 'dönerci', 'kasap'])) return 'Döner';
    if (_anyIn(nameLower, ['tavuk', 'chicken', 'broast', 'piliç'])) return 'Tavuk';
    if (_anyIn(nameLower, ['pide', 'lahmacun', 'pideci', 'pidecisi'])) return 'Pide & Lahmacun';
    if (_anyIn(nameLower, ['balık', 'balik', 'balıkçı', 'seafood', 'deniz',
        'levrek', 'çipura', 'alabalık'])) return 'Deniz Ürünleri';
    // Çiğ Köfte generic (no-space variants)
    if (_anyIn(nameLower, ['çiğköfte', 'cigkofte', 'çiğköfteci', 'cigkofteci',
        'çiğ köfte', 'cig kofte'])) return 'Çiğ Köfte';
    if (_anyIn(nameLower, ['köfte', 'kofte', 'steakhouse', 'ocakbaşı', 'mangal',
        'et lokantası', 'ızgara', 'izgara', 'köfteci', 'kofteci',
        'kaburga', 'pirzola', 'bonfile'])) return 'Et';
    if (_anyIn(nameLower, ['vegan', 'vejetaryen', 'vegetarian', 'organic', 'organik',
        'doğal beslenme', 'sağlıklı', 'bitki bazlı'])) return 'Vegan & Vejetaryen';
    if (_anyIn(nameLower, ['kahvaltı', 'kahvaltıcı', 'kahvaltı evi', 'breakfast',
        'serpme', 'sabah', 'gözleme', 'menemen'])) return 'Kahvaltı';
    if (_anyIn(nameLower, ['coffee', 'kahve', 'cafe', 'caffe', 'espresso',
        'çay bahçesi', 'çayhane', 'çayevi'])) return 'Kahve & İçecek';
    if (_anyIn(nameLower, ['pastane', 'pastacı', 'fırın', 'fırıncı', 'firın', 'börekçi',
        'börek', 'borek', 'bakery', 'çikolata', 'simit', 'simid', 'poğaça', 'pogaca',
        'unlu mamul', 'unlu', 'tatlıcı', 'dondurma', 'baklava', 'künefe',
        'kadayıf', 'helva', 'bülent börekçilik'])) return 'Pastane & Fırın';
    if (_anyIn(nameLower, ['mantı', 'manti', 'makarna', 'erişte', 'çorba',
        'çorbacı', 'corbaci', 'corba'])) return 'Mantı & Makarna';
    if (_anyIn(nameLower, ['kumpir', 'kokoreç', 'kokorec', 'tantuni', 'midye', 'waffle'])) return 'Sokak Lezzetleri';
    if (_anyIn(nameLower, ['meze', 'mezeci', 'meyhane', 'rakı', 'balık meyhane',
        'nargileci', 'içkili', 'ocakbaşı meyhane'])) return 'Aperatif';
    if (_anyIn(nameLower, ['lokanta', 'aşevi', 'ev yemeği', 'hazır yemek',
        'esnaf', 'mutfak', 'aile'])) return 'Ev Yemekleri';
    if (_anyIn(nameLower, ['sushi', 'suşi', 'thai', 'çin', 'japon', 'hint',
        'meksika', 'italyan', 'fransız', 'yunan', 'arap', 'lübnan',
        'korean', 'kore', 'wok', 'noodle', 'ramen', 'pho'])) return 'Dünya Mutfakları';

    // amenity fallback
    if (amenity == 'cafe') return 'Kahve & İçecek';
    if (amenity == 'bar') return 'Aperatif';

    return 'Ev Yemekleri'; // generic Turkish food as final fallback
  }

  static bool _anyIn(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  // ── Foursquare matching ───────────────────────────────────────
  static FsqVenue? _findFsqMatch(OsmRestaurant osm, Map<String, FsqVenue> fsqMap) {
    if (fsqMap.isEmpty) return null;
    final key = _normalize(osm.name);
    if (fsqMap.containsKey(key)) return fsqMap[key];

    // Partial name match
    for (final entry in fsqMap.entries) {
      if (entry.key.contains(key) || key.contains(entry.key)) {
        // Also check geo proximity (<200m)
        final v = entry.value;
        if (_haversine(osm.lat, osm.lng, v.lat, v.lng) < 0.2) return v;
      }
    }
    return null;
  }

  static String _normalize(String name) =>
      name.toLowerCase().replaceAll(RegExp(r'[^a-zğüşıöç0-9]'), '');

  // ── Review generation ─────────────────────────────────────────
  static const _names = [
    'Ahmet K.', 'Mehmet A.', 'Fatma Ş.', 'Ayşe D.', 'Ali R.',
    'Mustafa B.', 'Zeynep T.', 'Emre Y.', 'Selin K.', 'Burak Ö.',
    'Hasan M.', 'Elif N.', 'Tarık S.', 'Merve C.', 'Kadir P.',
    'Gülsüm A.', 'Osman F.', 'Büşra H.', 'Sercan E.', 'Dilek İ.',
    'Cem Y.', 'Pınar G.', 'Tolga B.', 'Esra K.', 'Barış D.',
    'Sibel A.', 'Alper T.', 'Özlem S.', 'Uğur M.', 'Neslihan R.',
  ];

  static const _highComments = [
    'Harika lezzetler, kesinlikle tavsiye ederim!',
    'Her şey mükemmeldi, kurye de çok hızlıydı.',
    'Yemekler sıcak ve taze geldi. Tekrar sipariş vereceğim.',
    'Fiyat/performans açısından çok iyi bir yer.',
    'Ailecek burayı çok sevdik, hep buradan sipariş veriyoruz.',
    'Porsiyonlar büyük ve lezzeti gerçekten harika.',
    'Uzun zamandır sipariş verdiğim en iyi yer.',
    'Hem lezzetli hem de hızlı teslimat. Teşekkürler!',
    'Malzemeler çok taze, lezzet mükemmel.',
    'Bu kadar lezzetli yemek beklemiyordum, çok memnunum!',
  ];

  static const _midComments = [
    'Gayet güzel, tekrar sipariş veririm.',
    'Lezzet iyiydi, teslimat biraz geç geldi.',
    'Fena değil, porsiyonlar biraz daha büyük olabilirdi.',
    'Genel olarak memnunum, fiyatlar biraz yüksek ama kaliteli.',
    'Makul bir seçenek, çevreye tavsiye ederim.',
    'Yemekler iyiydi, ambalaj biraz karışık gelmişti.',
    'Ortalama bir deneyim, beklentimi karşıladı.',
    'İdare eder, daha iyisini de yedim ama kötü değil.',
    'Fiyatlar makul, lezzet standart.',
  ];

  static const _lowComments = [
    'Yemek soğuk geldi, biraz hayal kırıklığı yaşadım.',
    'Beklediğim gibi değildi, porsiyonlar çok küçük.',
    'Teslimat çok geç geldi ve yemekler soğumuştu.',
    'Lezzet vasat, daha önce daha iyi yerdim.',
    'Sipariş eksik geldi, iletişim güçlüğü yaşadım.',
  ];

  static List<Review> _generateReviews(double rating, int count) {
    return List.generate(count, (i) {
      // Vary rating around the restaurant average
      final r = (rating + (_rng.nextDouble() - 0.4) * 1.5).clamp(1.0, 5.0);
      final comments = r >= 4.2
          ? _highComments
          : r >= 3.2
              ? _midComments
              : _lowComments;
      return Review(
        id: 'rr_$i',
        userName: _names[_rng.nextInt(_names.length)],
        rating: _round(r, 1),
        comment: comments[_rng.nextInt(comments.length)],
        createdAt: DateTime.now().subtract(Duration(days: _rng.nextInt(365))),
      );
    });
  }

  // ── Helper lookups ────────────────────────────────────────────
  static List<int> _deliveryTimes(double dist) {
    if (dist < 1.0) return [5, 15];
    if (dist < 2.0) return [15, 25];
    if (dist < 3.5) return [25, 35];
    if (dist < 5.0) return [35, 45];
    return [45, 60];
  }

  static double _minOrder(String cuisine) {
    const m = {
      'Kahve & İçecek': 60.0,
      'Sokak Lezzetleri': 50.0,
      'Pastane & Fırın': 60.0,
      'Deniz Ürünleri': 200.0,
      'Et': 150.0,
      'Vegan & Vejetaryen': 80.0,
    };
    return m[cuisine] ?? (80 + _rng.nextInt(6) * 10).toDouble();
  }

  static List<String> _tags(String cuisine) {
    const extras = {
      'Döner': ['Hızlı Servis', 'Paket'],
      'Pizza': ['İtalyan', 'Fırın Pizza'],
      'Burger': ['American Style', 'Smash Burger'],
      'Kahve & İçecek': ['Özel Harmanlar', 'Vegan Seçenekler'],
    };
    return [cuisine, ...(extras[cuisine] ?? [])];
  }

  static List<String> _badges(double rating, int reviews) {
    final b = <String>[];
    if (rating >= 4.5) b.add('Çok Satılan');
    if (rating >= 4.7) b.add('Süper Restoran');
    if (reviews > 300) b.add('Popüler');
    if (reviews > 200 && rating >= 4.3) b.add('Müşteri Favorisi');
    return b;
  }

  // ── Haversine distance in km ──────────────────────────────────
  static double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _rad(double d) => d * pi / 180;
  static double _round(double v, int decimals) {
    final f = pow(10, decimals);
    return (v * f).round() / f;
  }

  // ── Cache ─────────────────────────────────────────────────────
  static String _cacheKey(double lat, double lng) {
    final rLat = (lat * 100).round() / 100;
    final rLng = (lng * 100).round() / 100;
    return 'rrs_v5_cache_${rLat}_$rLng';
  }

  static Future<List<Restaurant>?> _loadCache(double lat, double lng) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _cacheKey(lat, lng);
      final raw = prefs.getString(key);
      if (raw == null) return null;

      final json = jsonDecode(raw) as Map<String, dynamic>;
      final ts = json['ts'] as int? ?? 0;
      if (DateTime.now().millisecondsSinceEpoch - ts > _cacheTtlMs) {
        await prefs.remove(key);
        return null;
      }

      final list = (json['data'] as List)
          .map((e) => _fromCacheEntry(e as Map<String, dynamic>))
          .whereType<Restaurant>()
          .toList();
      return list.isEmpty ? null : list;
    } catch (e) {
      debugPrint('RRS cache load error: $e');
      return null;
    }
  }

  static Future<void> _saveCache(
      double lat, double lng, List<Restaurant> restaurants) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _cacheKey(lat, lng);
      final payload = {
        'ts': DateTime.now().millisecondsSinceEpoch,
        'data': restaurants.map(_toCacheEntry).toList(),
      };
      await prefs.setString(key, jsonEncode(payload));
    } catch (e) {
      debugPrint('RRS cache save error: $e');
    }
  }

  static Map<String, dynamic> _toCacheEntry(Restaurant r) => {
    'id': r.id, 'name': r.name, 'imageUrl': r.imageUrl,
    'cuisine': r.cuisine, 'rating': r.rating, 'reviewCount': r.reviewCount,
    'deliveryTimeMin': r.deliveryTimeMin, 'deliveryTimeMax': r.deliveryTimeMax,
    'deliveryFee': r.deliveryFee, 'minOrder': r.minOrder,
    'isOpen': r.isOpen, 'tags': r.tags, 'address': r.address,
    'distance': r.distance, 'city': r.city, 'district': r.district,
    'lat': r.latitude, 'lng': r.longitude,
    'badges': r.badges,
    'reviews': r.reviews.map((rv) => {
      'id': rv.id, 'userName': rv.userName, 'rating': rv.rating,
      'comment': rv.comment,
      'createdAt': rv.createdAt.toIso8601String(),
    }).toList(),
  };

  static Restaurant? _fromCacheEntry(Map<String, dynamic> m) {
    try {
      final reviews = (m['reviews'] as List? ?? []).map((rv) {
        final rm = rv as Map<String, dynamic>;
        return Review(
          id: rm['id'] ?? '',
          userName: rm['userName'] ?? '',
          rating: (rm['rating'] as num).toDouble(),
          comment: rm['comment'] ?? '',
          createdAt: DateTime.tryParse(rm['createdAt'] ?? '') ?? DateTime.now(),
        );
      }).toList();

      final cuisine = m['cuisine'] as String? ?? 'Ev Yemekleri';
      return Restaurant(
        id: m['id'],
        name: m['name'],
        imageUrl: m['imageUrl'],
        cuisine: cuisine,
        rating: (m['rating'] as num).toDouble(),
        reviewCount: m['reviewCount'] as int,
        deliveryTimeMin: m['deliveryTimeMin'] as int,
        deliveryTimeMax: m['deliveryTimeMax'] as int,
        deliveryFee: (m['deliveryFee'] as num).toDouble(),
        minOrder: (m['minOrder'] as num).toDouble(),
        isOpen: m['isOpen'] as bool,
        tags: List<String>.from(m['tags'] ?? []),
        menu: DataService.getMenuForRestaurantByName(m['id'] ?? '', cuisine, m['name'] ?? ''),
        address: m['address'] ?? '',
        distance: (m['distance'] as num).toDouble(),
        city: m['city'] ?? '',
        district: m['district'] ?? '',
        latitude: (m['lat'] as num?)?.toDouble() ?? 0.0,
        longitude: (m['lng'] as num?)?.toDouble() ?? 0.0,
        badges: List<String>.from(m['badges'] ?? []),
        reviews: reviews,
      );
    } catch (e) {
      debugPrint('RRS cache entry parse error: $e');
      return null;
    }
  }
}
