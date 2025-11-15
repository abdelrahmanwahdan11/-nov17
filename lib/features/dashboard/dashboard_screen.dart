import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/stats_card.dart';
import '../../shared/skeletons/skeleton_widgets.dart';
import '../../core/models/mock_data.dart';
import '../../shared/controllers/insights_controller.dart';

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
                      const _FocusSummaryCard(),
                      const SizedBox(height: 24),
                      const _WorkspaceHealthCard(),
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
    final finance = WorkspaceScope.of(context).finance;
    return AnimatedBuilder(
      animation: finance,
      builder: (context, _) {
        final monthly = finance.monthlySnapshots.isEmpty
            ? <FinanceSnapshot>[]
            : finance.monthlySnapshots.reversed.take(4).toList().reversed.toList();
        final isLoading = finance.isLoading && monthly.isEmpty;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final maxRevenue = monthly.fold<double>(0, (value, item) => value > item.revenue ? value : item.revenue);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.translate('payment_summary'), style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              if (isLoading)
                const SkeletonContainer(height: 120)
              else if (monthly.isEmpty)
                Text(loc.translate('finance_invoices_empty'), style: theme.textTheme.bodySmall)
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: monthly.map((snapshot) {
                          final heightFactor = maxRevenue == 0 ? 0 : snapshot.revenue / maxRevenue;
                          final expensesFactor = maxRevenue == 0 ? 0 : snapshot.expenses / maxRevenue;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 400),
                                        height: 40 + 80 * heightFactor,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(18),
                                          color: colorScheme.primary.withOpacity(0.4),
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 400),
                                        height: 40 + 80 * expensesFactor,
                                        margin: const EdgeInsets.only(bottom: 6),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(18),
                                          color: const Color(0xFFF7FF5A).withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(snapshot.label, style: theme.textTheme.bodySmall),
                                  Text('\$${snapshot.revenue.toStringAsFixed(0)}', style: theme.textTheme.labelSmall),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Legend(color: colorScheme.primary, label: loc.translate('finance_bar_revenue')),
                        _Legend(color: const Color(0xFFF7FF5A), label: loc.translate('finance_bar_expenses')),
                        const SizedBox(height: 12),
                        Text(
                          loc.translate('finance_dashboard_outstanding',
                              params: {'amount': finance.totalOutstanding.toStringAsFixed(0)}),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FocusSummaryCard extends StatelessWidget {
  const _FocusSummaryCard();

  @override
  Widget build(BuildContext context) {
    final scope = WorkspaceScope.of(context);
    final app = scope.app;
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final materialLoc = MaterialLocalizations.of(context);

    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        final weekly = app.weeklyTrackedDuration;
        final total = app.totalTrackedDuration;
        final topTask = app.topTrackedTaskTitle;
        final last = app.lastTrackedSession;

        final weeklyLabel = _formatDuration(weekly);
        final totalLabel = _formatDuration(total);
        final topTaskLabel = topTask == null
            ? loc.translate('dashboard_focus_top_task_empty')
            : loc.translate('dashboard_focus_top_task', params: {'task': topTask});
        final lastLabel = last == null
            ? loc.translate('dashboard_focus_last_empty')
            : loc.translate(
                'dashboard_focus_last',
                params: {
                  'duration': _formatDuration(last.duration),
                  'time': '${materialLoc.formatShortDate(last.timestamp)} · '
                      '${materialLoc.formatTimeOfDay(TimeOfDay.fromDateTime(last.timestamp))}',
                },
              );

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.translate('dashboard_focus_title'), style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _FocusMetric(
                      label: loc.translate('dashboard_focus_week_label'),
                      value: weeklyLabel,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _FocusMetric(
                      label: loc.translate('dashboard_focus_total_label'),
                      value: totalLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(topTaskLabel, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(lastLabel, style: theme.textTheme.bodySmall),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds == 0) {
      return '0m';
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0 && minutes == 0) {
      return '${duration.inSeconds}s';
    }
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${minutes}m';
  }
}

class _FocusMetric extends StatelessWidget {
  const _FocusMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _WorkspaceHealthCard extends StatelessWidget {
  const _WorkspaceHealthCard();

  @override
  Widget build(BuildContext context) {
    final scope = WorkspaceScope.of(context);
    final insights = scope.insights;
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: insights,
      builder: (context, _) {
        final completionPercent = (insights.completionRate * 100).clamp(0, 100);
        final focusHours = insights.focusHoursThisWeek;
        final netIncome = insights.netIncome;
        final outstanding = insights.outstandingTotal;
        final deadlines = insights.deadlines.take(3).toList();
        final weekly = insights.weeklyCompletion;
        final priorityMix = insights.priorityMix;
        final focusBreakdown = insights.focusBreakdown;
        final totalPriorities = priorityMix.fold<int>(0, (sum, slice) => sum + slice.count);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(loc.translate('dashboard_insights_card_title'), style: theme.textTheme.titleLarge),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.insights),
                    child: Text(loc.translate('insights_open_button')),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _InsightMetric(
                      label: loc.translate('insights_completion_rate'),
                      value: '${completionPercent.toStringAsFixed(0)}%',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _InsightMetric(
                      label: loc.translate('insights_focus_hours'),
                      value: '${focusHours.toStringAsFixed(1)}h',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _InsightMetric(
                      label: loc.translate('insights_net_income'),
                      value: _formatNumber(netIncome),
                      caption: loc.translate('insights_outstanding_label', params: {'value': _formatNumber(outstanding)}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(loc.translate('insights_deadline_section'), style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              if (deadlines.isEmpty)
                Text(loc.translate('insights_deadline_none'), style: theme.textTheme.bodySmall)
              else
                Column(
                  children: deadlines
                      .map((deadline) => _InsightDeadlineTile(deadline: deadline))
                      .toList(),
                ),
              const SizedBox(height: 20),
              Text(loc.translate('insights_weekly_completion'), style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              _WeeklyCompletionChart(points: weekly),
              const SizedBox(height: 20),
              Text(loc.translate('insights_priority_mix'), style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              if (priorityMix.isEmpty)
                Text(loc.translate('insights_priority_empty'), style: theme.textTheme.bodySmall)
              else
                Column(
                  children: priorityMix
                      .map(
                        (slice) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: _PriorityBar(slice: slice, total: totalPriorities),
                        ),
                      )
                      .toList(),
                ),
              if (focusBreakdown.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(loc.translate('insights_focus_breakdown'), style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: focusBreakdown
                      .map(
                        (slice) {
                          final label = slice.label == 'Unassigned'
                              ? loc.translate('insights_focus_unassigned')
                              : slice.label;
                          return Chip(
                            label: Text('$label · ${_formatFocus(loc, slice)}'),
                          );
                        },
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatNumber(double value) {
    final absValue = value.abs();
    if (absValue >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (absValue >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  String _formatFocus(AppLocalizations loc, InsightFocusSlice slice) {
    if (slice.minutes >= 60) {
      return loc.translate('insights_focus_hours_short', params: {'hours': slice.hours.toStringAsFixed(1)});
    }
    return loc.translate('insights_focus_minutes_short', params: {'minutes': slice.minutes.toString()});
  }
}

class _InsightMetric extends StatelessWidget {
  const _InsightMetric({required this.label, required this.value, this.caption});

  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (caption != null) ...[
            const SizedBox(height: 6),
            Text(caption!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _InsightDeadlineTile extends StatelessWidget {
  const _InsightDeadlineTile({required this.deadline});

  final InsightDeadline deadline;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final materialLoc = MaterialLocalizations.of(context);
    final typeLabel = deadline.type == InsightDeadlineType.project
        ? loc.translate('insights_deadline_project')
        : loc.translate('insights_deadline_task');
    final dueLabel = _formatDueLabel(loc, deadline.dueDate);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(
            deadline.type == InsightDeadlineType.project ? Icons.work_outline : Icons.check_circle_outline,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deadline.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('$typeLabel · $dueLabel', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(materialLoc.formatShortDate(deadline.dueDate), style: theme.textTheme.labelSmall),
              const SizedBox(height: 6),
              Chip(label: Text(deadline.priority)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDueLabel(AppLocalizations loc, DateTime due) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(due.year, due.month, due.day);
    final diff = dueDay.difference(today).inDays;
    if (diff <= 0) {
      return loc.translate('insights_deadline_due_today');
    }
    if (diff == 1) {
      return loc.translate('insights_deadline_due_tomorrow');
    }
    return loc.translate('insights_deadline_due_in', params: {'days': diff.toString()});
  }
}

class _WeeklyCompletionChart extends StatelessWidget {
  const _WeeklyCompletionChart({required this.points});

  final List<InsightCompletionPoint> points;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (points.isEmpty || points.every((point) => point.total == 0)) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(loc.translate('insights_weekly_empty'), style: Theme.of(context).textTheme.bodySmall),
      );
    }
    final theme = Theme.of(context);
    final materialLoc = MaterialLocalizations.of(context);
    final maxTotal = points.fold<int>(0, (value, element) => element.total > value ? element.total : value);
    final baseHeight = 120.0;
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((point) {
          final totalHeight = maxTotal == 0 ? 0 : (point.total / maxTotal) * baseHeight;
          final completedHeight = maxTotal == 0 ? 0 : (point.completed / maxTotal) * baseHeight;
          final label = materialLoc.narrowWeekdays[(point.date.weekday - 1) % 7];
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: totalHeight,
                          width: 18,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: completedHeight,
                          width: 18,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(label, style: theme.textTheme.labelSmall),
                const SizedBox(height: 4),
                Text('${point.completed}/${point.total}', style: theme.textTheme.bodySmall),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PriorityBar extends StatelessWidget {
  const _PriorityBar({required this.slice, required this.total});

  final InsightPrioritySlice slice;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = total == 0 ? 0 : slice.count / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(slice.priority, style: theme.textTheme.bodyMedium)),
            Text(slice.count.toString(), style: theme.textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
            color: theme.colorScheme.primary,
          ),
        ),
      ],
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
