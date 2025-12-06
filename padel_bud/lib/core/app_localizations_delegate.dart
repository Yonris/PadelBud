import 'package:flutter/material.dart';
import 'app_localizations.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'he'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    if (locale.languageCode == 'he') {
      return AppLocalizationsHe();
    }
    return AppLocalizationsEn();
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
