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
import '../../features/clients/clients_screen.dart';
import '../../features/team/team_screen.dart';
import '../../features/tools/tools_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../controllers/app_controller.dart';
import '../controllers/catalog_controller.dart';
import '../controllers/compare_controller.dart';
import '../controllers/notifications_controller.dart';
import '../controllers/clients_controller.dart';
import '../controllers/projects_controller.dart';
import '../controllers/scheduler_controller.dart';
import '../controllers/tasks_controller.dart';
import '../controllers/workspace_scope.dart';
import '../controllers/templates_controller.dart';
import '../controllers/library_controller.dart';
import '../controllers/finance_controller.dart';
import '../controllers/insights_controller.dart';
import '../controllers/goals_controller.dart';
import '../controllers/team_controller.dart';
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
  late final NotificationsController _notificationsController;
  late final ClientsController _clientsController;
  late final SchedulerController _schedulerController;
  late final TemplatesController _templatesController;
  late final LibraryController _libraryController;
  late final FinanceController _financeController;
  late final InsightsController _insightsController;
  late final GoalsController _goalsController;
  late final TeamController _teamController;
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
    _notificationsController = NotificationsController(repository: _repository)
      ..addListener(_onNotificationsChanged);
    _clientsController = ClientsController(repository: _repository);
    _schedulerController = SchedulerController(repository: _repository);
    _templatesController = TemplatesController(repository: _repository);
    _libraryController = LibraryController(repository: _repository);
    _financeController = FinanceController(repository: _repository);
    _insightsController = InsightsController(
      repository: _repository,
      app: widget.controller,
      projects: _projectsController,
      tasks: _tasksController,
      finance: _financeController,
    );
    _goalsController = GoalsController(
      app: widget.controller,
      repository: _repository,
      tasks: _tasksController,
      finance: _financeController,
    );
    _teamController = TeamController(repository: _repository);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _projectsController.bootstrap();
      _tasksController.bootstrap();
      _catalogController.bootstrap();
      _notificationsController.bootstrap();
      _clientsController.bootstrap();
      _schedulerController.bootstrap();
      _templatesController.bootstrap();
      _libraryController.bootstrap();
      _financeController.bootstrap();
      _goalsController.bootstrap();
      _teamController.bootstrap();
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
    _notificationsController
      ..removeListener(_onNotificationsChanged)
      ..dispose();
    _clientsController.dispose();
    _schedulerController.dispose();
    _templatesController.dispose();
    _libraryController.dispose();
    _financeController.dispose();
    _insightsController.dispose();
    _goalsController.dispose();
    _teamController.dispose();
    _compareController.dispose();
    super.dispose();
  }

  void _onNotificationsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _openNotifications() {
    setState(() {
      _index = 11;
      _drawerOpen = false;
    });
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
        return const ClientsScreen();
      case 6:
        return const TeamScreen();
      case 7:
        return const ToolsScreen();
      case 8:
        return const CatalogScreen();
      case 9:
        return const CompareScreen();
      case 10:
        return const SearchScreen();
      case 11:
        return const NotificationsScreen();
      case 12:
        return SettingsScreen(controller: widget.controller);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final unreadCount = _notificationsController.unreadCount;
    final notificationsTitle = unreadCount > 0
        ? loc.translate('notifications_with_count', params: {'count': unreadCount.toString().padLeft(2, '0')})
        : loc.translate('notifications');
    final titles = [
      loc.translate('dashboard'),
      loc.translate('projects'),
      loc.translate('tasks'),
      loc.translate('calendar'),
      loc.translate('finance'),
      loc.translate('clients'),
      loc.translate('team'),
      loc.translate('tools'),
      loc.translate('catalog'),
      loc.translate('compare'),
      loc.translate('search'),
      notificationsTitle,
      loc.translate('settings'),
    ];

    return WorkspaceScope(
      app: widget.controller,
      repository: _repository,
      projects: _projectsController,
      tasks: _tasksController,
      catalog: _catalogController,
      compare: _compareController,
      notifications: _notificationsController,
      clients: _clientsController,
      scheduler: _schedulerController,
      templates: _templatesController,
      library: _libraryController,
      finance: _financeController,
      insights: _insightsController,
      goals: _goalsController,
      team: _teamController,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: _openNotifications,
                      icon: const Icon(Icons.notifications_rounded),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black87),
                          ),
                        ),
                      ),
                  ],
                ),
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
