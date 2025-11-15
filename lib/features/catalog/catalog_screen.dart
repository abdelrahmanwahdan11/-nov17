import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';
import '../../shared/widgets/ai_info_button.dart';
import '../../shared/skeletons/skeleton_widgets.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _filterType = 'All';
  String _filterPriority = 'All';
  bool _loading = false;
  final Set<CatalogItem> _compare = {};
  String _query = '';

  List<CatalogItem> get _filteredItems {
    return catalogMock.where((item) {
      final matchesType = _filterType == 'All' || item.type == _filterType;
      final matchesPriority = _filterPriority == 'All' || item.priority == _filterPriority;
      final matchesQuery = _query.isEmpty || item.title.toLowerCase().contains(_query);
      return matchesType && matchesPriority && matchesQuery;
    }).toList();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 950));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: kToolbarHeight + 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search catalog'),
                  onChanged: (query) => setState(() => _query = query.toLowerCase()),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: ['All', 'Template', 'Document']
                      .map(
                        (type) => ChoiceChip(
                          label: Text(type),
                          selected: _filterType == type,
                          onSelected: (_) => setState(() => _filterType = type),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: ['All', 'High', 'Medium', 'Low']
                      .map(
                        (priority) => FilterChip(
                          label: Text(priority),
                          selected: _filterPriority == priority,
                          onSelected: (_) => setState(() => _filterPriority = priority),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _loading
                ? const SkeletonContainer(height: 240)
                : Column(
                    children: items
                        .map(
                          (item) => GestureDetector(
                            onLongPress: () => setState(() {
                              if (_compare.contains(item)) {
                                _compare.remove(item);
                              } else {
                                _compare.add(item);
                              }
                            }),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(item.type),
                                      const Spacer(),
                                      AiInfoButton(key: ValueKey(item.title)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                                  const SizedBox(height: 8),
                                  Text(item.summary),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          if (_compare.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: () {},
                child: Text('Compare selected (${_compare.length})'),
              ),
            ),
        ],
      ),
    );
  }
}
