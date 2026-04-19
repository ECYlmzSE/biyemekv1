import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Raw restaurant data fetched from OpenStreetMap via Overpass API.
class OsmRestaurant {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String? cuisine;     // OSM cuisine tag (e.g. "kebab;turkish")
  final String? amenity;     // restaurant | cafe | fast_food | bar
  final String? street;
  final String? houseNumber;
  final String? suburb;      // mahalle / semt
  final String? district;    // ilçe (addr:district or addr:suburb)
  final String? city;        // şehir
  final String? phone;
  final String? website;
  final String? openingHours;
  final String? name_tr;

  const OsmRestaurant({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.cuisine,
    this.amenity,
    this.street,
    this.houseNumber,
    this.suburb,
    this.district,
    this.city,
    this.phone,
    this.website,
    this.openingHours,
    this.name_tr,
  });

  String get displayName => name_tr ?? name;

  String get fullAddress {
    final parts = <String>[];
    if (street != null) {
      parts.add(houseNumber != null ? '$street $houseNumber' : street!);
    }
    if (suburb != null) parts.add(suburb!);
    if (district != null && district != suburb) parts.add(district!);
    if (city != null) parts.add(city!);
    return parts.join(', ');
  }

  String get resolvedDistrict => district ?? suburb ?? '';
  String get resolvedCity => city ?? '';
}

class OverpassService {
  static const _endpoint = 'https://overpass-api.de/api/interpreter';

  /// Fetches food venues near [lat]/[lng] within [radiusMeters].
  /// Includes restaurants, cafes, fast food, bakeries.
  static Future<List<OsmRestaurant>> fetchNearby({
    required double lat,
    required double lng,
    int radiusMeters = 5000,
  }) async {
    final query = '''
[out:json][timeout:30];
(
  node(around:$radiusMeters,$lat,$lng)[amenity~"restaurant|cafe|fast_food"][name];
  way(around:$radiusMeters,$lat,$lng)[amenity~"restaurant|cafe|fast_food"][name];
);
out body center;
''';

    http.Response? response;
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        response = await http
            .post(
              Uri.parse(_endpoint),
              headers: {'Content-Type': 'application/x-www-form-urlencoded'},
              body: 'data=${Uri.encodeComponent(query)}',
            )
            .timeout(const Duration(seconds: 35));
        if (response.statusCode == 200) break;
        debugPrint('Overpass HTTP ${response.statusCode} (deneme $attempt/3)');
        if (attempt < 3) await Future.delayed(Duration(seconds: attempt * 2));
      } catch (e) {
        debugPrint('Overpass deneme $attempt hata: $e');
        if (attempt < 3) await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    try {
      if (response == null || response.statusCode != 200) {
        debugPrint('Overpass 3 denemeden sonra başarısız');
        return [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final elements = data['elements'] as List? ?? [];

      final results = <OsmRestaurant>[];
      final seen = <String>{};

      for (final el in elements) {
        final tags = (el['tags'] as Map?)?.cast<String, dynamic>() ?? {};
        final name = (tags['name'] ?? tags['name:tr'] ?? '').toString().trim();
        if (name.isEmpty) continue;

        // Coordinates: nodes have lat/lon directly; ways have center
        double? eLat, eLng;
        if (el['type'] == 'node') {
          eLat = (el['lat'] as num?)?.toDouble();
          eLng = (el['lon'] as num?)?.toDouble();
        } else {
          final center = el['center'] as Map?;
          eLat = (center?['lat'] as num?)?.toDouble();
          eLng = (center?['lon'] as num?)?.toDouble();
        }
        if (eLat == null || eLng == null) continue;

        // De-duplicate by name + approximate location
        final key = '${name.toLowerCase()}_${eLat.toStringAsFixed(3)}_${eLng.toStringAsFixed(3)}';
        if (seen.contains(key)) continue;
        seen.add(key);

        results.add(OsmRestaurant(
          id: 'osm_${el['type']}_${el['id']}',
          name: name,
          lat: eLat,
          lng: eLng,
          cuisine: tags['cuisine']?.toString(),
          amenity: tags['amenity']?.toString(),
          street: tags['addr:street']?.toString(),
          houseNumber: tags['addr:housenumber']?.toString(),
          suburb: tags['addr:suburb']?.toString() ?? tags['addr:quarter']?.toString(),
          district: tags['addr:district']?.toString() ?? tags['addr:suburb']?.toString(),
          city: tags['addr:city']?.toString() ?? tags['is_in:city']?.toString(),
          phone: tags['phone']?.toString() ?? tags['contact:phone']?.toString(),
          website: tags['website']?.toString() ?? tags['contact:website']?.toString(),
          openingHours: tags['opening_hours']?.toString(),
          name_tr: tags['name:tr']?.toString(),
        ));
      }

      debugPrint('Overpass: ${results.length} restaurants fetched near ($lat, $lng)');
      return results;
    } catch (e) {
      debugPrint('Overpass error: $e');
      return [];
    }
  }

  /// Reverse-geocodes a coordinate to extract city and district using Nominatim.
  /// Called once per user location to fill in missing address context.
  static Future<({String city, String district})> reverseGeocode(
      double lat, double lng) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse'
          '?lat=$lat&lon=$lng&format=json&addressdetails=1&zoom=10');
      final response = await http.get(url,
          headers: {'User-Agent': 'BiYemekApp/1.0'}).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final addr = data['address'] as Map? ?? {};
        final city = (addr['city'] ?? addr['town'] ?? addr['province'] ?? '').toString();
        final district = (addr['district'] ?? addr['suburb'] ?? addr['quarter'] ?? '').toString();
        return (city: city, district: district);
      }
    } catch (e) {
      debugPrint('Nominatim error: $e');
    }
    return (city: '', district: '');
  }
}
