import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';
import '../../core/models/mock_repository.dart';

class ClientsController extends ChangeNotifier {
  ClientsController({required MockRepository repository}) : _repository = repository;

  final MockRepository _repository;

  final List<Client> _paginated = [];
  int _page = 1;
  final int _pageSize = 8;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _bootstrapped = false;
  String _stage = 'All';
  String _query = '';

  bool get isLoading => _loading;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  String get stage => _stage;
  String get query => _query;

  List<Client> get clients => List.unmodifiable(_paginated);

  double get pipelineValue => _repository.clientsPipelineValue();

  int get activeClients => _repository.activeClientCount();

  int get starredClients => _repository.starredClientCount();

  Map<String, int> get stageDistribution => _repository.clientsByStage();

  List<Client> get spotlight => _repository.topPipelineClients(limit: 3);

  Future<void> bootstrap() async {
    if (_bootstrapped) return;
    _bootstrapped = true;
    await refresh();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    await _loadPage(1);
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
    final result = await _repository.fetchClients(
      page: page,
      pageSize: _pageSize,
      stage: _stage,
      query: _query,
    );
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

  void updateStage(String stage) {
    if (_stage == stage) return;
    _stage = stage;
    refresh();
  }

  void updateQuery(String query) {
    final sanitized = query.trim();
    if (_query == sanitized) return;
    _query = sanitized.toLowerCase();
    refresh();
  }

  Future<void> toggleStarred(Client client) async {
    final updated = client.copyWith(starred: !client.starred);
    final saved = await _repository.saveClient(updated);
    if (saved != null) {
      _replace(saved);
      notifyListeners();
    }
  }

  Future<void> updateStageFor(Client client, String stage) async {
    if (client.stage == stage) return;
    final saved = await _repository.saveClient(client.copyWith(stage: stage, lastInteraction: DateTime.now()));
    if (saved != null) {
      _replace(saved);
      notifyListeners();
    }
  }

  Future<Client> createClient({
    required String name,
    required String company,
    required String stage,
    required double value,
    String? email,
    String? phone,
    String? notes,
    List<String>? tags,
  }) async {
    final client = await _repository.createClient(
      name: name,
      company: company,
      stage: stage,
      value: value,
      email: email,
      phone: phone,
      notes: notes,
      tags: tags ?? const [],
    );
    final matchesStage = _stage == 'All' || client.stage.toLowerCase() == _stage.toLowerCase();
    final matchesQuery = _query.isEmpty ||
        client.name.toLowerCase().contains(_query) ||
        client.company.toLowerCase().contains(_query) ||
        client.tags.any((tag) => tag.toLowerCase().contains(_query));
    if (matchesStage && matchesQuery) {
      _paginated.insert(0, client);
      final maxLength = _page * _pageSize;
      if (_paginated.length > maxLength && maxLength > 0) {
        _paginated.removeLast();
      }
      notifyListeners();
    } else {
      notifyListeners();
    }
    return client;
  }

  Future<void> logInteraction({
    required Client client,
    required String type,
    required String note,
  }) async {
    final saved = await _repository.addClientInteraction(
      id: client.id,
      type: type,
      note: note,
    );
    if (saved != null) {
      _replace(saved);
      notifyListeners();
    }
  }

  void _replace(Client updated) {
    final index = _paginated.indexWhere((client) => client.id == updated.id);
    if (index != -1) {
      _paginated[index] = updated;
    }
  }

  @override
  void dispose() {
    _paginated.clear();
    super.dispose();
  }
}
