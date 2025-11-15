import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';
import '../../core/models/mock_repository.dart';
import 'compare_controller.dart';

class ProjectsController extends ChangeNotifier {
  ProjectsController({required MockRepository repository, required CompareController compare})
      : _repository = repository,
        _compare = compare {
    _compare.addListener(_onCompareChanged);
  }

  final MockRepository _repository;
  final CompareController _compare;

  final List<Project> _projects = [];
  int _page = 1;
  final int _pageSize = 4;
  String _priority = 'All';
  String _query = '';
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;

  List<Project> get projects => List.unmodifiable(_projects);
  bool get isLoading => _loading;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  String get priority => _priority;
  String get query => _query;
  int get compareCount => _compare.items.length;

  Future<void> bootstrap() async {
    if (_projects.isNotEmpty) return;
    await refresh();
  }

  Future<void> refresh() async {
    _loading = true;
    _page = 1;
    notifyListeners();
    final result = await _repository.fetchProjects(page: _page, pageSize: _pageSize, priority: _priority, query: _query);
    _projects
      ..clear()
      ..addAll(result.items);
    _hasMore = result.hasMore;
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    notifyListeners();
    final result = await _repository.fetchProjects(page: _page + 1, pageSize: _pageSize, priority: _priority, query: _query);
    if (result.items.isNotEmpty) {
      _page += 1;
      _projects.addAll(result.items);
      _hasMore = result.hasMore;
    } else {
      _hasMore = false;
    }
    _loadingMore = false;
    notifyListeners();
  }

  void updatePriority(String priority) {
    if (_priority == priority) return;
    _priority = priority;
    refresh();
  }

  void updateQuery(String query) {
    _query = query;
    refresh();
  }

  void toggleCompare(Project project) {
    _compare.toggleProject(project);
  }

  bool isCompared(Project project) => _compare.contains(project.id);

  void _onCompareChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _compare.removeListener(_onCompareChanged);
    super.dispose();
  }
}
