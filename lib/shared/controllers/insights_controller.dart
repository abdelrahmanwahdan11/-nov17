import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/models/mock_data.dart';
import '../../core/models/mock_repository.dart';
import '../../core/models/tracked_session.dart';
import 'app_controller.dart';
import 'finance_controller.dart';
import 'projects_controller.dart';
import 'tasks_controller.dart';

class InsightsController extends ChangeNotifier {
  InsightsController({
    required MockRepository repository,
    required AppController app,
    required ProjectsController projects,
    required TasksController tasks,
    required FinanceController finance,
  })  : _repository = repository,
        _app = app,
        _projects = projects,
        _tasks = tasks,
        _finance = finance {
    _app.addListener(_handleSourceChanged);
    _projects.addListener(_handleSourceChanged);
    _tasks.addListener(_handleSourceChanged);
    _finance.addListener(_handleSourceChanged);
    _recompute();
  }

  final MockRepository _repository;
  final AppController _app;
  final ProjectsController _projects;
  final TasksController _tasks;
  final FinanceController _finance;

  double _completionRate = 0;
  double _focusHoursThisWeek = 0;
  double _netIncome = 0;
  double _outstanding = 0;
  List<InsightDeadline> _deadlines = const [];
  List<InsightPrioritySlice> _priorityMix = const [];
  List<InsightCompletionPoint> _weeklyCompletion = const [];
  List<InsightFocusSlice> _focusBreakdown = const [];
  List<TrackedSession> _recentSessions = const [];

  double get completionRate => _completionRate;
  double get focusHoursThisWeek => _focusHoursThisWeek;
  double get netIncome => _netIncome;
  double get outstandingTotal => _outstanding;
  List<InsightDeadline> get deadlines => List.unmodifiable(_deadlines);
  List<InsightPrioritySlice> get priorityMix => List.unmodifiable(_priorityMix);
  List<InsightCompletionPoint> get weeklyCompletion => List.unmodifiable(_weeklyCompletion);
  List<InsightFocusSlice> get focusBreakdown => List.unmodifiable(_focusBreakdown);
  List<TrackedSession> get recentSessions => List.unmodifiable(_recentSessions);

  void _handleSourceChanged() => _recompute();

  void _recompute() {
    final tasks = _repository.allTasks();
    final projects = _repository.allProjects();

    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.status.toLowerCase() == 'done').length;
    _completionRate = totalTasks == 0 ? 0 : completedTasks / totalTasks;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcomingCutoff = today.add(const Duration(days: 5));

    final upcomingProjects = projects
        .where((project) => project.progress < 0.999 && !project.dueDate.isBefore(today) && project.dueDate.isBefore(upcomingCutoff))
        .map(
          (project) => InsightDeadline(
            id: project.id,
            title: project.title,
            dueDate: project.dueDate,
            type: InsightDeadlineType.project,
            priority: project.priority,
          ),
        );

    final upcomingTasks = tasks
        .where((task) => task.status.toLowerCase() != 'done' && !task.dueDate.isBefore(today) && task.dueDate.isBefore(upcomingCutoff))
        .map(
          (task) => InsightDeadline(
            id: task.id,
            title: task.title,
            dueDate: task.dueDate,
            type: InsightDeadlineType.task,
            priority: task.priority,
          ),
        );

    _deadlines = [...upcomingProjects, ...upcomingTasks]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final priorityCounts = <String, int>{};
    for (final task in tasks) {
      priorityCounts.update(task.priority, (value) => value + 1, ifAbsent: () => 1);
    }
    _priorityMix = priorityCounts.entries
        .map((entry) => InsightPrioritySlice(priority: entry.key, count: entry.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final dayStart = today;
    final weeklyPoints = <InsightCompletionPoint>[];
    for (var index = 6; index >= 0; index--) {
      final date = dayStart.subtract(Duration(days: index));
      final dailyTasks = tasks.where((task) => _isSameDay(task.dueDate, date)).toList();
      final completed = dailyTasks.where((task) => task.status.toLowerCase() == 'done').length;
      weeklyPoints.add(InsightCompletionPoint(date: date, completed: completed, total: dailyTasks.length));
    }
    _weeklyCompletion = weeklyPoints;

    final sessions = _app.trackedSessions;
    final startOfWeek = dayStart.subtract(Duration(days: dayStart.weekday - 1));
    final weeklySessions = sessions.where((session) => !session.timestamp.isBefore(startOfWeek)).toList();
    _focusHoursThisWeek = weeklySessions.fold<double>(0, (sum, session) => sum + session.duration.inMinutes / 60.0);

    final tasksById = {for (final task in tasks) task.id: task};
    final focusDurations = <String, Duration>{};
    for (final session in weeklySessions) {
      final task = session.taskId != null ? tasksById[session.taskId!] : null;
      final label = task?.category ?? session.taskTitle ?? 'Unassigned';
      focusDurations.update(label, (value) => value + session.duration, ifAbsent: () => session.duration);
    }
    _focusBreakdown = focusDurations.entries
        .map((entry) => InsightFocusSlice(label: entry.key, minutes: max(0, entry.value.inMinutes)))
        .where((slice) => slice.minutes > 0)
        .toList()
      ..sort((a, b) => b.minutes.compareTo(a.minutes));

    _recentSessions = sessions.take(5).toList();

    _netIncome = _finance.totalNet;
    _outstanding = _finance.totalOutstanding;

    notifyListeners();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    _app.removeListener(_handleSourceChanged);
    _projects.removeListener(_handleSourceChanged);
    _tasks.removeListener(_handleSourceChanged);
    _finance.removeListener(_handleSourceChanged);
    super.dispose();
  }
}

enum InsightDeadlineType { project, task }

class InsightDeadline {
  const InsightDeadline({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.type,
    required this.priority,
  });

  final String id;
  final String title;
  final DateTime dueDate;
  final InsightDeadlineType type;
  final String priority;
}

class InsightPrioritySlice {
  const InsightPrioritySlice({required this.priority, required this.count});

  final String priority;
  final int count;
}

class InsightCompletionPoint {
  const InsightCompletionPoint({required this.date, required this.completed, required this.total});

  final DateTime date;
  final int completed;
  final int total;

  double get completionRate => total == 0 ? 0 : completed / total;
}

class InsightFocusSlice {
  const InsightFocusSlice({required this.label, required this.minutes});

  final String label;
  final int minutes;

  double get hours => minutes / 60.0;
}
