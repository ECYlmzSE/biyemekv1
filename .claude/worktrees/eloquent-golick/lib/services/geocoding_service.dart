import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingResult {
  final String city;
  final String district;
  final String neighborhood;
  final String road;
  final String displayName;

  const GeocodingResult({
    required this.city,
    required this.district,
    required this.neighborhood,
    required this.road,
    required this.displayName,
  });
}

class GeocodingService {
  static const _nominatimBase = 'https://nominatim.openstreetmap.org';
  static const _headers = {'Accept-Language': 'tr', 'User-Agent': 'BiYemekApp/1.0'};

  /// Reverse geocode lat/lng → address parts
  static Future<GeocodingResult?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse('$_nominatimBase/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body);
      final addr = data['address'] as Map<String, dynamic>? ?? {};

      return GeocodingResult(
        city: addr['province'] ?? addr['city'] ?? addr['state'] ?? '',
        district: addr['county'] ?? addr['city_district'] ?? addr['town'] ?? addr['suburb'] ?? '',
        neighborhood: addr['quarter'] ?? addr['neighbourhood'] ?? addr['suburb'] ?? '',
        road: addr['road'] ?? addr['pedestrian'] ?? '',
        displayName: data['display_name'] ?? '',
      );
    } catch (e) {
      return null;
    }
  }

  /// Search places by text (Nominatim)
  static Future<List<SearchResult>> search(String query) async {
    if (query.trim().length < 2) return [];
    try {
      final uri = Uri.parse(
        '$_nominatimBase/search?q=${Uri.encodeComponent(query)}'
        '&format=json&addressdetails=1&limit=8&countrycodes=tr',
      );
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return [];
      final list = jsonDecode(res.body) as List;
      return list.map((e) => SearchResult(
        displayName: e['display_name'] ?? '',
        shortName: _shortName(e),
        lat: double.tryParse(e['lat'].toString()) ?? 0,
        lng: double.tryParse(e['lon'].toString()) ?? 0,
      )).where((r) => r.lat != 0).toList();
    } catch (e) {
      return [];
    }
  }

  static String _shortName(Map e) {
    final addr = e['address'] as Map<String, dynamic>? ?? {};
    final parts = <String>[];
    final name = e['name']?.toString() ?? '';
    if (name.isNotEmpty) parts.add(name);
    final sub = addr['suburb'] ?? addr['quarter'] ?? addr['neighbourhood'] ?? '';
    if (sub.isNotEmpty) parts.add(sub);
    final district = addr['county'] ?? addr['city_district'] ?? addr['town'] ?? '';
    if (district.isNotEmpty) parts.add(district);
    final city = addr['province'] ?? addr['city'] ?? '';
    if (city.isNotEmpty) parts.add(city);
    return parts.take(3).join(', ');
  }
}

class SearchResult {
  final String displayName;
  final String shortName;
  final double lat;
  final double lng;
  const SearchResult({required this.displayName, required this.shortName, required this.lat, required this.lng});
}
