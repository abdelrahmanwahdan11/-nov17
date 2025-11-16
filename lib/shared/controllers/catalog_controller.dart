import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';
import '../../core/models/mock_repository.dart';
import 'compare_controller.dart';

enum CatalogViewMode { list, grid }

class CatalogController extends ChangeNotifier {
  CatalogController({required MockRepository repository, required CompareController compare})
      : _repository = repository,
        _compare = compare {
    _compare.addListener(_onCompareChanged);
  }

  final MockRepository _repository;
  final CompareController _compare;

  final List<CatalogItem> _items = [];
  int _page = 1;
  final int _pageSize = 4;
  String _type = 'All';
  String _priority = 'All';
  String _query = '';
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  CatalogViewMode _viewMode = CatalogViewMode.list;

  List<CatalogItem> get items => List.unmodifiable(_items);
  bool get isLoading => _loading;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  String get typeFilter => _type;
  String get priorityFilter => _priority;
  String get query => _query;
  CatalogViewMode get viewMode => _viewMode;
  int get compareCount => _compare.items.length;

  Future<void> bootstrap() async {
    if (_items.isNotEmpty) return;
    await refresh();
  }

  Future<void> refresh() async {
    _loading = true;
    _page = 1;
    notifyListeners();
    final result = await _repository.fetchCatalog(page: _page, pageSize: _pageSize, type: _type, priority: _priority, query: _query);
    _items
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
    final result = await _repository.fetchCatalog(page: _page + 1, pageSize: _pageSize, type: _type, priority: _priority, query: _query);
    if (result.items.isNotEmpty) {
      _page += 1;
      _items.addAll(result.items);
      _hasMore = result.hasMore;
    } else {
      _hasMore = false;
    }
    _loadingMore = false;
    notifyListeners();
  }

  void updateType(String type) {
    if (_type == type) return;
    _type = type;
    refresh();
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

  void toggleViewMode() {
    _viewMode = _viewMode == CatalogViewMode.list ? CatalogViewMode.grid : CatalogViewMode.list;
    notifyListeners();
  }

  void toggleCompare(CatalogItem item) {
    _compare.toggleCatalog(item);
  }

  bool isCompared(CatalogItem item) => _compare.contains(item.id);

  void _onCompareChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _compare.removeListener(_onCompareChanged);
    super.dispose();
  }
}
