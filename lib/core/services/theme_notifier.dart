import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton ChangeNotifier that persists the user's chosen ThemeMode.
/// Access via [ThemeNotifier.instance] anywhere in the app.
class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier._internal();
  static final ThemeNotifier instance = ThemeNotifier._internal();

  static const _key = 'app_theme_mode';
  ThemeMode _mode = ThemeMode.dark;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  /// Load persisted preference (call once at startup in app.dart).
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    _mode = (saved == 'light') ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  /// Toggle between light and dark, persisting the choice.
  Future<void> toggle() async {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, isDark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}
