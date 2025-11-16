import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';
import '../../core/models/mock_repository.dart';
import '../../core/models/workspace_report.dart';
import 'app_controller.dart';
import 'clients_controller.dart';
import 'finance_controller.dart';
import 'insights_controller.dart';
import 'projects_controller.dart';
import 'tasks_controller.dart';

class ReportsController extends ChangeNotifier {
  ReportsController({
    required MockRepository repository,
    required AppController app,
    required ProjectsController projects,
    required TasksController tasks,
    required FinanceController finance,
    required ClientsController clients,
    required InsightsController insights,
  })  : _repository = repository,
        _app = app,
        _projects = projects,
        _tasks = tasks,
        _finance = finance,
        _clients = clients,
        _insights = insights;

  final MockRepository _repository;
  final AppController _app;
  final ProjectsController _projects;
  final TasksController _tasks;
  final FinanceController _finance;
  final ClientsController _clients;
  final InsightsController _insights;

  bool _loading = false;
  WorkspaceReportSnapshot? _latest;
  final List<WorkspaceReportSnapshot> _history = [];

  bool get isLoading => _loading;
  WorkspaceReportSnapshot? get latest => _latest;
  List<WorkspaceReportSnapshot> get history => List.unmodifiable(_history);
  int get snapshotCount => _history.length;

  Future<void> bootstrap() async {
    if (_latest != null) return;
    await generateReport();
  }

  Future<WorkspaceReportSnapshot?> generateReport() async {
    if (_loading) return _latest;
    _loading = true;
    notifyListeners();

    await Future.wait([
      _projects.bootstrap(),
      _tasks.bootstrap(),
      _finance.bootstrap(),
      _clients.bootstrap(),
    ]);

    await Future<void>.delayed(const Duration(milliseconds: 180));

    final allProjects = _repository.allProjects();
    final allTasks = _repository.allTasks();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final completedProjects = allProjects
        .where((project) => project.status.toLowerCase() == 'completed' || project.progress >= 0.99)
        .length;
    final dueSoonProjects = allProjects
        .where((project) =>
            project.progress < 0.99 &&
            !project.dueDate.isBefore(today) &&
            project.dueDate.isBefore(today.add(const Duration(days: 7))))
        .length;
    final atRiskProjects = allProjects
        .where((project) =>
            project.status.toLowerCase() == 'blocked' ||
            (project.progress < 0.4 && project.dueDate.isBefore(today.add(const Duration(days: 5)))))
        .length;

    final completedTasks = allTasks.where((task) => task.status.toLowerCase() == 'done').length;
    final overdueTasks = allTasks
        .where((task) => task.status.toLowerCase() != 'done' && task.dueDate.isBefore(today))
        .length;

    final monthlySnapshots = _finance.monthlySnapshots;
    FinanceSnapshot? latestMonthly;
    if (monthlySnapshots.isNotEmpty) {
      latestMonthly = monthlySnapshots.reduce(
        (value, element) => element.period.isAfter(value.period) ? element : value,
      );
    }

    final monthlyTaskCompleted = _repository.completedTasksForMonth(DateTime(now.year, now.month));

    final snapshot = WorkspaceReportSnapshot(
      generatedAt: DateTime.now(),
      totalProjects: allProjects.length,
      completedProjects: completedProjects,
      atRiskProjects: atRiskProjects,
      dueSoonProjects: dueSoonProjects,
      totalTasks: allTasks.length,
      completedTasks: completedTasks,
      overdueTasks: overdueTasks,
      completionRate: _insights.completionRate,
      focusHoursThisWeek: _insights.focusHoursThisWeek,
      focusGoalHours: _app.weeklyFocusGoal.inMinutes / 60.0,
      pipelineValue: _repository.clientsPipelineValue(),
      activeClients: _repository.activeClientCount(),
      monthlyRevenue: latestMonthly?.revenue ?? 0,
      monthlyExpenses: latestMonthly?.expenses ?? 0,
      netIncome: _insights.netIncome,
      outstandingInvoices: _finance.totalOutstanding,
      monthlyTaskGoal: _app.monthlyTaskGoal,
      monthlyTaskCompleted: monthlyTaskCompleted,
      primaryColorHex: _colorToHex(_app.primaryColor),
      topFocusLabel: _app.topTrackedTaskTitle,
      clientStageDistribution: _sortedMap(_repository.clientsByStage()),
      teamStatusDistribution: _sortedMap(_repository.teamStatusDistribution()),
    );

    _latest = snapshot;
    _history.insert(0, snapshot);
    if (_history.length > 10) {
      _history.removeRange(10, _history.length);
    }

    _loading = false;
    notifyListeners();
    return snapshot;
  }

  static Map<String, int> _sortedMap(Map<String, int> source) {
    final entries = source.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final entry in entries) entry.key: entry.value};
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
