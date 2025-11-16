import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';
import '../../core/models/mock_repository.dart';

class TeamMetrics {
  const TeamMetrics({
    required this.total,
    required this.active,
    required this.onboarding,
    required this.outOfOffice,
    required this.contractors,
    required this.averageFocus,
    required this.averageCapacity,
    required this.favoriteCount,
    required this.distribution,
    required this.checkInsThisWeek,
    this.highlight,
    this.latestCheckIn,
  });

  final int total;
  final int active;
  final int onboarding;
  final int outOfOffice;
  final int contractors;
  final double averageFocus;
  final double averageCapacity;
  final int favoriteCount;
  final Map<String, int> distribution;
  final TeamMember? highlight;
  final int checkInsThisWeek;
  final TeamCheckIn? latestCheckIn;

  factory TeamMetrics.empty() {
    return const TeamMetrics(
      total: 0,
      active: 0,
      onboarding: 0,
      outOfOffice: 0,
      contractors: 0,
      averageFocus: 0,
      averageCapacity: 0,
      favoriteCount: 0,
      distribution: const {},
      checkInsThisWeek: 0,
      highlight: null,
      latestCheckIn: null,
    );
  }
}

class TeamController extends ChangeNotifier {
  TeamController({required MockRepository repository}) : _repository = repository;

  final MockRepository _repository;
  final List<TeamMember> _members = [];

  int _page = 1;
  final int _pageSize = 8;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _bootstrapped = false;
  String _status = 'All';
  String _query = '';
  TeamMetrics _metrics = TeamMetrics.empty();
  final Map<String, List<TeamCheckIn>> _checkInsCache = {};
  final Set<String> _loadingCheckIns = {};
  final Set<String> _loadedCheckIns = {};

  bool get isLoading => _loading;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  String get status => _status;
  String get query => _query;
  TeamMetrics get metrics => _metrics;

  List<TeamMember> get members => List.unmodifiable(_members);

  Map<String, int> get distribution => Map.unmodifiable(_metrics.distribution);

  List<TeamMember> get spotlight => _repository.topTeamCollaborators(limit: 4);

  TeamMember? memberById(String id) {
    try {
      return _members.firstWhere((member) => member.id == id);
    } catch (_) {
      return _repository.teamMemberById(id);
    }
  }

  List<TeamCheckIn> checkInsFor(String memberId) => List.unmodifiable(_checkInsCache[memberId] ?? const []);

  bool isLoadingCheckIns(String memberId) => _loadingCheckIns.contains(memberId);

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

  Future<void> loadCheckIns(String memberId, {bool force = false}) async {
    if (_loadingCheckIns.contains(memberId)) return;
    if (!force && _loadedCheckIns.contains(memberId)) return;
    _loadingCheckIns.add(memberId);
    notifyListeners();
    final items = await _repository.fetchTeamCheckIns(memberId);
    _checkInsCache[memberId] = items;
    _loadingCheckIns.remove(memberId);
    _loadedCheckIns.add(memberId);
    notifyListeners();
  }

  Future<TeamCheckIn> logCheckIn({
    required String memberId,
    required String summary,
    required String sentiment,
    String author = 'You',
    List<String> highlights = const [],
    List<String> nextSteps = const [],
  }) async {
    final checkIn = await _repository.addTeamCheckIn(
      memberId: memberId,
      summary: summary,
      sentiment: sentiment,
      author: author,
      highlights: highlights,
      nextSteps: nextSteps,
    );
    final existing = _checkInsCache.putIfAbsent(memberId, () => <TeamCheckIn>[]);
    existing.insert(0, checkIn);
    _loadedCheckIns.add(memberId);
    final member = _repository.teamMemberById(memberId);
    if (member != null) {
      _replace(member);
    }
    _updateMetrics();
    notifyListeners();
    return checkIn;
  }

  Future<void> _loadPage(int page) async {
    final result = await _repository.fetchTeamMembers(
      page: page,
      pageSize: _pageSize,
      status: _status,
      query: _query,
    );
    if (page == 1) {
      _members
        ..clear()
        ..addAll(result.items);
    } else {
      _members.addAll(result.items);
    }
    _page = page;
    _hasMore = result.hasMore;
    _updateMetrics();
  }

  void updateStatusFilter(String status) {
    if (_status == status) return;
    _status = status;
    refresh();
  }

  void updateQuery(String value) {
    final sanitized = value.trim().toLowerCase();
    if (_query == sanitized) return;
    _query = sanitized;
    refresh();
  }

  Future<void> toggleFavorite(TeamMember member) async {
    final updated = member.copyWith(favorite: !member.favorite, lastActive: DateTime.now());
    final saved = await _repository.saveTeamMember(updated);
    if (saved != null) {
      _replace(saved);
      _updateMetrics();
      notifyListeners();
    }
  }

  Future<void> changeStatus(TeamMember member, String status) async {
    if (member.status == status) return;
    final saved = await _repository.saveTeamMember(
      member.copyWith(status: status, lastActive: DateTime.now()),
    );
    if (saved != null) {
      _replace(saved);
      _updateMetrics();
      notifyListeners();
    }
  }

  Future<TeamMember> createMember({
    required String name,
    required String role,
    required String status,
    String email = '',
    String location = '',
    String timezone = '',
    double focusHours = 12,
    int tasks = 8,
    double capacity = 0.5,
    List<String> skills = const [],
  }) async {
    final created = await _repository.createTeamMember(
      name: name,
      role: role,
      status: status,
      email: email,
      location: location,
      timezone: timezone,
      focusHours: focusHours,
      tasks: tasks,
      capacity: capacity,
      skills: skills,
    );
    final matchesStatus = _status == 'All' || created.status.toLowerCase() == _status.toLowerCase();
    final matchesQuery = _query.isEmpty ||
        created.name.toLowerCase().contains(_query) ||
        created.role.toLowerCase().contains(_query) ||
        created.location.toLowerCase().contains(_query) ||
        created.skills.any((skill) => skill.toLowerCase().contains(_query));
    if (matchesStatus && matchesQuery) {
      _members.insert(0, created);
      final maxLength = _page * _pageSize;
      if (_members.length > maxLength && maxLength > 0) {
        _members.removeLast();
      }
    }
    _updateMetrics();
    notifyListeners();
    return created;
  }

  void _replace(TeamMember member) {
    final index = _members.indexWhere((element) => element.id == member.id);
    if (index != -1) {
      _members[index] = member;
    }
  }

  void _updateMetrics() {
    final highlightCandidates = _repository.topTeamCollaborators(limit: 1);
    _metrics = TeamMetrics(
      total: _repository.teamMemberCount(),
      active: _repository.teamMembersByStatus('Active'),
      onboarding: _repository.teamMembersByStatus('Onboarding'),
      outOfOffice: _repository.teamMembersByStatus('Out of office'),
      contractors: _repository.teamMembersByStatus('Contractor'),
      averageFocus: _repository.teamAverageFocusHours(),
      averageCapacity: _repository.teamAverageCapacity(),
      favoriteCount: _repository.teamFavoriteCount(),
      distribution: _repository.teamStatusDistribution(),
      checkInsThisWeek: _repository.teamCheckInsWithin(const Duration(days: 7)),
      highlight: highlightCandidates.isEmpty ? null : highlightCandidates.first,
      latestCheckIn: _repository.latestTeamCheckIn(),
    );
  }

  @override
  void dispose() {
    _members.clear();
    _checkInsCache.clear();
    _loadingCheckIns.clear();
    _loadedCheckIns.clear();
    super.dispose();
  }
}
