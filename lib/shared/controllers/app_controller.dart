import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_routes.dart';
import '../../core/models/tracked_session.dart';
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
  List<TrackedSession> _trackedSessions = const [];
  List<String> _searchHistory = const [];

  String get initialRoute {
    if (!onboardingSeen) {
      return AppRoutes.onboarding;
    }
    if (!isLoggedIn) {
      return AppRoutes.login;
    }
    return AppRoutes.home;
  }

  List<TrackedSession> get trackedSessions => List.unmodifiable(_trackedSessions);

  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  TrackedSession? get lastTrackedSession => _trackedSessions.isEmpty ? null : _trackedSessions.first;

  Duration get totalTrackedDuration =>
      _trackedSessions.fold(Duration.zero, (previous, session) => previous + session.duration);

  Duration get weeklyTrackedDuration {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    return _trackedSessions
        .where((session) => !session.timestamp.isBefore(startOfWeek))
        .fold(Duration.zero, (previous, session) => previous + session.duration);
  }

  String? get topTrackedTaskTitle {
    if (_trackedSessions.isEmpty) {
      return null;
    }
    final totals = <String, Duration>{};
    for (final session in _trackedSessions) {
      final key = session.taskTitle?.trim().isEmpty ?? true
          ? (session.taskId ?? 'unassigned')
          : session.taskTitle!;
      totals[key] = (totals[key] ?? Duration.zero) + session.duration;
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.inSeconds.compareTo(a.value.inSeconds));
    final top = sorted.first;
    if (top.key == 'unassigned') {
      return null;
    }
    return top.key;
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
    _trackedSessions = _preferences.restoreTimeTrackerHistory();
    _searchHistory = List<String>.from(_preferences.restoreSearchHistory());
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

  Future<void> recordTrackedSession(TrackedSession session) async {
    final updated = [session, ..._trackedSessions];
    _trackedSessions = updated.length > 20 ? updated.take(20).toList() : updated;
    await _preferences.persistTimeTrackerHistory(_trackedSessions);
    notifyListeners();
  }

  Future<void> clearTrackedSessions() async {
    _trackedSessions = const [];
    lastTrackedDuration = Duration.zero;
    await _preferences.persistTimeTrackerHistory(_trackedSessions);
    await _preferences.persistTimeTrackerDuration(lastTrackedDuration);
    notifyListeners();
  }

  String get displayName => (userName == null || userName!.isEmpty) ? 'Alya Hassan' : userName!;

  String get displayEmail => (userEmail == null || userEmail!.isEmpty) ? 'alya@connecq.app' : userEmail!;

  Future<void> addSearchHistory(String query) async {
    final sanitized = query.trim();
    if (sanitized.isEmpty) {
      return;
    }
    final lower = sanitized.toLowerCase();
    final filtered = _searchHistory.where((item) => item.toLowerCase() != lower).toList(growable: false);
    final updated = [sanitized, ...filtered];
    _searchHistory = updated.length > 10 ? updated.take(10).toList(growable: false) : updated;
    await _preferences.persistSearchHistory(_searchHistory);
    notifyListeners();
  }

  Future<void> removeSearchHistory(String query) async {
    final lower = query.toLowerCase();
    final updated = _searchHistory.where((item) => item.toLowerCase() != lower).toList(growable: false);
    if (updated.length == _searchHistory.length) {
      return;
    }
    _searchHistory = updated;
    await _preferences.persistSearchHistory(_searchHistory);
    notifyListeners();
  }

  Future<void> clearSearchHistory() async {
    if (_searchHistory.isEmpty) {
      return;
    }
    _searchHistory = const [];
    await _preferences.persistSearchHistory(_searchHistory);
    notifyListeners();
  }
}
