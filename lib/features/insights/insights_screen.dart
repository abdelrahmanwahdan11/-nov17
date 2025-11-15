import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../shared/controllers/insights_controller.dart';
import '../../shared/controllers/workspace_scope.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = WorkspaceScope.of(context);
    final insights = scope.insights;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('insights_title'))),
      body: AnimatedBuilder(
        animation: insights,
        builder: (context, _) {
          final theme = Theme.of(context);
          final materialLoc = MaterialLocalizations.of(context);

          final completionPercent = (insights.completionRate * 100).clamp(0, 100);
          final focusHours = insights.focusHoursThisWeek;
          final netIncome = insights.netIncome;
          final outstanding = insights.outstandingTotal;
          final deadlines = insights.deadlines;
          final weekly = insights.weeklyCompletion;
          final priorityMix = insights.priorityMix;
          final totalPriorities = priorityMix.fold<int>(0, (sum, slice) => sum + slice.count);
          final focusBreakdown = insights.focusBreakdown;
          final sessions = insights.recentSessions;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _InsightsMetricCard(
                      label: loc.translate('insights_completion_rate'),
                      value: '${completionPercent.toStringAsFixed(0)}%',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _InsightsMetricCard(
                      label: loc.translate('insights_focus_hours'),
                      value: '${focusHours.toStringAsFixed(1)}h',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _InsightsMetricCard(
                      label: loc.translate('insights_net_income'),
                      value: _formatNumber(netIncome),
                      caption: loc.translate('insights_outstanding_label', params: {'value': _formatNumber(outstanding)}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _SectionHeader(title: loc.translate('insights_deadline_section')),
              const SizedBox(height: 12),
              if (deadlines.isEmpty)
                Text(loc.translate('insights_deadline_none'), style: theme.textTheme.bodySmall)
              else
                Column(
                  children: deadlines
                      .map((deadline) => _InsightsDeadlineTile(deadline: deadline))
                      .toList(),
                ),
              const SizedBox(height: 28),
              _SectionHeader(title: loc.translate('insights_weekly_completion')),
              const SizedBox(height: 12),
              _InsightsWeeklyChart(points: weekly),
              const SizedBox(height: 28),
              _SectionHeader(title: loc.translate('insights_priority_mix')),
              const SizedBox(height: 12),
              if (priorityMix.isEmpty)
                Text(loc.translate('insights_priority_empty'), style: theme.textTheme.bodySmall)
              else
                Column(
                  children: priorityMix
                      .map(
                        (slice) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: _PriorityProgress(slice: slice, total: totalPriorities),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 28),
              _SectionHeader(title: loc.translate('insights_focus_breakdown')),
              const SizedBox(height: 12),
              if (focusBreakdown.isEmpty)
                Text(loc.translate('insights_focus_empty'), style: theme.textTheme.bodySmall)
              else
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
              const SizedBox(height: 28),
              _SectionHeader(title: loc.translate('insights_recent_sessions')),
              const SizedBox(height: 12),
              if (sessions.isEmpty)
                Text(loc.translate('insights_sessions_empty'), style: theme.textTheme.bodySmall)
              else
                Column(
                  children: sessions
                      .map(
                        (session) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.timer, color: theme.colorScheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      session.taskTitle ?? loc.translate('insights_focus_unassigned'),
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${materialLoc.formatShortDate(session.timestamp)} · '
                                      '${materialLoc.formatTimeOfDay(TimeOfDay.fromDateTime(session.timestamp))}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(_formatDuration(session.duration), style: theme.textTheme.labelLarge),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          );
        },
      ),
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

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      return '${duration.inHours}h $minutes';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    }
    return '${duration.inSeconds}s';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _InsightsMetricCard extends StatelessWidget {
  const _InsightsMetricCard({required this.label, required this.value, this.caption});

  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          if (caption != null) ...[
            const SizedBox(height: 6),
            Text(caption!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _InsightsDeadlineTile extends StatelessWidget {
  const _InsightsDeadlineTile({required this.deadline});

  final InsightDeadline deadline;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final typeLabel = deadline.type == InsightDeadlineType.project
        ? loc.translate('insights_deadline_project')
        : loc.translate('insights_deadline_task');
    final dueLabel = _formatDueLabel(loc, deadline.dueDate);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(26),
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
          Chip(label: Text(deadline.priority)),
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

class _InsightsWeeklyChart extends StatelessWidget {
  const _InsightsWeeklyChart({required this.points});

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
    const baseHeight = 140.0;
    return SizedBox(
      height: 180,
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
                          width: 20,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: completedHeight,
                          width: 20,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(14),
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

class _PriorityProgress extends StatelessWidget {
  const _PriorityProgress({required this.slice, required this.total});

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
