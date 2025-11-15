import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/mock_data.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/controllers/catalog_controller.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/widgets/ai_info_button.dart';
import '../../shared/skeletons/skeleton_widgets.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  CatalogController? _controller;
  Timer? _debounce;

  CatalogController get controller => _controller ??= WorkspaceScope.of(context).catalog;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final scope = WorkspaceScope.of(context);
    if (_controller != scope.catalog) {
      _controller = scope.catalog;
      _searchController.text = controller.query;
    }
    super.didChangeDependencies();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      controller.updateQuery(value.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final types = [
      ('All', loc.translate('filter_all')),
      ('Template', loc.translate('type_template')),
      ('Document', loc.translate('type_document')),
      ('Task', loc.translate('type_task')),
    ];
    final priorities = [
      ('All', loc.translate('filter_all')),
      ('High', loc.translate('priority_high')),
      ('Medium', loc.translate('priority_medium')),
      ('Low', loc.translate('priority_low')),
    ];

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final items = controller.items;
          final isLoading = controller.isLoading && items.isEmpty;
          final grid = controller.viewMode == CatalogViewMode.grid;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: kToolbarHeight + 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: loc.translate('catalog_search_hint'),
                            ),
                            onSubmitted: (value) => controller.updateQuery(value.toLowerCase()),
                            onChanged: _onSearchChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: controller.toggleViewMode,
                          icon: Icon(grid ? Icons.view_list_rounded : Icons.grid_view_rounded),
                          tooltip: grid ? loc.translate('view_list') : loc.translate('view_grid'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: types
                          .map(
                            (entry) => ChoiceChip(
                              label: Text(entry.$2),
                              selected: controller.typeFilter == entry.$1,
                              onSelected: (_) => controller.updateType(entry.$1),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: priorities
                          .map(
                            (entry) => FilterChip(
                              label: Text(entry.$2),
                              selected: controller.priorityFilter == entry.$1,
                              onSelected: (_) => controller.updatePriority(entry.$1),
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
                child: isLoading
                    ? const SkeletonContainer(height: 240)
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: grid
                            ? _CatalogGrid(items: items, controller: controller)
                            : Column(
                                children: items
                                    .map(
                                      (item) => _CatalogCard(item: item, controller: controller),
                                    )
                                    .toList(),
                              ),
                      ),
              ),
              if (controller.hasMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: controller.isLoadingMore
                      ? const Center(child: CircularProgressIndicator())
                      : TextButton(
                          onPressed: controller.loadMore,
                          child: Text(loc.translate('load_more')),
                        ),
                ),
              if (controller.compareCount > 0)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: FilledButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.compare),
                    child: Text(
                      loc.translate('compare_selected_full', params: {'count': controller.compareCount.toString()}),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CatalogGrid extends StatelessWidget {
  const _CatalogGrid({required this.items, required this.controller});

  final List<CatalogItem> items;
  final CatalogController controller;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) => _CatalogCard(item: items[index], controller: controller),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({required this.item, required this.controller});

  final CatalogItem item;
  final CatalogController controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final selected = controller.isCompared(item);
    return GestureDetector(
      onLongPress: () => controller.toggleCompare(item),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary.withOpacity(0.6) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(loc.translate('type_${item.type.toLowerCase()}')),
                const Spacer(),
                AiInfoButton(key: ValueKey(item.id)),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(item.summary, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: item.tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      ))
                  .toList(),
            ),
            const Spacer(),
            Text('${item.estimatedHours.toStringAsFixed(1)}h'),
          ],
        ),
      ),
    );
  }
}
