import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';
import 'data_service.dart';

const String _apiKey = 'AIzaSyB8voNd5dgCVAGQpVIQJCt5CPdk3FZhoTY';

class PlacesRestaurantService {
  static final Random _rng = Random();

  /// Fetch real restaurants near a location from Google Places API
  static Future<List<Restaurant>> fetchNearbyRestaurants({
    required double lat,
    required double lng,
    int radiusMeters = 7000,
  }) async {
    final List<Restaurant> results = [];
    String? pageToken;

    try {
      // Fetch up to 3 pages (60 restaurants max from Places API)
      for (int page = 0; page < 3; page++) {
        final url = _buildUrl(lat, lng, radiusMeters, pageToken);
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
        final data = jsonDecode(response.body);

        if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
          debugPrint('Places API error: ${data['status']}');
          break;
        }

        final places = data['results'] as List? ?? [];
        for (final place in places) {
          final restaurant = _placeToRestaurant(place, lat, lng);
          if (restaurant != null) results.add(restaurant);
        }

        pageToken = data['next_page_token'];
        if (pageToken == null) break;
        // Google requires a short delay before using next_page_token
        await Future.delayed(const Duration(milliseconds: 2000));
      }
    } catch (e) {
      debugPrint('Places fetch error: $e');
    }

    // Sort by distance
    results.sort((a, b) => a.distance.compareTo(b.distance));
    return results;
  }

  static String _buildUrl(double lat, double lng, int radius, String? pageToken) {
    var url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lng'
        '&radius=$radius'
        '&type=restaurant'
        '&language=tr'
        '&key=$_apiKey';
    if (pageToken != null) url += '&pagetoken=$pageToken';
    return url;
  }

  static Restaurant? _placeToRestaurant(Map<String, dynamic> place, double userLat, double userLng) {
    try {
      final name = place['name'] as String? ?? '';
      if (name.isEmpty) return null;

      final placeId = place['place_id'] as String? ?? '';
      final lat = place['geometry']['location']['lat'] as double;
      final lng = place['geometry']['location']['lng'] as double;
      final rating = (place['rating'] ?? 3.5 + _rng.nextDouble() * 1.5).toDouble();
      final reviewCount = place['user_ratings_total'] ?? (50 + _rng.nextInt(2000));
      final isOpen = place['opening_hours']?['open_now'] ?? (_rng.nextDouble() > 0.2);
      final photoRef = (place['photos'] as List?)?.isNotEmpty == true
          ? place['photos'][0]['photo_reference'] as String?
          : null;
      final types = List<String>.from(place['types'] ?? []);
      final vicinity = place['vicinity'] as String? ?? '';

      final distance = _calcDistance(userLat, userLng, lat, lng);
      if (distance > 7.0) return null; // 7km limit

      final cuisine = _guessCuisine(name, types);
      final deliveryTimes = _getDeliveryTimes(distance);
      final minOrder = _getMinOrder(cuisine);
      final deliveryFee = distance < 2 ? 0.0 : (distance < 4 ? 4.99 : 9.99);
      final imageUrl = photoRef != null
          ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=600&photo_reference=$photoRef&key=$_apiKey'
          : _fallbackImage(cuisine);

      return Restaurant(
        id: 'gp_$placeId',
        name: name,
        imageUrl: imageUrl,
        cuisine: cuisine,
        rating: double.parse(rating.toStringAsFixed(1)),
        reviewCount: reviewCount,
        deliveryTimeMin: deliveryTimes[0],
        deliveryTimeMax: deliveryTimes[1],
        deliveryFee: deliveryFee,
        minOrder: minOrder,
        isOpen: isOpen,
        tags: _getTags(cuisine, types),
        menu: DataService.getMenuForCuisine(cuisine),
        address: vicinity,
        distance: double.parse(distance.toStringAsFixed(1)),
        badges: _getBadges(rating, reviewCount),
      );
    } catch (e) {
      debugPrint('Place parse error: $e');
      return null;
    }
  }

  static double _calcDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _rad(double deg) => deg * pi / 180;

  static String _guessCuisine(String name, List<String> types) {
    final lower = name.toLowerCase();
    if (lower.contains('pizza') || lower.contains('pizzacı')) return 'Pizza';
    if (lower.contains('burger') || lower.contains('hamburger')) return 'Burger';
    if (lower.contains('döner') || lower.contains('doner')) return 'Döner';
    if (lower.contains('tavuk') || lower.contains('chicken') || lower.contains('kfc') || lower.contains('popeye')) return 'Tavuk';
    if (lower.contains('pide') || lower.contains('lahmacun')) return 'Pide & Lahmacun';
    if (lower.contains('köfte') || lower.contains('kofte') || lower.contains('et ') || lower.contains('mangal') || lower.contains('ocakbaşı') || lower.contains('steakhouse')) return 'Et';
    if (lower.contains('balık') || lower.contains('balik') || lower.contains('deniz') || lower.contains('fish')) return 'Deniz Ürünleri';
    if (lower.contains('çiğ köfte') || lower.contains('cig kofte')) return 'Çiğ Köfte';
    if (lower.contains('kahvaltı') || lower.contains('kahvalti') || lower.contains('breakfast')) return 'Kahvaltı';
    if (lower.contains('vegan') || lower.contains('vejetaryen') || lower.contains('salad') || lower.contains('salata')) return 'Vegan';
    if (lower.contains('kumpir') || lower.contains('kokoreç') || lower.contains('tantuni') || lower.contains('simit')) return 'Sokak Lezzetleri';
    if (lower.contains('mantı') || lower.contains('makarna') || lower.contains('pasta')) return 'Mantı & Makarna';
    if (lower.contains('kahve') || lower.contains('coffee') || lower.contains('cafe') || lower.contains('çay')) return 'Kahve & İçecek';
    if (lower.contains('pastane') || lower.contains('fırın') || lower.contains('bakery') || lower.contains('börek')) return 'Pastane & Fırın';
    if (lower.contains('ev yemeği') || lower.contains('lokanta') || lower.contains('home')) return 'Ev Yemekleri';
    if (lower.contains('meze') || lower.contains('börek') || lower.contains('salata')) return 'Aperatif';
    // types fallback
    if (types.contains('cafe')) return 'Kahve & İçecek';
    if (types.contains('bakery')) return 'Pastane & Fırın';
    return 'Türk Mutfağı';
  }

  static List<int> _getDeliveryTimes(double distance) {
    if (distance < 1.5) return [5, 15];
    if (distance < 3.0) return [15, 25];
    if (distance < 4.5) return [25, 35];
    if (distance < 6.0) return [35, 45];
    return [45, 55];
  }

  static double _getMinOrder(String cuisine) {
    const map = {'Kahve & İçecek': 50.0, 'Çiğ Köfte': 30.0, 'Sokak Lezzetleri': 40.0, 'Pastane & Fırın': 50.0, 'Deniz Ürünleri': 150.0, 'Et': 120.0};
    return map[cuisine] ?? (60 + _rng.nextInt(5) * 10).toDouble();
  }

  static List<String> _getTags(String cuisine, List<String> types) {
    final tags = [cuisine];
    if (types.contains('meal_delivery')) tags.add('Hızlı Teslimat');
    if (types.contains('meal_takeaway')) tags.add('Paket Servis');
    return tags;
  }

  static List<String> _getBadges(double rating, int reviews) {
    final badges = <String>[];
    if (rating >= 4.5) badges.add('Çok Satılan');
    if (reviews > 1000) badges.add('Popüler');
    return badges;
  }

  static String _fallbackImage(String cuisine) {
    const map = {
      'Pizza': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600',
      'Burger': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600',
      'Döner': 'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=600',
      'Tavuk': 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=600',
      'Et': 'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=600',
      'Deniz Ürünleri': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=600',
      'Vegan': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600',
      'Kahvaltı': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600',
      'Kahve & İçecek': 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=600',
      'Pastane & Fırın': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=600',
    };
    return map[cuisine] ?? 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600';
  }
}
