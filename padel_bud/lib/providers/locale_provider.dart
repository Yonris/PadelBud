import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(const Locale('en'));
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(super.initialState);

  void setLocale(Locale locale) {
    state = locale;
  }

  void toggleLanguage() {
    if (state.languageCode == 'en') {
      state = const Locale('he');
    } else {
      state = const Locale('en');
    }
  }
}
