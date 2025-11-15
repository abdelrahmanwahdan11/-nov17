import 'package:flutter/material.dart';

class AppThemeBundle {
  const AppThemeBundle({required this.light, required this.dark});

  final ThemeData light;
  final ThemeData dark;
}

AppThemeBundle buildAppTheme(Color primaryColor, ThemeMode mode) {
  final colorSchemeLight = ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: Brightness.light,
    primary: primaryColor,
    background: const Color(0xFFF3F5F3),
    surface: const Color(0xFFF8F9F7),
  );

  final colorSchemeDark = ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: Brightness.dark,
    primary: primaryColor,
    background: const Color(0xFF111315),
    surface: const Color(0xFF1A1D20),
  );

  final baseTextTheme = Typography.englishLike2018.apply(fontSizeFactor: 1.0);

  ThemeData themed(ColorScheme colors) => ThemeData(
        colorScheme: colors,
        scaffoldBackgroundColor: colors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: colors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: colors.onBackground),
          titleTextStyle: baseTextTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onBackground,
          ),
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          color: colors.surface,
          elevation: colors.brightness == Brightness.light ? 0.5 : 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          backgroundColor: colors.surface,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(colors.primary),
          trackColor: MaterialStateProperty.all(colors.primary.withOpacity(0.3)),
        ),
      );

  return AppThemeBundle(
    light: themed(colorSchemeLight),
    dark: themed(colorSchemeDark),
  );
}
