import 'dart:async';
import 'dart:math';

import 'mock_data.dart';

class PaginatedResult<T> {
  PaginatedResult({required this.items, required this.total, required this.hasMore});

  final List<T> items;
  final int total;
  final bool hasMore;
}

class MockRepository {
  MockRepository()
      : _projects = seedProjects(),
        _tasks = seedTasks(),
        _catalog = seedCatalog(),
        _notifications = seedNotifications();

  final List<Project> _projects;
  final List<Task> _tasks;
  final List<CatalogItem> _catalog;
  final List<AppNotification> _notifications;

  Future<PaginatedResult<Project>> fetchProjects({
    required int page,
    required int pageSize,
    String priority = 'All',
    String query = '',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    final loweredQuery = query.toLowerCase();
    final filtered = _projects.where((project) {
      final priorityMatches = priority == 'All' || project.priority.toLowerCase() == priority.toLowerCase();
      final queryMatches = loweredQuery.isEmpty ||
          project.title.toLowerCase().contains(loweredQuery) ||
          project.tags.any((tag) => tag.toLowerCase().contains(loweredQuery));
      return priorityMatches && queryMatches;
    }).toList();
    final start = max(0, (page - 1) * pageSize);
    final end = min(start + pageSize, filtered.length);
    final slice = start >= filtered.length ? <Project>[] : filtered.sublist(start, end);
    final hasMore = end < filtered.length;
    return PaginatedResult<Project>(items: slice, total: filtered.length, hasMore: hasMore);
  }

  Future<PaginatedResult<Task>> fetchTasks({
    required int page,
    required int pageSize,
    String status = 'All',
    String query = '',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    final loweredQuery = query.toLowerCase();
    final filtered = _tasks.where((task) {
      final statusMatches = status == 'All' || task.status.toLowerCase() == status.toLowerCase();
      final queryMatches = loweredQuery.isEmpty ||
          task.title.toLowerCase().contains(loweredQuery) ||
          task.description.toLowerCase().contains(loweredQuery) ||
          task.category.toLowerCase().contains(loweredQuery);
      return statusMatches && queryMatches;
    }).toList();
    final start = max(0, (page - 1) * pageSize);
    final end = min(start + pageSize, filtered.length);
    final slice = start >= filtered.length ? <Task>[] : filtered.sublist(start, end);
    final hasMore = end < filtered.length;
    return PaginatedResult<Task>(items: slice, total: filtered.length, hasMore: hasMore);
  }

  Future<PaginatedResult<CatalogItem>> fetchCatalog({
    required int page,
    required int pageSize,
    String type = 'All',
    String priority = 'All',
    String query = '',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    final loweredQuery = query.toLowerCase();
    final filtered = _catalog.where((item) {
      final typeMatches = type == 'All' || item.type.toLowerCase() == type.toLowerCase();
      final priorityMatches = priority == 'All' || item.priority.toLowerCase() == priority.toLowerCase();
      final queryMatches = loweredQuery.isEmpty ||
          item.title.toLowerCase().contains(loweredQuery) ||
          item.summary.toLowerCase().contains(loweredQuery) ||
          item.tags.any((tag) => tag.toLowerCase().contains(loweredQuery));
      return typeMatches && priorityMatches && queryMatches;
    }).toList();
    final start = max(0, (page - 1) * pageSize);
    final end = min(start + pageSize, filtered.length);
    final slice = start >= filtered.length ? <CatalogItem>[] : filtered.sublist(start, end);
    final hasMore = end < filtered.length;
    return PaginatedResult<CatalogItem>(items: slice, total: filtered.length, hasMore: hasMore);
  }

  Future<List<AppNotification>> fetchNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _notifications;
  }

  Future<Map<String, List<dynamic>>> search(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (query.isEmpty) {
      return {'projects': [], 'tasks': [], 'catalog': []};
    }
    final lowered = query.toLowerCase();
    return {
      'projects': _projects
          .where((project) => project.title.toLowerCase().contains(lowered) || project.tags.any((tag) => tag.contains(lowered)))
          .toList(),
      'tasks': _tasks
          .where((task) => task.title.toLowerCase().contains(lowered) || task.description.toLowerCase().contains(lowered))
          .toList(),
      'catalog': _catalog
          .where((item) => item.title.toLowerCase().contains(lowered) || item.summary.toLowerCase().contains(lowered))
          .toList(),
    };
  }

  List<Task> tasksForDate(DateTime date) {
    return _tasks.where((task) => task.dueDate.year == date.year && task.dueDate.month == date.month && task.dueDate.day == date.day).toList();
  }
}
