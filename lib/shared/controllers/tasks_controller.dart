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

  void _onCompareChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _compare.removeListener(_onCompareChanged);
    super.dispose();
  }
}
