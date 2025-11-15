import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/ai_info_button.dart';
import '../../shared/skeletons/skeleton_widgets.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _filter = 'All';
  bool _loading = false;
  final Set<Project> _compare = {};

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All'
        ? projectsMock
        : projectsMock.where((project) => project.priority == _filter).toList();
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: kToolbarHeight + 16),
          const AppHeader(title: 'Projects', subtitle: 'Your running initiatives'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 12,
              children: ['All', 'High', 'Medium', 'Low']
                  .map(
                    (value) => ChoiceChip(
                      label: Text(value),
                      selected: _filter == value,
                      onSelected: (_) => setState(() => _filter = value),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _loading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: const _ProjectsSkeleton(),
            secondChild: Column(
              children: filtered
                  .map(
                    (project) => GestureDetector(
                      onLongPress: () {
                        setState(() {
                          if (_compare.contains(project)) {
                            _compare.remove(project);
                          } else {
                            _compare.add(project);
                          }
                        });
                      },
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.projectDetails, arguments: project);
                      },
                      child: AnimatedScale(
                        scale: _compare.contains(project) ? 0.98 : 1,
                        duration: const Duration(milliseconds: 150),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Text(project.priority),
                                        ),
                                        const SizedBox(width: 12),
                                        Text('#${project.index}', style: Theme.of(context).textTheme.titleMedium),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(project.title, style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 12),
                                    LinearProgressIndicator(value: project.progress),
                                  ],
                                ),
                              ),
                              AiInfoButton(key: ValueKey(project.title)),
                            ],
                          ),
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
                child: Text('Compare (${_compare.length})'),
              ),
            ),
        ],
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
