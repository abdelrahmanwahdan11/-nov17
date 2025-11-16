import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/mock_data.dart';
import '../../shared/controllers/library_controller.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/skeletons/skeleton_widgets.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  LibraryController? _controller;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  LibraryController get controller => _controller ??= WorkspaceScope.of(context).library;

  @override
  void didChangeDependencies() {
    final scope = WorkspaceScope.of(context);
    if (_controller != scope.library) {
      _controller = scope.library;
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
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final materialLoc = MaterialLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('library_title'))),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final items = controller.items;
            final isLoading = controller.isLoading;
            final types = controller.types;

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text(loc.translate('library_subtitle'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: loc.translate('library_search_hint'),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: types
                      .map(
                        (type) => ChoiceChip(
                          label: Text(type == 'All' ? loc.translate('filter_all') : type),
                          selected: controller.type == type,
                          onSelected: (_) => controller.updateType(type),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: isLoading && items.isEmpty
                      ? const _LibrarySkeleton()
                      : Column(
                          children: [
                            ...items.map(
                              (item) => _LibraryCard(
                                item: item,
                                materialLoc: materialLoc,
                                onShare: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(loc.translate('library_link_copied'))),
                                  );
                                },
                              ),
                            ),
                            if (controller.hasMore)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: controller.isLoadingMore
                                    ? const CircularProgressIndicator()
                                    : OutlinedButton(
                                        onPressed: controller.loadMore,
                                        child: Text(loc.translate('load_more')),
                                      ),
                              ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({required this.item, required this.materialLoc, required this.onShare});

  final LibraryItem item;
  final MaterialLocalizations materialLoc;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(IconlyBold.paper),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(item.title, style: Theme.of(context).textTheme.titleLarge)),
                IconButton(onPressed: onShare, icon: const Icon(Icons.share_outlined)),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.summary, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Chip(label: Text(item.type)),
                Chip(label: Text(item.author)),
                Chip(label: Text(materialLoc.formatFullDate(item.updatedAt))),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.link, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _LibrarySkeleton extends StatelessWidget {
  const _LibrarySkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: const SkeletonContainer(height: 160, borderRadius: 28),
        ),
      ),
    );
  }
}
