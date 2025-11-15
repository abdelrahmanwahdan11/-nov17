import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';
import '../../core/models/mock_repository.dart';

class LibraryController extends ChangeNotifier {
  LibraryController({required MockRepository repository}) : _repository = repository;

  final MockRepository _repository;
  final List<LibraryItem> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  final int _pageSize = 6;
  String _type = 'All';
  String _query = '';

  List<LibraryItem> get items => List.unmodifiable(_items);
  bool get isLoading => _loading;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  String get type => _type;
  String get query => _query;
  List<String> get types => _repository.libraryTypes();
  List<LibraryItem> get recent => _repository.recentLibraryItems(limit: 3);

  Future<void> bootstrap() async {
    if (_items.isNotEmpty) return;
    await refresh();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    await _load(1);
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    notifyListeners();
    await _load(_page + 1);
    _loadingMore = false;
    notifyListeners();
  }

  Future<void> _load(int page) async {
    final result = await _repository.fetchLibrary(page: page, pageSize: _pageSize, type: _type, query: _query);
    if (page == 1) {
      _items
        ..clear()
        ..addAll(result.items);
    } else {
      _items.addAll(result.items);
    }
    _page = page;
    _hasMore = result.hasMore;
  }

  void updateType(String type) {
    if (_type == type) return;
    _type = type;
    refresh();
  }

  void updateQuery(String query) {
    _query = query;
    refresh();
  }
}
