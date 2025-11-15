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
  String? userName;
  String? userEmail;
  Duration lastTrackedDuration = Duration.zero;
  String? lastTrackedTaskId;

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
    userName = _preferences.restoreUserName();
    userEmail = _preferences.restoreUserEmail();
    lastTrackedDuration = _preferences.restoreTimeTrackerDuration();
    lastTrackedTaskId = _preferences.restoreTimeTrackerTask();
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

  Future<void> updateUserProfile({String? name, String? email}) async {
    userName = name?.trim().isEmpty ?? true ? userName : name?.trim();
    userEmail = email?.trim().isEmpty ?? true ? userEmail : email?.trim();
    await _preferences.persistUserName(userName);
    await _preferences.persistUserEmail(userEmail);
    notifyListeners();
  }

  Future<void> updateLastTrackedDuration(Duration duration) async {
    lastTrackedDuration = duration;
    await _preferences.persistTimeTrackerDuration(duration);
    notifyListeners();
  }

  Future<void> updateLastTrackedTask(String? taskId) async {
    lastTrackedTaskId = taskId;
    await _preferences.persistTimeTrackerTask(taskId);
    notifyListeners();
  }

  String get displayName => (userName == null || userName!.isEmpty) ? 'Alya Hassan' : userName!;

  String get displayEmail => (userEmail == null || userEmail!.isEmpty) ? 'alya@connecq.app' : userEmail!;
}
