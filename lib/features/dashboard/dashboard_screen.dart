import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/stats_card.dart';
import '../../shared/skeletons/skeleton_widgets.dart';
import '../../core/models/mock_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _refresh(BuildContext context) async {
    final scope = WorkspaceScope.of(context);
    await Future.wait([
      scope.projects.refresh(),
      scope.tasks.refresh(),
      scope.catalog.refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final scope = WorkspaceScope.of(context);
    final loc = AppLocalizations.of(context);
    final firstName = scope.app.displayName.split(' ').first;

    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: AnimatedBuilder(
        animation: Listenable.merge([scope.projects, scope.tasks, scope.catalog]),
        builder: (context, _) {
          final projects = scope.projects;
          final tasks = scope.tasks;
          final isLoading = (projects.isLoading && projects.projects.isEmpty) ||
              (tasks.isLoading && tasks.tasks.isEmpty);

          final totalTasks = tasks.totalTasks;
          final todayTasks = scope.repository.tasksForDate(DateTime.now());
          final highPriority = projects.projects.where((project) => project.priority.toLowerCase() == 'high').length;
          final focusHours = todayTasks.fold<double>(0, (sum, task) => sum + task.hours);
          final timeline = List<Task>.from(tasks.tasks)
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: kToolbarHeight + 16),
              AppHeader(
                title: loc.translate('dashboard'),
                subtitle: loc.translate('good_morning', params: {'name': firstName}),
                onSearch: () => Navigator.pushNamed(context, AppRoutes.search),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  firstChild: const _DashboardSkeleton(),
                  secondChild: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: StatsCard(
                              label: loc.translate('tasks_total'),
                              value: totalTasks.toString().padLeft(2, '0'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatsCard(
                              label: loc.translate('dashboard_high_priority'),
                              value: highPriority.toString().padLeft(2, '0'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: StatsCard(
                              label: loc.translate('dashboard_today_tasks'),
                              value: todayTasks.length.toString().padLeft(2, '0'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatsCard(
                              label: loc.translate('dashboard_focus_hours'),
                              value: '${focusHours.toStringAsFixed(1)}h',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _PaymentSummaryCard(),
                      const SizedBox(height: 24),
                      _MonthlyTimeline(
                        title: loc.translate('monthly_tasks'),
                        tasks: timeline.take(5).toList(),
                      ),
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=900&q=80',
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SkeletonContainer(height: 160),
        SizedBox(height: 16),
        SkeletonContainer(height: 160),
        SizedBox(height: 16),
        SkeletonContainer(height: 200),
      ],
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final bars = [72, 54, 88, 63];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.translate('payment_summary'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: List.generate(bars.length, (index) {
                    final height = bars[index].toDouble();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: 8 + height,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.35 + index * 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Legend(color: const Color(0xFFF7FF5A), label: loc.translate('payment_invoices')),
                  _Legend(color: const Color(0xFFD9E272), label: loc.translate('payment_subscriptions')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _MonthlyTimeline extends StatelessWidget {
  const _MonthlyTimeline({required this.tasks, required this.title});

  final List<Task> tasks;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Column(
          children: tasks
              .map(
                (task) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(task.title)),
                      Text('${task.hours.toStringAsFixed(1)}h'),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
