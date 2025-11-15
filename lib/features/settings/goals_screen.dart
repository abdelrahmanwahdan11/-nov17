import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../shared/controllers/goals_controller.dart';
import '../../shared/controllers/workspace_scope.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = WorkspaceScope.of(context);
    final goals = scope.goals;
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('workspace_goals'))),
      body: RefreshIndicator(
        onRefresh: goals.refresh,
        child: AnimatedBuilder(
          animation: goals,
          builder: (context, _) {
            final focusHours = goals.focusThisWeek.inHours;
            final focusMinutes = goals.focusThisWeek.inMinutes.remainder(60);
            final focusValue = focusMinutes == 0
                ? loc.translate('workspace_goals_focus_value_hours', params: {'hours': focusHours.toString()})
                : loc.translate(
                    'workspace_goals_focus_value',
                    params: {
                      'hours': focusHours.toString(),
                      'minutes': focusMinutes.toString().padLeft(2, '0'),
                    },
                  );
            final taskValue = loc.translate(
              'workspace_goals_value_of_goal',
              params: {
                'value': goals.completedTasks.toString(),
                'goal': goals.monthlyTaskGoal.toString(),
              },
            );
            final revenueValue = loc.translate(
              'workspace_goals_currency_value',
              params: {
                'value': _formatThousands(goals.revenueThisMonth.round()),
                'goal': _formatThousands(goals.monthlyRevenueGoal.round()),
              },
            );
            final taskCaption = loc.translate(
              'workspace_goals_progress_caption',
              params: {'percent': goals.taskProgressPercent.toStringAsFixed(0)},
            );
            final revenueCaption = loc.translate(
              'workspace_goals_progress_caption',
              params: {'percent': goals.revenueProgressPercent.toStringAsFixed(0)},
            );
            final focusCaption = loc.translate(
              'workspace_goals_progress_caption',
              params: {'percent': goals.focusProgressPercent.toStringAsFixed(0)},
            );
            final taskTarget = loc.translate(
              'workspace_goals_target_tasks',
              params: {'count': goals.monthlyTaskGoal.toString()},
            );
            final revenueTarget = loc.translate(
              'workspace_goals_target_revenue',
              params: {'amount': _formatThousands(goals.monthlyRevenueGoal.round())},
            );
            final focusTarget = loc.translate(
              'workspace_goals_target_focus',
              params: {'hours': goals.weeklyFocusGoal.inHours.toString()},
            );
            final tasksRemainingCount = (goals.monthlyTaskGoal - goals.completedTasks).clamp(0, goals.monthlyTaskGoal);
            final revenueRemaining = (goals.monthlyRevenueGoal - goals.revenueThisMonth).clamp(0, goals.monthlyRevenueGoal);
            final focusDifference = goals.weeklyFocusGoal - goals.focusThisWeek;
            final focusRemaining = focusDifference.isNegative ? Duration.zero : focusDifference;
            final focusRemainingHours = focusRemaining.inHours;
            final focusRemainingMinutes = focusRemaining.inMinutes.remainder(60);
            final focusRemainingLabel = focusRemaining.inMinutes == 0
                ? loc.translate('workspace_goals_goal_met')
                : loc.translate(
                    'workspace_goals_focus_gap',
                    params: {
                      'hours': focusRemainingHours.toString(),
                      'minutes': focusRemainingMinutes.toString().padLeft(2, '0'),
                    },
                  );
            final tasksRemainingLabel = tasksRemainingCount == 0
                ? loc.translate('workspace_goals_goal_met')
                : loc.translate(
                    'workspace_goals_tasks_gap',
                    params: {'count': tasksRemainingCount.toString()},
                  );
            final revenueRemainingLabel = revenueRemaining <= 0
                ? loc.translate('workspace_goals_goal_met')
                : loc.translate(
                    'workspace_goals_revenue_gap',
                    params: {'amount': _formatThousands(revenueRemaining.round())},
                  );

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  loc.translate('workspace_goals_subtitle'),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                _GoalDetailCard(
                  title: loc.translate('workspace_goals_tasks_title'),
                  value: taskValue,
                  caption: taskCaption,
                  target: taskTarget,
                  remaining: tasksRemainingLabel,
                  progress: goals.taskProgress,
                  loading: goals.isLoading,
                ),
                const SizedBox(height: 16),
                _GoalDetailCard(
                  title: loc.translate('workspace_goals_revenue_title'),
                  value: revenueValue,
                  caption: revenueCaption,
                  target: revenueTarget,
                  remaining: revenueRemainingLabel,
                  progress: goals.revenueProgress,
                  loading: goals.isLoading,
                ),
                const SizedBox(height: 16),
                _GoalDetailCard(
                  title: loc.translate('workspace_goals_focus_title'),
                  value: focusValue,
                  caption: focusCaption,
                  target: focusTarget,
                  remaining: focusRemainingLabel,
                  progress: goals.focusProgress,
                  loading: goals.isLoading,
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => _openEditor(context, goals, loc),
                  icon: const Icon(IconlyBold.setting),
                  label: Text(loc.translate('workspace_goals_edit')),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, GoalsController goals, AppLocalizations loc) async {
    final rootContext = context;
    final mediaQuery = MediaQuery.of(context);
    var taskGoal = goals.monthlyTaskGoal.clamp(20, 200);
    var revenueGoal = goals.monthlyRevenueGoal.clamp(5000, 150000).toDouble();
    var focusGoal = goals.weeklyFocusGoal.inHours.clamp(5, 60).toDouble();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: mediaQuery.viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('workspace_goals_edit_title'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(loc.translate('workspace_goals_edit_description')),
                  const SizedBox(height: 24),
                  Text(loc.translate('workspace_goals_tasks_label')),
                  Slider(
                    value: taskGoal.toDouble(),
                    min: 20,
                    max: 200,
                    divisions: 180,
                    label: taskGoal.toString(),
                    onChanged: (value) => setState(() => taskGoal = value.round()),
                  ),
                  Text(
                    loc.translate('workspace_goals_target_tasks', params: {'count': taskGoal.toString()}),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(loc.translate('workspace_goals_revenue_label')),
                  Slider(
                    value: revenueGoal,
                    min: 5000,
                    max: 150000,
                    divisions: 145,
                    label: '\$${_formatThousands(revenueGoal.round())}',
                    onChanged: (value) => setState(() => revenueGoal = value),
                  ),
                  Text(
                    loc.translate(
                      'workspace_goals_target_revenue',
                      params: {'amount': _formatThousands(revenueGoal.round())},
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(loc.translate('workspace_goals_focus_label')),
                  Slider(
                    value: focusGoal,
                    min: 5,
                    max: 60,
                    divisions: 55,
                    label: '${focusGoal.round()}h',
                    onChanged: (value) => setState(() => focusGoal = value),
                  ),
                  Text(
                    loc.translate('workspace_goals_target_focus', params: {'hours': focusGoal.round().toString()}),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(loc.translate('workspace_goals_cancel')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            await goals.updateGoals(
                              taskGoal: taskGoal,
                              revenueGoal: revenueGoal,
                              focusGoal: Duration(hours: focusGoal.round()),
                            );
                            if (context.mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                          child: Text(loc.translate('workspace_goals_save')),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (saved == true && rootContext.mounted) {
      ScaffoldMessenger.of(rootContext).showSnackBar(
        SnackBar(content: Text(loc.translate('workspace_goals_saved'))),
      );
    }
  }

  String _formatThousands(num value) {
    final digits = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final index = digits.length - i;
      buffer.write(digits[i]);
      if (index > 1 && index % 3 == 1 && i != digits.length - 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}

class _GoalDetailCard extends StatelessWidget {
  const _GoalDetailCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.target,
    required this.remaining,
    required this.progress,
    required this.loading,
  });

  final String title;
  final String value;
  final String caption;
  final String target;
  final String remaining;
  final double progress;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(caption, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(target, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(remaining, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: loading ? null : progress.clamp(0, 1),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
