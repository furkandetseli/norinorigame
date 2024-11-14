import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode;
  Locale _locale;
  final SharedPreferences _prefs;

  static const String THEME_KEY = 'isDarkMode';
  static const String LANGUAGE_KEY = 'language';

  SettingsProvider(this._prefs)
      : _isDarkMode = _prefs.getBool(THEME_KEY) ?? false,
        _locale = Locale(_prefs.getString(LANGUAGE_KEY) ?? 'tr', '');

  bool get isDarkMode => _isDarkMode;
  Locale get locale => _locale;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(THEME_KEY, _isDarkMode);
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    await _prefs.setString(LANGUAGE_KEY, newLocale.languageCode);
    notifyListeners();
  }

  // Dil koduna göre geçerli dil adını döndürür
  String getCurrentLanguageName() {
    switch (_locale.languageCode) {
      case 'tr':
        return 'Türkçe 🇹🇷';
      case 'en':
        return 'English 🇬🇧';
      default:
        return 'Unknown';
    }
  }
}