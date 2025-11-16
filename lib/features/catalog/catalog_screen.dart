import 'dart:async';
import 'dart:math' as math;

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
      onTap: () => _showDetails(context),
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

  void _showDetails(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondary) {
        return _CatalogItemOverlay(item: item, controller: controller);
      },
      transitionBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _CatalogItemOverlay extends StatefulWidget {
  const _CatalogItemOverlay({required this.item, required this.controller});

  final CatalogItem item;
  final CatalogController controller;

  @override
  State<_CatalogItemOverlay> createState() => _CatalogItemOverlayState();
}

class _CatalogItemOverlayState extends State<_CatalogItemOverlay> {
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * 0.6;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: media.size.height * 0.85,
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(36),
              ),
              child: AnimatedBuilder(
                animation: widget.controller,
                builder: (context, _) {
                  final compared = widget.controller.isCompared(widget.item);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Chip(
                            label: Text(loc.translate('type_${widget.item.type.toLowerCase()}')),
                          ),
                          const Spacer(),
                          AiInfoButton(key: ValueKey(widget.item.id)),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: maxHeight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: _FlipCard(
                            showBack: _showBack,
                            front: _CatalogOverlayFront(
                              item: widget.item,
                              compared: compared,
                              onToggleCompare: () => _toggleCompare(context, compared),
                              onOpenCompare: () => _openCompare(context),
                            ),
                            back: _CatalogOverlayBack(item: widget.item),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _showBack = !_showBack),
                          icon: Icon(_showBack ? Icons.undo : Icons.auto_awesome),
                          label: Text(
                            loc.translate(
                              _showBack ? 'catalog_flip_button_back' : 'catalog_flip_button_front',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.translate('catalog_flip_hint'),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleCompare(BuildContext context, bool compared) {
    widget.controller.toggleCompare(widget.item);
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc.translate(
            compared ? 'catalog_compare_snackbar_removed' : 'catalog_compare_snackbar_added',
          ),
        ),
      ),
    );
  }

  void _openCompare(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushNamed(AppRoutes.compare);
  }
}

class _CatalogOverlayFront extends StatelessWidget {
  const _CatalogOverlayFront({
    required this.item,
    required this.compared,
    required this.onToggleCompare,
    required this.onOpenCompare,
  });

  final CatalogItem item;
  final bool compared;
  final VoidCallback onToggleCompare;
  final VoidCallback onOpenCompare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final priorityLabel = loc.translate('priority_${item.priority.toLowerCase()}');
    final typeLabel = loc.translate('type_${item.type.toLowerCase()}');
    final estimateLabel = loc.translate('catalog_estimated_hours', params: {'hours': item.estimatedHours.toStringAsFixed(1)});

    return Container(
      color: theme.colorScheme.surface,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  _catalogImageForItem(item),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(item.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(item.summary, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                Chip(label: Text(priorityLabel)),
                Chip(label: Text(typeLabel)),
                Chip(label: Text(estimateLabel)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.tags
                  .map(
                    (tag) => Chip(
                      label: Text('#$tag'),
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onToggleCompare,
              icon: Icon(compared ? Icons.check_circle : Icons.add_circle_outline),
              label: Text(
                loc.translate(compared ? 'catalog_remove_from_compare' : 'catalog_add_to_compare'),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onOpenCompare,
              icon: const Icon(Icons.table_rows_rounded),
              label: Text(loc.translate('catalog_open_compare')),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogOverlayBack extends StatelessWidget {
  const _CatalogOverlayBack({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final priority = loc.translate('priority_${item.priority.toLowerCase()}');
    final type = loc.translate('type_${item.type.toLowerCase()}');
    final separator = loc.locale.languageCode == 'ar' ? '، ' : ', ';
    final tags = item.tags.join(separator);
    final highlights = [
      loc.translate('catalog_highlight_priority', params: {'priority': priority}),
      loc.translate('catalog_highlight_type', params: {'type': type}),
      loc.translate('catalog_highlight_hours', params: {'hours': item.estimatedHours.toStringAsFixed(1)}),
      if (tags.isNotEmpty) loc.translate('catalog_highlight_tags', params: {'tags': tags}),
    ];

    return Container(
      color: theme.colorScheme.surface,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.translate('catalog_highlights_title'), style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            ...highlights.map(
              (text) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                loc.translate('catalog_flip_hint'),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlipCard extends StatelessWidget {
  const _FlipCard({required this.showBack, required this.front, required this.back});

  final bool showBack;
  final Widget front;
  final Widget back;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: showBack ? 1 : 0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final angle = value * math.pi;
        return Stack(
          fit: StackFit.expand,
          children: [
            _FlipSide(angle: angle, visible: angle <= math.pi / 2, child: front),
            _FlipSide(angle: angle - math.pi, visible: angle > math.pi / 2, child: back),
          ],
        );
      },
    );
  }
}

class _FlipSide extends StatelessWidget {
  const _FlipSide({required this.angle, required this.visible, required this.child});

  final double angle;
  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      maintainAnimation: true,
      maintainState: true,
      child: IgnorePointer(
        ignoring: !visible,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: child,
        ),
      ),
    );
  }
}

String _catalogImageForItem(CatalogItem item) {
  final type = item.type.toLowerCase();
  if (type.contains('template')) {
    return 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=1200&q=80';
  }
  if (type.contains('document')) {
    return 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=1200&q=80';
  }
  return 'https://images.unsplash.com/photo-1503387762-592deb58ef4e?auto=format&fit=crop&w=1200&q=80';
}
