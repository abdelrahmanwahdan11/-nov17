import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static const _localizedValues = {
    'en': {
      'app_title': 'ConnecQ Productivity OS',
      'skip': 'Skip',
      'next': 'Next',
      'get_started': 'Get Started',
      'login': 'Login',
      'login_guest': 'Login as guest',
      'email': 'Email address',
      'password': 'Password',
      'forgot_password': 'Forgot password?',
      'register': 'Register',
      'dashboard': 'Dashboard',
      'projects': 'Projects',
      'tasks': 'Tasks',
      'calendar': 'Calendar',
      'finance': 'Finance Overview',
      'tools': 'Tools',
      'catalog': 'Catalog',
      'compare': 'Compare',
      'search': 'Search',
      'notifications': 'Notifications',
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'primary_color': 'Primary color',
      'ai_placeholder': 'AI assistant will be available in a future version.',
      'done': 'Done',
      'refreshing': 'Refreshing data...'
    },
    'ar': {
      'app_title': 'نظام كونيك كيو للإنتاجية',
      'skip': 'تخطي',
      'next': 'التالي',
      'get_started': 'ابدأ الآن',
      'login': 'تسجيل الدخول',
      'login_guest': 'الدخول كضيف',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgot_password': 'هل نسيت كلمة المرور؟',
      'register': 'إنشاء حساب',
      'dashboard': 'لوحة التحكم',
      'projects': 'المشاريع',
      'tasks': 'المهام',
      'calendar': 'التقويم',
      'finance': 'نظرة مالية',
      'tools': 'الأدوات',
      'catalog': 'كتالوج',
      'compare': 'مقارنة',
      'search': 'بحث',
      'notifications': 'الإشعارات',
      'settings': 'الإعدادات',
      'theme': 'السمة',
      'language': 'اللغة',
      'dark_mode': 'الوضع الداكن',
      'primary_color': 'اللون الأساسي',
      'ai_placeholder': 'سيتوفر مساعد الذكاء الاصطناعي في إصدار لاحق.',
      'done': 'تم',
      'refreshing': 'جاري تحديث البيانات...'
    }
  };

  String translate(String key) => _localizedValues[locale.languageCode]?[key] ?? key;

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
