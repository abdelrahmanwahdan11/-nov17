import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingSeenKey = 'onboarding_seen';
  static const _isLoggedInKey = 'is_logged_in';
  static const _themeModeKey = 'theme_mode';
  static const _primaryColorKey = 'primary_color_hex';
  static const _localeKey = 'app_language';

  static Future<AppPreferences> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences(prefs);
  }

  bool restoreOnboardingSeen() => _prefs.getBool(_onboardingSeenKey) ?? false;

  Future<void> persistOnboardingSeen(bool value) => _prefs.setBool(_onboardingSeenKey, value);

  bool restoreIsLoggedIn() => _prefs.getBool(_isLoggedInKey) ?? false;

  Future<void> persistIsLoggedIn(bool value) => _prefs.setBool(_isLoggedInKey, value);

  ThemeMode restoreThemeMode() {
    final value = _prefs.getString(_themeModeKey);
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  Future<void> persistThemeMode(ThemeMode mode) => _prefs.setString(
        _themeModeKey,
        switch (mode) {
          ThemeMode.dark => 'dark',
          ThemeMode.system => 'system',
          _ => 'light',
        },
      );

  Color restorePrimaryColor(Color fallback) {
    final value = _prefs.getString(_primaryColorKey);
    if (value == null) {
      return fallback;
    }
    return Color(int.parse(value, radix: 16));
  }

  Future<void> persistPrimaryColor(Color color) => _prefs.setString(
        _primaryColorKey,
        color.value.toRadixString(16),
      );

  Locale restoreLocale(Locale fallback) {
    final value = _prefs.getString(_localeKey);
    if (value == null) {
      return fallback;
    }
    return Locale(value);
  }

  Future<void> persistLocale(Locale locale) => _prefs.setString(
        _localeKey,
        locale.languageCode,
      );
}
