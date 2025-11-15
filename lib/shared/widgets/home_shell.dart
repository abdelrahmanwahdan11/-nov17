import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_routes.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/projects/projects_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/finance/finance_overview_screen.dart';
import '../../features/catalog/catalog_screen.dart';
import '../../features/compare/compare_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/tools/tools_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../controllers/app_controller.dart';
import 'app_drawer.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final Map<int, Widget> _pages;
  int _index = 0;
  bool _drawerOpen = false;

  @override
  void initState() {
    super.initState();
    _pages = {
      0: const DashboardScreen(),
      1: const ProjectsScreen(),
      2: const TasksScreen(),
      3: const CalendarScreen(),
      4: const FinanceOverviewScreen(),
      5: const ToolsScreen(),
      6: const CatalogScreen(),
      7: const CompareScreen(),
      8: const SearchScreen(),
      9: const NotificationsScreen(),
      10: SettingsScreen(controller: widget.controller),
    };
  }

  void _navigate(int index) {
    setState(() {
      _index = index;
      _drawerOpen = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final titles = [
      loc.translate('dashboard'),
      loc.translate('projects'),
      loc.translate('tasks'),
      loc.translate('calendar'),
      loc.translate('finance'),
      loc.translate('tools'),
      loc.translate('catalog'),
      loc.translate('compare'),
      loc.translate('search'),
      loc.translate('notifications'),
      loc.translate('settings'),
    ];

    return Directionality(
      textDirection: widget.controller.locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        drawer: AppDrawer(
          controller: widget.controller,
          selectedIndex: _index,
          onNavigate: _navigate,
          destinations: titles,
        ),
        appBar: AppBar(
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                  setState(() => _drawerOpen = true);
                },
              );
            },
          ),
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              titles[_index],
              key: ValueKey(titles[_index]),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.identity()
            ..translate(_drawerOpen ? 20.0 : 0.0)
            ..scale(_drawerOpen ? 0.95 : 1.0),
          curve: Curves.easeInOut,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _pages[_index],
          ),
        ),
      ),
    );
  }
}
