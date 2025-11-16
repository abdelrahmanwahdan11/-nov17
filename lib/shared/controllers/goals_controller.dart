import 'package:flutter/foundation.dart';

import '../../core/models/mock_repository.dart';
import 'app_controller.dart';
import 'finance_controller.dart';
import 'tasks_controller.dart';

class GoalsController extends ChangeNotifier {
  GoalsController({
    required AppController app,
    required MockRepository repository,
    required TasksController tasks,
    required FinanceController finance,
  })  : _app = app,
        _repository = repository,
        _tasks = tasks,
        _finance = finance {
    _app.addListener(_handleAppChanged);
    _tasks.addListener(_handleSourceChanged);
    _finance.addListener(_handleSourceChanged);
  }

  final AppController _app;
  final MockRepository _repository;
  final TasksController _tasks;
  final FinanceController _finance;

  bool _bootstrapped = false;
  bool _loading = true;
  int _completedTasks = 0;
  double _revenueThisMonth = 0;
  Duration _focusThisWeek = Duration.zero;

  bool get isLoading => _loading;
  int get completedTasks => _completedTasks;
  double get revenueThisMonth => _revenueThisMonth;
  Duration get focusThisWeek => _focusThisWeek;

  int get monthlyTaskGoal => _app.monthlyTaskGoal;
  double get monthlyRevenueGoal => _app.monthlyRevenueGoal;
  Duration get weeklyFocusGoal => _app.weeklyFocusGoal;

  double get taskProgress => monthlyTaskGoal == 0
      ? 0
      : (_completedTasks / monthlyTaskGoal).clamp(0, 1).toDouble();
  double get revenueProgress => monthlyRevenueGoal <= 0
      ? 0
      : (_revenueThisMonth / monthlyRevenueGoal).clamp(0, 1).toDouble();
  double get focusProgress => weeklyFocusGoal.inMinutes == 0
      ? 0
      : (_focusThisWeek.inMinutes / weeklyFocusGoal.inMinutes).clamp(0, 1).toDouble();

  double get taskProgressPercent => taskProgress * 100;
  double get revenueProgressPercent => revenueProgress * 100;
  double get focusProgressPercent => focusProgress * 100;

  Future<void> bootstrap() async {
    if (_bootstrapped) return;
    _bootstrapped = true;
    await refresh();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    _recalculate();
    _loading = false;
    notifyListeners();
  }

  Future<void> updateGoals({
    required int taskGoal,
    required double revenueGoal,
    required Duration focusGoal,
  }) async {
    await _app.updateWorkspaceGoals(
      taskGoal: taskGoal,
      revenueGoal: revenueGoal,
      focusGoal: focusGoal,
    );
    _recalculate();
    notifyListeners();
  }

  void _recalculate() {
    final now = DateTime.now();
    _completedTasks = _repository.completedTasksForMonth(now);
    _revenueThisMonth = _repository.revenueForMonth(now);
    _focusThisWeek = _app.weeklyTrackedDuration;
  }

  void _handleSourceChanged() {
    if (_loading) return;
    _recalculate();
    notifyListeners();
  }

  void _handleAppChanged() {
    if (_loading) return;
    _recalculate();
    notifyListeners();
  }

  @override
  void dispose() {
    _app.removeListener(_handleAppChanged);
    _tasks.removeListener(_handleSourceChanged);
    _finance.removeListener(_handleSourceChanged);
    super.dispose();
  }
}
