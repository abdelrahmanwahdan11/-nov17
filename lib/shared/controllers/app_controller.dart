import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_routes.dart';
import '../../core/storage/app_preferences.dart';

class AppController extends ChangeNotifier {
  AppController(this._preferences);

  final AppPreferences _preferences;

  ThemeMode themeMode = ThemeMode.light;
  Locale locale = AppLocalizations.supportedLocales.first;
  Color primaryColor = const Color(0xFFD9E272);
  bool onboardingSeen = false;
  bool isLoggedIn = false;

  String get initialRoute {
    if (!onboardingSeen) {
      return AppRoutes.onboarding;
    }
    if (!isLoggedIn) {
      return AppRoutes.login;
    }
    return AppRoutes.home;
  }

  Future<void> restore() async {
    themeMode = _preferences.restoreThemeMode();
    primaryColor = _preferences.restorePrimaryColor(primaryColor);
    locale = _preferences.restoreLocale(locale);
    onboardingSeen = _preferences.restoreOnboardingSeen();
    isLoggedIn = _preferences.restoreIsLoggedIn();
    notifyListeners();
  }

  Future<void> markOnboardingSeen() async {
    onboardingSeen = true;
    await _preferences.persistOnboardingSeen(true);
    notifyListeners();
  }

  Future<void> updateLoginState(bool loggedIn) async {
    isLoggedIn = loggedIn;
    await _preferences.persistIsLoggedIn(loggedIn);
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    themeMode = mode;
    await _preferences.persistThemeMode(mode);
    notifyListeners();
  }

  Future<void> updateLocale(Locale newLocale) async {
    locale = newLocale;
    await _preferences.persistLocale(newLocale);
    notifyListeners();
  }

  Future<void> updatePrimaryColor(Color color) async {
    primaryColor = color;
    await _preferences.persistPrimaryColor(color);
    notifyListeners();
  }
}
