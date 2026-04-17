import 'dart:convert';
import 'package:http/http.dart' as http;

const String _placesApiKey = 'AIzaSyB8voNd5dgCVAGQpVIQJCt5CPdk3FZhoTY';

class PlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String fullText;

  PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.fullText,
  });
}

class PlaceDetail {
  final String name;
  final String formattedAddress;
  final double lat;
  final double lng;

  PlaceDetail({
    required this.name,
    required this.formattedAddress,
    required this.lat,
    required this.lng,
  });
}

class PlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  /// Autocomplete predictions for Turkey
  static Future<List<PlacePrediction>> autocomplete(String input) async {
    if (input.trim().isEmpty) return [];

    final url = Uri.parse(
      '$_baseUrl/place/autocomplete/json'
      '?input=${Uri.encodeComponent(input)}'
      '&components=country:tr'
      '&language=tr'
      '&types=geocode|establishment'
      '&key=$_placesApiKey',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        return (data['predictions'] as List).map((p) => PlacePrediction(
          placeId: p['place_id'],
          mainText: p['structured_formatting']['main_text'] ?? '',
          secondaryText: p['structured_formatting']['secondary_text'] ?? '',
          fullText: p['description'] ?? '',
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get place details by placeId
  static Future<PlaceDetail?> getPlaceDetail(String placeId) async {
    final url = Uri.parse(
      '$_baseUrl/place/details/json'
      '?place_id=$placeId'
      '&fields=name,formatted_address,geometry'
      '&language=tr'
      '&key=$_placesApiKey',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        final result = data['result'];
        final loc = result['geometry']['location'];
        return PlaceDetail(
          name: result['name'] ?? '',
          formattedAddress: result['formatted_address'] ?? '',
          lat: loc['lat'],
          lng: loc['lng'],
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Reverse geocode: lat/lng → address
  static Future<String?> reverseGeocode(double lat, double lng) async {
    final url = Uri.parse(
      '$_baseUrl/geocode/json'
      '?latlng=$lat,$lng'
      '&language=tr'
      '&key=$_placesApiKey',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
        return data['results'][0]['formatted_address'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Nearby restaurants search
  static Future<List<NearbyRestaurantResult>> nearbyRestaurants({
    required double lat,
    required double lng,
    int radius = 2000,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/place/nearbysearch/json'
      '?location=$lat,$lng'
      '&radius=$radius'
      '&type=restaurant'
      '&language=tr'
      '&key=$_placesApiKey',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        return (data['results'] as List).map((r) => NearbyRestaurantResult(
          placeId: r['place_id'] ?? '',
          name: r['name'] ?? '',
          rating: (r['rating'] ?? 0).toDouble(),
          userRatingsTotal: r['user_ratings_total'] ?? 0,
          vicinity: r['vicinity'] ?? '',
          isOpen: r['opening_hours']?['open_now'] ?? true,
          photoReference: (r['photos'] as List?)?.isNotEmpty == true
              ? r['photos'][0]['photo_reference']
              : null,
          lat: r['geometry']['location']['lat'],
          lng: r['geometry']['location']['lng'],
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get photo URL from photo reference
  static String getPhotoUrl(String photoReference, {int maxWidth = 600}) {
    return '$_baseUrl/place/photo'
        '?maxwidth=$maxWidth'
        '&photo_reference=$photoReference'
        '&key=$_placesApiKey';
  }
}

class NearbyRestaurantResult {
  final String placeId;
  final String name;
  final double rating;
  final int userRatingsTotal;
  final String vicinity;
  final bool isOpen;
  final String? photoReference;
  final double lat;
  final double lng;

  NearbyRestaurantResult({
    required this.placeId,
    required this.name,
    required this.rating,
    required this.userRatingsTotal,
    required this.vicinity,
    required this.isOpen,
    this.photoReference,
    required this.lat,
    required this.lng,
  });

  String get photoUrl => photoReference != null
      ? PlacesService.getPhotoUrl(photoReference!)
      : 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600';
}
