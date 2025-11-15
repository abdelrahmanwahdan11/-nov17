import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/controllers/projects_controller.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/ai_info_button.dart';
import '../../shared/skeletons/skeleton_widgets.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  ProjectsController? _controller;
  Timer? _debounce;

  ProjectsController get controller => _controller ??= WorkspaceScope.of(context).projects;

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
  void didChangeDependencies() {
    final scope = WorkspaceScope.of(context);
    if (_controller != scope.projects) {
      _controller = scope.projects;
      _searchController.text = controller.query;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
          final projects = controller.projects;
          final isLoading = controller.isLoading && projects.isEmpty;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: kToolbarHeight + 16),
              AppHeader(
                title: loc.translate('projects'),
                subtitle: loc.translate('projects_subtitle'),
                onSearch: () => Navigator.pushNamed(context, AppRoutes.search),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: loc.translate('search_projects_hint'),
                      ),
                      onSubmitted: (value) => controller.updateQuery(value.toLowerCase()),
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: priorities
                          .map(
                            (entry) => ChoiceChip(
                              label: Text(entry.$2),
                              selected: controller.priority == entry.$1,
                              onSelected: (_) => controller.updatePriority(entry.$1),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                firstChild: const _ProjectsSkeleton(),
                secondChild: Column(
                  children: [
                    ...projects.map((project) {
                      final selected = controller.isCompared(project);
                      return GestureDetector(
                        onLongPress: () => controller.toggleCompare(project),
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.projectDetails, arguments: project),
                        child: AnimatedScale(
                          scale: selected ? 0.97 : 1,
                          duration: const Duration(milliseconds: 150),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: selected
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.6)
                                    : Colors.transparent,
                                width: 2,
                              ),
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
                                      child: Text(loc.translate('priority_${project.priority.toLowerCase()}')),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('#${project.index}', style: Theme.of(context).textTheme.titleMedium),
                                    const Spacer(),
                                    AiInfoButton(key: ValueKey(project.id)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(project.title, style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(value: project.progress),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('${(project.progress * 100).round()}%'),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(project.status),
                                    const SizedBox(width: 16),
                                    Text('${project.estimatedHours.round()}h'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (controller.hasMore)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                            loc.translate('compare_selected', params: {'count': controller.compareCount.toString()}),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProjectsSkeleton extends StatelessWidget {
  const _ProjectsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => const SkeletonListItem()),
    );
  }
}
