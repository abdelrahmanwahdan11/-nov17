import 'package:flutter/material.dart';

import '../../shared/controllers/app_controller.dart';
import '../../shared/widgets/home_shell.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/catalog/catalog_screen.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/compare/compare_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/finance/finance_overview_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/onboarding/onboarding_story_screen.dart';
import '../../features/projects/project_details_screen.dart';
import '../../features/projects/projects_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/tasks/task_details_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../../features/time_tracker/time_tracker_screen.dart';
import '../../features/tools/library_screen.dart';
import '../../features/tools/scheduler_screen.dart';
import '../../features/tools/templates_screen.dart';
import '../../features/tools/tools_screen.dart';
import '../models/mock_data.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter({required this.controller});

  final AppController controller;
  final navigatorKey = GlobalKey<NavigatorState>();

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboarding:
        return _material(settings, OnboardingStoryScreen(controller: controller));
      case AppRoutes.login:
        return _material(settings, LoginScreen(controller: controller));
      case AppRoutes.register:
        return _material(settings, RegisterScreen(controller: controller));
      case AppRoutes.forgotPassword:
        return _material(settings, const ForgotPasswordScreen());
      case AppRoutes.home:
        return _material(settings, HomeShell(controller: controller));
      case AppRoutes.dashboard:
        return _material(settings, const DashboardScreen());
      case AppRoutes.projects:
        return _material(settings, const ProjectsScreen());
      case AppRoutes.projectDetails:
        return _material(settings, ProjectDetailsScreen(project: settings.arguments as Project));
      case AppRoutes.tasks:
        return _material(settings, const TasksScreen());
      case AppRoutes.taskDetails:
        return _material(settings, TaskDetailsScreen(task: settings.arguments as dynamic));
      case AppRoutes.calendar:
        return _material(settings, const CalendarScreen());
      case AppRoutes.finance:
        return _material(settings, const FinanceOverviewScreen());
      case AppRoutes.tools:
        return _material(settings, const ToolsScreen());
      case AppRoutes.scheduler:
        return _material(settings, const SchedulerScreen());
      case AppRoutes.templates:
        return _material(settings, const TemplatesScreen());
      case AppRoutes.library:
        return _material(settings, const LibraryScreen());
      case AppRoutes.catalog:
        return _material(settings, const CatalogScreen());
      case AppRoutes.compare:
        return _material(settings, const CompareScreen());
      case AppRoutes.search:
        return _material(settings, const SearchScreen());
      case AppRoutes.settings:
        return _material(settings, SettingsScreen(controller: controller));
      case AppRoutes.notifications:
        return _material(settings, const NotificationsScreen());
      case AppRoutes.timeTracker:
        return _material(settings, const TimeTrackerScreen());
    }
    return null;
  }

  MaterialPageRoute<dynamic> _material(RouteSettings settings, Widget child) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => child,
    );
  }
}
