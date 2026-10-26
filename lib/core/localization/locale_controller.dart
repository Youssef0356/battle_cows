import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController._();

  static final LocaleController instance = LocaleController._();

  static const String _prefKey = 'selected_locale';
  static const String _prefChosenKey = 'has_chosen_language';

  Locale _locale = const Locale('en');
  bool _hasChosenLanguage = false;

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isFrench => _locale.languageCode == 'fr';
  bool get isEnglish => _locale.languageCode == 'en';
  bool get hasChosenLanguage => _hasChosenLanguage;
  bool get isFirstLaunch => !_hasChosenLanguage;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);
      final hasChosen = prefs.getBool(_prefChosenKey);
      if (savedCode != null && (savedCode == 'en' || savedCode == 'fr' || savedCode == 'ar')) {
        _locale = Locale(savedCode);
        _hasChosenLanguage = true;
        notifyListeners();
      } else if (hasChosen == true) {
        _hasChosenLanguage = true;
      } else {
        _hasChosenLanguage = false;
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale newLocale) async {
    final changed = _locale != newLocale;
    _locale = newLocale;
    _hasChosenLanguage = true;
    if (changed) {
      notifyListeners();
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, newLocale.languageCode);
      await prefs.setBool(_prefChosenKey, true);
    } catch (_) {}
  }

  @visibleForTesting
  void resetForTesting() {
    _locale = const Locale('en');
    _hasChosenLanguage = false;
  }
}
