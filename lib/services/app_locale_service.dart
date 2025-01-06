import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocaleService {
  static const supportedLocales = [Locale('en'), Locale('es')];
  static const fallbackLocale = Locale('en');
  Map<String, Map<String, dynamic>> translations = {};
  Locale _locale = const Locale('en');
  Locale _systemLocale = const Locale('en');

  Locale get locale => _locale;

  AppLocaleService() {
    loadTranslations();
  }

  void loadTranslations() async {
    const String path = 'assets/translations';
    for (var locale in supportedLocales) {
      final String response =
          await rootBundle.loadString('$path/${locale.languageCode}.json');
      final Map<String, dynamic> data = await json.decode(response);
      translations[locale.languageCode] = data;
    }
  }

  String tr(Locale locale, String key) {
    print('translating: $key');
    if (translations[locale.languageCode] == null) {
      return 'Not Found';
    }
    return (translations[locale.languageCode]?[key] ?? 'Not Found').toString();
  }

  String get localeToAppend {
    print(locale.toString());
    return locale.toString() == 'en' ? '' : '_${locale.toString()}';
  }

  Locale get systemLocale => _systemLocale;

  set systemLocale(Locale locale) {
    _systemLocale = Locale(locale.languageCode);
    _locale = _locale ?? _systemLocale;
  }

  void changeLocale(Locale newLocale) {
    _locale = newLocale;
  }

  void resetLocaleToDefaultSystemLocale() {
    _locale = _systemLocale;
  }
}
