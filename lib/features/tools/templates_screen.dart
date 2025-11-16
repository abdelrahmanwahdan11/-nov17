import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/mock_data.dart';
import '../../shared/controllers/templates_controller.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/skeletons/skeleton_widgets.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  TemplatesController? _controller;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  TemplatesController get controller => _controller ??= WorkspaceScope.of(context).templates;

  @override
  void didChangeDependencies() {
    final scope = WorkspaceScope.of(context);
    if (_controller != scope.templates) {
      _controller = scope.templates;
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

  void _showDetails(TemplateItem template) {
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
                const SizedBox(height: 16),
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('templates_title'))),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final templates = controller.templates;
            final isLoading = controller.isLoading;
            final types = controller.types;

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text(loc.translate('templates_subtitle'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: loc.translate('templates_search_hint'),
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
                  child: isLoading && templates.isEmpty
                      ? const _TemplatesSkeleton()
                      : Column(
                          children: [
                            ...templates.map(
                              (template) => _TemplateCard(
                                template: template,
                                onTap: () => _showDetails(template),
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

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template, required this.onTap});

  final TemplateItem template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Hero(
          tag: template.id,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: template.popular ? Theme.of(context).colorScheme.primary.withOpacity(0.3) : Colors.transparent, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(template.type),
                    ),
                    const SizedBox(width: 12),
                    Text(template.category, style: Theme.of(context).textTheme.titleSmall),
                    const Spacer(),
                    if (template.popular)
                      Row(
                        children: [
                          Icon(Icons.star, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(AppLocalizations.of(context).translate('templates_popular'), style: Theme.of(context).textTheme.labelMedium),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(template.title, style: Theme.of(context).textTheme.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Text(template.summary, style: Theme.of(context).textTheme.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: template.tags.map((tag) => Chip(label: Text('#$tag'))).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TemplatesSkeleton extends StatelessWidget {
  const _TemplatesSkeleton();

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
