import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';
import '../../core/models/mock_repository.dart';

class TemplatesController extends ChangeNotifier {
  TemplatesController({required MockRepository repository}) : _repository = repository;

  final MockRepository _repository;
  final List<TemplateItem> _templates = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  final int _pageSize = 4;
  String _type = 'All';
  String _query = '';

  List<TemplateItem> get templates => List.unmodifiable(_templates);
  bool get isLoading => _loading;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  String get type => _type;
  String get query => _query;
  List<TemplateItem> get spotlight => _repository.popularTemplates(limit: 3);
  List<String> get types => _repository.templateTypes();

  Future<void> bootstrap() async {
    if (_templates.isNotEmpty) return;
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
    final result = await _repository.fetchTemplates(page: page, pageSize: _pageSize, type: _type, query: _query);
    if (page == 1) {
      _templates
        ..clear()
        ..addAll(result.items);
    } else {
      _templates.addAll(result.items);
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
