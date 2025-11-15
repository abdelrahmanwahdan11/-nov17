import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_routes.dart';
import '../../core/models/mock_repository.dart';
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
import '../controllers/catalog_controller.dart';
import '../controllers/compare_controller.dart';
import '../controllers/projects_controller.dart';
import '../controllers/tasks_controller.dart';
import '../controllers/workspace_scope.dart';
import 'app_drawer.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final MockRepository _repository;
  late final CompareController _compareController;
  late final ProjectsController _projectsController;
  late final TasksController _tasksController;
  late final CatalogController _catalogController;
  int _index = 0;
  bool _drawerOpen = false;

  @override
  void initState() {
    super.initState();
    _repository = MockRepository();
    _compareController = CompareController();
    _projectsController = ProjectsController(repository: _repository, compare: _compareController);
    _tasksController = TasksController(repository: _repository, compare: _compareController);
    _catalogController = CatalogController(repository: _repository, compare: _compareController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _projectsController.bootstrap();
      _tasksController.bootstrap();
      _catalogController.bootstrap();
    });
  }

  void _navigate(int index) {
    setState(() {
      _index = index;
      _drawerOpen = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _projectsController.dispose();
    _tasksController.dispose();
    _catalogController.dispose();
    _compareController.dispose();
    super.dispose();
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const ProjectsScreen();
      case 2:
        return const TasksScreen();
      case 3:
        return const CalendarScreen();
      case 4:
        return const FinanceOverviewScreen();
      case 5:
        return const ToolsScreen();
      case 6:
        return const CatalogScreen();
      case 7:
        return const CompareScreen();
      case 8:
        return const SearchScreen();
      case 9:
        return const NotificationsScreen();
      case 10:
        return SettingsScreen(controller: widget.controller);
    }
    return const SizedBox.shrink();
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

    return WorkspaceScope(
      app: widget.controller,
      repository: _repository,
      projects: _projectsController,
      tasks: _tasksController,
      catalog: _catalogController,
      compare: _compareController,
      child: Directionality(
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
              child: _buildPage(_index),
            ),
          ),
        ),
      ),
    );
  }
}
