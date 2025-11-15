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
        _notifications = seedNotifications(),
        _schedule = seedSchedule(),
        _templates = seedTemplates(),
        _library = seedLibraryItems();

  final List<Project> _projects;
  final List<Task> _tasks;
  final List<CatalogItem> _catalog;
  final List<AppNotification> _notifications;
  final List<ScheduleEntry> _schedule;
  final List<TemplateItem> _templates;
  final List<LibraryItem> _library;

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
    final notifications = List<AppNotification>.from(_notifications)
      ..sort((a, b) {
        if (a.pinned != b.pinned) {
          return a.pinned ? -1 : 1;
        }
        return b.timestamp.compareTo(a.timestamp);
      });
    return notifications;
  }

  Future<AppNotification?> saveNotification(AppNotification updated) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    final index = _notifications.indexWhere((item) => item.id == updated.id);
    if (index == -1) return null;
    _notifications[index] = updated;
    return updated;
  }

  Future<List<AppNotification>> markAllNotificationsRead() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    for (var i = 0; i < _notifications.length; i++) {
      final current = _notifications[i];
      if (!current.read) {
        _notifications[i] = current.copyWith(read: true);
      }
    }
    return fetchNotifications();
  }

  Future<void> clearNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    _notifications.clear();
  }

  Future<Map<String, List<dynamic>>> search(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (query.isEmpty) {
      return {'projects': [], 'tasks': [], 'templates': [], 'catalog': []};
    }
    final lowered = query.toLowerCase();
    return {
      'projects': _projects
          .where((project) => project.title.toLowerCase().contains(lowered) || project.tags.any((tag) => tag.contains(lowered)))
          .toList(),
      'tasks': _tasks
          .where((task) => task.title.toLowerCase().contains(lowered) || task.description.toLowerCase().contains(lowered))
          .toList(),
      'templates': _templates
          .where((template) =>
              template.title.toLowerCase().contains(lowered) ||
              template.summary.toLowerCase().contains(lowered) ||
              template.tags.any((tag) => tag.toLowerCase().contains(lowered)))
          .toList(),
      'catalog': _catalog
          .where((item) => item.title.toLowerCase().contains(lowered) || item.summary.toLowerCase().contains(lowered))
          .toList(),
    };
  }

  List<Task> tasksForDate(DateTime date) {
    return _tasks.where((task) => task.dueDate.year == date.year && task.dueDate.month == date.month && task.dueDate.day == date.day).toList();
  }

  Map<int, int> taskCountForMonth(DateTime month) {
    final counts = <int, int>{};
    for (final task in _tasks) {
      if (task.dueDate.year == month.year && task.dueDate.month == month.month) {
        counts.update(task.dueDate.day, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  Task? findTask(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (_) {
      return null;
    }
  }

  Project? findProject(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Task?> saveTask(Task updated) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final index = _tasks.indexWhere((task) => task.id == updated.id);
    if (index == -1) return null;
    _tasks[index] = updated;
    return updated;
  }

  Future<Project?> saveProject(Project updated) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _projects.indexWhere((project) => project.id == updated.id);
    if (index == -1) return null;
    _projects[index] = updated;
    return updated;
  }

  List<Task> allTasks() => List.unmodifiable(_tasks);

  Future<List<ScheduleEntry>> fetchSchedule(DateTime date) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final entries = _schedule
        .where((entry) => entry.start.year == date.year && entry.start.month == date.month && entry.start.day == date.day)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return entries;
  }

  Future<ScheduleEntry> addScheduleEntry(ScheduleEntry entry) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _schedule.add(entry);
    _schedule.sort((a, b) => a.start.compareTo(b.start));
    return entry;
  }

  Future<void> removeScheduleEntry(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    _schedule.removeWhere((entry) => entry.id == id);
  }

  List<ScheduleEntry> nextScheduleEntries(int limit) {
    final now = DateTime.now();
    final upcoming = _schedule.where((entry) => entry.end.isAfter(now)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return upcoming.take(limit).toList();
  }

  Future<PaginatedResult<TemplateItem>> fetchTemplates({
    required int page,
    required int pageSize,
    String type = 'All',
    String query = '',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    final lowered = query.toLowerCase();
    final filtered = _templates.where((template) {
      final typeMatches = type == 'All' || template.type.toLowerCase() == type.toLowerCase();
      final queryMatches = lowered.isEmpty ||
          template.title.toLowerCase().contains(lowered) ||
          template.summary.toLowerCase().contains(lowered) ||
          template.tags.any((tag) => tag.toLowerCase().contains(lowered));
      return typeMatches && queryMatches;
    }).toList();
    final start = max(0, (page - 1) * pageSize);
    final end = min(start + pageSize, filtered.length);
    final slice = start >= filtered.length ? <TemplateItem>[] : filtered.sublist(start, end);
    final hasMore = end < filtered.length;
    return PaginatedResult<TemplateItem>(items: slice, total: filtered.length, hasMore: hasMore);
  }

  List<TemplateItem> popularTemplates({int limit = 3}) {
    final sorted = List<TemplateItem>.from(_templates)
      ..sort((a, b) {
        if (a.popular == b.popular) {
          return a.title.compareTo(b.title);
        }
        return a.popular ? -1 : 1;
      });
    return sorted.take(limit).toList();
  }

  List<String> templateTypes() {
    final set = _templates.map((template) => template.type).toSet().toList()..sort();
    return ['All', ...set];
  }

  Future<PaginatedResult<LibraryItem>> fetchLibrary({
    required int page,
    required int pageSize,
    String type = 'All',
    String query = '',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    final lowered = query.toLowerCase();
    final filtered = _library.where((item) {
      final typeMatches = type == 'All' || item.type.toLowerCase() == type.toLowerCase();
      final queryMatches = lowered.isEmpty ||
          item.title.toLowerCase().contains(lowered) ||
          item.summary.toLowerCase().contains(lowered) ||
          item.author.toLowerCase().contains(lowered);
      return typeMatches && queryMatches;
    }).toList();
    final start = max(0, (page - 1) * pageSize);
    final end = min(start + pageSize, filtered.length);
    final slice = start >= filtered.length ? <LibraryItem>[] : filtered.sublist(start, end);
    final hasMore = end < filtered.length;
    return PaginatedResult<LibraryItem>(items: slice, total: filtered.length, hasMore: hasMore);
  }

  List<LibraryItem> recentLibraryItems({int limit = 3}) {
    final sorted = List<LibraryItem>.from(_library)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(limit).toList();
  }

  List<String> libraryTypes() {
    final set = _library.map((item) => item.type).toSet().toList()..sort();
    return ['All', ...set];
  }
}
