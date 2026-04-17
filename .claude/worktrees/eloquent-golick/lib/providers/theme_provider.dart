import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> initialize() async {
    try {
      final p = await SharedPreferences.getInstance();
      _isDark = p.getBool('dark_mode') ?? false;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggle() async {
    _isDark = !_isDark;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool('dark_mode', _isDark);
    } catch (_) {}
  }
}
