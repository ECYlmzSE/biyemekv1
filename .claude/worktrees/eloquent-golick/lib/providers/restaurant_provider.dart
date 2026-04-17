import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant.dart';
import '../services/data_service.dart';
import '../services/real_restaurant_service.dart';

enum SortOption { rating, deliveryTime, deliveryFee, distance, reviewCount }

extension SortOptionExt on SortOption {
  String get label {
    switch (this) {
      case SortOption.rating:       return 'En Yüksek Puan';
      case SortOption.deliveryTime: return 'En Hızlı';
      case SortOption.deliveryFee:  return 'En Düşük Teslimat';
      case SortOption.distance:     return 'En Yakın';
      case SortOption.reviewCount:  return 'En Popüler';
    }
  }
}

class RestaurantProvider extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────────────
  String      _city             = 'İstanbul';
  String      _district         = '';    // ilçe — empty = tümü
  String      _searchQuery      = '';
  String      _selectedCategory = 'Tümü';
  SortOption  _sortOption       = SortOption.distance;
  double      _maxDeliveryFee   = 999;
  double      _minRating        = 0;
  bool        _onlyOpen         = false;
  bool        _freeDelivery     = false;
  String?     _deliveryTimeFilter;
  Set<String> _favorites        = {};
  bool        _isLoading        = false;
  bool        _hasRealData      = false;
  List<Restaurant> _realRestaurants = [];

  // ── Getters ───────────────────────────────────────────────────
  String     get selectedCity       => _city;
  String     get selectedDistrict   => _district;
  String     get searchQuery        => _searchQuery;
  String     get selectedCategory   => _selectedCategory;
  SortOption get sortOption         => _sortOption;
  double     get maxDeliveryFee     => _maxDeliveryFee;
  double     get minRating          => _minRating;
  bool       get onlyOpen           => _onlyOpen;
  bool       get freeDelivery       => _freeDelivery;
  String?    get deliveryTimeFilter => _deliveryTimeFilter;
  Set<String> get favorites         => _favorites;
  bool       get isLoading          => _isLoading;
  bool       get hasRealData        => _hasRealData;

  final List<String> deliveryTimeOptions = [
    '5-15 dk','15-25 dk','25-35 dk','35-45 dk','45-55 dk','1+ saat',
  ];

  final List<String> categories = [
    'Tümü','Pizza','Tavuk','Burger','Döner','Pide & Lahmacun',
    'Sokak Lezzetleri','Çiğ Köfte','Kahvaltı','Et','Deniz Ürünleri',
    'Mantı & Makarna','Vegan & Vejetaryen','Kahve & İçecek',
    'Pastane & Fırın','Tatlı','Aperatif','Ev Yemekleri','Dünya Mutfakları',
  ];

  // ── Restaurant sources ────────────────────────────────────────
  /// All restaurants: only real data (no fake fallback).
  List<Restaurant> get allRestaurants => _realRestaurants;

  // ── City filter ───────────────────────────────────────────────
  /// Real data is already fetched near the user — all of it is the "city".
  List<Restaurant> get cityRestaurants => _realRestaurants;

  // ── Districts for the current city (unique, sorted) ───────────
  List<String> get districts {
    final set = <String>{};
    for (final r in _realRestaurants) {
      if (r.district.isNotEmpty) set.add(r.district);
    }
    return set.toList()..sort();
  }

  // ── User review → persist to restaurant ──────────────────────

  /// Stable key that survives restarts: uses OSM id primarily,
  /// and ALSO writes a name+city fallback so reviews survive
  /// if the same place is returned with a different OSM node id.
  String _reviewKey(String restaurantId) => 'user_reviews_$restaurantId';
  String _reviewKeyByName(String name, String city) {
    final n = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final c = city.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return 'user_reviews_name_${n}_$c';
  }

  Future<void> addUserReview(String restaurantId, Review review) async {
    final idx = _realRestaurants.indexWhere((r) => r.id == restaurantId);

    if (idx >= 0) {
      final old = _realRestaurants[idx];
      final newReviews = [review, ...old.reviews];
      // Recalculate rating as weighted average
      final totalRating = newReviews.fold(0.0, (s, r) => s + r.rating);
      final newRating = double.parse((totalRating / newReviews.length).toStringAsFixed(1));
      _realRestaurants[idx] = old.copyWith(
        reviews: newReviews,
        rating: newRating,
        reviewCount: old.reviewCount + 1,
      );
      notifyListeners();
      await _persistUserReviews(old, newReviews, newRating, old.reviewCount + 1);
    } else {
      // Restaurant not in current list — persist by ID only so it applies
      // when the restaurant is loaded next time.
      final prefs = await SharedPreferences.getInstance();
      final key = _reviewKey(restaurantId);
      final existing = prefs.getString(key);
      List<Map<String, dynamic>> reviews = [];
      double rating = review.rating;
      int reviewCount = 1;
      if (existing != null) {
        try {
          final data = jsonDecode(existing) as Map<String, dynamic>;
          reviews = List<Map<String, dynamic>>.from(data['reviews'] ?? []);
          rating = (data['rating'] as num).toDouble();
          reviewCount = (data['reviewCount'] as int? ?? 0) + 1;
          final total = reviews.fold(0.0, (s, r) => s + (r['rating'] as num).toDouble()) + review.rating;
          rating = double.parse((total / reviewCount).toStringAsFixed(1));
        } catch (_) {}
      }
      reviews.insert(0, {
        'id': review.id, 'userName': review.userName, 'rating': review.rating,
        'comment': review.comment, 'createdAt': review.createdAt.toIso8601String(),
      });
      await prefs.setString(key, jsonEncode({
        'rating': rating, 'reviewCount': reviewCount,
        'reviews': reviews.take(50).toList(),
      }));
    }
  }

  Future<void> _persistUserReviews(
    Restaurant restaurant,
    List<Review> reviews,
    double rating,
    int reviewCount,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'rating': rating,
        'reviewCount': reviewCount,
        'reviews': reviews.take(50).map((r) => {
          'id': r.id, 'userName': r.userName, 'rating': r.rating,
          'comment': r.comment, 'createdAt': r.createdAt.toIso8601String(),
        }).toList(),
      };
      final encoded = jsonEncode(data);
      // Write under both id-key and name-key for maximum resilience.
      await prefs.setString(_reviewKey(restaurant.id), encoded);
      await prefs.setString(_reviewKeyByName(restaurant.name, restaurant.city), encoded);
    } catch (_) {}
  }

  /// Applies persisted user reviews on top of freshly loaded real restaurants.
  Future<void> _applyPersistedReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (int i = 0; i < _realRestaurants.length; i++) {
        final r = _realRestaurants[i];
        // Try by id first, then by name+city fallback.
        final raw = prefs.getString(_reviewKey(r.id))
            ?? prefs.getString(_reviewKeyByName(r.name, r.city));
        if (raw == null) continue;
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final reviews = (data['reviews'] as List).map((rv) {
          final rm = rv as Map<String, dynamic>;
          return Review(
            id: rm['id'] ?? '',
            userName: rm['userName'] ?? '',
            rating: (rm['rating'] as num).toDouble(),
            comment: rm['comment'] ?? '',
            createdAt: DateTime.tryParse(rm['createdAt'] ?? '') ?? DateTime.now(),
          );
        }).toList();
        // De-duplicate: don't double-add reviews already in the list.
        final existingIds = r.reviews.map((rv) => rv.id).toSet();
        final newOnly = reviews.where((rv) => !existingIds.contains(rv.id)).toList();
        if (newOnly.isEmpty && (data['rating'] as num).toDouble() == r.rating) continue;
        _realRestaurants[i] = r.copyWith(
          reviews: [...newOnly, ...r.reviews],
          rating: (data['rating'] as num).toDouble(),
          reviewCount: data['reviewCount'] as int,
        );
      }
    } catch (_) {}
  }

  // ── Filtered + sorted list ────────────────────────────────────
  List<Restaurant> get filteredRestaurants {
    var list = cityRestaurants.where((r) {
      // District filter
      if (_district.isNotEmpty && r.district != _district) return false;
      if (_onlyOpen     && !r.isOpen)           return false;
      if (_freeDelivery && r.deliveryFee > 0)   return false;
      if (r.deliveryFee > _maxDeliveryFee)       return false;
      if (r.rating < _minRating)                 return false;
      if (_selectedCategory != 'Tümü' && r.cuisine != _selectedCategory) return false;
      if (_deliveryTimeFilter != null) {
        if (_deliveryTimeFilter == '5-15 dk'  && r.deliveryTimeMax > 15)                                return false;
        if (_deliveryTimeFilter == '15-25 dk' && !(r.deliveryTimeMin >= 15 && r.deliveryTimeMax <= 25)) return false;
        if (_deliveryTimeFilter == '25-35 dk' && !(r.deliveryTimeMin >= 25 && r.deliveryTimeMax <= 35)) return false;
        if (_deliveryTimeFilter == '35-45 dk' && !(r.deliveryTimeMin >= 35 && r.deliveryTimeMax <= 45)) return false;
        if (_deliveryTimeFilter == '45-55 dk' && !(r.deliveryTimeMin >= 45 && r.deliveryTimeMax <= 55)) return false;
        if (_deliveryTimeFilter == '1+ saat'  && r.deliveryTimeMax < 60)                                return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!r.name.toLowerCase().contains(q) &&
            !r.cuisine.toLowerCase().contains(q) &&
            !r.tags.any((t) => t.toLowerCase().contains(q))) return false;
      }
      return true;
    }).toList();

    switch (_sortOption) {
      case SortOption.rating:       list.sort((a,b) => b.rating.compareTo(a.rating));
      case SortOption.deliveryTime: list.sort((a,b) => a.deliveryTimeMin.compareTo(b.deliveryTimeMin));
      case SortOption.deliveryFee:  list.sort((a,b) => a.deliveryFee.compareTo(b.deliveryFee));
      case SortOption.distance:     list.sort((a,b) => a.distance.compareTo(b.distance));
      case SortOption.reviewCount:  list.sort((a,b) => b.reviewCount.compareTo(a.reviewCount));
    }
    return list;
  }

  List<Restaurant> get topRated {
    final l = cityRestaurants.where((r) => r.isOpen).toList()
      ..sort((a,b) => b.rating.compareTo(a.rating));
    return l.take(20).toList();
  }

  List<Restaurant> get nearbyRestaurants {
    final l = [...cityRestaurants]..sort((a,b) => a.distance.compareTo(b.distance));
    return l.take(30).toList();
  }

  List<Restaurant> get favoriteRestaurants =>
      allRestaurants.where((r) => _favorites.contains(r.id)).toList();

  bool isFavorite(String id) => _favorites.contains(id);
  void toggleFavorite(String id) {
    _favorites.contains(id) ? _favorites.remove(id) : _favorites.add(id);
    notifyListeners();
  }

  // ── Setters ───────────────────────────────────────────────────
  void setCity(String city) {
    if (city.trim().isEmpty) return;
    final newCity = city.trim();
    // When city actually changes, mark data as stale so home screen reloads.
    if (newCity.toLowerCase() != _city.toLowerCase()) {
      _hasRealData = false;
    }
    _city = newCity;
    _district = '';
    notifyListeners();
    _persistCity(newCity);
  }

  /// Updates the stored city name WITHOUT clearing hasRealData.
  /// Used after a successful load to sync the city label from address,
  /// preventing the build condition from re-triggering a reload.
  void syncCity(String city) {
    final c = city.trim();
    if (c.isEmpty || c.toLowerCase() == _city.toLowerCase()) return;
    _city = c;
    notifyListeners();
    _persistCity(c);
  }

  /// Marks data as stale so the next build triggers a reload.
  /// Use when the user location changes without a city change.
  void markStale() {
    _hasRealData = false;
    notifyListeners();
  }

  void setDistrict(String district) {
    _district = district;
    notifyListeners();
  }

  void setSearchQuery(String q)         { _searchQuery = q;        notifyListeners(); }
  void setCategory(String c)            { _selectedCategory = c;   notifyListeners(); }
  void setSortOption(SortOption s)      { _sortOption = s;         notifyListeners(); }
  void setMaxDeliveryFee(double v)      { _maxDeliveryFee = v;     notifyListeners(); }
  void setMinRating(double v)           { _minRating = v;          notifyListeners(); }
  void setOnlyOpen(bool v)              { _onlyOpen = v;           notifyListeners(); }
  void setFreeDelivery(bool v)          { _freeDelivery = v;       notifyListeners(); }
  void setDeliveryTimeFilter(String? v) { _deliveryTimeFilter = v; notifyListeners(); }
  void setAddressCity(String city)      => setCity(city);

  void resetFilters() {
    _selectedCategory = 'Tümü'; _sortOption = SortOption.distance;
    _maxDeliveryFee = 999; _minRating = 0; _onlyOpen = false;
    _freeDelivery = false; _deliveryTimeFilter = null; _district = '';
    notifyListeners();
  }

  // ── Real data fetch ───────────────────────────────────────────
  /// Fetches real restaurants near the user via Overpass + Foursquare.
  /// Call this after location permission is granted.
  Future<void> loadRealRestaurants(double lat, double lng,
      {bool bypassCache = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final restaurants = await RealRestaurantService.fetchNearby(
        lat: lat,
        lng: lng,
        bypassCache: bypassCache,
      );

      if (restaurants.isNotEmpty) {
        // OSM verisinde az olan kategorileri simüle restoranlarla tamamla
        const _sparseMin = 3;
        const _sparseCategories = [
          'Kahvaltı', 'Tatlı', 'Aperatif', 'Vegan & Vejetaryen', 'Çiğ Köfte',
          'Sokak Lezzetleri', 'Deniz Ürünleri', 'Mantı & Makarna',
          'Pastane & Fırın', 'Kahve & İçecek',
        ];
        var augmented = List<Restaurant>.from(restaurants);
        for (final cat in _sparseCategories) {
          final existing = augmented.where((r) => r.cuisine == cat).length;
          if (existing < _sparseMin) {
            augmented.addAll(DataService.generateForCategory(
              cat, lat, lng, count: _sparseMin + 3 - existing));
          }
        }
        _realRestaurants = augmented;
        _hasRealData = true;

        // Reapply user reviews on top of fresh data
        await _applyPersistedReviews();

        // Update city from first result that has a city
        final firstWithCity = restaurants.firstWhere(
            (r) => r.city.isNotEmpty,
            orElse: () => restaurants.first);
        if (firstWithCity.city.isNotEmpty) {
          _city = firstWithCity.city;
        }

        _persistCity(_city);
        debugPrint('RestaurantProvider: loaded ${restaurants.length} real restaurants');
      }
    } catch (e) {
      debugPrint('RestaurantProvider loadReal error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Init & persistence ────────────────────────────────────────
  Future<void> initialize() async {
    try {
      final p = await SharedPreferences.getInstance();
      final saved = p.getString('rp_selected_city');
      if (saved != null && saved.isNotEmpty) {
        _city = saved;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _persistCity(String city) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('rp_selected_city', city);
    } catch (_) {}
  }

  int get activeFilterCount {
    int c = 0;
    if (_selectedCategory != 'Tümü') c++;
    if (_sortOption != SortOption.distance) c++;
    if (_maxDeliveryFee < 999) c++;
    if (_minRating > 0) c++;
    if (_onlyOpen) c++;
    if (_freeDelivery) c++;
    if (_deliveryTimeFilter != null) c++;
    if (_district.isNotEmpty) c++;
    return c;
  }

  // Legacy stub kept for call-site compatibility
  bool get isLoadingReal => _isLoading;
}
