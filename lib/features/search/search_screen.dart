import 'package:flutter/material.dart';

import 'dart:async';

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
  Map<String, List<dynamic>> _results = const {'projects': [], 'tasks': [], 'catalog': []};

  MockRepository get repository => WorkspaceScope.of(context).repository;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () async {
      final response = await repository.search(value.toLowerCase());
      if (mounted) {
        setState(() => _results = response);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _SearchSection(
                    title: loc.translate('search_results_projects'),
                    items: _results['projects'] ?? [],
                    onTap: (item) => Navigator.pushNamed(context, AppRoutes.projectDetails, arguments: item as Project),
                  ),
                  _SearchSection(
                    title: loc.translate('search_results_tasks'),
                    items: _results['tasks'] ?? [],
                    onTap: (item) => Navigator.pushNamed(context, AppRoutes.taskDetails, arguments: item as Task),
                  ),
                  _SearchSection(
                    title: loc.translate('search_results_catalog'),
                    items: _results['catalog'] ?? [],
                    onTap: (item) => Navigator.pushNamed(context, AppRoutes.catalog),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
