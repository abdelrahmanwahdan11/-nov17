import 'package:flutter/widgets.dart';

import '../../core/models/mock_repository.dart';
import 'app_controller.dart';
import 'catalog_controller.dart';
import 'compare_controller.dart';
import 'notifications_controller.dart';
import 'projects_controller.dart';
import 'scheduler_controller.dart';
import 'tasks_controller.dart';
import 'templates_controller.dart';
import 'library_controller.dart';
import 'finance_controller.dart';

class WorkspaceScope extends InheritedWidget {
  const WorkspaceScope({
    super.key,
    required this.app,
    required this.repository,
    required this.projects,
    required this.tasks,
    required this.catalog,
    required this.compare,
    required this.notifications,
    required this.scheduler,
    required this.templates,
    required this.library,
    required this.finance,
    required super.child,
  });

  final AppController app;
  final MockRepository repository;
  final ProjectsController projects;
  final TasksController tasks;
  final CatalogController catalog;
  final CompareController compare;
  final NotificationsController notifications;
  final SchedulerController scheduler;
  final TemplatesController templates;
  final LibraryController library;
  final FinanceController finance;

  static WorkspaceScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<WorkspaceScope>();
    assert(scope != null, 'WorkspaceScope not found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant WorkspaceScope oldWidget) => false;
}
