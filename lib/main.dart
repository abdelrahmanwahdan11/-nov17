import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/localization/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/storage/app_preferences.dart';
import 'core/theme/app_theme.dart';
import 'shared/controllers/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await AppPreferences.getInstance();
  final controller = AppController(preferences);
  await controller.restore();
  runApp(ConnecQApp(controller: controller));
}

class ConnecQApp extends StatefulWidget {
  const ConnecQApp({super.key, required this.controller});

  final AppController controller;

  @override
  State<ConnecQApp> createState() => _ConnecQAppState();
}

class _ConnecQAppState extends State<ConnecQApp> {
  late AppRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter(controller: widget.controller);
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = buildAppTheme(widget.controller.primaryColor, widget.controller.themeMode);

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'ConnecQ Productivity OS',
          theme: theme.light,
          darkTheme: theme.dark,
          themeMode: widget.controller.themeMode,
          navigatorKey: _router.navigatorKey,
          onGenerateRoute: _router.onGenerateRoute,
          initialRoute: widget.controller.initialRoute,
          locale: widget.controller.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          builder: (context, child) {
            final textTheme = GoogleFonts.urbanistTextTheme(Theme.of(context).textTheme);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: DefaultTextStyle.merge(
                style: textTheme.bodyMedium,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}
