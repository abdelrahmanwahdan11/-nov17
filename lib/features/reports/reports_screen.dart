import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/workspace_report.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/widgets/app_header.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Future<void> _refresh(BuildContext context) {
    final reports = WorkspaceScope.of(context).reports;
    return reports.generateReport().then((_) => null);
  }

  Future<void> _copySnapshot(
    BuildContext context,
    AppLocalizations loc,
    WorkspaceReportSnapshot snapshot,
  ) async {
    await Clipboard.setData(ClipboardData(text: snapshot.toPrettyJson()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.translate('reports_copied'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = WorkspaceScope.of(context);
    final reports = scope.reports;
    final loc = AppLocalizations.of(context);
    final materialLoc = MaterialLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: AnimatedBuilder(
        animation: reports,
        builder: (context, _) {
          final snapshot = reports.latest;
          final history = reports.history;
          final isLoading = reports.isLoading && snapshot == null;
          final generatedLabel = snapshot == null
              ? loc.translate('reports_never_generated')
              : loc.translate(
                  'reports_last_generated',
                  params: {
                    'timestamp':
                        '${materialLoc.formatFullDate(snapshot.generatedAt)} · ${materialLoc.formatTimeOfDay(TimeOfDay.fromDateTime(snapshot.generatedAt))}',
                  },
                );

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: kToolbarHeight + 16),
              AppHeader(
                title: loc.translate('reports'),
                subtitle: loc.translate('reports_subtitle'),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: isLoading
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 32),
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            )
                          : Column(
                              key: ValueKey(snapshot?.generatedAt.toIso8601String() ?? 'empty'),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.translate('reports_summary_title'),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  generatedLabel,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    FilledButton.icon(
                                      onPressed: reports.isLoading ? null : () => reports.generateReport(),
                                      icon: const Icon(Icons.auto_graph_rounded),
                                      label: Text(loc.translate('reports_generate_full')),
                                    ),
                                    const SizedBox(width: 12),
                                    if (snapshot != null)
                                      OutlinedButton.icon(
                                        onPressed: () => _copySnapshot(context, loc, snapshot),
                                        icon: const Icon(Icons.copy_rounded),
                                        label: Text(loc.translate('reports_copy')),
                                      ),
                                  ],
                                ),
                                if (snapshot != null) ...[
                                  const SizedBox(height: 24),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      _SummaryChip(
                                        label: loc.translate('reports_projects_total'),
                                        value: snapshot.totalProjects.toString(),
                                      ),
                                      _SummaryChip(
                                        label: loc.translate('reports_tasks_total'),
                                        value: snapshot.totalTasks.toString(),
                                      ),
                                      _SummaryChip(
                                        label: loc.translate('reports_clients_active'),
                                        value: snapshot.activeClients.toString(),
                                      ),
                                      _SummaryChip(
                                        label: loc.translate('reports_completion_rate'),
                                        value: '${snapshot.completionPercentage.toStringAsFixed(0)}%',
                                      ),
                                      _SummaryChip(
                                        label: loc.translate('reports_focus_hours'),
                                        value: _formatHours(snapshot.focusHoursThisWeek),
                                      ),
                                      _SummaryChip(
                                        label: loc.translate('reports_pipeline_value'),
                                        value: _formatCurrency(snapshot.pipelineValue),
                                      ),
                                      _ColorChip(
                                        label: loc.translate('reports_primary_color'),
                                        colorHex: snapshot.primaryColorHex,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  _ProgressTile(
                                    title: loc.translate('reports_focus_goal'),
                                    value: snapshot.focusHoursThisWeek,
                                    goal: snapshot.focusGoalHours,
                                    valueLabel:
                                        '${_formatHours(snapshot.focusHoursThisWeek)} / ${_formatHours(snapshot.focusGoalHours)}',
                                  ),
                                  const SizedBox(height: 12),
                                  _ProgressTile(
                                    title: loc.translate(
                                      'reports_task_goal_progress',
                                      params: {
                                        'progress': (snapshot.taskGoalProgress * 100).toStringAsFixed(0),
                                      },
                                    ),
                                    value: snapshot.monthlyTaskCompleted.toDouble(),
                                    goal: snapshot.monthlyTaskGoal.toDouble(),
                                    valueLabel: loc.translate(
                                      'reports_goal_progress',
                                      params: {
                                        'completed': snapshot.monthlyTaskCompleted.toString(),
                                        'goal': snapshot.monthlyTaskGoal.toString(),
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              if (snapshot != null) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _SectionCard(
                    title: loc.translate('reports_projects_heading'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MetricRow(
                          items: [
                            _MetricDetail(
                              label: loc.translate('reports_projects_completed'),
                              value: snapshot.completedProjects.toString(),
                            ),
                            _MetricDetail(
                              label: loc.translate('reports_projects_at_risk'),
                              value: snapshot.atRiskProjects.toString(),
                              highlight: snapshot.atRiskProjects > 0,
                            ),
                            _MetricDetail(
                              label: loc.translate('reports_projects_due_soon'),
                              value: snapshot.dueSoonProjects.toString(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Theme.of(context).dividerColor.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        Text(
                          loc.translate('reports_tasks_heading'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _MetricRow(
                          items: [
                            _MetricDetail(
                              label: loc.translate('reports_tasks_completed'),
                              value: snapshot.completedTasks.toString(),
                            ),
                            _MetricDetail(
                              label: loc.translate('reports_tasks_overdue'),
                              value: snapshot.overdueTasks.toString(),
                              highlight: snapshot.overdueTasks > 0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _ProgressTile(
                          title: loc.translate('reports_completion_rate'),
                          value: snapshot.completionRate,
                          goal: 1,
                          valueLabel: '${snapshot.completionPercentage.toStringAsFixed(0)}%',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _SectionCard(
                    title: loc.translate('reports_finance_heading'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MetricRow(
                          items: [
                            _MetricDetail(
                              label: loc.translate('reports_finance_revenue'),
                              value: _formatCurrency(snapshot.monthlyRevenue),
                            ),
                            _MetricDetail(
                              label: loc.translate('reports_finance_expenses'),
                              value: _formatCurrency(snapshot.monthlyExpenses),
                            ),
                            _MetricDetail(
                              label: loc.translate('reports_finance_net'),
                              value: _formatCurrency(snapshot.netIncome),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _MetricRow(
                          items: [
                            _MetricDetail(
                              label: loc.translate('reports_pipeline_value'),
                              value: _formatCurrency(snapshot.pipelineValue),
                            ),
                            _MetricDetail(
                              label: loc.translate('reports_outstanding'),
                              value: _formatCurrency(snapshot.outstandingInvoices),
                              highlight: snapshot.outstandingInvoices > 0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _SectionCard(
                    title: loc.translate('reports_people_heading'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.translate('reports_team_distribution'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _DistributionChips(distribution: snapshot.teamStatusDistribution),
                        const SizedBox(height: 16),
                        Text(
                          loc.translate('reports_clients_distribution'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _DistributionChips(distribution: snapshot.clientStageDistribution),
                        const SizedBox(height: 16),
                        Text(
                          loc.translate('reports_top_focus'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.topFocusLabel ?? loc.translate('reports_focus_none'),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SectionCard(
                  title: loc.translate('reports_history'),
                  child: history.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            loc.translate('reports_history_empty'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : Column(
                          children: [
                            for (var i = 0; i < history.length; i++) ...[
                              if (i > 0) const Divider(height: 24),
                              _HistoryTile(
                                index: i + 1,
                                snapshot: history[i],
                                loc: loc,
                                materialLoc: materialLoc,
                                onCopy: () => _copySnapshot(context, loc, history[i]),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant
            .withOpacity(theme.brightness == Brightness.light ? 0.6 : 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({required this.label, required this.colorHex});

  final String label;
  final String colorHex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color parsed;
    try {
      parsed = Color(int.parse(colorHex.replaceFirst('#', ''), radix: 16) + 0xFF000000);
    } catch (_) {
      parsed = theme.colorScheme.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: parsed, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              Text(colorHex, style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({
    required this.title,
    required this.value,
    required this.goal,
    required this.valueLabel,
  });

  final String title;
  final double value;
  final double goal;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal == 0 ? 0.0 : (value / goal).clamp(0, 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: progress,
            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
        const SizedBox(height: 6),
        Text(valueLabel, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricDetail {
  const _MetricDetail({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.items});

  final List<_MetricDetail> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        final defaultColor = theme.textTheme.headlineSmall?.color ?? theme.colorScheme.onSurface;
        return Wrap(
          spacing: 24,
          runSpacing: 16,
          children: items.map((item) {
            final highlightColor = item.highlight ? theme.colorScheme.error : defaultColor;
            final minWidth = isCompact ? 140.0 : (constraints.maxWidth / items.length) - 8;
            return ConstrainedBox(
              constraints: BoxConstraints(minWidth: minWidth.clamp(120.0, double.infinity)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: highlightColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: item.highlight ? highlightColor : theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _DistributionChips extends StatelessWidget {
  const _DistributionChips({required this.distribution});

  final Map<String, int> distribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (distribution.isEmpty) {
      return Text('-/-', style: theme.textTheme.bodySmall);
    }
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: distribution.entries.map((entry) {
        return Chip(
          label: Text('${entry.key} · ${entry.value}'),
          backgroundColor: theme.colorScheme.surfaceVariant
              .withOpacity(theme.brightness == Brightness.light ? 0.5 : 0.3),
        );
      }).toList(),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.index,
    required this.snapshot,
    required this.loc,
    required this.materialLoc,
    required this.onCopy,
  });

  final int index;
  final WorkspaceReportSnapshot snapshot;
  final AppLocalizations loc;
  final MaterialLocalizations materialLoc;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = materialLoc.formatFullDate(snapshot.generatedAt);
    final subtitle = loc.translate(
      'reports_history_entry',
      params: {
        'projects': snapshot.totalProjects.toString(),
        'tasks': snapshot.totalTasks.toString(),
      },
    );
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
        child: Text(index.toString(), style: theme.textTheme.labelLarge),
      ),
      title: Text(dateLabel, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle),
      trailing: IconButton(
        tooltip: loc.translate('reports_copy'),
        icon: const Icon(Icons.copy_rounded),
        onPressed: onCopy,
      ),
    );
  }
}

String _formatCurrency(double value) {
  const symbol = String.fromCharCode(36);
  final absValue = value.abs();
  if (absValue >= 1000000) {
    return symbol + (value / 1000000).toStringAsFixed(1) + 'M';
  }
  if (absValue >= 1000) {
    return symbol + (value / 1000).toStringAsFixed(1) + 'K';
  }
  return symbol + value.toStringAsFixed(0);
}

String _formatHours(double value) {
  return '${value.toStringAsFixed(value >= 10 ? 0 : 1)}h';
}
