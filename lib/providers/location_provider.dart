import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationProvider extends ChangeNotifier {
  Position? _position;
  String _currentAddress = 'Konum henüz alınmadı';
  String? _detectedCity;
  bool _loading = false;

  Position? get position        => _position;
  String   get currentAddress   => _currentAddress;
  String?  get detectedCity     => _detectedCity;
  bool     get loading          => _loading;

  String get shortAddress {
    if (_detectedCity != null) return _detectedCity!;
    if (_currentAddress.length > 30) return '${_currentAddress.substring(0, 28)}…';
    return _currentAddress;
  }

  // Turkish city detection from coordinates (approximate bounding boxes)
  static const _cityBounds = <String, List<double>>{
    'İstanbul'   : [28.0, 41.0, 30.0, 41.6],
    'Ankara'     : [31.8, 39.6, 33.4, 40.4],
    'İzmir'      : [26.1, 37.8, 28.0, 39.0],
    'Bursa'      : [28.0, 39.7, 30.0, 40.5],
    'Antalya'    : [29.0, 36.0, 32.0, 37.5],
    'Adana'      : [35.0, 36.9, 36.5, 37.8],
    'Konya'      : [31.5, 37.0, 34.5, 38.8],
    'Gaziantep'  : [36.5, 36.8, 37.8, 37.4],
    'Kayseri'    : [35.0, 38.4, 36.5, 39.4],
    'Trabzon'    : [39.5, 40.7, 40.5, 41.2],
    'Samsun'     : [35.5, 41.0, 37.0, 41.6],
    'Diyarbakır' : [39.5, 37.7, 40.5, 38.2],
    'Eskişehir'  : [30.0, 39.4, 31.5, 40.2],
    'Mersin'     : [33.0, 36.4, 35.0, 37.2],
    'Kocaeli'    : [29.6, 40.5, 30.8, 41.1],
    'Malatya'    : [37.5, 38.1, 38.9, 38.8],
    'Sakarya'    : [29.8, 40.5, 31.2, 41.2],
  };

  String? _detectCityFromCoords(double lat, double lon) {
    for (final entry in _cityBounds.entries) {
      final b = entry.value; // [minLon, minLat, maxLon, maxLat]
      if (lon >= b[0] && lat >= b[1] && lon <= b[2] && lat <= b[3]) {
        return entry.key;
      }
    }
    return null;
  }

  Future<void> getCurrentLocation() async {
    _loading = true;
    notifyListeners();

    try {
      // İzin kontrol
      var status = await Permission.location.status;
      if (status.isDenied) {
        status = await Permission.location.request();
      }
      if (!status.isGranted) {
        _currentAddress = 'Konum izni verilmedi. Ayarlardan izin verin.';
        _loading = false;
        notifyListeners();
        return;
      }

      // Servis aktif mi?
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _currentAddress = 'Konum servisi kapalı. Lütfen GPS\'i açın.';
        _loading = false;
        notifyListeners();
        return;
      }

      _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 12),
      );

      _detectedCity = _detectCityFromCoords(_position!.latitude, _position!.longitude);
      _currentAddress = _detectedCity != null
        ? '$_detectedCity (${_position!.latitude.toStringAsFixed(3)}, ${_position!.longitude.toStringAsFixed(3)})'
        : '${_position!.latitude.toStringAsFixed(4)}, ${_position!.longitude.toStringAsFixed(4)}';

    } on LocationServiceDisabledException {
      _currentAddress = 'GPS kapalı. Lütfen konumu açın.';
    } on PermissionDeniedException {
      _currentAddress = 'Konum izni reddedildi.';
    } catch (e) {
      debugPrint('Location error: $e');
      _currentAddress = 'Konum alınamadı. Tekrar deneyin.';
    }

    _loading = false;
    notifyListeners();
  }
}
