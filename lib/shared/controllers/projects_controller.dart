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
  final Map<String, (double progress, String status)> _previousState = {};
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

  Project? findById(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (_) {
      return _repository.findProject(id);
    }
  }

  Future<void> updateProject(Project project) async {
    final saved = await _repository.saveProject(project);
    if (saved != null) {
      _replaceProject(saved);
      _compare.updateProject(saved);
      notifyListeners();
    }
  }

  Future<void> toggleCompletion(Project project) async {
    final isCompleted = project.status.toLowerCase() == 'completed' || project.progress >= 0.999;
    if (!isCompleted) {
      _previousState[project.id] = (project.progress, project.status);
      await updateProject(project.copyWith(progress: 1.0, status: 'Completed'));
    } else {
      final previous = _previousState[project.id];
      final restored = project.copyWith(
        progress: previous?.$1 ?? 0.62,
        status: previous?.$2 ?? 'In Progress',
      );
      await updateProject(restored);
    }
  }

  Future<Project> createProject({
    required String title,
    required String priority,
    required String status,
    required DateTime dueDate,
    required double estimatedHours,
    required double progress,
    required List<String> tags,
  }) async {
    final project = await _repository.createProject(
      title: title,
      priority: priority,
      status: status,
      dueDate: dueDate,
      estimatedHours: estimatedHours,
      progress: progress,
      tags: tags,
    );
    await refresh();
    return project;
  }

  void _replaceProject(Project project) {
    final index = _projects.indexWhere((item) => item.id == project.id);
    if (index != -1) {
      _projects[index] = project;
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
