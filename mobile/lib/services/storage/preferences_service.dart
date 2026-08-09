// Wraps SharedPreferences access for settings and scan history storage.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLocale = 'locale';

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_keyThemeMode, mode.index);
  }

  ThemeMode getThemeMode() {
    final index = _prefs.getInt(_keyThemeMode);
    if (index == null) return ThemeMode.system;
    if (index < 0 || index >= ThemeMode.values.length) return ThemeMode.system;
    return ThemeMode.values[index];
  }

  Future<void> saveLocale(String languageCode) async {
    await _prefs.setString(_keyLocale, languageCode);
  }

  Locale? getLocale() {
    final code = _prefs.getString(_keyLocale);
    if (code == null) return null;
    return Locale(code);
  }
}
