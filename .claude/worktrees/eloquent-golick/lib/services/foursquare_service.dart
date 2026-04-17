import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// ────────────────────────────────────────────────────────────
///  HOW TO GET A FOURSQUARE API KEY (free)
///  1. Go to https://developer.foursquare.com/
///  2. Sign up / Log in
///  3. Create a new project → "Places API"
///  4. Copy your API Key (starts with FSQ3...)
///  5. Paste it below as [foursquareApiKey]
///
///  Free tier: 1 000 API calls / day (plenty for a demo app)
/// ────────────────────────────────────────────────────────────

/// Lightweight data returned from Foursquare for a single venue.
class FsqVenue {
  final String fsqId;
  final String name;
  final double lat;
  final double lng;
  final String? photoUrl;   // full photo URL (prefix + size + suffix)
  final double? rating;     // 0-10 scale, null if not returned
  final String? category;   // primary category name

  const FsqVenue({
    required this.fsqId,
    required this.name,
    required this.lat,
    required this.lng,
    this.photoUrl,
    this.rating,
    this.category,
  });

  /// Converts Foursquare 0-10 rating to 0-5 scale.
  double? get rating5 => rating != null ? rating! / 2 : null;
}

class FoursquareService {
  static const _baseUrl = 'https://api.foursquare.com/v3';

  // ── Category IDs ──────────────────────────────────────────────
  // 13000 = Food (all restaurants)
  static const _foodCategoryId = '13000';

  /// Searches for venues near [lat]/[lng] using the Foursquare Places API.
  /// Returns up to [limit] venues with name, location, category, photo, and rating.
  ///
  /// [apiKey] must be a valid Foursquare v3 API key (FSQ3...).
  /// Returns empty list silently if key is missing or quota is exceeded.
  static Future<List<FsqVenue>> searchNearby({
    required double lat,
    required double lng,
    required String apiKey,
    int radiusMeters = 5000,
    int limit = 50,
  }) async {
    if (apiKey.isEmpty) return [];

    try {
      // Request fields: basic + photos + rating (premium — counts against quota)
      final uri = Uri.parse('$_baseUrl/places/search').replace(queryParameters: {
        'll': '$lat,$lng',
        'radius': '$radiusMeters',
        'categories': _foodCategoryId,
        'limit': '$limit',
        'fields': 'fsq_id,name,geocodes,location,categories,photos,rating',
        'sort': 'DISTANCE',
      });

      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': apiKey,
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List? ?? [];
        final venues = results.map(_parseVenue).whereType<FsqVenue>().toList();
        debugPrint('Foursquare: ${venues.length} venues near ($lat, $lng)');
        return venues;
      } else if (response.statusCode == 429) {
        debugPrint('Foursquare: rate limit hit');
      } else if (response.statusCode == 401) {
        debugPrint('Foursquare: invalid API key');
      } else {
        debugPrint('Foursquare HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Foursquare error: $e');
    }
    return [];
  }

  static FsqVenue? _parseVenue(dynamic raw) {
    try {
      final m = raw as Map<String, dynamic>;
      final fsqId = m['fsq_id'] as String? ?? '';
      final name  = m['name']   as String? ?? '';
      if (fsqId.isEmpty || name.isEmpty) return null;

      final geo = m['geocodes']?['main'] as Map?;
      final lat = (geo?['latitude']  as num?)?.toDouble() ?? 0.0;
      final lng = (geo?['longitude'] as num?)?.toDouble() ?? 0.0;
      if (lat == 0.0 && lng == 0.0) return null;

      // Photo URL: combine prefix + size + suffix
      String? photoUrl;
      final photos = m['photos'] as List?;
      if (photos != null && photos.isNotEmpty) {
        final p = photos.first as Map;
        final prefix = p['prefix']?.toString() ?? '';
        final suffix = p['suffix']?.toString() ?? '';
        if (prefix.isNotEmpty && suffix.isNotEmpty) {
          photoUrl = '${prefix}600x400$suffix';
        }
      }

      // Rating (0-10 from FSQ, we store raw here)
      final rating = (m['rating'] as num?)?.toDouble();

      // Primary category name
      final categories = m['categories'] as List?;
      String? category;
      if (categories != null && categories.isNotEmpty) {
        category = (categories.first as Map)['name']?.toString();
      }

      return FsqVenue(
        fsqId: fsqId,
        name: name,
        lat: lat,
        lng: lng,
        photoUrl: photoUrl,
        rating: rating,
        category: category,
      );
    } catch (e) {
      debugPrint('Foursquare parse error: $e');
      return null;
    }
  }
}
