import 'package:flutter/material.dart';

import 'dart:async';

import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/mock_data.dart';
import '../../core/models/mock_repository.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/controllers/workspace_scope.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  Map<String, List<dynamic>> _results = const {
    'projects': [],
    'tasks': [],
    'templates': [],
    'catalog': [],
    'clients': [],
  };
  bool _isSearching = false;

  MockRepository get repository => WorkspaceScope.of(context).repository;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _isSearching = false;
        _results = const {
          'projects': [],
          'tasks': [],
          'templates': [],
          'catalog': [],
          'clients': [],
        };
      });
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 320), () => _performSearch(trimmed));
  }

  Future<void> _performSearch(String query) async {
    final response = await repository.search(query.toLowerCase());
    if (!mounted) {
      return;
    }
    setState(() {
      _results = response;
      _isSearching = false;
    });
  }

  void _onSubmitted(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    WorkspaceScope.of(context).app.addSearchHistory(trimmed);
    FocusScope.of(context).unfocus();
    _debounce?.cancel();
    setState(() => _isSearching = true);
    _performSearch(trimmed);
  }

  void _useHistory(String query) {
    _controller.text = query;
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: query.length));
    _onSubmitted(query);
  }

  void _removeHistory(String query) {
    WorkspaceScope.of(context).app.removeSearchHistory(query);
  }

  void _clearHistory() {
    WorkspaceScope.of(context).app.clearSearchHistory();
  }

  void _persistCurrentQuery() {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      return;
    }
    WorkspaceScope.of(context).app.addSearchHistory(query);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final app = WorkspaceScope.of(context).app;
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('search'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: loc.translate('search_global_hint')),
              onChanged: _onQueryChanged,
              onSubmitted: _onSubmitted,
            ),
            if (_isSearching) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(minHeight: 2),
            ],
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: app,
              builder: (context, _) {
                final history = app.searchHistory;
                if (history.isEmpty) {
                  return Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      loc.translate('search_empty_history'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(loc.translate('search_history'), style: Theme.of(context).textTheme.titleSmall),
                        const Spacer(),
                        TextButton(onPressed: _clearHistory, child: Text(loc.translate('search_clear_history'))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: history
                          .map(
                            (entry) => InputChip(
                              label: Text(entry),
                              onPressed: () => _useHistory(entry),
                              onDeleted: () => _removeHistory(entry),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _SearchSection(
                    title: loc.translate('search_results_projects'),
                    items: _results['projects'] ?? [],
                    onTap: (item) {
                      _persistCurrentQuery();
                      Navigator.pushNamed(context, AppRoutes.projectDetails, arguments: item as Project);
                    },
                  ),
                  _SearchSection(
                    title: loc.translate('search_results_tasks'),
                    items: _results['tasks'] ?? [],
                    onTap: (item) {
                      _persistCurrentQuery();
                      Navigator.pushNamed(context, AppRoutes.taskDetails, arguments: item as Task);
                    },
                  ),
                  _SearchSection(
                    title: loc.translate('search_results_templates'),
                    items: _results['templates'] ?? [],
                    onTap: (item) {
                      _persistCurrentQuery();
                      _showTemplateDetails(item as TemplateItem);
                    },
                  ),
                  _SearchSection(
                    title: loc.translate('search_results_catalog'),
                    items: _results['catalog'] ?? [],
                    onTap: (item) {
                      _persistCurrentQuery();
                      Navigator.pushNamed(context, AppRoutes.catalog);
                    },
                  ),
                  _ClientSearchSection(
                    clients: List<Client>.from(_results['clients'] ?? const []),
                    onTap: (client) {
                      _persistCurrentQuery();
                      Navigator.pushNamed(context, AppRoutes.clients);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTemplateDetails(TemplateItem template) {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(template.title, style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [
                    Chip(label: Text(template.type)),
                    Chip(label: Text(template.category)),
                    Chip(label: Text(loc.translate('templates_hours', params: {'hours': template.estimatedHours.toStringAsFixed(0)}))),
                  ],
                ),
                const SizedBox(height: 12),
                Text(template.summary, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: template.tags.map((tag) => Chip(label: Text('#$tag'))).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text(loc.translate('templates_added_to_catalog'))),
                      );
                    },
                    icon: const Icon(IconlyBold.add_user),
                    label: Text(loc.translate('templates_add_to_catalog')),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ClientSearchSection extends StatelessWidget {
  const _ClientSearchSection({required this.clients, required this.onTap});

  final List<Client> clients;
  final ValueChanged<Client> onTap;

  @override
  Widget build(BuildContext context) {
    if (clients.isEmpty) {
      return const SizedBox.shrink();
    }
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.translate('search_results_clients'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...clients.map(
          (client) => ListTile(
            title: Text(client.name),
            subtitle: Text(
              '${client.company} · ${loc.translate('clients_stage_${client.stage.toLowerCase()}')}',
            ),
            trailing: Text('\$${client.value.toStringAsFixed(0)}'),
            onTap: () => onTap(client),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({required this.title, required this.items, required this.onTap});

  final String title;
  final List<dynamic> items;
  final ValueChanged<dynamic> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...items.map(
          (item) => ListTile(
            title: Text((item as dynamic).title as String),
            onTap: () => onTap(item),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
