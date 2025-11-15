import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';
import '../../core/models/mock_repository.dart';
import 'compare_controller.dart';

enum TaskView { today, calendar }

class TasksController extends ChangeNotifier {
  TasksController({required MockRepository repository, required CompareController compare})
      : _repository = repository,
        _compare = compare {
    _compare.addListener(_onCompareChanged);
  }

  final MockRepository _repository;
  final CompareController _compare;

  final List<Task> _paginated = [];
  List<Task> _calendarTasks = [];
  int _page = 1;
  final int _pageSize = 6;
  String _status = 'All';
  String _query = '';
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  TaskView _view = TaskView.today;
  DateTime _selectedDate = DateTime.now();

  bool get isLoading => _loading;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  String get statusFilter => _status;
  String get query => _query;
  TaskView get view => _view;
  DateTime get selectedDate => _selectedDate;
  int get compareCount => _compare.items.length;

  List<Task> get tasks => _view == TaskView.today ? List.unmodifiable(_paginated) : List.unmodifiable(_calendarTasks);

  int get totalTasks => _paginated.length;
  double get totalHours => _paginated.fold(0, (previousValue, task) => previousValue + task.hours);

  Future<void> bootstrap() async {
    if (_paginated.isNotEmpty) return;
    await refresh();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    await _loadPage(1);
    _calendarTasks = _repository.tasksForDate(_selectedDate);
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    notifyListeners();
    await _loadPage(_page + 1);
    _loadingMore = false;
    notifyListeners();
  }

  Future<void> _loadPage(int page) async {
    final result = await _repository.fetchTasks(page: page, pageSize: _pageSize, status: _status, query: _query);
    if (page == 1) {
      _paginated
        ..clear()
        ..addAll(result.items);
    } else {
      _paginated.addAll(result.items);
    }
    _hasMore = result.hasMore;
    _page = page;
  }

  void updateStatus(String status) {
    if (_status == status) return;
    _status = status;
    refresh();
  }

  void updateQuery(String query) {
    _query = query;
    refresh();
  }

  void selectView(TaskView view) {
    if (_view == view) return;
    _view = view;
    if (view == TaskView.calendar) {
      _calendarTasks = _repository.tasksForDate(_selectedDate);
    }
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    if (_view == TaskView.calendar) {
      _calendarTasks = _repository.tasksForDate(date);
      notifyListeners();
    }
  }

  void toggleCompare(Task task) {
    _compare.toggleTask(task);
  }

  bool isCompared(Task task) => _compare.contains(task.id);

  Task? findById(String id) {
    final inPage = _paginated.where((task) => task.id == id);
    if (inPage.isNotEmpty) return inPage.first;
    final inCalendar = _calendarTasks.where((task) => task.id == id);
    if (inCalendar.isNotEmpty) return inCalendar.first;
    return _repository.findTask(id);
  }

  List<Task> tasksForDate(DateTime date) {
    final tasks = _repository.tasksForDate(date);
    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return tasks;
  }

  Map<int, int> taskCountForMonth(DateTime month) => _repository.taskCountForMonth(month);

  Future<void> updateTaskStatus(Task task, String status) async {
    final updated = task.copyWith(status: status);
    final saved = await _repository.saveTask(updated);
    if (saved != null) {
      _replaceTask(saved);
      _compare.updateTask(saved);
      notifyListeners();
    }
  }

  Future<void> toggleCompletion(Task task) {
    final isDone = task.status.toLowerCase() == 'done';
    return updateTaskStatus(task, isDone ? 'In Progress' : 'Done');
  }

  void _replaceTask(Task updated) {
    final index = _paginated.indexWhere((task) => task.id == updated.id);
    if (index != -1) {
      _paginated[index] = updated;
    }
    final calendarIndex = _calendarTasks.indexWhere((task) => task.id == updated.id);
    if (calendarIndex != -1) {
      _calendarTasks[calendarIndex] = updated;
    } else {
      _calendarTasks = _repository.tasksForDate(_selectedDate);
    }
  }

  void _onCompareChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _compare.removeListener(_onCompareChanged);
    super.dispose();
  }
}
