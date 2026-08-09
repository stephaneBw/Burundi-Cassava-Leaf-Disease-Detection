// Manages locale and theme settings loaded from local preferences.

import 'package:flutter/material.dart';
import '../../../services/storage/preferences_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController(this._preferencesService);
  final PreferencesService _preferencesService;

  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  Future<void> loadSettings() async {
    _themeMode = _preferencesService.getThemeMode();
    _locale = _preferencesService.getLocale();
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    notifyListeners();
    await _preferencesService.saveThemeMode(newThemeMode);
  }

  Future<void> updateLocale(Locale? newLocale) async {
    if (newLocale == null) return;
    if (newLocale == _locale) return;

    _locale = newLocale;
    notifyListeners();
    await _preferencesService.saveLocale(newLocale.languageCode);
  }
}
