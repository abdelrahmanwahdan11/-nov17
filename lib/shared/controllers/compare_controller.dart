import 'dart:collection';

import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';

enum ComparableKind { project, task, catalog }

class ComparableItem {
  ComparableItem({
    required this.id,
    required this.title,
    required this.kind,
    required this.priority,
    required this.status,
    required this.estimatedHours,
    this.dueDate,
    this.tags = const [],
    this.summary,
  });

  factory ComparableItem.fromProject(Project project) => ComparableItem(
        id: project.id,
        title: project.title,
        kind: ComparableKind.project,
        priority: project.priority,
        status: project.status,
        estimatedHours: project.estimatedHours,
        dueDate: project.dueDate,
        tags: project.tags,
        summary: 'Progress ${(project.progress * 100).round()}%',
      );

  factory ComparableItem.fromTask(Task task) => ComparableItem(
        id: task.id,
        title: task.title,
        kind: ComparableKind.task,
        priority: task.priority,
        status: task.status,
        estimatedHours: task.hours,
        dueDate: task.dueDate,
        tags: [task.category],
        summary: task.description,
      );

  factory ComparableItem.fromCatalog(CatalogItem item) => ComparableItem(
        id: item.id,
        title: item.title,
        kind: ComparableKind.catalog,
        priority: item.priority,
        status: item.type,
        estimatedHours: item.estimatedHours,
        tags: item.tags,
        summary: item.summary,
      );

  final String id;
  final String title;
  final ComparableKind kind;
  final String priority;
  final String status;
  final double estimatedHours;
  final DateTime? dueDate;
  final List<String> tags;
  final String? summary;
}

class CompareController extends ChangeNotifier {
  final LinkedHashMap<String, ComparableItem> _items = LinkedHashMap();

  List<ComparableItem> get items => List.unmodifiable(_items.values);

  bool contains(String id) => _items.containsKey(id);

  void toggleProject(Project project) => _toggle(ComparableItem.fromProject(project));

  void toggleTask(Task task) => _toggle(ComparableItem.fromTask(task));

  void toggleCatalog(CatalogItem item) => _toggle(ComparableItem.fromCatalog(item));

  void remove(String id) {
    if (_items.remove(id) != null) {
      notifyListeners();
    }
  }

  void clear() {
    if (_items.isNotEmpty) {
      _items.clear();
      notifyListeners();
    }
  }

  void updateProject(Project project) {
    if (_items.containsKey(project.id)) {
      _items[project.id] = ComparableItem.fromProject(project);
      notifyListeners();
    }
  }

  void updateTask(Task task) {
    if (_items.containsKey(task.id)) {
      _items[task.id] = ComparableItem.fromTask(task);
      notifyListeners();
    }
  }

  void _toggle(ComparableItem item) {
    if (_items.containsKey(item.id)) {
      _items.remove(item.id);
    } else {
      if (_items.length == 3) {
        _items.remove(_items.keys.first);
      }
      _items[item.id] = item;
    }
    notifyListeners();
  }
}
